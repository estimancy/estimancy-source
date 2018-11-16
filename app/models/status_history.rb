class StatusHistory < ActiveRecord::Base
  attr_accessible :action, :change_date, :comments, :organization, :origin, :project, :target, :user, :version_number, :gap
end
