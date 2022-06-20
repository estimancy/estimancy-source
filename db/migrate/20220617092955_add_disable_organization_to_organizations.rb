class AddDisableOrganizationToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :disable_organization, :boolean, default: false
  end
end
