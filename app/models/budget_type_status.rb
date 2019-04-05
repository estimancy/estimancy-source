class BudgetTypeStatus < ActiveRecord::Base
  attr_accessible :organization_id, :budget_type_id, :estimation_status_id, :application_id

  belongs_to :budget_type
  belongs_to :estimation_status
end

