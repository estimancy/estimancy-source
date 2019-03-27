class BudgetType < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :description

  belongs_to :application

end
