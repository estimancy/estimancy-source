class DemandStatus < ActiveRecord::Base
  attr_accessible :organization_id, :status_number, :status_alias, :name, :status_color

  has_many :demands
end
