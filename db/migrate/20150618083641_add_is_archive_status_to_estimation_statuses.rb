class AddIsArchiveStatusToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :is_archive_status, :boolean, after: :status_color
  end
end
