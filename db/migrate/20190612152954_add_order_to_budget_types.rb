class AddOrderToBudgetTypes < ActiveRecord::Migration
  def change
    add_column :budget_types, :display_order, :integer
  end
end
