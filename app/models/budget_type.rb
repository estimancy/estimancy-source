class BudgetType < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :description, :color

  belongs_to :estimation_status
  has_many :budget_type_statuses, :dependent=> :destroy
  has_many :application_budget_types, :dependent=> :destroy

  def to_s
    self.nil? ? '' : self.name
  end

  def get_budget_type_statuses
    self.budget_type_statuses.each do |bt_status|
      bt_status.estimation_status.name
    end
  end

end