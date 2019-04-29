class AddCustomFieldToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :field_id, :string
  end
end
