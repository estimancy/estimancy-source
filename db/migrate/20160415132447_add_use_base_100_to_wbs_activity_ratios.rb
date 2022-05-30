class AddUseBase100ToWbsActivityRatios < ActiveRecord::Migration
  def change
    add_column :wbs_activity_ratios, :use_base_100, :boolean, after: :wbs_activity_id
  end
end
