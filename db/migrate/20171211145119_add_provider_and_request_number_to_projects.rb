class AddProviderAndRequestNumberToProjects < ActiveRecord::Migration

  def change
    # Ajout du champs forunisseur dans une estimation
    add_column :projects, :provider_id, :integer

    # Ajout du champs forunisseur dans une estimation
    add_column :projects, :request_number, :string
  end

end
