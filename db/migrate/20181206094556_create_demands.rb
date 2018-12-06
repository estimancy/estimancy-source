class CreateDemands < ActiveRecord::Migration
  def change
    create_table :demands do |t|
      t.string :name
      t.text :description
      t.string :business_need
      t.integer :demande_type_id
      t.integer :application_id
      t.integer :demand_status_id
      t.integer :organization_id
      t.float :cost

      t.timestamps null: false
    end
  end
end
