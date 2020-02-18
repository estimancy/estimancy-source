class AddProviderAndRequestNumberToProjects < ActiveRecord::Migration

  def change
    # Ajout du champs forunisseur dans une estimation
    add_column :projects, :provider_id, :integer unless column_exists?(:projects, :provider_id)

    # Ajout du champs forunisseur dans une estimation
    add_column :projects, :request_number, :string unless column_exists?(:projects, :request_number)
  end

end
