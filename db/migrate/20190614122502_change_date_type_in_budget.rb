class ChangeDateTypeInBudget < ActiveRecord::Migration
  def change
    change_column :budgets, :start_date, :date
    change_column :budgets, :end_date, :date
  end
end
