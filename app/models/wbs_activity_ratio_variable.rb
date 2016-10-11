class WbsActivityRatioVariable < ActiveRecord::Base
  attr_accessible :description, :is_modifiable, :name, :percentage_of_input, :wbs_activity_ratio_id

  belongs_to :wbs_activity_ratio
end
