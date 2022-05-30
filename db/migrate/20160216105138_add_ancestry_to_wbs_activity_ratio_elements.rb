class AddAncestryToWbsActivityRatioElements < ActiveRecord::Migration
  def change

    add_column :wbs_activity_ratio_elements, :ancestry, :string
    add_index  :wbs_activity_ratio_elements, :ancestry

    add_column :wbs_activity_ratio_profiles, :ancestry, :string
    add_index  :wbs_activity_ratio_profiles, :ancestry
  end
end
