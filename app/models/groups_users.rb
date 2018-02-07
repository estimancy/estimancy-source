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

class GroupsUsers < ActiveRecord::Base
  attr_accessible  :group_id, :user_id, :originator_id, :event_organization_id, :transaction_id

  belongs_to :group
  belongs_to :user

  # Security Audit management
  before_save :update_transaction_id_for_triggers

  # Hair-Triggers
  trigger.after(:insert) do
    <<-SQL

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM users WHERE id = NEW.user_id),
          author_id = NEW.originator_id,
          item_type = 'GroupUser',
          item_id = NEW.user_id,
          user_id = NEW.user_id,
          group_id = NEW.group_id,
          object_class_name = 'User',
          association_class_name = 'Group',
          event = 'create',
          object_changes = CONCAT('{ "user_id": ', NEW.user_id, ',', ' "group_id": ', NEW.group_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        transaction_id = (SELECT transaction_id FROM users WHERE id = OLD.user_id),
        author_id = OLD.originator_id,
        item_type = 'GroupUser',
        item_id = OLD.user_id,
        user_id = OLD.user_id,
        group_id = OLD.group_id,
        object_class_name = 'User',
        association_class_name = 'Group',
        event = 'delete',
        object_changes = CONCAT('{ "user_id": ', OLD.user_id, ',', ' "group_id": ', OLD.group_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL
  end

  #object_changes = CONCAT('{ "user_id": ', '["', '', '", "', NEW.user_id, '"],', ' "group_id": ', '["', '', '", "', NEW.group_id, '"]}'),
  #object_changes = CONCAT('{ "user_id": ', '["', '', '", "', OLD.user_id, '"],', ' "group_id": ', '["', '', '", "', OLD.group_id, '"]}'),
  # END Hair-Triggers

  private
  def update_transaction_id_for_triggers
    self.transaction_id = self.user.transaction_id || self.group.transaction_id rescue nil
    self.originator_id = User.current
    self.event_organization_id = Organization.current
  end


end