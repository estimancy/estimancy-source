class AddForfaitMcoToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :forfait_mco, :float
    add_column :applications, :month_number, :integer
  end
end
