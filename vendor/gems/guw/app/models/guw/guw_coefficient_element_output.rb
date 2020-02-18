module Guw
  class GuwCoefficientElementOutput < ActiveRecord::Base
    belongs_to :guw_coefficient_element
    belongs_to :guw_output
  end
end
