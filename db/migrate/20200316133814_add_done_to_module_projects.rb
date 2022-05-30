class AddDoneToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :done, :boolean
  end
end
