class AddNotificationEmailsToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :notification_emails, :text
  end
end
