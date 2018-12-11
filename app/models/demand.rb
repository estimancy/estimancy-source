class Demand < ActiveRecord::Base
  attr_accessible :name, :description, :business_need, :demand_type_id, :application_id, :demand_status_id, :organization_id, :cost, :attachment

  mount_uploader :attachment, AttachmentUploader
  belongs_to :demand_type
  belongs_to :organization
  belongs_to :application
  belongs_to :demand_status

  has_many :projects

  def to_s
    name
  end
end
