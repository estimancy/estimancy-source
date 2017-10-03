module Guw
  class GuwCoefficientElementUnitOfWork < ActiveRecord::Base

    belongs_to :guw_coefficient_element
    belongs_to :guw_unit_of_work
    belongs_to :guw_coefficient

    # validates :guw_unit_of_work_id, uniqueness: {scope: [:guw_coefficient_element_id]}

  end
end
