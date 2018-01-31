## TEST

class CreateUserTriggersForUsers < ActiveRecord::Migration

  def up
    execute <<-SQL

      --  User Super_admin, password
       CREATE TRIGGER user_events AFTER UPDATE ON users FOR EACH ROW
        BEGIN
          DECLARE old_value varchar(255);
          DECLARE new_value varchar(255);
          SET
            old_value = OLD.id,
            new_value = NEW.id;

          -- Pour le super_admin
          IF (OLD.super_admin != NEW.super_admin) THEN
            INSERT INTO autorization_log_events SET
              organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = JSON_OBJECT( 'super_admin', json_array(OLD.super_admin, NEW.super_admin)),
              created_at = UTC_TIMESTAMP() ;
          END IF;

          -- Pour le mot de passe
          IF (OLD.encrypted_password != NEW.encrypted_password) THEN
            INSERT INTO autorization_log_events SET
              organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = JSON_OBJECT( 'password',  json_array('...', 'changement de mot de passe')),
              created_at = UTC_TIMESTAMP() ;
          END IF;

          -- Pour le mot de passe
          IF (OLD.email != NEW.email) THEN
            INSERT INTO autorization_log_events SET
              organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = JSON_OBJECT( 'Email', json_array(OLD.email, NEW.email)),
              created_at = UTC_TIMESTAMP() ;
          END IF;
        END;;
    SQL

  end


  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS user_events;
    SQL
  end

end



# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

#========================== MARCHE le 29/01=========================

# execute <<-SQL
#
#       -- User super_admin
#
#
#       --  User Super_admin, password
#        CREATE TRIGGER user_for_test AFTER UPDATE ON users FOR EACH ROW
#         BEGIN
#           DECLARE old_value varchar(255);
#           DECLARE new_value varchar(255);
#           SET
#             old_value = OLD.id,
#             new_value = NEW.id;
#
#           -- Pour le super_admin
#           IF (OLD.super_admin != NEW.super_admin) THEN
#             INSERT INTO autorization_log_events SET
#               organization_id = NEW.event_organization_id,
#               author_id = NEW.originator_id,
#               item_type = 'User',
#               item_id = OLD.id,
#               object_class_name = 'User',
#               event = 'update',
#               object_changes = JSON_OBJECT( 'super_admin',  json_array(OLD.super_admin, NEW.super_admin)),
#               created_at = UTC_TIMESTAMP() ;
#           END IF;
#
#           -- Pour les organisations de l'utilisateur
#           IF (NEW.organization_ids_before_last_update != NEW.organization_ids_after_last_update) THEN
#             INSERT INTO autorization_log_events SET
#               organization_id = NEW.event_organization_id,
#               author_id = NEW.originator_id,
#               item_type = 'UserOrganizations',
#               item_id=  OLD.id,
#               event = 'update',
#               object_changes = JSON_OBJECT( 'organization_ids',  json_array(NEW.organization_ids_before_last_update, NEW.organization_ids_after_last_update)),
#               created_at = UTC_TIMESTAMP();
#           END IF;
#
#           -- Pour les groupes de l'utilisateur
#           IF (NEW.group_ids_before_last_update != NEW.group_ids_after_last_update) THEN
#             INSERT INTO autorization_log_events SET
#               organization_id = NEW.event_organization_id,
#               author_id = NEW.originator_id,
#               item_type = 'UserGroups',
#               item_id=  OLD.id,
#               event = 'update',
#               object_changes = JSON_OBJECT( 'group_ids',  json_array(NEW.group_ids_before_last_update, NEW.group_ids_after_last_update)),
#               created_at = UTC_TIMESTAMP();
#           END IF;
#
#         END;;
# SQL



#========================== MARCHE =========================

# CREATE TRIGGER user_for_test AFTER UPDATE ON users FOR EACH ROW
# BEGIN
#   DECLARE old_value varchar(255);
#   DECLARE new_value varchar(255);
#   SET
#   old_value = OLD.id,
#       new_value = NEW.id;
#
#   SET @json = "{";
#   SET @first = true;
#
#   IF (OLD.super_admin != NEW.super_admin) THEN
#   SET @first = false;
#   SET @json = CONCAT(@json, '\"super_admin\"', ':', '\"', NEW.super_admin, '\"');
#   END IF;
#
#   SET @json = CONCAT(@json, "}");
#
#   INSERT INTO autorization_log_events SET
#   organization_id = NEW.event_organization_id,
#       author_id = NEW.originator_id,
#       item_type = 'User',
#       item_id=  OLD.id,
#       event = 'update',
#       object_changes = JSON_OBJECT( 'super_admin',  json_array(OLD.super_admin, NEW.super_admin)),
#       created_at =  CURRENT_TIMESTAMP;

#========================== MARCHE =========================

# class CreateTriggersUsersUpdateOrOrganizationsUsersInsertOrOrganizationsUsersDeleteOrOrganizationsUsersUpdate < ActiveRecord::Migration
#   def up
#     create_trigger("users_after_update_of_super_admin_row_tr", :generated => true, :compatibility => 1).
#         on("users").
#         after(:update).
#         of(:super_admin) do
#       "INSERT INTO autorization_log_events (organization_id, author_id, item_type, item_id, event, object, object_changes) VALUES (NEW.event_organization_id, NEW.originator_id, 'User', OLD.id, 'update', '', '{ super_admin: NEW.super_admin }' );"
#     end
#
#     create_trigger("organizations_users_after_insert_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:insert) do
#       "INSERT INTO authorization_event_logs (organization_id, item_type, item_id, event, object) VALUES (NEW.organization_id, 'User', NEW.organization_id, 'create', NEW.organization_id);"
#     end
#
#     create_trigger("organizations_users_after_delete_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:delete) do
#       "INSERT INTO versions (organization_id, item_type, item_id, event, object) VALUES (OLD.organization_id, 'User', OLD.id, 'delete', OLD.user_id);"
#     end
#
#     create_trigger("organizations_users_after_update_of_user_id_row_tr", :generated => true, :compatibility => 1).
#         on("organizations_users").
#         after(:update).
#         of(:user_id) do
#       "INSERT INTO versions (organization_id, item_type, item_id, event, object) VALUES (NEW.organization_id, 'User', NEW.id, 'update', NEW.user_id);"
#     end
#   end
#
#   def down
#     drop_trigger("users_after_update_of_super_admin_row_tr", "users", :generated => true)
#
#     drop_trigger("organizations_users_after_insert_row_tr", "organizations_users", :generated => true)
#
#     drop_trigger("organizations_users_after_delete_row_tr", "organizations_users", :generated => true)
#
#     drop_trigger("organizations_users_after_update_of_user_id_row_tr", "organizations_users", :generated => true)
#   end
# end
