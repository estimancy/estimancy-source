class AddOriginatorAndEventOrganizationToTables < ActiveRecord::Migration
  def change
    # Ajouter "originator_id" à toutes les tables qu'on surveille
    add_column :groups, :originator_id, :integer
    add_column :groups, :event_organization_id, :integer

    add_column :users, :originator_id, :integer    #Pas d'organization_id
    add_column :users, :event_organization_id, :integer    #Pas d'organization_id
    add_column :users, :organization_ids_before_last_update, :string
    add_column :users, :organization_ids_after_last_update, :string
    add_column :users, :group_ids_before_last_update, :string
    add_column :users, :group_ids_after_last_update, :string

    add_column :organizations_users, :originator_id, :integer
    add_column :organizations_users, :event_organization_id, :integer

    add_column :groups_users, :originator_id, :integer
    add_column :groups_users, :event_organization_id, :integer

    add_column :project_securities, :originator_id, :integer
    add_column :project_securities, :event_organization_id, :integer

    add_column :project_security_levels, :originator_id, :integer
    add_column :project_security_levels, :event_organization_id, :integer

    add_column :permissions_project_security_levels, :originator_id, :integer
    add_column :permissions_project_security_levels, :event_organization_id, :integer

    add_column :estimation_status_group_roles, :originator_id, :integer
    add_column :estimation_status_group_roles, :event_organization_id, :integer

    add_column :groups_permissions, :originator_id, :integer
    add_column :groups_permissions, :event_organization_id, :integer

    add_column :groups_projects, :originator_id, :integer
    add_column :groups_projects, :event_organization_id, :integer

    add_column :projects, :originator_id, :integer
    add_column :projects, :event_organization_id, :integer
  end
end
