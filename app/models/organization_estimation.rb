
class OrganizationEstimation < ActiveRecord::Base
  self.primary_key = 'project_id'
  has_ancestry  # For the Ancestry gem

  #### Nexts and Previous by date DESC
  scope :next_by_date, lambda {|organization_id, created_at| where("organization_id = ? AND created_at < ?", organization_id, created_at) }
  scope :previous_by_date, lambda {|organization_id, created_at| where("organization_id = ? AND created_at > ?", organization_id, created_at) }

  belongs_to :organization
  belongs_to :application
  has_and_belongs_to_many :applications

  belongs_to :project_area
  belongs_to :acquisition_category
  belongs_to :platform_category
  belongs_to :project_category
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :estimation_status
  belongs_to :project
  belongs_to :provider

  has_many :module_projects, :dependent => :destroy
  has_many :pemodules, :through => :module_projects
  has_many :project_securities, :dependent => :destroy
  has_many :project_fields, :dependent => :destroy

  has_many :projects_from_model, foreign_key: "original_model_id", class_name: "Project"

  has_and_belongs_to_many :groups

  has_many :pe_wbs_projects
  has_many :pbs_project_elements, :through => :pe_wbs_projects
  has_many :wbs_project_elements, :through => :pe_wbs_projects

  # Next ones by Created_at DESC
  def next_ones_by_date(n)
    OrganizationEstimation.next_by_date(self.organization_id, self.created_at).limit(n)
  end

  #Previous ones by Created_at DESC
  def previous_ones_by_date(n)
    OrganizationEstimation.previous_by_date(self.organization_id, self.created_at).limit(n)
  end


  #  Estimation status name
  def status_name
    self.estimation_status.nil? ? nil : self.estimation_status.name
  end

  def author
    self.creator_id.nil? ? "" : self.creator
  end

  # The status background color for estimations list
  def status_background_color
    self.estimation_status.nil? ? "#999999" : "##{self.estimation_status.status_color}"
  end


  def project_fields_to_h(arr_sep=' ; ', key_sep=': ')
    array = self.project_fields_result.split(arr_sep)
    hash = HashWithIndifferentAccess.new  #{}

    array.each do |e|
      key_value = e.split(key_sep)
      hash[key_value[0]] = key_value[1]
    end

    return hash
  end


end
