class AddEstimationValueIdToEstimationsValues < ActiveRecord::Migration
  def change
    add_column :estimation_values, :estimation_value_id, :integer
  end
end
