class AddSamlProviderInformationsToOrganization < ActiveRecord::Migration
  def change
    # Add SMAL Identity Provider (IDP) informations
    add_column :organizations, :idp_name, :string
    add_column :organizations, :idp_login_url, :string
    add_column :organizations, :idp_logout_url, :string
    add_column :organizations, :idp_change_password_url, :string
    add_column :organizations, :idp_signing_certicate, :text
    add_column :organizations, :idp_signing_certicate_fingerprint, :text
    add_column :organizations, :idp_metadata, :text
    add_column :organizations, :idp_name_identifier_format, :string
  end
end
