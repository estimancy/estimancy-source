#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class OrganizationTechnology < ActiveRecord::Base
  attr_accessible :alias, :description, :name, :organization_id, :productivity_ratio, :state, :unit_of_work_ids

  include AASM

  aasm :column => :state do # defaults to aasm_state
    state :draft, :initial => true
    state :defined
    state :retired
  end

  belongs_to :organization
  has_many :guw_complexity_technologies, class_name: "Guw::GuwComplexityTechnology"

  validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false}

  # Add the amoeba gem for the copy
  amoeba do
    enable
    exclude_association [:pbs_project_elements, :inputs, :guw_complexity_technologies]

    customize(lambda { |original_organization_technology, new_organization_technology|
      new_organization_technology.copy_id = original_organization_technology.id
    })
  end


  default_scope { order('alias DESC') }

  #Search fields
  scoped_search :on => [:name, :alias, :description]

  def to_s
    self.nil? ? '' : self.name
  end

end
