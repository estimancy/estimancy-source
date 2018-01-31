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
  attr_accessible :organization_id, :user_id

  belongs_to :organization
  belongs_to :user

  # Security Audit management
  has_paper_trail

  # Triggers
  trigger.after(:insert) do
    <<-SQL

    INSERT INTO autorization_log_events
      SET
        organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'OrganizationsUsers',
        item_id=  NEW.id,
        event = 'create',
        object_changes = JSON_OBJECT( 'user_id', json_array("", NEW.user_id), 'organization_id', json_array("", NEW.organization_id)),
        created_at =  CURRENT_TIMESTAMP;
    SQL
  end

  trigger.after(:update).of(:user_id) do
    <<-SQL

    INSERT INTO autorization_log_events
      SET
        organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'OrganizationsUsers',
        item_id=  OLD.id,
        event = 'update',
        object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, NEW.user_id), 'organization_id', json_array(OLD.organization_id, NEW.organization_id)),
        created_at =  CURRENT_TIMESTAMP;
    SQL
  end

  trigger.after(:delete) do
    <<-SQL

    INSERT INTO autorization_log_events
      SET
        organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'OrganizationsUsers',
        item_id=  OLD.id,
        event = 'delete',
        object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, ""), 'organization_id', json_array(OLD.organization_id, "")),
        created_at =  CURRENT_TIMESTAMP;
    SQL
  end

end
