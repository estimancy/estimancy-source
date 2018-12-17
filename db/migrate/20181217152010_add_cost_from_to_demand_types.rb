class AddCostFromToDemandTypes < ActiveRecord::Migration
  def change
    add_column :demand_types, :cost_from, :string
  end
end
