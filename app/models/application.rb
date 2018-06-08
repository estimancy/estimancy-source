class Application < ActiveRecord::Base
  attr_accessible :name, :organization_id
  belongs_to :organization

  has_and_belongs_to_many :projects

  validates :name, :presence => true , :uniqueness => { :scope => :organization_id, :case_sensitive => false }

  default_scope { order('name ASC') }

  def to_s
    self.nil? ? '' : self.name
  end
end
