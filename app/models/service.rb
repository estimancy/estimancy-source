class Service < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id

  has_one :livrable

  has_and_belongs_to_many :demand_types


  def to_s
    name.nil? ? '' : name
  end

end
