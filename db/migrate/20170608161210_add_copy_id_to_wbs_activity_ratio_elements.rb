class AddCopyIdToWbsActivityRatioElements < ActiveRecord::Migration
  def change
    add_column :wbs_activity_ratio_elements, :copy_id, :integer
  end
end
