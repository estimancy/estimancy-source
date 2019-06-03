class BudgetType < ActiveRecord::Base
   #attr_accessible :name, :organization_id, :application_id, :budget_id, :description, :color
  attr_accessible :name, :organization_id, :application_id, :budget_id, :description, :color

  belongs_to :estimation_status
  has_many :budget_type_statuses, dependent: :destroy

  def to_s
    self.nil? ? '' : self.name
  end

end