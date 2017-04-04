class AddEstimationsCounterHistoryToOrganizations < ActiveRecord::Migration

  def change
    add_column :organizations, :estimations_counter_history, :text
  end
end
