
class OrganizationEstimation < ActiveRecord::Base
  self.primary_key = 'project_id'

  belongs_to :organization
end
