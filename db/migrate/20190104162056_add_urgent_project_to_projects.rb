class AddUrgentProjectToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :urgent_project, :boolean
  end

  def down
    remove_column :projects, :urgent_project
  end
end
