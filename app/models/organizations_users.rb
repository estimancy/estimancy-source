# encoding: UTF-8
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

class OrganizationsUsers < ActiveRecord::Base
  attr_accessible :organization_id, :user_id, :originator_id, :event_organization_id, :transaction_id

  belongs_to :organization
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
          item_type = 'OrganizationUser',
          item_id = NEW.user_id,
          user_id = NEW.user_id,
          organization_id = NEW.organization_id,
          object_class_name = 'User',
          association_class_name = 'Organization',
          event = 'create',
          object_changes = CONCAT('{ "user_id": ', NEW.user_id, ',', ' "organization_id": ', NEW.organization_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  trigger.after(:delete) do
    <<-SQL
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.organization_id,
          transaction_id = (SELECT transaction_id FROM users WHERE id = OLD.user_id),
          author_id = OLD.originator_id,
          item_type = 'OrganizationUser',
          item_id = OLD.user_id,
          user_id = OLD.user_id,
          organization_id = OLD.organization_id,
          object_class_name = 'User',
          association_class_name = 'Organization',
          event = 'delete',
          object_changes = CONCAT('{ "user_id": ', OLD.user_id, ',', ' "organization_id": ', OLD.organization_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL
  end

  # END Hair-Triggers


  private
  def update_transaction_id_for_triggers
    begin
      self.transaction_id = self.user.transaction_id
      self.originator_id = User.current
      self.event_organization_id = Organization.current
    rescue
    end

  end


  # Triggers
  # trigger.after(:insert) do
  #   <<-SQL
  #
  #   INSERT INTO autorization_log_events
  #     SET
  #       organization_id = NEW.event_organization_id,
  #       author_id = NEW.originator_id,
  #       item_type = 'OrganizationsUsers',
  #       item_id=  NEW.id,
  #       event = 'create',
  #       object_changes = JSON_OBJECT( 'user_id', json_array("", NEW.user_id), 'organization_id', json_array("", NEW.organization_id)),
  #       created_at =  UTC_TIMESTAMP();
  #   SQL
  # end

  # trigger.after(:update).of(:user_id) do
  #   <<-SQL
  #
  #   INSERT INTO autorization_log_events
  #     SET
  #       organization_id = NEW.event_organization_id,
  #       author_id = NEW.originator_id,
  #       item_type = 'OrganizationsUsers',
  #       item_id=  OLD.id,
  #       event = 'update',
  #       object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, NEW.user_id), 'organization_id', json_array(OLD.organization_id, NEW.organization_id)),
  #       created_at =  UTC_TIMESTAMP();
  #   SQL
  # end

  # trigger.after(:delete) do
  #   <<-SQL
  #
  #   INSERT INTO autorization_log_events
  #     SET
  #       organization_id = OLD.event_organization_id,
  #       author_id = OLD.originator_id,
  #       item_type = 'OrganizationsUsers',
  #       item_id=  OLD.id,
  #       event = 'delete',
  #       object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, ""), 'organization_id', json_array(OLD.organization_id, "")),
  #       created_at =  UTC_TIMESTAMP();
  #   SQL
  # end

  #object_changes = CONCAT('{ "user_id": ', '["', '', '", "', NEW.user_id, '"],', ' "organization_id": ', '["', '', '", "', NEW.organization_id, '"]}'),
  #object_changes = CONCAT('{ "user_id": ', '["', '', '", "', OLD.user_id, '"],', ' "organization_id": ', '["', '', '", "', OLD.organization_id, '"]}'),


end
