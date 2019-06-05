class RemoveBudgetIdFromBudgetType < ActiveRecord::Migration
  def change
    remove_column :budget_types, :budget_id
  end
end
