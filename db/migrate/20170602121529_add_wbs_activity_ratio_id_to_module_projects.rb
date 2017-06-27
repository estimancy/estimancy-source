class AddWbsActivityRatioIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :wbs_activity_ratio_id, :integer, after: :wbs_activity_id
  end
end
