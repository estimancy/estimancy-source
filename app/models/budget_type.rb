class BudgetType < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :description

  belongs_to :application
  has_many :budget_type_statuses

end
