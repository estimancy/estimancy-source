class AddAllowCorrectionBeforeChangeToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :allow_correction_before_change, :boolean
  end
end
