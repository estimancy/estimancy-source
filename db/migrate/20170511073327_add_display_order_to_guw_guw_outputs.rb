class AddDisplayOrderToGuwGuwOutputs < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_outputs, :display_order, :integer
    rescue
      #
    end
  end
end
