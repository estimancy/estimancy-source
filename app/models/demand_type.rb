class DemandType < ActiveRecord::Base
  attr_accessible :name, :description, :fixed_billing, :deadlined_billing, :cost_from, :organization_id, :demand_status_id, :billing

  has_many :demands

  belongs_to :organization
  belongs_to :demand_status #statut de départ

end
