class AddDescriptionToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :description, :text
    add_column :admin_settings, :category, :string
  end
end
