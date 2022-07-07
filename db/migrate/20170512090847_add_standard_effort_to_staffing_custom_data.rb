class AddStandardEffortToStaffingCustomData < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_custom_data, :standard_effort, :decimal, :precision => 20, :scale => 6, :after => :period_unit
  end
end
