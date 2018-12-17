class DemandType < ActiveRecord::Base
  attr_accessible :name, :description, :fixed_billing, :deadlined_billing, :cost_from, :organization_id

  has_many :demands

  belongs_to :organization

end
