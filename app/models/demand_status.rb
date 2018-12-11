class DemandStatus < ActiveRecord::Base
  attr_accessible :organization_id, :status_number, :status_alias, :name, :status_color

  has_many :from_transitions, :foreign_key => 'from_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :to_transition_statuses, :through => :from_transitions

  has_many :to_transitions, :foreign_key => 'to_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :from_transition_statuses, :through => :to_transitions

  has_many :demands

  def to_s
    name
  end
end
