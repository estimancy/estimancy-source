class DropBudgets < ActiveRecord::Migration
  def change
    drop_table :budgets
  end
end
