class AddDemandStatusIdToDemandTypes < ActiveRecord::Migration
  def change
    add_column :demand_types, :demand_status_id, :integer
  end
end
