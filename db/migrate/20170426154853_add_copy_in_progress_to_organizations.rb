class AddCopyInProgressToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :copy_in_progress, :boolean
  end
end
