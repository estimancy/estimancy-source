module Guw
  class GuwUsedCoefficientElement < ActiveRecord::Base
    self.primary_key = 'id'
    #self.primary_key = 'guw_coefficient_element_id'

    belongs_to :guw_model
    belongs_to :guw_coefficient
    belongs_to :guw_used_coefficient, foreign_key: :guw_coefficient_id, class_name: GuwCoefficient

    has_many :guw_complexity_coefficient_elements, foreign_key: :guw_coefficient_element_id, dependent: :destroy
    #has_many :guw_complexity_coefficient_elements, through: :guw_used_coefficient, source: :guw_coefficient_elements,  foreign_key: :guw_coefficient_element_id, dependent: :destroy
  end
end
