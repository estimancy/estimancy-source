class AddFormulaToWbsActivityRatioElements < ActiveRecord::Migration
  def change

    add_column :wbs_activity_elements, :phase_short_name, :string
    add_column :wbs_activity_ratio_elements, :formula, :string
    add_column :wbs_activity_ratio_elements, :is_modifiable, :boolean, default: false

    add_column :wbs_activities, :phases_short_name_number, :integer, default: 0

    add_column :module_project_ratio_elements, :phase_short_name, :string

  end
end
