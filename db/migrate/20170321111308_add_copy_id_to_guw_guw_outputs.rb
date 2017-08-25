class AddCopyIdToGuwGuwOutputs < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_outputs, :copy_id, :integer
    rescue
      #
    end
  end
end
