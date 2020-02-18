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

class WbsActivity < ActiveRecord::Base
  attr_accessible :name, :description, :state, :organization_id, :parent_id,
                  :cost_unit, :cost_unit_coefficient, :effort_unit, :effort_unit_coefficient, :three_points_estimation, :enabled_input,
                  :organization_profile_ids, :phases_short_name_number, :hide_wbs_header, :average_rate_wording, :wbs_for_config, :use_real_profiles

  INPUT_EFFORTS_ALIAS = ["E1", "E2", "E3", "E4"]   ###["effort_1", "effort_2", "effort_3", "effort_4"]

  include AASM

  aasm :column => :state do # defaults to aasm_state
    state :draft, :initial => true
    state :defined
    state :retired
  end

  belongs_to :organization

  has_many :wbs_activity_elements, :dependent => :destroy
  has_many :wbs_activity_ratios, :dependent => :destroy
  has_many :wbs_activity_inputs, :dependent => :destroy

  has_many :pe_wbs_projects
  has_many :pbs_project_elements
  has_many :module_projects

  has_and_belongs_to_many :organization_profiles    #has_many :organization_profiles_wbs_activities    #has_many :organization_profiles, through: :organization_profiles_wbs_activities
  #has_and_belongs_to_many :wbs_organization_profiles, :class_name=>'OrganizationProfile', :join_table => "organization_profiles_wbs_activities"

  #Relation needed to delete wbs_activity_ratio_profiles when organization_profiles is unselected on WBS
  has_many :wbs_activity_ratio_elements, through: :wbs_activity_ratios
  has_many :wbs_activity_ratio_profiles, through: :wbs_activity_ratio_elements, dependent: :destroy
  #wbs-activity-ratio-variables
  has_many :wbs_activity_ratio_variables, through: :wbs_activity_ratios

  ###validates :organization_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    #include_association [:wbs_activity_ratios]
    include_association [:wbs_activity_ratios, :organization_profiles]

    customize(lambda { |original_wbs_activity, new_wbs_activity|
      #new_wbs_activity.name = "Copy_#{ original_wbs_activity.copy_number.to_i+1} of #{original_wbs_activity.name}"
      new_wbs_activity.copy_id = original_wbs_activity.id
      new_wbs_activity.copy_number = 0
      original_wbs_activity.copy_number = original_wbs_activity.copy_number.to_i+1
    })

    propagate
  end

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]
  scoped_search :in => :organization, :on => :name
  scoped_search :in => :wbs_activity_elements, :on => [:name, :description]
  scoped_search :in => :wbs_activity_ratios, :on => [:name, :description]

  def to_s(mp=nil)
    if mp.nil?
      self.name
    else
      ###"#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      "#{self.name} (#{mp.creation_order})"
    end
  end

  def root_element
    self.wbs_activity_elements.select{|i| i.is_root == true }.first
  end

  #Moulinette de mise à jour des profils de l'organisation dans les instances de Wbs-activity
  # WbsActivity.all.each do |wbs_activity|
  #   organization_profiles = wbs_activity.organization.organization_profiles
  #   organization_profiles_ids = organization_profiles.map(&:id)
  #   all_organization_profile_ids = wbs_activity.organization_profile_ids + organization_profiles_ids
  #   wbs_activity.organization_profile_ids = all_organization_profile_ids.uniq
  #   wbs_activity.save
  # end

end
