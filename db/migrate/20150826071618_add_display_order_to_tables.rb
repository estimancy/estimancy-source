class AddDisplayOrderToTables < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexities, :display_order, :integer, :default => 0
    add_column :guw_guw_work_units, :display_order, :integer, :default => 0
    add_column :guw_guw_type_complexities, :display_order, :integer, :default => 0
  end
end
