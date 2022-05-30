class Provider < ActiveRecord::Base
  attr_accessible :name, :organization_id, :coefficient, :coefficient_label

  validates :name, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }

  belongs_to :organization
  has_many :projects
  has_many :organization_estimations

  amoeba do
    enable
    exclude_association [:projects, :organization_estimations]
    customize(lambda { |original_provider, new_provider|
                new_provider.copy_id = original_provider.id
              })
  end

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

end
