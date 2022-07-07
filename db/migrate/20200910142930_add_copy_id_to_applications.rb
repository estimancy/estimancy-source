class AddCopyIdToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :copy_id, :integer
  end
end
