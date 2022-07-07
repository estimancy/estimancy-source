class AddDescriptionToBudgetTypes < ActiveRecord::Migration
  def change
    add_column :budget_types, :description, :string
  end
end
