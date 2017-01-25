class RenameColumnVersionToProjects < ActiveRecord::Migration
  def change
    begin
      rename_column :projects, :version, :version_number
    rescue
    end
  end
end
