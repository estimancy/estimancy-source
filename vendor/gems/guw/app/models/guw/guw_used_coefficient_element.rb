module Guw
  class GuwUsedCoefficientElement < ActiveRecord::Base
    self.primary_key = 'id'

    belongs_to :guw_model
    belongs_to :guw_coefficient
    belongs_to :guw_used_coefficient, foreign_key: :guw_coefficient_id

    has_many :guw_complexity_coefficient_elements, foreign_key: :guw_coefficient_element_id, dependent: :destroy
  end
end
