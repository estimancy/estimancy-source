class RenameUseBase100 < ActiveRecord::Migration
  def change
      rename_column :wbs_activity_ratios, :use_base_100, :use_real_base_percentage
  end
end
