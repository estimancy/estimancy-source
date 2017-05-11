class AddDisplayOrderToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :display_order, :integer
  end
end
