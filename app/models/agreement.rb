class Agreement < ActiveRecord::Base
  attr_accessible :name, :demand_type_id, :organization_id, :origin_target_mode

  has_many :criticality_severities

  belongs_to :organization
  belongs_to :demand_type
end
