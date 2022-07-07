class AddDescriptionsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :description_2, :text
    add_column :projects, :description_3, :text
  end
end
