class AddApplicationNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :application_name, :string
  end
end
