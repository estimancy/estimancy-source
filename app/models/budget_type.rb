class BudgetType < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :budget_id, :description, :color

  belongs_to :application
  has_many :budget_type_statuses, dependent: :destroy

end
