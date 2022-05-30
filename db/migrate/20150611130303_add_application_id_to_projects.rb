class AddApplicationIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :application_id, :integer
  end
end
