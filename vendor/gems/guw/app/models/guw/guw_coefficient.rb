module Guw
  class GuwCoefficient < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_coefficient_elements, dependent: :destroy

    validates :name, :presence => true

    attr_accessible :name, :coefficient_type, :guw_model_id,
                    :coefficient_calc, :allow_intermediate_value, :deported, :description, :allow_comments

    amoeba do
      include_association [:guw_coefficient_elements]

      enable
    end
  end
end
