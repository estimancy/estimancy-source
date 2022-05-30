class CreateBudgetTypes < ActiveRecord::Migration
  def change
    create_table :budget_types, force: true do |t|
      t.string :name
      t.integer :organization_id
      t.integer :application_id

      t.timestamps null: false
    end
  end
end
