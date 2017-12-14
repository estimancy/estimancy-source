class Provider < ActiveRecord::Base
  attr_accessible :name, :organization_id

  belongs_to :organization
  has_many :projects

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

end
