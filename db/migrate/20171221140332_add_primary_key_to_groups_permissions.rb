class AddPrimaryKeyToGroupsPermissions < ActiveRecord::Migration
  def change
    add_column :groups_permissions, :id, :primary_key
  end
end
