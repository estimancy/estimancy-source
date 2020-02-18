class AddActualsBasedOnToStaffingStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :actuals_based_on, :string
  end
end
