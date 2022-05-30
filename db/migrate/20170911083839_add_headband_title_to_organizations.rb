class AddHeadbandTitleToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :headband_title, :string, after: :name
  end
end
