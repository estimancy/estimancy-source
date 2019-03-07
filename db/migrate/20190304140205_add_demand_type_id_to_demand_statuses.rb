class AddDemandTypeIdToDemandStatuses < ActiveRecord::Migration
  def change
    add_column :demand_statuses, :demand_type_id, :integer
  end
end
