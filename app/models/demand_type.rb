class DemandType < ActiveRecord::Base
  attr_accessible :name, :description, :fixed_billing, :deadlined_billing, :organization_id

  has_many :demands

  belongs_to :organization

end
