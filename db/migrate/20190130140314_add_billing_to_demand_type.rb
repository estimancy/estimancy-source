class AddBillingToDemandType < ActiveRecord::Migration
  def change
    add_column :demand_types, :billing, :integer
  end
end
