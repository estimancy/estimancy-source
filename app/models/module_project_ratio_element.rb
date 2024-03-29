class ModuleProjectRatioElement < ActiveRecord::Base
  #attr_accessible :name, :description, :comments, :ratio_value, :multiple_references, :position, :pbs_project_element_id, :module_project_id, :wbs_activity_ratio_id, :wbs_activity_element_id, :wbs_activity_ratio_element_id

  has_ancestry

  #validates :name, :presence => true###, :uniqueness => {:scope => [:pbs_project_element_id, :module_project_id, :wbs_activity_ratio_id, :ancestry], :case_sensitive => false}
  #validates :module_project_id, :wbs_activity_ratio_id, :pbs_project_element_id, :presence => true

  belongs_to :organization
  belongs_to :wbs_activity

  belongs_to :pbs_project_element
  belongs_to :module_project
  belongs_to :wbs_activity_ratio
  belongs_to :wbs_activity_ratio_element
  belongs_to :wbs_activity_element

  def name_to_show
    if self.name_is_modified == true
      self.name
    else
      begin
        self.wbs_activity_element.name
      rescue
        self.name
      end
    end
  end

end
