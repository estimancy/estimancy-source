class BudgetBudgetType < ActiveRecord::Base
  attr_accessible :organization_id, :budget_id, :budget_type_id

  belongs_to :organization
  belongs_to :budget
  belongs_to :budget_type

end
