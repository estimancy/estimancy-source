class CreateDemandTypes < ActiveRecord::Migration
  def change
    create_table :demand_types do |t|
      t.string :name
      t.text :description
      t.boolean :fixed_billing
      t.boolean :deadlined_billing

      t.timestamps null: false
    end
  end
end
