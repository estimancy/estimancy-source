class AddHideWbsHeaderToWbsActivities < ActiveRecord::Migration
  def change
    add_column :wbs_activities, :hide_wbs_header, :boolean
  end
end
