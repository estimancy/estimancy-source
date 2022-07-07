class AddMaxStaffingRayleighToStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :max_staffing_rayleigh, :float
  end
end
