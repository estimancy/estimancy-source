module Guw
  class GuwTypeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    has_many :attribute_complexities
  end
end
