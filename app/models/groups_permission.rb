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

class GroupsPermission < ActiveRecord::Base
  attr_accessible  :group_id, :permission_id, :originator_id, :event_organization_id, :transaction_id

  belongs_to :group
  belongs_to :permission

  # Security Audit management
  before_save :update_transaction_id_for_triggers

  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM groups WHERE id = NEW.group_id),
          author_id = NEW.originator_id,
          item_type = 'GroupPermission',
          item_id = NEW.group_id,
          group_id = NEW.group_id,
          permission_id = NEW.permission_id,
          object_class_name = 'Group',
          association_class_name = 'Permission',
          event = 'create',
          object_changes = CONCAT('{ "group_id": ', NEW.group_id, ',', ' "permission_id": ', NEW.permission_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM groups WHERE id = OLD.group_id),
        transaction_id = (SELECT transaction_id FROM groups WHERE id = OLD.group_id),
        author_id = OLD.originator_id,
        item_type = 'GroupPermission',
        item_id = OLD.group_id,
        group_id = OLD.group_id,
        permission_id = OLD.permission_id,
        object_class_name = 'Group',
        association_class_name = 'Permission',
        event = 'delete',
        object_changes = CONCAT('{ "group_id": ', OLD.group_id, ',', ' "permission_id": ', OLD.permission_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end
  # END Hair-Triggers

  private
  def update_transaction_id_for_triggers
    begin
      self.transaction_id = self.group.transaction_id
      self.originator_id = User.current
      self.event_organization_id = Organization.current
    rescue
    end
  end
end