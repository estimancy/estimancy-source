class ApplicationBudgetType < ActiveRecord::Base
  belongs_to :organization
  belongs_to :budget
  belongs_to :budget_type
  belongs_to :application
  belongs_to :estimation_status
end
