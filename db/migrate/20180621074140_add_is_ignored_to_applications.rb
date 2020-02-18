class AddIsIgnoredToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :is_ignored, :boolean
  end
end
