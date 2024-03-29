class CreateDemandTypes < ActiveRecord::Migration
  def change
    begin
      create_table :demand_types do |t|
        t.string :name
        t.text :description
        t.boolean :fixed_billing
        t.boolean :deadlined_billing

        t.integer :organization_id

        t.timestamps null: false
      end
    rescue
    end
  end
end
