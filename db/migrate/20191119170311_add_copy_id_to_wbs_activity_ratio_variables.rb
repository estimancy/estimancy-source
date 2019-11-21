class AddCopyIdToWbsActivityRatioVariables < ActiveRecord::Migration
  def change
    add_column :wbs_activity_ratio_variables, :copy_id, :integer
    add_column :module_project_ratio_variables, :copy_id, :integer
  end
end
