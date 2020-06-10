class IndicatorDashboard < ActiveRecord::Base

  belongs_to :organization
  has_many :iwidgets

  validates :name, presence: true

  def to_s
    self.nil? ? '' : self.name
  end

end
