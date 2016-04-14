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
  attr_accessible :title, :description, :version, :alias, :state, :estimation_status_id, :status_comment,
                  :start_date, :is_model, :organization_id, :project_area_id, :project_category_id,
                  :acquisition_category_id, :platform_category_id, :parent_id, :application_id, :creator_id,
                  :private

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

  has_many :module_projects, :dependent => :destroy
  has_many :pemodules, :through => :module_projects
  has_many :project_securities, :dependent => :destroy
  has_many :project_fields, :dependent => :destroy

  has_many :projects_from_model, foreign_key: "original_model_id", class_name: "Project"

  has_and_belongs_to_many :groups

  has_many :pe_wbs_projects
  has_many :pbs_project_elements, :through => :pe_wbs_projects
  has_many :wbs_project_elements, :through => :pe_wbs_projects

  default_scope order('title ASC, version ASC')

  serialize :included_wbs_activities, Array

  validates_presence_of :organization_id, :estimation_status_id, :creator_id
  # validates :title, :presence => true, :uniqueness => true
  validates :title, :presence => true, :uniqueness => {  :scope => [:version,:organization_id], case_sensitive: false, :message => I18n.t(:error_validation_project) }
  ###validates :alias, :presence => true, :uniqueness => { :scope => :organization_id, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  # validates :version, :presence => true, :length => { :maximum => 64 }, :uniqueness => { scope: [:title, :organization_id],
  #                                                                                        case_sensitive: false,
  #                                                                                        message: I18n.t(:error_validation_project) }

  #Search fields
  scoped_search :on => [:title, :alias, :description, :start_date, :created_at, :updated_at]
  # scoped_search :in => :organization, :on => :name
  # scoped_search :in => :pbs_project_elements, :on => :name
  # scoped_search :in => :wbs_project_elements, :on => [:name, :description]

  amoeba do
    enable
    include_association [:pe_wbs_projects, :module_projects, :project_securities, :project_fields]

    customize(lambda { |original_project, new_project|
      new_copy_number = original_project.copy_number.to_i+1
      new_project.copy_id = original_project.id
      new_project.title = "#{original_project.title}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.title}"
      new_project.alias = "#{original_project.alias}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.alias}"
      #new_project.version = '1.0'
      new_project.description = " #{original_project.description} \n \n This project is a duplication of project \"#{original_project.title} (#{original_project.alias}) - #{original_project.version}\" "
      new_project.copy_number = 0
      original_project.copy_number = new_copy_number
    })

    propagate
  end

  # get the selectable/available inline columns
  class_attribute :available_inline_columns
  self.available_inline_columns =
    [
      QueryColumn.new(:title, :sortable => "#{Project.table_name}.title", :caption => "label_project_name"),
      QueryColumn.new(:application, :sortable => "#{Application.table_name}.name", :caption => "application"),
      QueryColumn.new(:original_model, :sortable => "#{Project.table_name}.name", :caption => "original_model"),
      QueryColumn.new(:version, :sortable => "#{Project.table_name}.version", :caption => "label_version"),
      QueryColumn.new(:status_name, :sortable => "#{EstimationStatus.table_name}.name", :caption => "state"),
      QueryColumn.new(:project_area, :sortable => "#{ProjectArea.table_name}.name", :caption => "project_area"),
      QueryColumn.new(:project_category, :sortable => "#{ProjectCategory.table_name}.name", :caption => "category"),
      QueryColumn.new(:acquisition_category, :sortable => "#{AcquisitionCategory.table_name}.name", :caption => "label_acquisition"),
      QueryColumn.new(:platform_category, :sortable => "#{PlatformCategory.table_name}.name", :caption => "label_platform"),
      QueryColumn.new(:description, :sortable => "#{Project.table_name}.description", :caption => "description"),
      QueryColumn.new(:start_date, :sortable => "#{Project.table_name}.start_date", :caption => "label_date"),
      QueryColumn.new(:creator, :sortable => "#{User.table_name}.first_name", :caption => "author"),
      QueryColumn.new(:created_at, :sortable => "#{Project.table_name}.created_at", :caption => "created_at"),
      QueryColumn.new(:updated_at, :sortable => "#{Project.table_name}.updated_at", :caption => "updated_at"),
      QueryColumn.new(:private, :sortable => "#{Project.table_name}.private", :caption => "private_estimation")
    ]

  #class_attribute :selected_inline_columns
  #self.selected_inline_columns = update_selected_inline_columns(Project)
  #self.selected_inline_columns = self.available_inline_columns.select{ |column| column.name.to_s.in?(@current_organization.project_selected_columns)}

  class_attribute :default_selected_columns
  self.default_selected_columns = ["application", "version", "start_date", "status_name", "description"]

  def self.selectable_inline_columns
    [
      [I18n.t(:label_product_name), "application"], [I18n.t(:label_project_name), "title"], [I18n.t(:label_version),"version"],
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
    "#{self.nil? ? '' : self.title} - #{self.nil? ? '' : self.version}"
  end

  # Change project status according to the project's organization estimation statuses
  def commit_status
    #Get the project's current status
    current_status_number = self.estimation_status.status_number
    # According to the status transitions map, only possible statuses will consider
    possible_statuses = self.project_estimation_statuses.map(&:status_number).sort #self.estimation_status.to_transition_statuses.map(&:status_number).uniq.sort
    current_status_index = possible_statuses.index(current_status_number)
    # By default the first possible status is candidate
    next_status_number = possible_statuses.first
    # If the current status is not the last element of the array, the next status is next element after the current status
    if current_status_number != possible_statuses.last
      next_status_number = possible_statuses[current_status_index+1]
    end

    begin
      # Get the next status
      next_status = self.organization.estimation_statuses.find_by_status_number(next_status_number)
      self.update_attribute(:estimation_status_id, next_status.id)
    rescue
    end
  end

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
    (self.is_locked.nil? or self.is_locked == true) ? true : false
  end

  def in_frozen_status?
    (self.state.in?(%w(rejected released checkpoint))) ? true : false
  end


  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      #{:id => node.id.to_s, :name => node.title, :title => node.title, :version => node.version, :data => {}, :children => json_tree(sub_nodes).compact}
      #{id: node.id.to_s, name: node.title, title: node.title, version: node.version, data: {}, children: json_tree(sub_nodes).compact}
      {:id => node.id.to_s, :name => node.version, :data => {:title => node.title, :version => node.version, :state => node.status_name.to_s}, :children => json_tree(sub_nodes).compact}
    end
  end

  # Method that execute the duplication core
  def self.execute_duplication_SAVE_NOT_WORKING(project_id, parameters, create_from_template = nil)
    #Project.transaction do
      begin
        old_prj = Project.find(project_id)

        new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
        new_prj.ancestry = nil
        new_prj.is_model = false

        #if creation from template
        if !create_from_template.nil?   #!parameters[:create_project_from_template].nil?
          new_prj.original_model_id = old_prj.id

          #Update some parameters with the form input data
          new_prj.title = parameters['project']['title']
          new_prj.alias = parameters['project']['alias']
          new_prj.version = parameters['project']['version']
          new_prj.description = parameters['project']['description']
          start_date = (parameters['project']['start_date'].nil? || parameters['project']['start_date'].blank?) ? Time.now.to_date : parameters['project']['start_date']
          new_prj.start_date = start_date

          #Only the securities for the generated project will be taken in account
          new_prj.project_securities = new_prj.project_securities.where(is_model_permission: [false, nil])
        end

        if new_prj.save
          old_prj.save #Original project copy number will be incremented to 1

          #Update the project securities for the current user who create the estimation from model
          #if parameters[:action_name] == "create_project_from_template"
          if !create_from_template.nil?   #!parameters[:create_project_from_template].nil?
            creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
            unless creator_securities.nil?
              creator_securities.update_attribute(:user_id, current_user.id)
            end
          end

          #Managing the component tree : PBS
          pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

          # For PBS
          new_prj_components = pe_wbs_product.pbs_project_elements
          new_prj_components.each do |new_c|
            new_ancestor_ids_list = []
            new_c.ancestor_ids.each do |ancestor_id|
              ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
              new_ancestor_ids_list.push(ancestor_id)
            end
            new_c.ancestry = new_ancestor_ids_list.join('/')
            new_c.save
          end

          # For ModuleProject associations
          old_prj.module_projects.group(:id).each do |old_mp|
            new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

            # ModuleProject Associations for the new project
            old_mp.associated_module_projects.each do |associated_mp|
              new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
              new_mp.associated_module_projects << new_associated_mp
            end

            #Copy the views and widgets for the new project
            new_view = View.create(organization_id: new_prj.organization_id, name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "")

            #We have to copy all the selected view's widgets in a new view for the current module_project
            if old_mp.view
              old_mp_view_widgets = old_mp.view.views_widgets.all
              old_mp_view_widgets.each do |view_widget|
                new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
                new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
                widget_est_val = view_widget.estimation_value
                unless widget_est_val.nil?
                  in_out = widget_est_val.in_out
                  widget_pe_attribute_id = widget_est_val.pe_attribute_id
                  unless new_view_widget_mp.nil?
                    new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
                    estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
                    widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id, name: view_widget.name, show_name: view_widget.show_name,
                                                     icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                     width: view_widget.width, height: view_widget.height, position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)


                    pf = ProjectField.where(project_id: new_prj.id, views_widget_id: view_widget.id).first
                    unless pf.nil?
                      pf.views_widget_id = widget_copy.id
                      pf.save
                    end

                  end
                end
              end
            end
            #update the new module_project view
            new_mp.update_attribute(:view_id, new_view.id)

            #Update the Unit of works's groups
            new_mp.guw_unit_of_work_groups.each do |guw_group|
              new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
              new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
              guw_group.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)

              # Update the group unit of works and attributes
              guw_group.guw_unit_of_works.each do |guw_uow|
                new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
                new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

                new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
                new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
                guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id)
              end
            end

            # new_mp.uow_inputs.each do |uo|
            #   new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
            #   new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
            #
            #   uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
            # end

            ["input", "output"].each do |io|
              new_mp.pemodule.pe_attributes.each do |attr|
                old_prj.pbs_project_elements.each do |old_component|
                  new_prj_components.each do |new_component|
                    ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                    unless ev.nil?
                      ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
                      ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
                      ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
                      ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id
                      ev.save
                    end
                  end
                end
              end
            end
          end

        else
          new_prj = nil
        end

      rescue
        #raise ActiveRecord::Rollback
        new_prj = nil
      end

      new_prj
    #end
  end


end