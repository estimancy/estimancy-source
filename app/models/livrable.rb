class Livrable < ActiveRecord::Base
  attr_accessible :name, :description, :state, :organization_id, :service_id

  belongs_to :organization
  belongs_to :service

  # validates_presence_of :state
  # validates_presence_of :service_id
  # validates_presence_of :name

  def to_s
    name.nil? ? '' : name
  end

end
