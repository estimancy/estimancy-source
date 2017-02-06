module Guw
  class GuwOutputComplexityInitialization < ActiveRecord::Base
    belongs_to :guw_complexity
    belongs_to :guw_output
  end
end
