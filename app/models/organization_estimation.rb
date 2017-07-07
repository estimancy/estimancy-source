
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

  # get the selectable/available inline columns
  class_attribute :available_inline_columns
  self.available_inline_columns =
      [
          QueryColumn.new(:title, :sortable => "#{Project.table_name}.title", :caption => "label_project_name"),
          QueryColumn.new(:application, :sortable => "#{Application.table_name}.name", :caption => "application"),
          QueryColumn.new(:original_model, :sortable => "#{Project.table_name}.name", :caption => "original_model"),
          QueryColumn.new(:version_number, :sortable => "#{Project.table_name}.version_number", :caption => "label_version"),
          QueryColumn.new(:status_name, :sortable => "#{EstimationStatus.table_name}.name", :caption => "state"),
          QueryColumn.new(:project_area, :sortable => "#{ProjectArea.table_name}.name", :caption => "project_area"),
          QueryColumn.new(:project_category, :sortable => "#{ProjectCategory.table_name}.name", :caption => "category"),
          QueryColumn.new(:acquisition_category, :sortable => "#{AcquisitionCategory.table_name}.name", :caption => "label_acquisition"),
          QueryColumn.new(:platform_category, :sortable => "#{PlatformCategory.table_name}.name", :caption => "label_platform"),
          QueryColumn.new(:description, :sortable => "#{Project.table_name}.description", :caption => "description"),
          QueryColumn.new(:start_date, :sortable => "#{Project.table_name}.start_date", :caption => "label_date"),
          QueryColumn.new(:creator, :sortable => "#{User.table_name}.first_name", :caption => "author"),
          QueryColumn.new(:created_at, :sortable => "#{Project.table_name}.created_at", :caption => "created_at"),
          QueryColumn.new(:updated_at, :sortable => "#{Project.table_name}.updated_at", :caption => "updated_at"),
          QueryColumn.new(:private, :sortable => "#{Project.table_name}.private", :caption => "private_estimation")
      ]

  class_attribute :default_selected_columns
  self.default_selected_columns = ["application", "version_number", "start_date", "status_name", "description"]


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
