class AddOldVersionNumberToStatusHistories < ActiveRecord::Migration
  def change
    add_column :status_histories, :old_version_number, :string, after: :project
    rename_column :status_histories, :version_number, :new_version_number
  end
end
