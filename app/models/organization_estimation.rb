
class OrganizationEstimation < ActiveRecord::Base
  self.primary_key = 'project_id'

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

  has_many :project_fields, :dependent => :destroy
  has_many :projects_from_model, foreign_key: "original_model_id", class_name: "Project"


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



end
