class AddIsProtectedGroupToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :is_protected_group, :boolean
  end
end
