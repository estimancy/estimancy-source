class AddColorToBudgetTypes < ActiveRecord::Migration
  def change
    add_column :budget_types, :color, :string
  end
end
