class AddRecentProjectsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recent_projects, :text
  end
end
