class DemandStatusesDemandType < ActiveRecord::Base

  attr_accessible :organization_id, :demand_status_id, :demand_type_id, :percent

  belongs_to :organization
  belongs_to :demand_status
  belongs_to :demand_type

end
