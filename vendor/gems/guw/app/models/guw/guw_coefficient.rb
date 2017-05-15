module Guw
  class GuwCoefficient < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_coefficient_elements, dependent: :destroy

    validates :name, :presence => true

    amoeba do
      include_association [:guw_coefficient_elements]

      enable
    end
  end
end
