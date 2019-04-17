class Budget < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :start_date, :end_date, :sum

  belongs_to :organization
  has_many :budget_types, dependent: :destroy
end
