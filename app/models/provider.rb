class Provider < ActiveRecord::Base
  attr_accessible :name, :organization_id

  validates :name, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }

  belongs_to :organization
  has_many :projects

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

end
