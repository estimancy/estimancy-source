class ModuleProjectRatioVariable < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :pbs_project_element
  belongs_to :module_project
  belongs_to :wbs_activity_ratio
  belongs_to :wbs_activity_ratio_variable
end
