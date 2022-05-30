class AddEstimationStatusIdToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :estimation_status_id, :integer
  end
end
