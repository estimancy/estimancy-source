class CreateIndicatorDashboards < ActiveRecord::Migration
  def change
    create_table :indicator_dashboards do |t|
      t.integer :organization_id
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
