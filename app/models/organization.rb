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
#Organization of the User
class Organization < ActiveRecord::Base

  attr_accessible :name, :description, :is_image_organization, :number_hours_per_day, :number_hours_per_month, :cost_per_hour, :currency_id, :inflation_rate,
                  :limit1, :limit2, :limit3, :limit4, :estimations_counter, :estimations_counter_history, :headband_title, :automatic_quotation_number,
                  :limit1_coef, :limit2_coef, :limit3_coef, :limit4_coef,
                  :limit1_unit, :limit2_unit, :limit3_unit, :limit4_unit


  serialize :project_selected_columns, Array

  #has_and_belongs_to_many :users
  #Groups created on local, will be attached to an organization
  has_many :groups, :dependent => :destroy
  #has_many :users, through: :groups, uniq: true
  ###has_and_belongs_to_many :users   ##to comment if not working

  #For user without group
  has_many :organizations_users, class_name: 'OrganizationsUsers'
  has_many :users, through: :organizations_users

  has_many :fields, :dependent => :destroy
  has_many :wbs_activities, :dependent => :destroy
  has_many :attribute_organizations, :dependent => :delete_all
  has_many :pe_attributes, :source => :pe_attribute, :through => :attribute_organizations

  has_many :organization_technologies, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :module_projects, through: :projects

  # View
  has_many :organization_estimations

  has_many :organization_profiles, :dependent => :destroy

  #Estimations statuses
  has_many :estimation_statuses, :dependent => :destroy
  has_many :status_transitions, :through => :estimation_statuses
  has_many :estimation_status_group_roles, :through => :estimation_statuses

  #Guw Model
  has_many :operation_models, class_name: "Operation::OperationModel", dependent: :destroy
  has_many :guw_models, class_name: "Guw::GuwModel", dependent: :destroy
  has_many :ge_models, class_name: "Ge::GeModel", dependent: :destroy
  has_many :kb_models, class_name: "Kb::KbModel", dependent: :destroy
  has_many :skb_models, class_name: "Skb::SkbModel", dependent: :destroy
  has_many :expert_judgement_instances, class_name: "ExpertJudgement::Instance", dependent: :destroy
  has_many :staffing_models, class_name: "Staffing::StaffingModel", dependent: :destroy

  has_many :project_areas, dependent: :destroy
  has_many :project_categories, dependent: :destroy
  has_many :platform_categories, dependent: :destroy
  has_many :acquisition_categories, dependent: :destroy

  has_many :work_element_types, dependent: :destroy

  has_many :project_security_levels, dependent: :destroy

  # Results view
  has_many :views
  has_many :applications
  has_many :providers
  has_many :versions, class_name: "PaperTrail::Version", dependent: :destroy

  belongs_to :currency

  #validates_presence_of :name
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :number_hours_per_month, :cost_per_hour, numericality: { greater_than: 0 }   ###, on: :update, :unless => Proc.new {|organization| organization.number_hours_per_day.nil? || organization.number_hours_per_month.nil? || organization.cost_per_hour.nil? }
  validates :currency_id, :presence => true
  validates_presence_of :limit1, :limit2, :limit3
  validates :estimations_counter, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :automatic_quotation_number, format: { with: /\A\d+\z/, message: I18n.t(:only_numeric) }

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

  # Get the current user in model
  def self.current
    Thread.current[:organization]
  end
  def self.current=(organization)
    Thread.current[:organization] = organization
  end


  ## Get the organization Custom fields for QueryColumn
  #def custom_fields_query_columns
  #  custom_fields = []
  #  self.fields.each do |custom_field|
  #    custom_fields << QueryColumn.new(custom_field.name.to_sym, :sortable => "#{Field.table_name}.name", :caption => "#{custom_field.name}", :field_id => custom_field.id)
  #  end
  #  custom_fields
  #end

  # Add the amoeba gem for the copy
  # La copie des modules WBS-Activité, des Applications est gérée dans la fonction de copie
  amoeba do
    enable
    # include_association [:project_areas, :project_categories, :platform_categories, :acquisition_categories,
    #                      :work_element_types, :attribute_organizations, :organization_technologies,
    #                      :organization_profiles, :unit_of_works, :technology_size_types,
    #                      :fields, :groups, :project_security_levels,
    #                      :estimation_statuses, :guw_models, :operation_models, :kb_models, :ge_models,
    #                      :staffing_models, :expert_judgement_instances]

    exclude_association [:organizations_users, :users, :wbs_activities, :pe_attributes, :projects, :organization_estimations,
                         :module_projects, :status_transitions, :estimation_status_group_roles, :views]

    customize(lambda { |original_organization, new_organization|
      new_copy_number = original_organization.copy_number.to_i+1
      new_organization.name = "#{original_organization.name}(#{new_copy_number})" ###"Copy of '#{original_organization.name}' at #{Time.now}"
      original_organization.copy_number = new_copy_number
      new_organization.copy_number = 0
      new_organization.copy_in_progress = false
    })
  end

  #Override de destroy method, to use the Sidekiq Worker task
  #def destroy
  #  OrganizationDeleteWorker.perform_async(self.id)
  #end


  # Get organisation
  def self.get_organization_unit(v, organization)
    unless v.class == Hash
      value = v.to_f
      if value < organization.limit1.to_i
        [organization.limit1_coef.to_f, organization.limit1_unit]
      elsif value < organization.limit2.to_i
        [organization.limit2_coef.to_f, organization.limit2_unit]
      elsif value < organization.limit3.to_i
        [organization.limit3_coef.to_f, organization.limit3_unit]
      elsif value < organization.limit4.to_i
        [organization.limit4_coef.to_f, organization.limit4_unit]
      else
        [organization.limit4_coef.to_f, organization.limit4_unit]
      end
    else
      []
    end
  end

end


