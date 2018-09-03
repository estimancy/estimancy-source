class Application < ActiveRecord::Base
  attr_accessible :name, :organization_id, :is_ignored
  belongs_to :organization

  has_and_belongs_to_many :projects

  validates :name, :presence => true , :uniqueness => { :scope => :organization_id, :case_sensitive => false }

  default_scope { order('name ASC') }

  # scope :active, where(is_ignored: [false, nil])
  # scope :ignored, where(is_ignored: true)

  scope :active, -> {
    where(:is_ignored => [false, nil])
  }

  scope :ignored, -> {
    where(:is_ignored => true)
  }

  def to_s
    self.nil? ? '' : self.name
  end
end
