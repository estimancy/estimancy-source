class AddUrgentProjectToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :urgent_project, :boolean
  end
end
