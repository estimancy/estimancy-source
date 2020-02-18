class WbsActivityRatioVariable < ActiveRecord::Base
  attr_accessible :description, :is_modifiable, :name, :percentage_of_input, :wbs_activity_ratio_id, :is_used_in_ratio_calculation,
                  :organization_id, :wbs_activity_id

  belongs_to :organization
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio
end
