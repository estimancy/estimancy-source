module Guw
  class GuwCoefficientElement < ActiveRecord::Base

    attr_accessible :name, :guw_coefficient_id, :value,
                    :display_order, :guw_model_id, :organization_id,
                    :min_value, :max_value, :default_value, :description,
                    :default, :color_code, :color_priority, :default_display_value

    belongs_to :guw_model
    belongs_to :guw_coefficient

    has_many :guw_complexity_coefficient_elements, dependent: :destroy

    amoeba do
      include_association [:guw_complexity_coefficient_elements]
    end
  end
end
