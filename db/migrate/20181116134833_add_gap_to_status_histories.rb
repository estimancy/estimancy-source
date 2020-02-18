class AddGapToStatusHistories < ActiveRecord::Migration
  def change
    add_column :status_histories, :gap, :integer
  end
end
