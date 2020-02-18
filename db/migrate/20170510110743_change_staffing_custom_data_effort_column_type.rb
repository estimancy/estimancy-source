class ChangeStaffingCustomDataEffortColumnType < ActiveRecord::Migration
  def up
    change_column :staffing_staffing_custom_data, :global_effort_value, :decimal, :precision => 20, :scale => 6
  end

  def down
    change_column :staffing_staffing_custom_data, :global_effort_value, :float
  end

end
