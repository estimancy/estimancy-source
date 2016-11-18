class RenameColumnVersionToProjects < ActiveRecord::Migration
  def change
    rename_column :projects, :version, :version_number
  end
end
