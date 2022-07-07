class Criticality < ActiveRecord::Base
  attr_accessible :name, :organization_id

  has_many :wbs_activity_elements

  #has_and_belongs_to_many :demand_types


  def to_s
    name.nil? ? '' : name
  end
end
