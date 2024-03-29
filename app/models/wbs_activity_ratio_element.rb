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

class WbsActivityRatioElement < ActiveRecord::Base
  attr_accessible :ratio_value,:simple_reference, :multiple_references, :wbs_activity_ratio_id, :wbs_activity_element_id,
                  :formula, :is_modifiable, :effort_is_modifiable, :cost_is_modifiable, :is_optional, :organization_id, :wbs_activity_id

  has_ancestry

  belongs_to :organization
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio
  belongs_to :wbs_activity_element

  has_many :wbs_activity_ratio_profiles, dependent: :delete_all
  has_many :organization_profiles, through: :wbs_activity_ratio_profiles

  has_many :module_project_ratio_elements, dependent: :destroy

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    include_association [:wbs_activity_ratio_profiles]

    customize(lambda { |original_wbs_activity_ratio_elt, new_wbs_activity_ratio_elt|
                        new_wbs_activity_ratio_elt.copy_id = original_wbs_activity_ratio_elt.id
    })

  end
end
