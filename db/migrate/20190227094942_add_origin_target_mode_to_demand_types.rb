class AddOriginTargetModeToDemandTypes < ActiveRecord::Migration
  def change
    add_column :demand_types, :origin_target_mode, :string
  end
end
