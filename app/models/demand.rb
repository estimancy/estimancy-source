class Demand < ActiveRecord::Base
  attr_accessible :name, :description, :business_need, :demande_type_id, :application_id, :demand_status_id, :organization_id, :cost

  belongs_to :demand_type
  belongs_to :organization

  has_many :projects

  def to_s
    name
  end
end
