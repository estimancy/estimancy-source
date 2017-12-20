class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers, :force => true do |t|
      t.string :name
      t.integer :organization_id

      t.timestamps
    end
  end
end
