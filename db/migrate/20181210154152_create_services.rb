class CreateServices < ActiveRecord::Migration
=begin
  def change
    create_table :services do |t|
      t.integer :organization_id
      t.integer :livrable_id

      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
=end
end
