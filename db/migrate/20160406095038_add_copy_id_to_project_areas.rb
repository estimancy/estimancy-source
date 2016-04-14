class AddCopyIdToProjectAreas < ActiveRecord::Migration
  def change
    add_column :project_areas, :copy_id, :integer
    add_column :platform_categories, :copy_id, :integer
    add_column :project_categories, :copy_id, :integer
    add_column :acquisition_categories, :copy_id, :integer
  end
end
