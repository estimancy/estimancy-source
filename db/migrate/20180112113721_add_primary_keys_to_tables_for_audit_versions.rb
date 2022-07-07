class AddPrimaryKeysToTablesForAuditVersions < ActiveRecord::Migration
  def change
    add_column :groups_users, :id, :primary_key, :first => true
    add_column :permissions_project_security_levels, :id, :primary_key, :first => true
    add_column :organizations_users, :id, :primary_key, :first => true
  end
end
