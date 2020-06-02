class IndicatorDashboard < ActiveRecord::Base

  belongs_to :organization
  has_many :iwidgets

end
