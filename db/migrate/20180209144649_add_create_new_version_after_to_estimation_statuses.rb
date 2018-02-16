class AddCreateNewVersionAfterToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :create_new_version_when_changing_status, :boolean
  end
end
