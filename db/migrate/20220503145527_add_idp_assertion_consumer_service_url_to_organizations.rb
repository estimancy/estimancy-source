class AddIdpAssertionConsumerServiceUrlToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :idp_assertion_consumer_service_url, :string, after: :idp_name
  end
end
