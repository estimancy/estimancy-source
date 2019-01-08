class AddUrgentProjectToProjects < ActiveRecord::Migration
  def change
=begin
    add_column :projects, :urgent_project, :boolean
=end
  end
end
