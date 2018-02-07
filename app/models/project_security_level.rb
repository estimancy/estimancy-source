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

#Master Data
class ProjectSecurityLevel < ActiveRecord::Base

  attr_accessible :name, :description, :organization_id, :originator_id, :event_organization_id, :transaction_id

  has_many :project_securities, dependent: :destroy
  has_many :estimation_status_group_roles  #Estimations permissions on Group according to the estimation status

  #has_and_belongs_to_many :permissions
  has_many :permissions_project_security_levels, class_name: 'PermissionsProjectSecurityLevels'
  has_many :permissions, through: :permissions_project_security_levels

  belongs_to :organization

  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
        organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = NEW.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'create',
        object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', '"description": ', '["', '', '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:update).of(:name, :description) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL

  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end

  # END Hair-Triggers


  validates :name, :presence => true

  amoeba do
    enable
    #include_association []
    exclude_association [:project_securities]
    customize(lambda { |original_project_security_level, new_project_security_level|
      new_project_security_level.copy_id = original_project_security_level.id
    })
  end

  def to_s
    self.nil? ? '' : self.name
  end

end
