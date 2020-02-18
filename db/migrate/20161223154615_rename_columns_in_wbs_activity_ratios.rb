class RenameColumnsInWbsActivityRatios < ActiveRecord::Migration

  def up

    add_column :wbs_activity_ratio_variables, :is_used_in_ratio_calculation, :boolean
    add_column :module_project_ratio_variables, :is_used_in_ratio_calculation, :boolean

    rename_column :wbs_activity_ratios, :use_real_base_percentage, :do_not_show_cost
    rename_column :wbs_activity_ratios, :allow_modify_ratio_value, :do_not_show_phases_with_zero_value

    change_column :wbs_activity_ratios, :do_not_show_cost, :boolean, :default => nil
    change_column :wbs_activity_ratios, :do_not_show_phases_with_zero_value, :boolean, :default => nil
  end


  def down
    remove_column :wbs_activity_ratio_variables, :is_used_in_ratio_calculation
    remove_column :module_project_ratio_variables, :is_used_in_ratio_calculation

    rename_column :wbs_activity_ratios, :do_not_show_cost, :use_real_base_percentage
    rename_column :wbs_activity_ratios, :do_not_show_phases_with_zero_value, :allow_modify_ratio_value
  end
end
