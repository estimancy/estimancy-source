# encoding: UTF-8
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

class WbsActivityRatioProfile < ActiveRecord::Base
  attr_accessible :organization_profile_id, :ratio_value, :wbs_activity_ratio_element_id

  has_ancestry

  belongs_to :wbs_activity_ratio_element
  belongs_to :organization_profile

  #Amoeba##validates :wbs_activity_ratio_element_id, :organization_profile_id, :presence => true
  validates :ratio_value, :numericality => { :allow_blank => true }
end
