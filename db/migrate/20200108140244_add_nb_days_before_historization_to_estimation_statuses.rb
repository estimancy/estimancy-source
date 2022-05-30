class AddNbDaysBeforeHistorizationToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :is_historization_status, :boolean
    add_column :estimation_statuses, :nb_day_before_historization, :float

    add_column :projects, :historization_time, :datetime
    add_column :projects, :is_historized, :boolean
  end
end
