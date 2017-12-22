class CreateIndexOrganizationProjectsTitleUniqueness < ActiveRecord::Migration

  def up
    add_index :projects, [:organization_id, :is_model, :version_number, :title], unique: true, name: :organization_projects_title_uniqueness unless index_exists?(:projects, [:organization_id, :is_model, :version_number, :title], name: :organization_projects_title_uniqueness)
  end


  def down
    remove_index :projects, name: :organization_projects_title_uniqueness if index_exists?(:projects, [:organization_id, :is_model, :version_number, :title], name: :organization_projects_title_uniqueness)
  end
end
