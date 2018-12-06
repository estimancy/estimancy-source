class Demand < ActiveRecord::Base
  attr_accessible :name, :description, :business_need, :demande_type_id, :application_id, :demand_status_id, :organization_id, :cost
end
