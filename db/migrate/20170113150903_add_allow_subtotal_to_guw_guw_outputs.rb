class AddAllowSubtotalToGuwGuwOutputs < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_outputs, :allow_subtotal, :boolean
    rescue
      #
    end
  end
end
