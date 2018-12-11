class ServiceDemandLivrable < ActiveRecord::Base
  attr_accessible :organization_id, :service_id, :demand_id, :livrable_id, :contract_date, :expected_date, :actual_date, :state, :delivered, :delayed
end
