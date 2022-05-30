class DemandStatus < ActiveRecord::Base
  attr_accessible :organization_id, :status_number, :status_alias, :name, :status_color, :demand_type_id

  has_many :demand_from_transitions, :foreign_key => 'demand_from_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :demand_to_transition_statuses, :through => :demand_from_transitions

  has_many :demand_to_transitions, :foreign_key => 'demand_to_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :demand_from_transition_statuses, :through => :demand_to_transitions

  has_many :demands

  belongs_to :demand_type

  default_scope { order(status_number: :asc) }

  def to_s
    name
  end
end
