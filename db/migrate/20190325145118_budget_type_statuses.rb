class BudgetTypeStatuses < ActiveRecord::Migration
  def change
    create_table :budget_type_statuses do |t|
      t.integer :organization_id
      t.integer :budget_type_id
      t.integer :estimation_status_id
      t.integer :application_id

      t.timestamps null: false
    end
  end
end
