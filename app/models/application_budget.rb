class ApplicationBudget < ActiveRecord::Base
  attr_accessible :organization_id, :application_id, :budget_id, :montant, :is_used

  belongs_to :organization
  belongs_to :application
  belongs_to :budget_type
end
