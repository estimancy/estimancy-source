class AddNameIsModifiedToModuleProjectRatioElements < ActiveRecord::Migration
  def change
    add_column :module_project_ratio_elements, :name_is_modified, :boolean, after: :name
  end
end
