module Guw
  class GuwOutputType < ActiveRecord::Base
    belongs_to :guw_model
    belongs_to :guw_output
    belongs_to :guw_type

    validates :guw_model_id, uniqueness: { scope: [:guw_output_id, :guw_type_id] }

  end
end
