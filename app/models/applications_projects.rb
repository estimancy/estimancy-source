class ApplicationsProjects < ActiveRecord::Base
  belongs_to :application
  belongs_to :project
end
