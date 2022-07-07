class AddStartDateToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :start_date, :datetime
    add_column :applications, :end_date, :datetime
  end
end
