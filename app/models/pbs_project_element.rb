#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

#Component of the PE-WBS-Project. Component belongs to a type (dev, cots, folder, link...)
#Component use Ancestry gem (has_ancestry). See ancestry on github for more informations.
class PbsProjectElement < ActiveRecord::Base
  has_ancestry

  belongs_to :pe_wbs_project
  belongs_to :work_element_type
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio

  has_many :estimation_values

  has_and_belongs_to_many :module_projects

  validates_presence_of :name
  #validates :wbs_activity_ratio_id, :uniqueness => { :scope => :wbs_activity_id }  #TODO Review validation

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    exclude_field [:estimation_values]

    customize(lambda { |original_pbs_project_elt, new_pbs_project_elt|
      new_pbs_project_elt.copy_id = original_pbs_project_elt.id
    })
  end

  #Metaprogrammation
  #Generate an method folder?, link?, etc...
  #Usage: component1.folder?
  #Return a boolean.
  types_wet = WorkElementType::work_element_type_list
  types_wet.each do |type|
    define_method("#{type}?") do
      (self.work_element_type.alias == type) ? true : false
    end
  end

  #Override
  def to_s
    self.name
  end

end
