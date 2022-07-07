module Guw
  class GuwCoefficient < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_coefficient_elements, dependent: :destroy
    #has_many :guw_used_coefficient_elements, foreign_key: :guw_coefficient_element_id, dependent: :destroy

    validates :name, :presence => true

    attr_accessible :name, :coefficient_type, :guw_model_id, :organization_id,
                    :coefficient_calc, :allow_intermediate_value, :deported,
                    :description, :allow_comments, :math_set, :show_coefficient_label

    amoeba do
      include_association [:guw_coefficient_elements]

      enable
    end
  end
end
