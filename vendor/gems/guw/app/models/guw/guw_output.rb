module Guw
  class GuwOutput < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_output_associations, dependent: :destroy
    has_many :guw_output_complexities, dependent: :destroy

    amoeba do
      enable
      exclude_association [:guw_output_associations, :guw_output_complexities]

      customize(lambda { |original_guw_output, new_guw_output|
                  new_guw_output.copy_id = original_guw_output.id
                })

    end
  end
end
