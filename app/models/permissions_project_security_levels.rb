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

class PermissionsProjectSecurityLevels < ActiveRecord::Base

  attr_accessible  :project_security_level_id, :permission_id, :originator_id, :event_organization_id, :transaction_id

  belongs_to :project_security_level
  belongs_to :permission

  has_many :estimation_status_group_roles

  # Security Audit management
  before_save :update_transaction_id_for_triggers
  #has_paper_trail

  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM project_security_levels WHERE id = NEW.project_security_level_id),
          author_id = NEW.originator_id,
          item_type = 'PermissionProjectSecurityLevel',
          item_id = NEW.project_security_level_id,
          project_security_level_id = NEW.project_security_level_id,
          permission_id = NEW.permission_id,
          object_class_name = 'ProjectSecurityLevel',
          association_class_name = 'Permission',
          event = 'create',
          object_changes = CONCAT('{ "permission_id": ', NEW.permission_id, ',', ' "project_security_level_id": ', NEW.project_security_level_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        transaction_id = (SELECT transaction_id FROM project_security_levels WHERE id = OLD.project_security_level_id),
        author_id = OLD.originator_id,
        item_type = 'PermissionProjectSecurityLevel',
        item_id = OLD.project_security_level_id,
        project_security_level_id = OLD.project_security_level_id,
        permission_id = OLD.permission_id,
        object_class_name = 'ProjectSecurityLevel',
        association_class_name = 'Permission',
        event = 'delete',
        object_changes = CONCAT('{ "permission_id": ', OLD.permission_id, ',', ' "project_security_level_id": ', OLD.project_security_level_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end
  # END Hair-Triggers

  private
  def update_transaction_id_for_triggers
    self.transaction_id = self.project_security_level.transaction_id rescue nil
    self.originator_id = User.current
    self.event_organization_id = Organization.current
  end

end