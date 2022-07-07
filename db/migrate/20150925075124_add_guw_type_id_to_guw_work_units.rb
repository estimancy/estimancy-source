class AddGuwTypeIdToGuwWorkUnits < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexity_work_units, :guw_type_id, :integer
  end
end
