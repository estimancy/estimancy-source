class CriticalitySeverity < ActiveRecord::Base
  attr_accessible :organization_id, :criticality_id, :severity_id, :duration, :origin_status_id, :target_status_id, :demand_type_id
end
