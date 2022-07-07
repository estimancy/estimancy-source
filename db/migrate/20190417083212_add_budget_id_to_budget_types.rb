class AddBudgetIdToBudgetTypes < ActiveRecord::Migration
  def change
    add_column :budget_types, :budget_id, :integer
  end
end
