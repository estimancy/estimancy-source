class AddCoefficientToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :coefficient, :float
  end
end
