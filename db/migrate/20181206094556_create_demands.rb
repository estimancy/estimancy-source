class CreateDemands < ActiveRecord::Migration
  def change
    begin
      create_table :demands do |t|
        t.string :name
        t.text :description
        t.string :business_need
        t.integer :demand_type_id
        t.integer :application_id
        t.integer :demand_status_id
        t.integer :organization_id
        t.float :cost

        t.timestamps null: false
      end
    rescue

    end
  end
end
