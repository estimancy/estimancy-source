module Guw
  class GuwCoefficientElement < ActiveRecord::Base
    belongs_to :guw_model
    belongs_to :guw_coefficient

  end
end
