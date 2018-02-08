# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersMultipleTables < ActiveRecord::Migration
  def up
    create_trigger("groups_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("groups").
        after(:insert) do
      <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          author_id = NEW.originator_id,
          item_type = 'Group',
          item_id = NEW.id,
          object_class_name = 'Group',
          event = 'create',
          object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', ' "description": ', '["', '', '", "', NEW.description, '"]}'),
          created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("groups_after_update_of_name_description_row_tr", :generated => true, :compatibility => 1).
        on("groups").
        after(:update).
        of(:name, :description) do
      <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("groups_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("groups").
        after(:delete) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("project_securities_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("project_securities").
        after(:insert) do
      <<-SQL_ACTIONS

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
      SQL_ACTIONS
    end

    create_trigger("project_securities_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("project_securities").
        after(:delete) do
      <<-SQL_ACTIONS
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
      SQL_ACTIONS
    end

    create_trigger("project_security_levels_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("project_security_levels").
        after(:insert) do
      <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = NEW.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'create',
        object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', '"description": ', '["', '', '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("project_security_levels_after_update_of_name_description_row_tr", :generated => true, :compatibility => 1).
        on("project_security_levels").
        after(:update).
        of(:name, :description) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("project_security_levels_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("project_security_levels").
        after(:delete) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("estimation_status_group_roles_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("estimation_status_group_roles").
        after(:insert) do
      <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM estimation_statuses WHERE id = NEW.estimation_status_id),
          author_id = NEW.originator_id,
          item_type = 'EstimationStatusGroupRole',
          item_id = NEW.estimation_status_id,
          estimation_status_id = NEW.estimation_status_id,
          group_id = NEW.group_id,
          project_security_level_id = NEW.project_security_level_id,
          object_class_name = 'EstimationStatus',
          association_class_name = 'EstimationStatusGroupRole',
          event = 'create',
          object_changes = CONCAT('{ "estimation_status_id": ', NEW.estimation_status_id, ',',
                                      ' "project_security_level_id": ', NEW.project_security_level_id,
                                      ' "group_id": ', NEW.group_id,
                               '}'),
          created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("estimation_status_group_roles_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("estimation_status_group_roles").
        after(:delete) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM estimation_statuses WHERE id = OLD.estimation_status_id),
        transaction_id = (SELECT transaction_id FROM estimation_statuses WHERE id = OLD.estimation_status_id),
        author_id = OLD.originator_id,
        item_type = 'EstimationStatusGroupRole',
        item_id = OLD.estimation_status_id,
        group_id = OLD.group_id,
        project_security_level_id = OLD.project_security_level_id,
        object_class_name = 'EstimationStatus',
        association_class_name = 'EstimationStatusGroupRole',
        event = 'delete',
          object_changes = CONCAT('{ "estimation_status_id": ', OLD.estimation_status_id, ',',
                                      ' "project_security_level_id": ', OLD.project_security_level_id,
                                      ' "group_id": ', OLD.group_id,
                               '}'),
        created_at = UTC_TIMESTAMP();
      SQL_ACTIONS
    end

    create_trigger("groups_permissions_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("groups_permissions").
        after(:insert) do
      <<-SQL_ACTIONS

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
      SQL_ACTIONS
    end

    create_trigger("groups_permissions_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("groups_permissions").
        after(:delete) do
      <<-SQL_ACTIONS
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
      SQL_ACTIONS
    end

    create_trigger("groups_users_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("groups_users").
        after(:insert) do
      <<-SQL_ACTIONS

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
      SQL_ACTIONS
    end

    create_trigger("groups_users_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("groups_users").
        after(:delete) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM groups WHERE id = OLD.group_id),
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
      SQL_ACTIONS
    end

    create_trigger("organizations_users_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("organizations_users").
        after(:insert) do
      <<-SQL_ACTIONS

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
      SQL_ACTIONS
    end

    create_trigger("organizations_users_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("organizations_users").
        after(:delete) do
      <<-SQL_ACTIONS
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
      SQL_ACTIONS
    end

    create_trigger("permissions_project_security_levels_after_insert_row_tr", :generated => true, :compatibility => 1).
        on("permissions_project_security_levels").
        after(:insert) do
      <<-SQL_ACTIONS

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
      SQL_ACTIONS
    end

    create_trigger("permissions_project_security_levels_after_delete_row_tr", :generated => true, :compatibility => 1).
        on("permissions_project_security_levels").
        after(:delete) do
      <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM project_security_levels WHERE id = OLD.project_security_level_id),
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
      SQL_ACTIONS
    end
  end

  def down
    drop_trigger("groups_after_insert_row_tr", "groups", :generated => true)

    drop_trigger("groups_after_update_of_name_description_row_tr", "groups", :generated => true)

    drop_trigger("groups_after_delete_row_tr", "groups", :generated => true)

    drop_trigger("project_securities_after_insert_row_tr", "project_securities", :generated => true)

    drop_trigger("project_securities_after_delete_row_tr", "project_securities", :generated => true)

    drop_trigger("project_security_levels_after_insert_row_tr", "project_security_levels", :generated => true)

    drop_trigger("project_security_levels_after_update_of_name_description_row_tr", "project_security_levels", :generated => true)

    drop_trigger("project_security_levels_after_delete_row_tr", "project_security_levels", :generated => true)

    drop_trigger("estimation_status_group_roles_after_insert_row_tr", "estimation_status_group_roles", :generated => true)

    drop_trigger("estimation_status_group_roles_after_delete_row_tr", "estimation_status_group_roles", :generated => true)

    drop_trigger("groups_permissions_after_insert_row_tr", "groups_permissions", :generated => true)

    drop_trigger("groups_permissions_after_delete_row_tr", "groups_permissions", :generated => true)

    drop_trigger("groups_users_after_insert_row_tr", "groups_users", :generated => true)

    drop_trigger("groups_users_after_delete_row_tr", "groups_users", :generated => true)

    drop_trigger("organizations_users_after_insert_row_tr", "organizations_users", :generated => true)

    drop_trigger("organizations_users_after_delete_row_tr", "organizations_users", :generated => true)

    drop_trigger("permissions_project_security_levels_after_insert_row_tr", "permissions_project_security_levels", :generated => true)

    drop_trigger("permissions_project_security_levels_after_delete_row_tr", "permissions_project_security_levels", :generated => true)
  end
end
