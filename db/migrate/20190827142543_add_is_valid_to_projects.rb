class AddIsValidToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_valid, :boolean, default: true
  end
end
