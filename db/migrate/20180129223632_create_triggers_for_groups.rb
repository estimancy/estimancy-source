class CreateTriggersForGroups < ActiveRecord::Migration
#   def up
#     execute <<-SQL
#       -- ================ GROUP ==================== --
#
#       -- CREATE
#       CREATE TRIGGER group_creation AFTER INSERT ON groups FOR EACH ROW
#       INSERT INTO autorization_log_events SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'Group',
#         item_id = NEW.id,
#         object_class_name = 'Group',
#         event = 'create',
#         object_changes = JSON_OBJECT( 'name', json_array('', NEW.name), 'description', json_array('', NEW.description)),
#         created_at = CURRENT_TIMESTAMP;
#
#       --  UPDATE
#       CREATE TRIGGER group_update AFTER UPDATE ON groups FOR EACH ROW
#       INSERT INTO autorization_log_events SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'Group',
#         item_id = OLD.id,
#         object_class_name = 'Group',
#         event = 'update',
#         object_changes = JSON_OBJECT( 'name', json_array(OLD.name, NEW.name), 'description', json_array(OLD.description, NEW.description)),
#         created_at = CURRENT_TIMESTAMP;
#
#       -- DELETE
#       CREATE TRIGGER group_deletion AFTER DELETE ON groups FOR EACH ROW
#       INSERT INTO autorization_log_events SET
#         organization_id = OLD.event_organization_id,
#         author_id = OLD.originator_id,
#         item_type = 'Group',
#         item_id = OLD.id,
#         object_class_name = 'Group',
#         event = 'delete',
#         object_changes = JSON_OBJECT('name', json_array(OLD.name, ''), 'description', json_array(OLD.description, '')),
#         created_at = CURRENT_TIMESTAMP;
#     SQL
#
#   end
#
#
#   def down
#     execute <<-SQL
#       DROP TRIGGER IF EXISTS group_creation;
#       DROP TRIGGER IF EXISTS group_update;
#       DROP TRIGGER IF EXISTS group_deletion;
#     SQL
#   end
end



# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

# class CreateTriggersMultipleTables < ActiveRecord::Migration
#   def up
#     create_trigger("groups_after_insert_row_tr", :generated => true, :compatibility => 1).
#         on("groups").
#         after(:insert) do
#       <<-SQL_ACTIONS
#
#       INSERT INTO autorization_log_events SET
#           organization_id = NEW.event_organization_id,
#           author_id = NEW.originator_id,
#           item_type = 'Group',
#           item_id = NEW.id,
#           object_class_name = 'Group',
#           event = 'create',
#           object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', ' "description": ', '["', '', '", "', NEW.description, '"]}'),
#           created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("groups_after_update_row_tr", :generated => true, :compatibility => 1).
#         on("groups").
#         after(:update) do
#       <<-SQL_ACTIONS
#
#       INSERT INTO autorization_log_events SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'Group',
#         item_id = OLD.id,
#         object_class_name = 'Group',
#         event = 'update',
#         object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
#         created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("groups_after_delete_row_tr", :generated => true, :compatibility => 1).
#         on("groups").
#         after(:delete) do
#       <<-SQL_ACTIONS
#       INSERT INTO autorization_log_events SET
#         organization_id = OLD.event_organization_id,
#         author_id = OLD.originator_id,
#         item_type = 'Group',
#         item_id = OLD.id,
#         object_class_name = 'Group',
#         event = 'delete',
#         object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
#         created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("project_security_levels_after_insert_row_tr", :generated => true, :compatibility => 1).
#         on("project_security_levels").
#         after(:insert) do
#       <<-SQL_ACTIONS
#
#       INSERT INTO autorization_log_events SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'ProjectSecurityLevel',
#         item_id = NEW.id,
#         object_class_name = 'ProjectSecurityLevel',
#         event = 'create',
#         object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', '"description": ', '["', '', '", "', NEW.description, '"]}'),
#         created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("project_security_levels_after_update_row_tr", :generated => true, :compatibility => 1).
#         on("project_security_levels").
#         after(:update) do
#       <<-SQL_ACTIONS
#       INSERT INTO autorization_log_events SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'ProjectSecurityLevel',
#         item_id = OLD.id,
#         object_class_name = 'ProjectSecurityLevel',
#         event = 'update',
#         object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
#         created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("project_security_levels_after_delete_row_tr", :generated => true, :compatibility => 1).
#         on("project_security_levels").
#         after(:delete) do
#       <<-SQL_ACTIONS
#       INSERT INTO autorization_log_events SET
#         organization_id = OLD.event_organization_id,
#         author_id = OLD.originator_id,
#         item_type = 'ProjectSecurityLevel',
#         item_id = OLD.id,
#         object_class_name = 'ProjectSecurityLevel',
#         event = 'delete',
#         object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
#         created_at = CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("organizations_users_after_insert_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:insert) do
#       <<-SQL_ACTIONS
#
#     INSERT INTO autorization_log_events
#       SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'OrganizationsUsers',
#         item_id=  NEW.id,
#         event = 'create',
#         object_changes = JSON_OBJECT( 'user_id', json_array("", NEW.user_id), 'organization_id', json_array("", NEW.organization_id)),
#         created_at =  CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("organizations_users_after_update_of_user_id_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:update).
#         of(:user_id) do
#       <<-SQL_ACTIONS
#
#     INSERT INTO autorization_log_events
#       SET
#         organization_id = NEW.event_organization_id,
#         author_id = NEW.originator_id,
#         item_type = 'OrganizationsUsers',
#         item_id=  OLD.id,
#         event = 'update',
#         object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, NEW.user_id), 'organization_id', json_array(OLD.organization_id, NEW.organization_id)),
#         created_at =  CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#
#     create_trigger("organizations_users_after_delete_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:delete) do
#       <<-SQL_ACTIONS
#
#     INSERT INTO autorization_log_events
#       SET
#         organization_id = OLD.event_organization_id,
#         author_id = OLD.originator_id,
#         item_type = 'OrganizationsUsers',
#         item_id=  OLD.id,
#         event = 'delete',
#         object_changes = JSON_OBJECT( 'user_id', json_array(OLD.user_id, ""), 'organization_id', json_array(OLD.organization_id, "")),
#         created_at =  CURRENT_TIMESTAMP;
#       SQL_ACTIONS
#     end
#   end
#
#   def down
#     drop_trigger("groups_after_insert_row_tr", "groups", :generated => true)
#
#     drop_trigger("groups_after_update_row_tr", "groups", :generated => true)
#
#     drop_trigger("groups_after_delete_row_tr", "groups", :generated => true)
#
#     drop_trigger("project_security_levels_after_insert_row_tr", "project_security_levels", :generated => true)
#
#     drop_trigger("project_security_levels_after_update_row_tr", "project_security_levels", :generated => true)
#
#     drop_trigger("project_security_levels_after_delete_row_tr", "project_security_levels", :generated => true)
#
#     drop_trigger("organizations_users_after_insert_row_tr", "organizations_users", :generated => true)
#
#     drop_trigger("organizations_users_after_update_of_user_id_row_tr", "organizations_users", :generated => true)
#
#     drop_trigger("organizations_users_after_delete_row_tr", "organizations_users", :generated => true)
#   end
# end
