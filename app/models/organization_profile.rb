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

class OrganizationProfile < ActiveRecord::Base
  attr_accessible :cost_per_hour, :description, :name, :organization_id, :profile_id, :wbs_activity_ids, :copy_id,
                  :is_real_profile, :use_dynamic_coefficient, :associated_services, :r_value, :tm_value, :formula, :used_cost

  serialize :associated_services, Array

  default_scope { order(:name) }

  belongs_to :organization
  has_many :wbs_activity_ratio_profiles, :dependent => :delete_all
  has_and_belongs_to_many :wbs_activities   #has_many :organization_profiles_wbs_activities    #has_many :wbs_activities, through: :organization_profiles_wbs_activities
  #=== test
  ####has_and_belongs_to_many :wbs_activities_model, :class_name=>'WbsActivity', :join_table => "organization_profiles_wbs_activities"
  #=== test

  #validates :organization_id, :presence => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates :cost_per_hour, :numericality => { :allow_blank => true }

  # Add the amoeba gem for the copy
  amoeba do
    enable
    ###exclude_association [:wbs_activity_ratio_profiles, :wbs_activities]
    exclude_association [:wbs_activity_ratio_profiles, :wbs_activities]

    customize(lambda { |original_organization_profile, new_organization_profile|
      new_organization_profile.copy_id = original_organization_profile.id
    })
  end

  #Search fields
  scoped_search :on => [:name, :description]
end
