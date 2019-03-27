class DropOrganizationTechnologies < ActiveRecord::Migration
  def change
    drop_table :organization_technologies
  end
end
