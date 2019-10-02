class AddCoefficientToOrganizationProfiles < ActiveRecord::Migration
  def change
    add_column :organization_profiles, :coefficient, :float
  end
end
