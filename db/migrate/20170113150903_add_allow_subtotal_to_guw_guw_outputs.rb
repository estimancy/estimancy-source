class AddAllowSubtotalToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :allow_subtotal, :boolean
  end
end
