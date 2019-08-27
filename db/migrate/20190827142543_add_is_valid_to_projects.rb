class AddIsValidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_valid, :boolean
  end
end
