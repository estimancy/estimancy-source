class RenameColumnIsLockedFromProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :is_locked, :is_historicized
  end
end
