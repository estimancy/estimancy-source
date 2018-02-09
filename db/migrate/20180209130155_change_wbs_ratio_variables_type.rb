class ChangeWbsRatioVariablesType < ActiveRecord::Migration
  def up
    change_column :module_project_ratio_variables, :value_from_percentage, :decimal, :precision => 20, :scale => 6

    change_column :module_project_ratio_elements, :theoretical_effort_low, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :theoretical_effort_high, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :theoretical_effort_most_likely, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :theoretical_effort_probable, :decimal, :precision => 20, :scale => 6

    change_column :module_project_ratio_elements, :retained_effort_low, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :retained_effort_high, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :retained_effort_most_likely, :decimal, :precision => 20, :scale => 6
    change_column :module_project_ratio_elements, :retained_effort_probable, :decimal, :precision => 20, :scale => 6
  end

  def down
    change_column :module_project_ratio_variables, :value_from_percentage, :float

    change_column :module_project_ratio_elements, :theoretical_effort_low, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :theoretical_effort_high, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :theoretical_effort_most_likely, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :theoretical_effort_probable, :decimal, :precision => 15, :scale => 5

    change_column :module_project_ratio_elements, :retained_effort_low, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :retained_effort_high, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :retained_effort_most_likely, :decimal, :precision => 15, :scale => 5
    change_column :module_project_ratio_elements, :retained_effort_probable, :decimal, :precision => 15, :scale => 5
  end
end
