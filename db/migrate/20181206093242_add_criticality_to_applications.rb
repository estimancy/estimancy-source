class AddCriticalityToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :criticality, :int
  end
end
