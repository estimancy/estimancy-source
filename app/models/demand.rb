class Demand < ActiveRecord::Base
  attr_accessible :name, :description, :business_need, :demand_type_id, :application_id, :demand_status_id, :organization_id, :cost, :attachment, :selected

  mount_uploader :attachment, AttachmentUploader
  belongs_to :demand_type
  belongs_to :organization
  belongs_to :application
  belongs_to :demand_status

  has_many :projects

  def to_s
    name
  end

  def get_demand_statuses(organization=nil)
    if new_record? || self.demand_status.nil?
      if organization.nil?
        nil
      else
        initial_status = organization.demand_statuses.first_or_create(organization_id: organization.id,
                                                                      name: 'Préliminaire')
        [[initial_status.name, initial_status.id]]
      end
      #nil
    else
      demand_statuses = self.demand_status.demand_to_transition_statuses
      demand_statuses << self.demand_status
      demand_statuses = demand_statuses.uniq
    end
  end
end
