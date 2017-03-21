class AddCopyIdToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :copy_id, :integer
  end
end
