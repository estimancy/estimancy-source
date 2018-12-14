class Service < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id

end
