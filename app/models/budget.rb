class Budget < ActiveRecord::Base
  attr_accessible :name, :organization_id, :application_id, :start_date, :end_date, :sum

  belongs_to :application
  #has_many :budget_type_statuses, dependent: :destroy
end
