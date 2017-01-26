class AddPercentToStaffingStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :percent, :float
  end
end
