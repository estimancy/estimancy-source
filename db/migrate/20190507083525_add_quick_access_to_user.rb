class AddQuickAccessToUser < ActiveRecord::Migration
  def change
    add_column :users, :quick_access, :bool
  end
end
