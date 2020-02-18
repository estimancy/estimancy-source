class AddRayleighDurationToStaffingStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :rayleigh_duration, :float
  end
end
