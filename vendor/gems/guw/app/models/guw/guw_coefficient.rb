module Guw
  class GuwCoefficient < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_coefficient_elements

    amoeba do
      enable
    end
  end
end
