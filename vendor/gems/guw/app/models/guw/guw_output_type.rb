module Guw
  class GuwOutputType < ActiveRecord::Base
    belongs_to :guw_model
    belongs_to :guw_output
    belongs_to :guw_type
  end
end
