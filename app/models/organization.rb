#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of thewicked_pdf
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

  attr_accessible :name, :description, :is_image_organization, :disable_organization, :number_hours_per_day, :number_hours_per_month, :cost_per_hour, :currency_id, :inflation_rate,
                  :limit1, :limit2, :limit3, :limit4, :estimations_counter, :estimations_counter_history, :headband_title, :automatic_quotation_number, :support_contact,
                  :limit1_coef, :limit2_coef, :limit3_coef, :limit4_coef,
                  :limit1_unit, :limit2_unit, :limit3_unit, :limit4_unit, :allow_demand, :show_reports, :show_kpi,
                  :activate_indicators_dashboard, :activate_project_dashboard_indicators,
                  :idp_name, :idp_assertion_consumer_service_url, :idp_login_url, :idp_logout_url, :idp_change_password_url, :idp_name_identifier_format, :idp_signing_certicate, :idp_signing_certicate_fingerprint, :idp_metadata


  serialize :project_selected_columns, Array
  serialize :show_reports, Hash
  serialize :show_kpi, Hash

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
  has_many :budget_types, dependent: :destroy
  has_many :budgets, dependent: :destroy

  has_many :work_element_types, dependent: :destroy

  has_many :project_security_levels, dependent: :destroy

  # Results view
  has_many :views, dependent: :destroy
  has_many :applications, dependent: :destroy

  has_many :guw_coefficients, class_name: "Guw::GuwCoefficient", dependent: :destroy
  has_many :guw_coefficient_elements, class_name: "Guw::GuwCoefficientElement", dependent: :destroy
  has_many :guw_complexity_coefficient_elements, class_name: "Guw::GuwComplexityCoefficientElement", dependent: :destroy
  has_many :guw_output_associations, class_name: "Guw::GuwOutputAssociation", dependent: :destroy
  has_many :guw_output_complexities, class_name: "Guw::GuwOutputComplexity", dependent: :destroy
  has_many :guw_output_complexity_initializations, class_name: "Guw::GuwOutputComplexityInitialization", dependent: :destroy
  has_many :guw_output_types, class_name: "Guw::GuwOutputType", dependent: :destroy

  has_many :providers
  has_many :versions, class_name: "PaperTrail::Version", dependent: :destroy

  has_many :kpis
  has_many :indicator_dashboards

  # has_many :demands
  # has_many :demand_types
  # has_many :demand_statuses
  # has_many :livrables
  # has_many :services
  # has_many :criticalities
  # has_many :severities
  # has_many :agreements

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


  def self.get_number_precision_params(user)
    locale = user.language.locale rescue "fr"
    precision = user.number_precision.nil? ? 2 : user.number_precision
    case locale
    when "fr", "fr_smals", "fr_edf", "fr_acoss", "fral"
      delimiter = ' '
      separator = ','
    when "en", "en_smals", "en-gb", "fr_acoss"
      delimiter = ','
      separator = '.'
    else
      delimiter = ' '
      separator = ','
    end
    precision, delimiter, separator = precision, delimiter, separator
  end

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


  # Met à jour les estimations qui sont dans un statut d'historisation (en fonction de la)
  def self.update_historized_estimations_save
    Organization.all.each do |organization|
      historized_statuses = organization.estimation_statuses.where(is_historization_status: true)
      historized_status_ids = historized_statuses.map(&:id)
      organization.projects.where(estimation_status_id: historized_status_ids).each do |project|

        if project.historization_time.blank?
          project.update_attributes(historization_time: Time.now, is_historized: true)
          puts "#{project.to_s} : historisé sans date d'historisation"

        elsif project.historization_time <= Time.now
          project.update_attributes(is_historized: true)
          puts project.to_s
        end
      end
    end
  end


  #Renvoie la liste des estimations d'une organization (OrganizationEstimation (liste principale) / Project (les avec les archives))
  def self.organization_projects_list(organization_id, historized)

    if historized.present? && historized == "1"
      #@all_projects = OrganizationEstimation.where(:is_model => [nil, false], organization_id: @organization.id).where(is_historized: true)
      #class_name = Object.const_get('Project')
      all_projects = Project.unscoped.where(:is_model => [nil, false], organization_id: organization_id)
    else
      #@all_projects = OrganizationEstimation.where(:is_model => [nil, false], organization_id: @organization.id).where(is_historized: [nil, false])
      #class_name = Object.const_get('OrganizationEstimation')
      all_projects = OrganizationEstimation.unscoped.where(organization_id: organization_id)
    end

    all_projects
  end

end


