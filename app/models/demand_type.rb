class DemandType < ActiveRecord::Base
  attr_accessible :name, :description, :fixed_billing, :deadlined_billing, :cost_from, :organization_id, :demand_status_id, :billing, :service_ids

  has_many :demands

  belongs_to :organization
  belongs_to :demand_status #statut de départ

  has_and_belongs_to_many :services

end
