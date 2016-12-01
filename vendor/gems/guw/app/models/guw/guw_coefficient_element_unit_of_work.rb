module Guw
  class GuwCoefficientElementUnitOfWork < ActiveRecord::Base

    belongs_to :guw_coefficient_element
    belongs_to :guw_unit_of_work
    belongs_to :guw_coefficient

  end
end
