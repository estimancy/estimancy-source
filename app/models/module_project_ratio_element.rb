class ModuleProjectRatioElement < ActiveRecord::Base
  #attr_accessible :name, :description, :comments, :ratio_value, :multiple_references, :position, :pbs_project_element_id, :module_project_id, :wbs_activity_ratio_id, :wbs_activity_element_id, :wbs_activity_ratio_element_id

  belongs_to :pbs_project_element
  belongs_to :module_project
  belongs_to :wbs_activity_ratio
  belongs_to :wbs_activity_ratio_element
  belongs_to :wbs_activity_element

end
