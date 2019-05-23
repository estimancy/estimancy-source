class AddSupportContactToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :support_contact, :string
  end
end
