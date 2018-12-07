class CreateDemandStatuses < ActiveRecord::Migration
  def change
    create_table :demand_statuses do |t|
      t.integer :organization_id
      t.integer :status_number
      t.string :status_alias
      t.string :name
      t.string :status_color

      t.timestamps null: false
    end
  end
end
