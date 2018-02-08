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

#ProjectSecurity belongs to User, Group and Project
class ProjectSecurity < ActiveRecord::Base
  attr_accessible :project_id, :user_id, :group_id, :project_security_level_id, :is_estimation_permission, :is_model_permission,
                  :originator_id, :event_organization_id, :transaction_id

  belongs_to :user
  belongs_to :group
  belongs_to :project, :touch => true
  belongs_to :project_security_level

  # Security Audit management
  has_paper_trail

  # Security Audit management
  before_save :update_transaction_id_for_triggers
  #has_paper_trail

  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM projects WHERE id = NEW.project_id),
          author_id = NEW.originator_id,
          item_type = 'ProjectSecurity',
          item_id = NEW.project_id,
          project_id = NEW.project_id,
          group_id = NEW.group_id,
          user_id = NEW.user_id,
          project_security_level_id = NEW.project_security_level_id,
          is_model_permission = NEW.is_model_permission,
          is_estimation_permission = NEW.is_estimation_permission,
          is_model = (SELECT is_model FROM projects WHERE id = NEW.project_id),
          object_class_name = 'Project',
          association_class_name = 'EstimationStatusGroupRole',
          event = 'create',
          object_changes = CONCAT('{ "project_id": ', NEW.project_id, ',', ' "project_security_level_id": ', NEW.project_security_level_id,
                                      ' "group_id": ', NEW.group_id,
                                      ' "user_id": ', NEW.user_id,
                                      ' "is_model_permission": ', NEW.is_model_permission,
                                      ' "is_estimation_permission": ', NEW.is_estimation_permission,
                                 '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM projects WHERE id = OLD.project_id),
        transaction_id = (SELECT transaction_id FROM projects WHERE id = OLD.project_id),
        author_id = OLD.originator_id,
        item_type = 'ProjectSecurity',
        item_id = OLD.project_id,
        project_id = OLD.project_id,
        group_id = OLD.group_id,
        user_id = OLD.user_id,
        project_security_level_id = OLD.project_security_level_id,
        is_model_permission = OLD.is_model_permission,
        is_estimation_permission = OLD.is_estimation_permission,
        is_model = (SELECT is_model FROM projects WHERE id = OLD.project_id),
        object_class_name = 'Project',
        association_class_name = 'EstimationStatusGroupRole',
        event = 'delete',
        object_changes = CONCAT('{ "project_id": ', OLD.project_id, ',', ' "project_security_level_id": ', OLD.project_security_level_id,
                                    ' "group_id": ', OLD.group_id,
                                    ' "user_id": ', OLD.user_id,
                                    ' "is_model_permission": ', OLD.is_model_permission,
                                    ' "is_estimation_permission": ', OLD.is_estimation_permission,
                          '}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end
  # END Hair-Triggers

  #Return level of security project
  def level
    self.project_security_level.nil? ? '-' : self.project_security_level.name
  end

  def to_s
    id.to_s
  end

  private
  def update_transaction_id_for_triggers
    begin
      self.transaction_id = self.project.transaction_id || self.project.transaction_id rescue nil
      self.originator_id = User.current
      self.event_organization_id = Organization.current
    rescue
    end
  end

end
