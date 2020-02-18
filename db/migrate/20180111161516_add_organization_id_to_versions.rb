class AddOrganizationIdToVersions < ActiveRecord::Migration

  def up
    add_column :versions, :organization_id, :integer, :after => :id
    add_column :versions, :is_model, :boolean, after: :organization_id
    add_column :versions, :is_group_security, :boolean
    add_column :versions, :is_user_security, :boolean
    add_column :versions, :is_security_on_model, :boolean
    add_column :versions, :is_security_on_created_from_model, :boolean


    add_index :versions, [:organization_id], name: :organization_audit_versions unless index_exists?(:versions, [:organization_id], name: :organization_audit_versions)
  end

  def down
    remove_column :versions, :organization_id
    remove_column :versions, :is_model
    remove_column :versions, :is_group_security
    remove_column :versions, :is_user_security
    remove_column :versions, :is_security_on_model
    remove_column :versions, :is_security_on_created_from_model


    remove_index :versions, name: :organization_audit_versions if index_exists?(:versions, [:organization_id], name: :organization_audit_versions)
  end

end
