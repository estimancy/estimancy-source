class DropBudgets < ActiveRecord::Migration
  def change
    begin
      drop_table :budgets
    rescue
      #
    end
  end
end
