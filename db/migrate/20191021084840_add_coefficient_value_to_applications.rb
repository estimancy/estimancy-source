class AddCoefficientValueToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :criticality, :string
    add_column :applications, :coefficient_label, :string
  end
end
