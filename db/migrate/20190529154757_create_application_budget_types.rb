class CreateApplicationBudgetTypes < ActiveRecord::Migration
  def up
    create_table :application_budget_types do |t|
      t.integer :organization_id
      t.integer :budget_id
      t.integer :application_id
      t.integer :budget_type_id
      t.integer :estimation_status_id

      t.timestamps null: false
    end
  end

  def down
    #drop_table :application_budget_types
  end
end
