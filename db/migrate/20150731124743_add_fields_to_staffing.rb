class AddFieldsToStaffing < ActiveRecord::Migration
  def change
    remove_column :staffing_staffing_custom_data, :chart_theoretical_coordinates

    add_column :staffing_staffing_custom_data, :trapeze_chart_theoretical_coordinates, :text
    add_column :staffing_staffing_custom_data, :rayleigh_chart_theoretical_coordinates, :text
  end
end
