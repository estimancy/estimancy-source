class DemandType < ActiveRecord::Base
  attr_accessible :name, :description, :fixed_billing, :deadlined_billing, :cost_from,
                  :organization_id, :demand_status_id, :billing, :service_ids, :agreement_id

  has_many :demands

  belongs_to :organization
  belongs_to :demand_status #statut de départ # obsolète

  has_many :demand_statuses
  has_many :agreements

  has_and_belongs_to_many :services

  def to_s
    self.nil? ? nil : self.name
  end
end
