class Service < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id

  has_one :livrable

  def to_s
    name
  end

end
