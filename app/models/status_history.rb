class StatusHistory < ActiveRecord::Base
  attr_accessible :action, :change_date, :comments, :organization, :origin, :project, :target, :user, :old_version_number, :new_version_number, :gap, :project_id
end
