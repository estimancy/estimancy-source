module Guw
  class GuwOutputComplexity < ActiveRecord::Base
    belongs_to :guw_complexity
    belongs_to :aguw_output, class_name: GuwOutput, foreign_key: :guw_output_associated_id
  end
end
