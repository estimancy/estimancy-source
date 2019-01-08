class CreateLivrables < ActiveRecord::Migration
  def change
    begin
      create_table :livrables do |t|
        t.string :name
        t.text :description
        t.string :state
        t.integer :organization_id

        t.timestamps null: false
      end
    rescue
    end
  end
end