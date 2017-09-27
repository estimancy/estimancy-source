class AddAverageRateColumnNameToWbsActivities < ActiveRecord::Migration
  def change
    add_column :wbs_activities, :average_rate_wording, :string
  end
end
