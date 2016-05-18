class AddIsNewStatusToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :is_new_status, :boolean
  end
end
