class CreateBudgetBudgetTypes < ActiveRecord::Migration
  def change
    create_table :budget_budget_types do |t|
      t.integer :organization_id
      t.integer :budget_id
      t.integer :budget_type_id

      t.timestamps null: false
    end
  end
end
