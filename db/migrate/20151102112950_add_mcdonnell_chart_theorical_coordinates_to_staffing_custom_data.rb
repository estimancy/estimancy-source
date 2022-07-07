class AddMcdonnellChartTheoricalCoordinatesToStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :mcdonnell_chart_theorical_coordinates, :text
  end
end
