#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


#Special Data
#Group class contains some User.
class Group < ActiveRecord::Base

  attr_accessible :name, :description, :for_global_permission, :for_project_security, :organization_id,
                  :originator_id, :event_organization_id, :transaction_id, :is_protected_group

  has_and_belongs_to_many :users
  has_and_belongs_to_many :projects

  has_many :project_securities

  has_many :groups_permission, dependent: :destroy
  has_many :permissions, through: :groups_permission

  #Estimations permissions on Group according to the estimation status
  has_many :estimation_status_group_roles

  belongs_to :organization

  has_many :groups_users, class_name: 'GroupsUsers'
  has_many :users, through: :groups_users

  # Security Audit management
  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          author_id = NEW.originator_id,
          item_type = 'Group',
          item_id = NEW.id,
          object_class_name = 'Group',
          event = 'create',
          object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', ' "description": ', '["', '', '", "', NEW.description, '"]}'),
          created_at = UTC_TIMESTAMP();
      SQL
  end

  trigger.after(:update).of(:name, :description) do
    <<-SQL

      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end

  # object_changes = JSON_OBJECT( 'name', json_array('', NEW.name), 'description', json_array('', NEW.description)),
  # object_changes = JSON_OBJECT( 'name', json_array(OLD.name, NEW.name), 'description', json_array(OLD.description, NEW.description)),
  # object_changes = JSON_OBJECT('name', json_array(OLD.name, ''), 'description', json_array(OLD.description, '')),
  # END Hair-Triggers

  validates :name, :presence => true , :uniqueness => { :scope => :organization_id, :case_sensitive => false }

  default_scope {order('name ASC')}

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

  #Return group project_securities for selected project_id
  def project_securities_for_select(prj_id, is_model_permission=nil)
    if is_model_permission == true
      #self.project_securities.select { |i| i.project_id == prj_id }.first
      self.project_securities.select { |i| i.project_id == prj_id && i.is_model_permission == true}.first
    else
      self.project_securities.select { |i| i.project_id == prj_id && i.is_model_permission != true}.first
    end
  end

  amoeba do
    enable
    include_association [:permissions]
    customize(lambda { |original_group, new_group|
      new_group.copy_id = original_group.id
    })
  end

end
