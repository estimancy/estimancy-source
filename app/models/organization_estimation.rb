
class OrganizationEstimation < ActiveRecord::Base
  self.primary_key = 'project_id'

  belongs_to :organization

  #estimation_status, :project_area, :application, :creator, :acquisition_category
  belongs_to :application
  has_and_belongs_to_many :applications

  belongs_to :estimation_status


  belongs_to :project_area
  belongs_to :acquisition_category
  belongs_to :platform_category
  belongs_to :project_category
  belongs_to :acquisition_category
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'


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
