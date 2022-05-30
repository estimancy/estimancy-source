class AddDisplayOrderToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :display_order, :integer
  end
end
