class CreateOrganizationProfilesWbsActivities < ActiveRecord::Migration

  def change
    create_table :organization_profiles_wbs_activities, :id => false, :force => true do |t|
      t.integer  :organization_profile_id
      t.integer  :wbs_activity_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :organization_profiles_wbs_activities, [:organization_profile_id, :wbs_activity_id], :unique => true, :name => "wbs_activity_profiles_index"

  end
end
