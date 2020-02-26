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

class Project < ActiveRecord::Base

  attr_accessible :title, :description, :version_number, :alias, :state, :estimation_status_id, :status_comment,
                  :start_date, :is_model, :organization_id, :project_area_id, :project_category_id,
                  :acquisition_category_id, :platform_category_id, :parent_id, :application_id, :creator_id,
                  :private, :provider_id, :request_number, :use_automatic_quotation_number, :business_need, :transaction_id,
                  :allow_export_pdf, :is_locked, :demand_id, :urgent_project, :is_valid, :historization_time, :is_historized

  attr_accessor :project_organization_statuses, :new_status_comment, :available_inline_columns

  include ActionView::Helpers
  include ActiveModel::Dirty

  has_ancestry  # For the Ancestry gem

  belongs_to :application
  has_and_belongs_to_many :applications

  belongs_to :organization
  belongs_to :project_area
  belongs_to :acquisition_category
  belongs_to :platform_category
  belongs_to :project_category
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :original_model, :class_name => 'Project', :foreign_key => 'original_model_id'
  belongs_to :estimation_status
  belongs_to :provider
  belongs_to :demand

  has_many :module_projects, :dependent => :destroy
  has_many :pemodules, :through => :module_projects
  has_many :status_histories

  has_many :views_widgets, :through => :module_projects
  has_many :project_securities, :dependent => :destroy
  has_many :project_fields, :dependent => :destroy

  has_many :projects_from_model, foreign_key: "original_model_id", class_name: "Project"

  has_and_belongs_to_many :groups

  has_many :pe_wbs_projects
  has_many :pbs_project_elements, :through => :pe_wbs_projects
  has_many :wbs_project_elements, :through => :pe_wbs_projects

  has_many :guw_unit_of_works, class_name: "Guw::GuwUnitOfWork", dependent: :destroy

  has_many :guw_model, :through => :module_projects, class_name: "Guw::GuwModel"
  has_many :guw_coefficients, :through => :guw_model, class_name: "Guw::GuwCoefficient"
  has_many :guw_attributes, :through => :guw_model, class_name: "Guw::GuwAttribute"
  has_many :guw_types, :through => :guw_unit_of_works, class_name: "Guw::GuwType"
  has_many :guw_unit_of_work_attributes, :through => :guw_unit_of_works, class_name: "Guw::GuwUnitOfWorkAttribute"
  has_many :guw_coefficient_element_unit_of_works, :through => :guw_unit_of_works, class_name: "Guw::GuwCoefficientElementUnitOfWork"

  
  default_scope { order('title ASC, version_number ASC') }

  serialize :included_wbs_activities, Array

  validates_presence_of :organization_id, :estimation_status_id, :creator_id
  validates :title, :presence => true, :uniqueness => {  :scope => [:version_number, :is_model, :organization_id], case_sensitive: false,
                                                         :message => "  #{I18n.t(:error_validation_project)} \n\n  #{I18n.t(:project_already_exist, %{value})}" }

  #Search fields
  scoped_search :on => [:title, :alias, :description, :start_date, :created_at, :updated_at]

  amoeba do
    enable
    include_association [:pe_wbs_projects, :module_projects, :project_securities, :project_fields]

    customize(lambda { |original_project, new_project|
      new_copy_number = original_project.copy_number.to_i+1
      new_project.copy_id = original_project.id
      new_project.title = "#{original_project.title}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.title}"
      new_project.alias = "#{original_project.alias}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.alias}"
      new_project.description = " #{original_project.description} \n \n  #{I18n.t(:text_project_duplication_of)} \"#{original_project.title} (#{original_project.alias}) - #{original_project.version_number}\" "
      new_project.copy_number = 0
      original_project.copy_number = new_copy_number
    })

    propagate
  end

  # Security Audit management
  #before_save :update_associations_for_triggers

  # get the selectable/available inline columns
  class_attribute :available_inline_columns
  self.available_inline_columns =
    [
      QueryColumn.new(:title, :sortable => "#{Project.table_name}.title", :caption => "label_project_name"),
      QueryColumn.new(:request_number, :sortable => "#{Project.table_name}.request_number", :caption => "request_number"),
      QueryColumn.new(:business_need, :sortable => "#{Project.table_name}.business_need", :caption => "business_need"),
      QueryColumn.new(:application, :sortable => "#{Application.table_name}.name", :caption => "application"),
      QueryColumn.new(:original_model, :sortable => "#{Project.table_name}.name", :caption => "original_model"),
      QueryColumn.new(:version_number, :sortable => "#{Project.table_name}.version_number", :caption => "label_version"),
      QueryColumn.new(:status_name, :sortable => "#{EstimationStatus.table_name}.name", :caption => "state"),
      QueryColumn.new(:project_area, :sortable => "#{ProjectArea.table_name}.name", :caption => "project_area"),
      QueryColumn.new(:project_category, :sortable => "#{ProjectCategory.table_name}.name", :caption => "category"),
      QueryColumn.new(:acquisition_category, :sortable => "#{AcquisitionCategory.table_name}.name", :caption => "label_acquisition"),
      QueryColumn.new(:platform_category, :sortable => "#{PlatformCategory.table_name}.name", :caption => "label_platform"),
      QueryColumn.new(:provider, :sortable => "#{Provider.table_name}.name", :caption => "provider"),
      QueryColumn.new(:description, :sortable => "#{Project.table_name}.description", :caption => "description"),
      QueryColumn.new(:start_date, :sortable => "#{Project.table_name}.start_date", :caption => "label_start_date"),
      QueryColumn.new(:creator, :sortable => "#{User.table_name}.first_name", :caption => "author"),
      QueryColumn.new(:created_at, :sortable => "#{Project.table_name}.created_at", :caption => "created_at"),
      QueryColumn.new(:updated_at, :sortable => "#{Project.table_name}.updated_at", :caption => "updated_at"),
      QueryColumn.new(:private, :sortable => "#{Project.table_name}.private", :caption => "private_estimation"),
      QueryColumn.new(:urgent_project, :sortable => "#{Project.table_name}.urgent_project", :caption => "urgent_project")
    ]

  class_attribute :default_selected_columns
  self.default_selected_columns = ["application", "version_number", "start_date", "status_name", "description"]

  before_save :update_historization_time
  after_save :reload_cache_archived

  def update_historization_time
    project_estimation_status = self.estimation_status

    # On met à jour la date d'historisation de l'estimation
    if project_estimation_status.is_historization_status == true
      self.historization_time = project_estimation_status.nb_day_before_historization.to_f.days.from_now
    end
  end


  def reload_cache_archived
    key = "not_archived_#{self.organization_id}"
    #archived_status = EstimationStatus.where(is_archive_status: true, organization_id: self.organization_id).first
    #historization_status = EstimationStatus.where(is_historization_status: true, organization_id: self.organization_id).first

    Rails.cache.fetch(key, force: true) do
      # Project.get_unarchived_project_ids(archived_status, self.organization_id)
    end
  end


  def self.get_unarchived_project_ids(archived_status, organization_id)

    @organization = Organization.find(organization_id)

    if archived_status.nil?
      # Project.where(organization_id: organization_id).pluck(:id)
      project_ids = @organization.organization_estimations.pluck(:id)
    else
      # Project
      #     .where(organization_id: organization_id)
      #     .where("estimation_status_id != ?", archived_status.id)
      #     .pluck(:id)
      project_ids = @organization.organization_estimations.pluck(:id)
    end
  end

  def self.selectable_inline_columns
    [
      [I18n.t(:label_product_name), "application"], [I18n.t(:label_project_name), "title"], [I18n.t(:label_version),"version_number"],
      [I18n.t(:state), "estimation_status_id"], [ I18n.t(:project_area), "project_area_id"], [I18n.t(:category), "project_category_id"],
      [I18n.t(:label_acquisition), "acquisition_category_id"], [I18n.t(:label_platform), "platform_category_id"], [I18n.t(:description), "description"],
      [I18n.t(:start_date), "start_date"], [I18n.t(:author), "creator_id"], [I18n.t(:created_at), "created_at"], [I18n.t(:updated_at), "updated_at"]
    ]
  end

  #Get the project's WBS-Activity
  def project_wbs_activity
    project_wbs_activity = nil
    # Project pe_wbs_activity
    pe_wbs_activity = self.pe_wbs_projects.activities_wbs.first
    # Get the wbs_project_element which contain the wbs_activity_ratio
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
    # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
    wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first
    if wbs_project_elt_with_ratio
      project_wbs_activity = wbs_project_elt_with_ratio.wbs_activity  # Select only Wbs-Activities affected to current project's organization
    end
    project_wbs_activity
  end

  #  Estimation status name
  def status_name
    self.estimation_status.nil? ? nil : self.estimation_status.name
  end

  def author
    self.creator_id.nil? ? "" : self.creator
  end

  # The status background color for estimations list
  def status_background_color
    self.estimation_status.nil? ? "#999999" : "##{self.estimation_status.status_color}"
  end

  # Estimation statuses possible transitions according to the project status
  def project_estimation_statuses(organization=nil)
    if new_record? || self.estimation_status.nil? #|| !self.organization.estimation_statuses.include?(self.estimation_status)
      # For new record
      if organization.nil?
        nil
      else
        initial_status = organization.estimation_statuses.first_or_create(organization_id: organization.id,
                                                                          status_number: 0,
                                                                          status_alias: 'preliminary',
                                                                          name: 'Préliminaire',
                                                                          status_color: 'F5FFFD')
        [[initial_status.name, initial_status.id]]
      end
      #nil
    else
      estimation_statuses = self.estimation_status.to_transition_statuses
      estimation_statuses << self.estimation_status
      estimation_statuses = estimation_statuses.uniq
      # estimation_statuses.uniq.sort{|s1, s2| s1 <=> s2 }
    end
  end

  def get_project_organization_statuses
    self.project_organization_statuses = self.organization.estimation_statuses

    initial_state = EstimationStatus.order(:status_number).first

    # Define existing estimation_status as aasm_state
    self.project_organization_statuses.all.each do |status|
      #aasm.state status.status_alias.to_sym
      aasm  do # defaults to aasm_state
        state status.status_alias.to_sym

        # Workflow definition for the commit event   # Redesign the 'commit' event AASM workflow with the estimation_statuses workflow
        event :commit do
          # generate workflow according to the defining workflow in organizations
          StatusTransition.all.each do |status_transition|
            to_transition_status = EstimationStatus.find(status_transition.to_transition_status_id)
            from_transitions = to_transition_status.from_transition_statuses.map(&:status_alias).map(&:to_sym)

            transitions :from => from_transitions, :to => to_transition_status.status_alias.to_sym
          end
        end
      end
    end
  end

  def self.encoding
    ['Big5', 'CP874', 'CP932', 'CP949', 'gb18030', 'ISO-8859-1', 'ISO-8859-13', 'ISO-8859-15', 'ISO-8859-2', 'ISO-8859-8', 'ISO-8859-9', 'UTF-8', 'Windows-874']
  end

  #Return the root pbs_project_element of the pe-wbs-project and consequently of the project.
  def root_component
    self.pe_wbs_projects.products_wbs.first.pbs_project_elements.select { |i| i.is_root = true }.first unless self.pe_wbs_projects.products_wbs.first.nil?
  end

  def wbs_project_element_root
    self.pe_wbs_projects.activities_wbs.first.wbs_project_elements.select { |i| i.is_root = true }.first unless self.pe_wbs_projects.activities_wbs.first.nil?
  end

  #Override
  def to_s
    "#{self.nil? ? '' : self.title} - #{self.nil? ? '' : self.version_number}"
  end

  # Obtenir le prochain statut d'une estimation
  def get_next_status_for_commit
    #Get the project's current status
    current_status = self.estimation_status
    current_status_number = current_status.status_number
    # According to the status transitions map, only possible statuses will consider
    possible_statuses = self.project_estimation_statuses.map(&:status_number).sort #self.estimation_status.to_transition_statuses.map(&:status_number).uniq.sort
    current_status_index = possible_statuses.index(current_status_number)
    # By default the first possible status is candidate
    next_status_number = possible_statuses.first
    # If the current status is not the last element of the array, the next status is next element after the current status
    if current_status_number != possible_statuses.last
      next_status_number = possible_statuses[current_status_index+1]
    end

    # Get the next status
    next_status = self.organization.estimation_statuses.find_by_status_number(next_status_number)
  end

  # Change project status according to the project's organization estimation statuses
  def commit_status
    begin
      # Get the next status
      next_status = self.get_next_status_for_commit

      if next_status.create_new_version_when_changing_status == true
        self.create_new_version_when_changing_status(next_status)
      else
        self.update_attribute(:estimation_status_id, next_status.id)
      end
    rescue
      # ignored
    end
  end


  def create_new_version_when_changing_status(next_status, new_version_number=nil)
    current_user = User.find(User.current) rescue nil
    last_estimation_status_name = self.estimation_status_id.nil? ? "" : self.estimation_status.name

    if new_version_number.blank?
      new_version_number = self.set_next_project_version
    end
    if next_status.blank?
      next_status = self.get_next_status_for_commit
    end

    # Si un statut d'accueil des anciennes version est défini, on archive toutes les anciennes version
    archive_status = self.organization.estimation_statuses.where(is_archive_status: true).first
    automatic_change_old_versions = archive_status.nil? ? "no" : "yes"

    # On cree la nouvelle version
    new_project_version = self.checkout_project_base(current_user, self.description, new_version_number, automatic_change_old_versions)
    new_estimation_status_name = next_status.nil? ? "" : next_status.name

    # Puis on lui change de statut
    new_comments_for_version = "#{I18n.l(Time.now)} : #{I18n.t(:text_automatic_created_version)}  \r\n" + "#{I18n.t(:change_estimation_status_from_to, from_status: last_estimation_status_name, to_status: new_estimation_status_name, current_user_name: current_user.name)}. \r\n"  + "___________________________________________________________________________\r\n" + self.status_comment
    new_project_version.update_attributes(estimation_status_id: next_status.id, status_comment: new_comments_for_version)
    new_project_version
  end

  #Function that check the couples (title,version_number) and (alias, version_number) availability
  def is_project_version_available?(parent_title, parent_alias, new_version)
    begin
      #No authorize required
      project = Project.where('(title=? AND version_number=?) OR (alias=? AND version_number=?)', parent_title, new_version, parent_alias, new_version).first
      if project
        false
      else
        true
      end
    rescue
      false
    end
  end

  # Récupérer le prochain numéro de version
  # Set the new checked-outed project version_number
  def set_next_project_version
    project_to_checkout = self

    #No authorize is required as method is private and could not be accessed by any route
    parent_version = project_to_checkout.version_number

    # The new version_number number is calculated according to the parent project position (if parent project has children or not)
    if project_to_checkout.is_childless?
      # get the version_number last numerical value
      version_ended = parent_version.split(/(\d\d*)$/).last

      #Test if ended version_number value is a Integer
      if version_ended.valid_integer?
        new_version_ended = "#{ version_ended.to_i + 1 }"
        new_version = parent_version.gsub(/(\d\d*)$/, new_version_ended)
      else
        new_version = "#{ version_ended }.1"
      end
    else
      #That means project has successor(s)/children, and a new branch need to be created
      branch_version = 1
      parent_version_ended_end = 0
      if parent_version.include?('-')
        split_parent_version = parent_version.split('-')
        branch_name = split_parent_version.first
        parent_version_ended = split_parent_version.last

        split_parent_version_ended = parent_version_ended.split('.')

        parent_version_ended_begin = split_parent_version_ended.first
        parent_version_ended_end = split_parent_version_ended.last

        branch_version = parent_version_ended_begin.to_i + 1

        #new_version = parent_version.gsub(/(-.*)/, "-#{branch_version}")

        new_version = "#{branch_name}-#{branch_version}.#{parent_version_ended_end}"
      else
        branch_name = parent_version
        new_version = "#{branch_name}-#{branch_version}.0"
      end

      # If new_version is not available, then check for new available version_number
      until is_project_version_available?(project_to_checkout.title, project_to_checkout.alias, new_version)
        branch_version = branch_version+1
        new_version = "#{branch_name}-#{branch_version}.#{parent_version_ended_end}"
      end
    end
    new_version
  end


  #Update new project/estimation views and widgets
  def update_project_views_and_widgets(old_mp, new_mp)

    new_prj = self
    organization_id = new_prj.organization_id

    #We have to copy all the selected view's widgets in a new view for the current module_project
    if old_mp.view
      #Copy the views and widgets for the new project
      new_view = View.new(organization_id: organization_id, pemodule_id: new_mp.pemodule_id , name: "#{new_prj} :  #{new_mp}", description: "")

      if new_view.save
        old_mp_view_widgets = old_mp.view.views_widgets.all
        old_mp_view_widgets.each do |old_view_widget|
          new_view_widget_mp = ModuleProject.where(organization_id: organization_id,
                                                   project_id: new_prj.id,
                                                   copy_id: old_view_widget.module_project_id).first

          new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
          widget_est_val = old_view_widget.estimation_value
          if old_view_widget.is_kpi_widget || widget_est_val.nil?
            # Vignette Commentaires et Vignette KPI
            new_view_widget = ViewsWidget.new(view_id: new_view.id,
                                              module_project_id: new_view_widget_mp_id,
                                              name: old_view_widget.name,
                                              show_name: old_view_widget.show_name,
                                              show_tjm: old_view_widget.show_tjm,
                                              is_label_widget: old_view_widget.is_label_widget,
                                              comment: old_view_widget.comment,
                                              is_kpi_widget: old_view_widget.is_kpi_widget,
                                              kpi_unit: old_view_widget.kpi_unit,
                                              equation: old_view_widget.equation,
                                              is_project_data_widget: old_view_widget.is_project_data_widget,
                                              project_attribute_name: old_view_widget.project_attribute_name,
                                              icon_class: old_view_widget.icon_class,
                                              color: old_view_widget.color,
                                              show_min_max: old_view_widget.show_min_max,
                                              widget_type: old_view_widget.widget_type,
                                              width: old_view_widget.width,
                                              height: old_view_widget.height,
                                              position: old_view_widget.position,
                                              position_x: old_view_widget.position_x,
                                              min_value: old_view_widget.min_value,
                                              max_value: old_view_widget.max_value,
                                              validation_text: old_view_widget.validation_text,
                                              position_y: old_view_widget.position_y)

            #Update KPI Widget aquation
            ["A", "B", "C", "D", "E"].each do |letter|
              unless old_view_widget.equation[letter].nil?

                new_array = []
                est_val_id = old_view_widget.equation[letter].first
                mp_id = old_view_widget.equation[letter].last

                begin
                  new_mpr = new_prj.module_projects.where(organization_id: organization_id, copy_id: mp_id).first
                  new_mpr_id = new_mpr.id
                  begin
                    new_est_val_id = new_mpr.estimation_values.where(organization_id: organization_id, copy_id: est_val_id).first.id
                  rescue
                    new_est_val_id = nil
                  end
                rescue
                  new_mpr_id = nil
                end

                new_array << new_est_val_id
                new_array << new_mpr_id

                new_view_widget.equation[letter] = new_array
              end
            end

            #new_view_widget.save
            if new_view_widget.save
              #Update the copied project_fields
              pf = ProjectField.where(project_id: new_prj.id, views_widget_id: old_view_widget.id).first
              unless pf.nil?
                pf.views_widget_id = new_view_widget.id
                pf.save
              end
            end
          else
            in_out = widget_est_val.in_out
            widget_pe_attribute_id = widget_est_val.pe_attribute_id
            unless new_view_widget_mp.nil?
              new_estimation_value = new_view_widget_mp.estimation_values.where(organization_id: organization_id, pe_attribute_id: widget_pe_attribute_id , in_out: in_out).last
              estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id

              new_view_widget = ViewsWidget.new(view_id: new_view.id,
                                                module_project_id: new_view_widget_mp_id,
                                                estimation_value_id: estimation_value_id,
                                                name: old_view_widget.name,
                                                show_name: old_view_widget.show_name,
                                                show_tjm: old_view_widget.show_tjm,
                                                show_wbs_activity_ratio: old_view_widget.show_wbs_activity_ratio,
                                                is_label_widget: old_view_widget.is_label_widget,
                                                comment: old_view_widget.comment,
                                                is_kpi_widget: old_view_widget.is_kpi_widget,
                                                kpi_unit: old_view_widget.kpi_unit,
                                                equation: old_view_widget.equation,
                                                is_project_data_widget: old_view_widget.is_project_data_widget,
                                                project_attribute_name: old_view_widget.project_attribute_name,
                                                icon_class: old_view_widget.icon_class,
                                                color: old_view_widget.color,
                                                show_min_max: old_view_widget.show_min_max,
                                                widget_type: old_view_widget.widget_type,
                                                use_organization_effort_unit: old_view_widget.use_organization_effort_unit,
                                                width: old_view_widget.width,
                                                height: old_view_widget.height,
                                                position: old_view_widget.position,
                                                position_x: old_view_widget.position_x,
                                                position_y: old_view_widget.position_y,
                                                min_value: old_view_widget.min_value,
                                                max_value: old_view_widget.max_value,
                                                validation_text: old_view_widget.validation_text)
              if new_view_widget.save
                #Update the copied project_fields
                pf = ProjectField.where(project_id: new_prj.id, views_widget_id: old_view_widget.id).first
                unless pf.nil?
                  pf.views_widget_id = new_view_widget.id
                  pf.save
                end
              end
            end
          end

        end
        #update the new module_project view
        new_mp.update_attribute(:view_id, new_view.id)
      end
    end
    ###end
  end

  def checkout_project_base(current_user, description, version_number=nil, archive_last_project_version="no", new_project_version="no")
    old_prj = self
    organization = old_prj.organization

    #begin
      old_prj_copy_number = old_prj.copy_number

      #old_prj_pe_wbs_product_name = old_prj.pe_wbs_projects.products_wbs.first.name
      #old_prj_pe_wbs_activity_name = old_prj.pe_wbs_projects.activities_wbs.first.name

      new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
      old_prj.copy_number = old_prj_copy_number

      new_prj.title = old_prj.title
      new_prj.alias = old_prj.alias
      new_prj.description = description
      new_prj.parent_id = old_prj.id
      new_prj.creator_id = current_user.id rescue nil

      # On met à jour ce champs pour la gestion des Trigger
      new_prj.is_new_created_record = true

      new_prj.version_number = version_number

      new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_version_from_to, from_version: old_prj.version_number, to_version: new_prj.version_number, current_user_name: (current_user.name rescue nil))}. \r\n"

      # Copier la zone de commentaire de l'ancienne version
      new_prj.status_comment << "___________________________________________________________________________"
      new_prj.status_comment << "\r\n #{old_prj.status_comment} \r\n"

      # Faire le changement de statut
      StatusHistory.create(organization: new_prj.organization.name,
                           project_id: new_prj.id,
                           project: new_prj.title,
                           old_version_number: old_prj.version_number,
                           new_version_number: new_prj.version_number,
                           change_date: Time.now,
                           action: "Changement de version",
                           comments: nil,
                           origin: nil,
                           target: nil,
                           user: current_user.name,
                           gap: nil)

      new_prj.transaction do

        if new_prj.save
          old_prj.save #Original project copy number will be incremented to 1

          #Managing the component tree : PBS
          pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first
          pe_wbs_product.save(validate: false)

          # For PBS
          new_prj_components = pe_wbs_product.pbs_project_elements
          new_prj_components.each do |new_c|
            unless new_c.is_root?
              new_ancestor_ids_list = []
              new_c.ancestor_ids.each do |ancestor_id|
                ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
                new_ancestor_ids_list.push(ancestor_id)
              end
              new_c.ancestry = new_ancestor_ids_list.join('/')
              new_c.save(validate: false)
            end
          end


          hash_apps = {}
          organization.applications.each do |app|
            hash_apps[app.name] = app
          end

          #For applications
          old_prj.applications.where(organization_id: organization.id).each do |application|
            # Application.where(name: application.name, organization_id: @organization.id).first
            app = hash_apps[application.name]
            ApplicationsProjects.create(application_id: app.id, project_id: new_prj.id)
          end

          # For ModuleProject associations
          old_prj.module_projects.where(organization_id: organization.id).group(:id).each do |old_mp|
            new_mp = ModuleProject.where(organization_id: organization.id, project_id: new_prj.id, copy_id: old_mp.id).first  #.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

            # ModuleProject Associations for the new project
            old_mp.associated_module_projects.each do |associated_mp|
              new_associated_mp = ModuleProject.where(organization_id: organization.id, project_id: new_prj.id, copy_id: associated_mp.id).first
              new_mp.associated_module_projects << new_associated_mp
            end

            ### Wbs activity
            #create module_project ratio elements
            old_mp.module_project_ratio_elements.where(organization_id: organization.id).each do |old_mp_ratio_elt|

              mp_ratio_element = old_mp_ratio_elt.dup
              mp_ratio_element.module_project_id = new_mp.id
              mp_ratio_element.copy_id = old_mp_ratio_elt.id

              pbs = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first
              unless pbs.nil?
                mp_ratio_element.pbs_project_element_id = pbs.id
              end

              mp_ratio_element.save
            end

            new_mp_ratio_elements = new_mp.module_project_ratio_elements.where(organization_id: organization.id)
            new_mp_ratio_elements.each do |mp_ratio_element|

              #unless mp_ratio_element.is_root?
              new_ancestor_ids_list = []
              mp_ratio_element.ancestor_ids.each do |ancestor_id|
                ancestor = new_mp_ratio_elements.where(copy_id: ancestor_id).first
                if ancestor
                  ancestor_id = ancestor.id
                  new_ancestor_ids_list.push(ancestor_id)
                end
              end
              mp_ratio_element.ancestry = new_ancestor_ids_list.join('/')
              #end
              mp_ratio_element.save
            end
            ### End wbs_activity

            # For SKB-Input
            old_mp.skb_inputs.each do |skbi|
              Skb::SkbInput.create(data: skbi.data, processing: skbi.processing, retained_size: skbi.retained_size,
                                   organization_id: organization.id, module_project_id: new_mp.id)
            end

            #For ge_model_factor_descriptions
            old_mp.ge_model_factor_descriptions.each do |factor_description|
              Ge::GeModelFactorDescription.create(ge_model_id: factor_description.ge_model_id, ge_factor_id: factor_description.ge_factor_id,
                                                  factor_alias: factor_description.factor_alias, description: factor_description.description,
                                                  module_project_id: new_mp.id, project_id: new_prj.id, organization_id: organization.id)
            end

            # if the module_project is nil
            unless old_mp.view.nil?
              #Update the new project/estimation views and widgets
              new_prj.update_project_views_and_widgets(old_mp, new_mp)
            end


            #Update the Unit of works's groups
            new_mp.guw_unit_of_work_groups.each do |guw_group|
              new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
              new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
              guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id,
                                          project_id: new_prj.id,
                                          guw_model_id: old_mp.guw_model_id,
                                          organization_id: new_prj.organization_id)

              # Update the group unit of works and attributes
              guw_group.guw_unit_of_works.each do |guw_uow|
                new_uow_mp = ModuleProject.where(organization_id: organization.id, project_id: new_prj.id, copy_id: guw_uow.module_project_id).first  #.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
                new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

                new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
                new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
                guw_uow.update_attributes(module_project_id: new_uow_mp_id,
                                          pbs_project_element_id: new_pbs_id,
                                          organization_id: new_prj.organization_id,
                                          project_id: new_prj.id)

                # copy des coefficient-elements-unit-of-works
                guw_uow.guw_coefficient_element_unit_of_works.each do |new_guw_coeff_elt_uow|
                  unless new_guw_coeff_elt_uow.nil?
                    new_guw_coeff_elt_uow.guw_unit_of_work_id = guw_uow.id
                    new_guw_coeff_elt_uow.module_project_id = new_mp.id
                    new_guw_coeff_elt_uow.guw_model_id = old_mp.guw_model_id
                    new_guw_coeff_elt_uow.project_id = new_prj.id
                    new_guw_coeff_elt_uow.save
                  end
                end

              end
            end

            new_mp_pemodule_pe_attributes = new_mp.pemodule.pe_attributes
            old_prj_pbs_project_elements = old_prj.pbs_project_elements
            new_mp_estimation_values = new_mp.estimation_values.where(organization_id: organization.id)
            hash_nmpevs = {}

            new_mp_estimation_values.where(pe_attribute_id: new_mp_pemodule_pe_attributes.map(&:id), in_out: ["input", "output"]).each do |nmpev|
              hash_nmpevs["#{nmpev.pe_attribute_id}_#{nmpev.in_out}"] = nmpev
            end

            ["input", "output"].each do |io|
              new_mp_pemodule_pe_attributes.each do |attr|
                old_prj_pbs_project_elements.each do |old_component|
                  new_prj_components.each do |new_component|
                    ev = hash_nmpevs["#{attr.id}_#{io}"]

                    unless ev.nil?
                      ev_low = ev.string_data_low.delete(old_component.id)
                      ev_most_likely = ev.string_data_most_likely.delete(old_component.id)
                      ev_high = ev.string_data_high.delete(old_component.id)
                      ev_probable = ev.string_data_probable.delete(old_component.id)

                      ev.string_data_low[new_component.id.to_i] = ev_low
                      ev.string_data_most_likely[new_component.id.to_i] = ev_most_likely
                      ev.string_data_high[new_component.id.to_i] = ev_high
                      ev.string_data_probable[new_component.id.to_i] = ev_probable

                      # update ev attribute links
                      unless ev.estimation_value_id.nil?
                        project_id = new_prj.id
                        new_evs = EstimationValue.where(copy_id: ev.estimation_value_id).all
                        new_ev = new_evs.select { |est_v| est_v.module_project.project_id == project_id}.first
                        if new_ev
                          ev.estimation_value_id = new_ev.id
                        end
                      end
                      ev.save
                    end
                  end
                end
              end
            end
          end

          #Archive project last versions
          if archive_last_project_version == "yes"
            #get last versions of the projects
            project_ancestors = new_prj.ancestors
            unless project_ancestors.empty? || project_ancestors.nil?
              #Get the archive status of the project's organization
              archive_status = new_prj.organization.estimation_statuses.where(is_archive_status: true).first
              if archive_status
                old_version = old_prj.version_number
                project_ancestors.each do |ancestor|
                  ancestor.update_attribute(:estimation_status_id, archive_status.id)
                  ancestor.status_comment = "#{I18n.l(Time.now)} - #{I18n.t(:text_automatic_changed_status)}  #{old_version} #{I18n.t(:to)} #{new_prj.version_number} #{I18n.t(:by)} #{current_user.name rescue nil}. #{I18n.t(:text_new_status)} : #{archive_status.name} \r ___________________________________________________________________________\r\n" + ancestor.status_comment
                  ancestor.save
                end
              end
            end
          end

          #New project last versions
          if new_project_version == "yes"
            #get last versions of the projects
            #Get the archive status of the project's organization
            new_status = new_prj.organization.estimation_statuses.where(is_new_status: true).first
            if new_status
              old_version = old_prj.version_number
              new_prj.update_attribute(:estimation_status_id, new_status.id)
              new_prj.status_comment = "#{I18n.l(Time.now)} - #{I18n.t(:text_automatic_changed_status)}  #{old_version} #{I18n.t(:to)} #{new_prj.version_number} #{I18n.t(:by)} #{current_user.name rescue nil}. #{I18n.t(:text_new_status)} : #{new_status.name}\r ___________________________________________________________________________\r\n" + new_prj.status_comment
              new_prj.save
            end
          end
        end
      end

      new_prj
    # rescue
    #   nil
    # end
  end

  # Sauvegarde avant la tâche sur la creation de version automatique lors du changement de statut
  # def commit_status_SAVE_13_02_2018
  #   #Get the project's current status
  #   current_status_number = self.estimation_status.status_number
  #   # According to the status transitions map, only possible statuses will consider
  #   possible_statuses = self.project_estimation_statuses(self.organization).map(&:status_number).sort #self.estimation_status.to_transition_statuses.map(&:status_number).uniq.sort
  #   current_status_index = possible_statuses.index(current_status_number)
  #   # By default the first possible status is candidate
  #   next_status_number = possible_statuses.first
  #   # If the current status is not the last element of the array, the next status is next element after the current status
  #   if current_status_number != possible_statuses.last
  #     next_status_number = possible_statuses[current_status_index+1]
  #   end
  #
  #   begin
  #     # Get the next status
  #     next_status = self.organization.estimation_statuses.find_by_status_number(next_status_number)
  #     self.update_attribute(:estimation_status_id, next_status.id)
  #   rescue
  #     # ignored
  #   end
  # end

  #Return project value
  def project_value(attr)
    self.send(attr.project_value.gsub('_id', ''))
  end

  def self.table_search(search)
    if search
      where('title LIKE ? or alias LIKE ? or state LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      scoped
    end
  end

  #Estimation plan o project is locked or not?
  def locked?
    # (self.is_historicized.nil? or self.is_historicized == true) ? true : false
    false
  end

  def in_frozen_status?
    (self.state.in?(%w(rejected released checkpoint))) ? true : false
  end


  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      #{:id => node.id.to_s, :name => node.title, :title => node.title, :version_number => node.version_number, :data => {}, :children => json_tree(sub_nodes).compact}
      #{id: node.id.to_s, name: node.title, title: node.title, version_number: node.version_number, data: {}, children: json_tree(sub_nodes).compact}
      {:id => node.id.to_s, :name => node.version_number, :data => {:title => node.title, :version_number => node.version_number, :state => node.status_name.to_s}, :children => json_tree(sub_nodes).compact}
    end
  end

  # private
  # def update_associations_for_triggers
  #   ApplicationController.helpers.save_associations_event_changes(self)
  #   #puts self.changed?
  # end


  ###   APPEND PEMODULE
  #Allow o add or append a pemodule to a estimation process
  def self.append_pemodule(project_id, pbs_project_element_id, module_selected)

    @project = Project.find(project_id)
    @organization = @project.organization
    @pemodule = Pemodule.find(module_selected.split(',').last.to_i)

    # if @project.is_model
    #   authorize! :manage_estimation_models, Project
    # else
    #   authorize! :alter_estimation_plan, @project
    # end

    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.where(organization_id: @organization.id, pemodule_id: @initialization_module.id).first #.find_by_pemodule_id(@initialization_module.id)

    if pbs_project_element_id && pbs_project_element_id != ''
      @pbs_project_element = PbsProjectElement.find(pbs_project_element_id)
    else
      @pbs_project_element = @project.root_component
    end

    my_module_project = nil

    unless @pemodule.nil? || @project.nil?
      @array_modules = Pemodule.all
      @pemodules ||= Pemodule.all

      #Max pos or 1
      @module_positions = ModuleProject.where(organization_id: @organization.id, :project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(organization_id: @organization.id, :project_id => @project.id).all.map(&:position_x).uniq.max

      # Get the module_project creation order : for this, we have to count the number of MP with same pemodule in this project
      mp_creation_order = @project.module_projects.where(organization_id: @organization.id, pemodule_id: @pemodule.id).all.map(&:creation_order).max

      #When adding a module in the "timeline", it creates an entry in the table ModuleProject for the current project, at position 2 (the one being reserved for the input module).
      my_module_project = ModuleProject.new(:project_id => @project.id, :organization_id => @organization.id, :pemodule_id => @pemodule.id,
                                            :position_y => 1, :position_x => @module_positions_x.to_i + 1,
                                            :top_position => 100, :left_position => 600, :creation_order => mp_creation_order.to_i+1)
      my_module_project.save

      #si le module est un module generic on l'associe le module project
      if @pemodule.alias == "guw"
        my_module_project.guw_model_id = module_selected.split(',').first
      elsif @pemodule.alias == "kb"
        kb_model_id = module_selected.split(',').first.to_i
        my_module_project.kb_model_id = kb_model_id
        Kb::KbInput.create( organization_id: @current_organization.id,
                            module_project_id: my_module_project.id,
                            kb_model_id: kb_model_id)
      elsif @pemodule.alias == "skb"
        skb_model_id = module_selected.split(',').first.to_i
        my_module_project.skb_model_id = skb_model_id
        Skb::SkbInput.create( organization_id: @current_organization.id,
                              module_project_id: my_module_project.id,
                              skb_model_id: skb_model_id)
      elsif @pemodule.alias == "ge"
        my_module_project.ge_model_id = module_selected.split(',').first

      elsif @pemodule.alias == "operation"
        my_module_project.operation_model_id = module_selected.split(',').first

      elsif @pemodule.alias == "staffing"
        staffing_model_id = module_selected.split(',').first.to_i
        my_module_project.staffing_model_id = staffing_model_id
        staffing_model = Staffing::StaffingModel.find(staffing_model_id)
        #Then create an staffing_custom_data object for current module_project
        Staffing::StaffingCustomDatum.create( staffing_model_id: staffing_model_id,
                                              module_project_id: my_module_project.id,
                                              pbs_project_element_id: @pbs_project_element.id,
                                              staffing_method: 'trapeze',
                                              period_unit: 'week',
                                              global_effort_type: 'probable',
                                              mc_donell_coef: 6,
                                              puissance_n: 0.33,
                                              trapeze_parameter_values: staffing_model.trapeze_default_values)

      elsif @pemodule.alias == "effort_breakdown"
        wbs_id = module_selected.split(',').first.to_i
        my_module_project.wbs_activity_id = wbs_id

        my_module_project.wbs_activity.wbs_activity_ratios.each do |ratio|
          ratio_wai = WbsActivityInput.new(module_project_id: my_module_project.id,
                                           wbs_activity_id: wbs_id, wbs_activity_ratio_id: ratio.id,
                                           pbs_project_element_id: @pbs_project_element.id)
          ratio_wai.save
        end


        my_module_project.wbs_activity_inputs.first

        #create module_project ratio elements
        my_module_project.wbs_activity.wbs_activity_ratios.each do |ratio|

          # create the module_project_ratio_variable
          ratio.wbs_activity_ratio_variables.each do |ratio_variable|
            mp_ratio_variable = ModuleProjectRatioVariable.new(pbs_project_element_id: @pbs_project_element.id, module_project_id: my_module_project.id,
                                                               organization_id: @organization.id, wbs_activity_id: my_module_project.wbs_activity_id,
                                                               wbs_activity_ratio_id: ratio.id, wbs_activity_ratio_variable_id: ratio_variable.id,
                                                               name: ratio_variable.name, description: ratio_variable.description,
                                                               percentage_of_input: ratio_variable.percentage_of_input, is_modifiable: ratio_variable.is_modifiable,
                                                               is_used_in_ratio_calculation: ratio_variable.is_used_in_ratio_calculation)
            mp_ratio_variable.save
          end


          # create the module_project_ratio_elements
          ratio.wbs_activity_ratio_elements.each do |ratio_element|
            mp_ratio_element = ModuleProjectRatioElement.new(organization_id: @organization.id,
                                                             wbs_activity_id: my_module_project.wbs_activity_id,
                                                             pbs_project_element_id: @pbs_project_element.id,
                                                             module_project_id: my_module_project.id,
                                                             wbs_activity_ratio_id: ratio.id,
                                                             wbs_activity_ratio_element_id: ratio_element.id,
                                                             wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                                             multiple_references: ratio_element.multiple_references, name: ratio_element.wbs_activity_element.name,
                                                             description: ratio_element.wbs_activity_element.description, selected: true, is_optional: ratio_element.is_optional,
                                                             ratio_value: ratio_element.ratio_value, position: ratio_element.wbs_activity_element.position)
            mp_ratio_element.save
          end
          #Update module_project_ratio_element ancestry
          #current_ratio_mp_ratio_elements = my_module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio.id, pbs_project_element_id: @pbs_project_element.id)
          current_ratio_mp_ratio_elements = my_module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio.id)
          my_module_project.wbs_activity.wbs_activity_elements.each do |activity_elt|
            activity_elt_ancestor_ids = activity_elt.ancestor_ids
            unless activity_elt.is_root?
              new_ancestor_ids_list = []
              activity_elt_ancestor_ids.each do |ancestor_id|
                ancestor = current_ratio_mp_ratio_elements.where(wbs_activity_element_id: ancestor_id).first
                unless ancestor.nil?
                  new_ancestor_ids_list.push(ancestor.id)
                end
              end
              new_ancestry = new_ancestor_ids_list.join('/')
              mp_ratio_elements = current_ratio_mp_ratio_elements.where(wbs_activity_element_id: activity_elt.id)
              unless mp_ratio_elements.nil?
                mp_ratio_elements.update_all(ancestry: new_ancestry)
              end
            end
          end
        end

      elsif @pemodule.alias == "expert_judgement"
        eji_id = module_selected.split(',').first
        my_module_project.expert_judgement_instance_id = eji_id.to_i
      end

      my_module_project.save


      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max

      if @pemodule.alias.in?(["guw", "operation"])
        #guw_model = Guw::GuwModel.find(my_module_project.guw_model_id)
        #guw_outputs = guw_model.guw_outputs

        all_attribute_modules = my_module_project.pemodule.attribute_modules

        case @pemodule.alias
          when "guw"
            attribute_modules = all_attribute_modules.where(guw_model_id: my_module_project.guw_model_id)
          when "operation"
            attribute_modules = all_attribute_modules.where(operation_model_id: my_module_project.operation_model_id)
          else
            attribute_modules = all_attribute_modules
        end

        #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
        attribute_modules.each do |am|

          unless am.pe_attribute.nil?
            if am.in_out == 'both'
              ['input', 'output'].each do |in_out|
                EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                       :organization_id => @organization.id,
                                       :module_project_id => my_module_project.id,
                                       :in_out => in_out,
                                       :is_mandatory => am.is_mandatory,
                                       :description => am.description,
                                       :display_order => am.display_order,
                                       :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                       :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                       :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                       :custom_attribute => am.custom_attribute,
                                       :project_value => am.project_value)

              end
            elsif am.in_out != nil
              EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                     :organization_id => @organization.id,
                                     :module_project_id => my_module_project.id,
                                     :in_out => am.in_out,
                                     :is_mandatory => am.is_mandatory,
                                     :display_order => am.display_order,
                                     :description => am.description,
                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                     :custom_attribute => am.custom_attribute,
                                     :project_value => am.project_value)
            end
          end
        end

      else
        #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
        my_module_project.pemodule.attribute_modules.each do |am|
          unless am.pe_attribute.nil?

            if am.in_out == 'both'
              ['input', 'output'].each do |in_out|
                EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                       :organization_id => @organization.id,
                                       :module_project_id => my_module_project.id,
                                       :in_out => in_out,
                                       :is_mandatory => am.is_mandatory,
                                       :description => am.description,
                                       :display_order => am.display_order,
                                       :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                       :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                       :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                       :custom_attribute => am.custom_attribute,
                                       :project_value => am.project_value)
              end
            else
              EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                     :organization_id => @organization.id,
                                     :module_project_id => my_module_project.id,
                                     :in_out => am.in_out,
                                     :is_mandatory => am.is_mandatory,
                                     :display_order => am.display_order,
                                     :description => am.description,
                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                     :custom_attribute => am.custom_attribute,
                                     :project_value => am.project_value)
            end
          end
        end
      end

      #Link initialization module to other modules
      unless @initialization_module.nil?
        my_module_project.update_attribute('associated_module_project_ids', @initialization_module_project.id) unless @initialization_module_project.nil?
      end

      #======
      #Select the default view for module_project
      default_view = View.where("organization_id = ? AND pemodule_id = ? AND is_default_view = ?",  @project.organization_id, @pemodule.id, true).first
      new_copied_view = View.new(name: "#{@project} - #{my_module_project} view", description: "", pemodule_id: my_module_project.pemodule_id, organization_id: @organization.id)

      #Then copy the default view widgets in the new created view
      if new_copied_view.save
        unless default_view.nil?
          #Then copy the widgets of the dafult view
          #new_copied_view = View.new(name: "#{@project} - #{my_module_project} view", description: "", pemodule_id: my_module_project.pemodule_id, organization_id: @organization.id, initial_view_id: default_view.id)
          new_copied_view.update_attributes(initial_view_id: default_view.id)
          default_view.views_widgets.each do |view_widget|
            widget_est_val = view_widget.estimation_value
            in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
            estimation_value = my_module_project.estimation_values.where(:organization_id => @organization.id, pe_attribute_id: view_widget.estimation_value.pe_attribute_id, in_out: in_out).last
            estimation_value_id = estimation_value.nil? ? nil : estimation_value.id
            widget_copy = ViewsWidget.new(view_id: new_copied_view.id, module_project_id: my_module_project.id,
                                          estimation_value_id: estimation_value_id,
                                          name: view_widget.name, show_name: view_widget.show_name,
                                          show_tjm: view_widget.show_tjm,
                                          equation: view_widget.equation,
                                          comment: view_widget.comment,
                                          is_label_widget: view_widget.is_label_widget,
                                          is_kpi_widget: view_widget.is_kpi_widget,
                                          kpi_unit: view_widget.kpi_unit,
                                          use_organization_effort_unit: view_widget.use_organization_effort_unit,
                                          is_project_data_widget: view_widget.is_project_data_widget,
                                          project_attribute_name: view_widget.project_attribute_name,
                                          icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max,
                                          width: view_widget.width, height: view_widget.height, widget_type: view_widget.widget_type,
                                          position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y,
                                          min_value: view_widget.min_value,
                                          max_value: view_widget.max_value,
                                          validation_text: view_widget.validation_text)
            #Save and copy project_fields
            if widget_copy.save
              unless view_widget.project_fields.empty?
                project_field = view_widget.project_fields.last

                #Get project_field value
                @value = 0
                if widget_copy.estimation_value.module_project.pemodule.alias == "effort_breakdown"
                  begin
                    @value = widget_copy.estimation_value.string_data_probable[current_component.id][widget_copy.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                  rescue
                    begin
                      @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                    rescue
                      @value = 0
                    end
                  end
                else
                  @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                end

                #create the new project_field
                ProjectField.create(project_id: @project.id, field_id: project_field.field_id, views_widget_id: widget_copy.id, value: @value)
              end
            end
          end
        end

        my_module_project.view_id = new_copied_view.id
        my_module_project.save
      end
      #======
    end

    puts "ModuleProject : #{my_module_project}"
    my_module_project
  end
  ### END APPEND PEMODULE

end