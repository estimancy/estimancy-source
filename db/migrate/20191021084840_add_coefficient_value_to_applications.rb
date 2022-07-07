class AddCoefficientValueToApplications < ActiveRecord::Migration
  def change

    if column_exists? :applications, :criticality
      remove_column :applications, :criticality
    end

    add_column :applications, :criticality, :string
    add_column :applications, :coefficient_label, :string
  end
end
