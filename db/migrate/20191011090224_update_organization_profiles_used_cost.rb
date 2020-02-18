class UpdateOrganizationProfilesUsedCost < ActiveRecord::Migration
  def change
    rename_column :organization_profiles, :used_cost, :initial_cost_per_hour

    OrganizationProfile.all.each do |profile|
      profile.initial_cost_per_hour = profile.cost_per_hour
      profile.save
    end
  end
end
