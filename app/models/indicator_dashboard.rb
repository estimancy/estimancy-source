class IndicatorDashboard < ActiveRecord::Base

  belongs_to :organization
  has_many :iwidgets

  validates :name, presence: true, uniqueness: true

  amoeba do
    enable
    include_association [:iwidgets]
  end

  def to_s
    self.nil? ? '' : self.name
  end

end
