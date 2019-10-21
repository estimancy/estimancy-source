class AddCoefficientValueToApplications < ActiveRecord::Migration
  def change
    remove_column :applications, :coefficient, :float

    add_column :applications, :coefficient_name, :string
    add_column :applications, :coefficient_value, :float
  end
end
