class AddDynamicCoefficientToOrganizationProfiles < ActiveRecord::Migration
  def change
    add_column :organization_profiles, :is_real_profile, :boolean
    add_column :organization_profiles, :use_dynamic_coefficient, :boolean
    add_column :organization_profiles, :associated_services, :string
    add_column :organization_profiles, :r_value, :float
    add_column :organization_profiles, :tm_value, :float
    add_column :organization_profiles, :formula, :string
    add_column :organization_profiles, :used_cost, :float
  end
end
