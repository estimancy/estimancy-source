class AddUseRealProfileToWbsActivities < ActiveRecord::Migration
  def change
    add_column :wbs_activities, :use_real_profiles, :boolean
    add_column :wbs_activities, :wbs_for_config, :boolean
  end
end
