class AddEffortWeekUnitToStaffingModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :effort_week_unit, :integer
  end
end
