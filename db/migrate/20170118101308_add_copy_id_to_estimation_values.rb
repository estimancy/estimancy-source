class AddCopyIdToEstimationValues < ActiveRecord::Migration
  def change
    add_column :estimation_values, :copy_id, :integer
  end
end
