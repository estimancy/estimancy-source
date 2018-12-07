class Livrable < ActiveRecord::Base
  attr_accessible :name, :description, :state, :organization_id

  belongs_to :organization

end
