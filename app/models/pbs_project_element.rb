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

#Component of the PE-WBS-Project. Component belongs to a type (dev, cots, folder, link...)
#Component use Ancestry gem (has_ancestry). See ancestry on github for more information.
class PbsProjectElement < ActiveRecord::Base
  attr_accessible :name, :description, :pe_wbs_project_id, :is_completed, :is_validated, :position, :is_root,
                  :work_element_type_id, :ancestry, :wbs_activity_id, :wbs_activity_ratio_id, :parent_id,
                  :organization_technology_id, :start_date, :end_date

  has_ancestry

  belongs_to :pe_wbs_project, :touch => true
  # belongs_to :work_element_type
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio
  belongs_to :organization_technology

  has_many :estimation_values
  has_many :views_widgets, dependent: :destroy
  has_many :module_project_ratio_elements, dependent: :destroy

  has_and_belongs_to_many :module_projects

  validates :name, :start_date, presence: true
  validates_presence_of :organization_technology_id
  #validates :wbs_activity_ratio_id, :uniqueness => { :scope => :wbs_activity_id }

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    exclude_association [:estimation_values, :views_widgets, :module_project_ratio_elements]

    customize(lambda { |original_pbs_project_elt, new_pbs_project_elt|
      new_pbs_project_elt.copy_id = original_pbs_project_elt.id
      #if original_pbs_project_elt.is_root == true
      #new_pbs_project_elt.name = "Copy_#{ new_pbs_project_elt.pe_wbs_projects.first.project.copy_number.to_i+1} of #{original_pbs_project_elt.name}"
      #end
    })
  end


  #Metaprogrammation
  #Generate an method folder?, link?, etc...
  #Usage: component1.folder?
  #Return a boolean.
  # Load this list unless on Test ENV
  # types_wet = nil
  # unless Rails.env.test?
  #   types_wet = WorkElementType::work_element_type_list
  #   types_wet.each do |type|
  #     define_method("#{type}?") do
  #       begin
  #         (self.work_element_type.alias == type) ? true : false
  #       rescue
  #         false
  #       end
  #     end
  #   end
  # end

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

end
