module Guw
  class GuwCoefficientElement < ActiveRecord::Base
    belongs_to :guw_model
    belongs_to :guw_coefficient

    has_many :guw_complexity_coefficient_elements, dependent: :destroy

    amoeba do
      include_association [:guw_complexity_coefficient_elements]
    end
  end
end
