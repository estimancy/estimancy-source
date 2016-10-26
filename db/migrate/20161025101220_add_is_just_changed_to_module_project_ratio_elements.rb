class AddIsJustChangedToModuleProjectRatioElements < ActiveRecord::Migration
  def change
    add_column :module_project_ratio_elements, :is_just_changed, :boolean
  end
end
