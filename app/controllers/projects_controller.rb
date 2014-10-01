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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

class ProjectsController < ApplicationController
  include WbsActivityElementsHelper
  include ModuleProjectsHelper
  include ProjectsHelper
  include PemoduleEstimationMethods

  load_resource

  helper_method :sort_direction, :is_collapsible?, :set_attribute_unit

  before_filter :load_data, :only => [:update, :edit, :new, :create, :show]
  before_filter :get_record_statuses

protected

  def load_data
    #No authorize required since this method protected and is used to load data and shared by the other one.
    if params[:id]
      @project = Project.find(params[:id])
    else
      @project = Project.new :state => 'preliminary'
    end
    @user = @project.users.first
    @project_areas = ProjectArea.defined
    @platform_categories = PlatformCategory.defined
    @acquisition_categories = AcquisitionCategory.defined
    @project_categories = ProjectCategory.defined

    @pemodules ||= Pemodule.defined
    @project_modules = @project.pemodules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @organizations = current_user.organizations
    @project_modules = @project.pemodules
    @project_security_levels = ProjectSecurityLevel.all
    @module_project = ModuleProject.find_by_project_id(@project.id)
  end


public

  def index
    #No authorize required since everyone can access the list (permission will be managed project per project)
    set_page_title 'Estimations'
    set_breadcrumbs "Dashboard" => "/dashboard"

    # The current user can only see projects of its organizations
    @projects = []
    current_user.organizations.each do |organization|
      @projects << organization.projects.all
    end
    # Then only projects on which the current is authorise to see will be displayed
    @projects = (@projects.flatten & current_user.projects).reject { |i| !i.is_childless? }
  end

  def new
    authorize! :create_project_from_scratch, Project
    set_breadcrumbs "Dashboard" => "/dashboard", "Estimations" => projects_path
    set_page_title 'New estimation'
  end

  #Create a new project
  def create
    authorize! :create_project_from_scratch, Project
    set_page_title 'Create estimation'

    @product_name = params[:project][:product_name]
    @project_title = params[:project][:title]
    @project = Project.new(params[:project])
    @project.creator_id = current_user.id
    @project.users << current_user

    #Give full control to project creator
    full_control_security_level = ProjectSecurityLevel.find_by_name('FullControl')
    current_user_ps = @project.project_securities.build
    current_user_ps.user = current_user
    current_user_ps.project_security_level = full_control_security_level

    @wbs_activity_elements = []
    @project.is_locked = false

    if @project.start_date.nil? or @project.start_date.blank?
      @project.start_date = Time.now.to_date
    end

    Project.transaction do
      begin
        @project.add_to_transaction

        if @project.valid?
          @project.save!
          #New default Pe-Wbs-Project
          pe_wbs_project_product = @project.pe_wbs_projects.build(:name => "#{@project.title}", :wbs_type => 'Product')
          pe_wbs_project_activity = @project.pe_wbs_projects.build(:name => "#{@project.title} WBS-Activity", :wbs_type => 'Activity')

          pe_wbs_project_product.add_to_transaction
          pe_wbs_project_activity.add_to_transaction

          pe_wbs_project_product.save!
          ##New root Pbs-Project-Element
          pbs_project_element = pe_wbs_project_product.pbs_project_elements.build(:name => "#{@product_name.blank? ? @project_title : @product_name}",
                                                                                  :is_root => true,
                                                                                  :work_element_type_id => default_work_element_type.id,
                                                                                  :position => 0,
                                                                                  :start_date => Time.now)
          pbs_project_element.add_to_transaction

          pbs_project_element.save!
          pe_wbs_project_product.save!

          pe_wbs_project_activity.save!
          ##New Root Wbs-Project-Element
          wbs_project_element = pe_wbs_project_activity.wbs_project_elements.build(:name => "#{@project.title} - WBS-Activity",
                                                                                   :is_root => true,
                                                                                   :description => 'WBS-Activity Root Element',
                                                                                   :author_id => current_user.id)
          wbs_project_element.add_to_transaction
          wbs_project_element.save!


          #Get the initialization module from ApplicationController
          #When creating project, we need to create module_projects for created initialization
          unless @initialization_module.nil?
            cap_module_project = @project.module_projects.build(:pemodule_id => @initialization_module.id, :position_x => 0, :position_y => 0)
            if cap_module_project.save!
              #Create the corresponding EstimationValues
              unless @project.organization.nil? || @project.organization.attribute_organizations.nil?
                @project.organization.attribute_organizations.each do |am|
                  ['input', 'output'].each do |in_out|
                    mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                                 :module_project_id => cap_module_project.id,
                                                 :in_out => in_out,
                                                 :is_mandatory => am.is_mandatory,
                                                 :description => am.pe_attribute.description,
                                                 :display_order => nil,
                                                 :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                                 :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                                 :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                  end
                end
              end
            end
          end
          redirect_to redirect_apply(edit_project_path(@project)), notice: "#{I18n.t(:notice_project_successful_created)}"
        else
          flash[:error] = "#{I18n.t(:error_project_creation_failed)} #{@project.errors.full_messages.to_sentence}"
          render :new
        end

        #raise ActiveRecord::Rollback
      rescue ActiveRecord::UnknownAttributeError, ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid => error
        flash[:error] = "#{I18n.t (:error_project_creation_failed)} #{@project.errors.full_messages.to_sentence}"
        redirect_to projects_url
      end
    end
  end


  #Edit a selected project
  def edit
    set_page_title 'Edit estimation'

    @project = Project.find(params[:id])

    set_breadcrumbs "Dashboard" => "/dashboard", "Estimations" => projects_path, @project => edit_project_path(@project)

    if (cannot? :edit_project, @project) ||                                               # No write access to project
        (@project.in_frozen_status? && (cannot? :alter_frozen_project, @project)) ||      # frozen project
        (@project.in_review? && (cannot? :write_access_to_inreview_project, @project))    # InReview project
      redirect_to(:action => 'show')
    end

    # We need to verify user's groups rights on estimation according to the current estimation status
    if !can_modify_estimation?(@project)
      if can_show_estimation?(@project)
        redirect_to(:action => 'show')
      else
        redirect_to(projects_path, flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)})
      end
    end

    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    @modules_selected = Pemodule.where('record_status_id = ? AND alias <> ?', @defined_status.id, 'initialization').all.map { |i| [i.title, i.id] }

    @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @wbs_activity_ratios = []

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    #defined_wbs_activities = WbsActivity.where('record_status_id = ?', @defined_status.id).all
    defined_wbs_activities = @project.organization.wbs_activities.where('record_status_id = ?', @defined_status.id).all
    @wbs_activities = defined_wbs_activities.reject { |i| @project.included_wbs_activities.include?(i.id) }
    @wbs_activity_elements = []
    @wbs_activities.each do |wbs_activity|
      elements_root = wbs_activity.wbs_activity_elements.elements_root.first
      unless elements_root.nil?
        @wbs_activity_elements << elements_root #wbs_activity.wbs_activity_elements.last.root
      end
    end

    #Project tree as JSON DATA for the graphical representation
    project_root = @project.root
    project_tree = project_root.subtree
    arranged_projects = project_tree.arrange
    array_json_tree = Project.json_tree(arranged_projects)
    @projects_json_tree = Hash[*array_json_tree.flatten]
    @projects_json_tree = @projects_json_tree.to_json
  end

  def update
    set_page_title 'Edit estimation'
    @project = Project.find(params[:id])

    set_breadcrumbs "Dashboard" => "/dashboard", "Estimations" => projects_path, @project => edit_project_path(@project)

    # We need to verify user's groups rights on estimation according to the current estimation status
    if !can_modify_estimation?(@project)
      if can_show_estimation?(@project)
        redirect_to(:action => 'show', flash: { warning: I18n.t(:warning_no_modify_permission_on_project_status)})
      else
        redirect_to(projects_path, flash: { warning: I18n.t(:warning_no_modify_permission_on_project_status)})
      end
    end

    unless (cannot? :edit_project, @project) || # No write access to project
        (@project.in_frozen_status? && (cannot? :alter_frozen_project, @project)) ||   # frozen project
        (@project.in_review? && (cannot? :write_access_to_inreview_project, @project)) # InReview project

      @product_name = params[:project][:product_name]
      project_root = @project.root_component
      project_root.name = "#{@product_name.blank? ? @project.title : @product_name}"
      project_root.save

      @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
      @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
      @wbs_activity_elements = []
      @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
      @wbs_activity_ratios = []

      @project.users.each do |u|
        ps = ProjectSecurity.find_by_user_id_and_project_id(u.id, @project.id)
        if ps
          ps.project_security_level_id = params["user_securities_#{u.id}"]
          ps.save
        elsif !params["user_securities_#{u.id}"].blank?
          new_ps = @project.project_securities.build #ProjectSecurity.new
          new_ps.user_id = u.id
          new_ps.project_security_level_id = params["user_securities_#{u.id}"]
        end
      end

      @project.groups.each do |gpe|
        ps = ProjectSecurity.where(:group_id => gpe.id, :project_id => @project.id).first
        if ps
          ps.project_security_level_id = params["group_securities_#{gpe.id}"]
          ps.save
        elsif !params["group_securities_#{gpe.id}"].blank?
          #ProjectSecurity.create(:group_id => gpe.id, :project_id => @project.id, :project_security_level_id => params["group_securities_#{gpe.id}"])
          new_ps = @project.project_securities.build
          new_ps.group_id = gpe.id
          new_ps.project_security_level_id = params["group_securities_#{gpe.id}"]
        end
      end

      # Get the max X and Y positions of modules
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

      #Get the project Organization before update
      project_organization = @project.organization

      if @project.update_attributes(params[:project])
        begin
          date = Date.strptime(params[:project][:start_date], I18n.t('date.formats.default'))
          @project.start_date = date
        rescue
          @project.start_date = Time.now.to_date
        end

        # Initialization Module
        unless @initialization_module.nil?
          # Get the project initialization module_project or create if it doesn't exist
          cap_module_project = @project.module_projects.find_by_pemodule_id(@initialization_module.id)
          if cap_module_project.nil?
            cap_module_project = @project.module_projects.create(:pemodule_id => @initialization_module.id, :position_x => 0, :position_y => 0)
          end

          # Create the project initialization module estimation_values if project organization has changed and not nil
          if project_organization.nil? && !@project.organization.nil?

            #Create the corresponding EstimationValues
            unless @project.organization.attribute_organizations.nil?
              @project.organization.attribute_organizations.each do |am|
                ['input', 'output'].each do |in_out|
                  mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                               :module_project_id => cap_module_project.id,
                                               :in_out => in_out,
                                               :is_mandatory => am.is_mandatory,
                                               :description => am.pe_attribute.description,
                                               :display_order => nil,
                                               :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                               :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                               :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                end
              end
            end

            # When project organization exists
          elsif !project_organization.nil?

            # project's organization is deleted and none one is selected
            if @project.organization.nil?
              cap_module_project.estimation_values.delete_all
            end

            # Project's organization has changed
            if !@project.organization.nil? && project_organization != @project.organization
              # Delete all last estimation values for this organization on this project
              cap_module_project.estimation_values.delete_all

              # Create estimation_values for the new selected organization
              @project.organization.attribute_organizations.each do |am|
                ['input', 'output'].each do |in_out|
                  mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                               :module_project_id => cap_module_project.id,
                                               :in_out => in_out,
                                               :is_mandatory => am.is_mandatory,
                                               :description => am.pe_attribute.description,
                                               :display_order => nil,
                                               :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                               :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                               :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                end
              end
            end
          end
        end

        @project.save

        redirect_to redirect_apply(edit_project_path(@project, :anchor => session[:anchor]), nil, projects_path), notice: "#{I18n.t(:notice_project_successful_updated)}"
      else
        @wbs_activity_ratios = WbsActivityRatio.all
        render :action => 'edit'
      end
    end
  end


  def show
    @project = Project.find(params[:id])
    set_breadcrumbs "Dashboard" => "/dashboard", "Estimations" => projects_path, @project => edit_project_path(@project)

    authorize! :show_project, @project
    set_page_title 'Show estimation'

    # We need to verify user's groups rights on estimation according to the current estimation status
    if !can_show_estimation?(@project)
      redirect_to(projects_path, flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)})
    end

    @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @wbs_activity_elements = []
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
    @wbs_activity_ratios = []

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    #defined_wbs_activities = WbsActivity.where('record_status_id = ?', @defined_status.id).all
    defined_wbs_activities = @project.organization.wbs_activities.where('record_status_id = ?', @defined_status.id).all
    @wbs_activities = defined_wbs_activities.reject { |i| @project.included_wbs_activities.include?(i.id) }
    @wbs_activity_elements = []
    @wbs_activities.each do |wbs_activity|
      elements_root = wbs_activity.wbs_activity_elements.elements_root.first
      unless elements_root.nil?
        @wbs_activity_elements << elements_root #wbs_activity.wbs_activity_elements.last.root
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    authorize! :delete_project, @project

    case params[:commit]
      when I18n.t('delete')
        if params[:yes_confirmation] == 'selected'
          if ((can? :delete_project, @project) || (can? :manage, @project)) && (@project.is_childless? && !@project.rejected? && !@project.released? && !@project.checkpoint?)
            @project.destroy
            current_user.delete_recent_project(@project.id)
            session[:current_project_id] = current_user.projects.first
            flash[:notice] = I18n.t(:notice_project_successful_deleted, :value => 'Project')
            if !params[:from_tree_history_view].blank? && params['current_showed_project_id'] != params[:id]
              redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history')
            else
              redirect_to projects_path
            end
          else
            flash[:warning] = I18n.t(:error_access_denied)
            redirect_to (params[:from_tree_history_view].nil? ?  projects_path : edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'))
          end
        else
          flash[:warning] = I18n.t('warning_need_check_box_confirmation')
          render :template => 'projects/confirm_deletion'
        end
      when I18n.t('cancel')
        redirect_to projects_path
      else
        render :template => 'projects/confirm_deletion'
    end
  end


  #Update the project's organization estimation statuses
  def update_organization_estimation_statuses
    @estimation_statuses = []

    unless params[:project_organization_id].nil? || params[:project_organization_id].blank?
      @organization = Organization.find(params[:project_organization_id])
      @project = Project.find(params[:project_id])
      unless @project.new_record?
        # Editing project that does not have estimation status
        if @project.estimation_status.nil? || !@organization.estimation_statuses.include?(@project.estimation_status)
          # Note: When estimation's organization changed, the status id won't be valid for the new selected organization
          initial_status = @organization.estimation_statuses.order(:status_number).first_or_create(organization_id: @project.organization_id, status_number: 0, status_alias: 'preliminary', name: 'Préliminaire', status_color: 'F5FFFD')
          @estimation_statuses = [[initial_status.name, initial_status.id]]
        else
          estimation_statuses = @project.estimation_status.to_transition_statuses.map{ |i| [i.name, i.id]}
          estimation_statuses << [@project.estimation_status.name, @project.estimation_status.id]
          @estimation_statuses = estimation_statuses.uniq
        end
      end
    end

    @estimation_statuses

  end


  def confirm_deletion
    @project = Project.find(params[:project_id])
    authorize! :delete_project, @project
    @from_tree_history_view = params[:from_tree_history_view]
    @current_showed_project_id = params['current_showed_project_id']

    if @project.has_children? || @project.rejected? || @project.released? || @project.checkpoint?
      if @from_tree_history_view
        redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'), :flash => {:warning => I18n.t(:warning_project_cannot_be_deleted)}
      else
        redirect_to projects_path, :flash => {:warning => I18n.t(:warning_project_cannot_be_deleted)}
      end
    end
  end

  def select_categories
    #No authorize required
    if params[:project_area_selected].is_numeric?
      @project_area = ProjectArea.find(params[:project_area_selected])
    else
      @project_area = ProjectArea.find_by_name(params[:project_area_selected])
    end

    @project_areas = ProjectArea.defined
    @platform_categories = PlatformCategory.defined
    @acquisition_categories = AcquisitionCategory.defined
    @project_categories = ProjectCategory.defined
  end

  #Change selected project ("Jump to a project" select box)
  def change_selected_project
    if params[:project_id]
      project = Project.find(params[:project_id])
      authorize! :edit_project, project
      session[:current_project_id] = params[:project_id]
    end
    redirect_to '/dashboard'
  end

  #Load specific security depending of user selected (last tabs on project editing page)
  def load_security_for_selected_user
    #No authorize required
    set_page_title 'Project securities'
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @prj_scrt = ProjectSecurity.find_by_user_id_and_project_id(@user.id, @project.id)
    if @prj_scrt.nil?
      @prj_scrt = ProjectSecurity.create(:user_id => @user.id, :project_id => @project.id)
    end

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end

  end

  #Load specific security depending of user selected (last tabs on project editing page)
  def load_security_for_selected_group
    #No authorize required
    set_page_title 'Project securities'
    @group = Group.find(params[:group_id])
    @project = Project.find(params[:project_id])
    @prj_scrt = ProjectSecurity.find_by_group_id_and_project_id(@group.id, @project.id)
    if @prj_scrt.nil?
      @prj_scrt = ProjectSecurity.create(:group_id => @user.id, :project_id => @project.id)
    end

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end

  end

  #Updates the security according to the previous users
  def update_project_security_level
    #TODO check if No authorize is required
    set_page_title 'Project securities'
    @project = Project.find(params[:project_id])
    @user = User.find(params[:user_id].to_i)
    @prj_scrt = ProjectSecurity.find_by_user_id_and_project_id(@user.id, current_project.id)
    @prj_scrt.update_attribute('project_security_level_id', params[:project_security_level])

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end
  end

  #Updates the security according to the previous users
  def update_project_security_level_group
    #TODO check if No authorize is required
    set_page_title 'Project securities'
    @project = Project.find(params[:project_id])
    @group = Group.find(params[:group_id].to_i)
    @prj_scrt = ProjectSecurity.find_by_group_id_and_project_id(@group.id, current_project.id)
    @prj_scrt.update_attribute('project_security_level_id', params[:project_security_level])

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end
  end

  #Allow o add or append a pemodule to a estimation process
  def append_pemodule
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    if params[:pbs_project_element_id] && params[:pbs_project_element_id] != ''
      @pbs_project_element = PbsProjectElement.find(params[:pbs_project_element_id])
    else
      @pbs_project_element = @project.root_component
    end

    unless params[:module_selected].nil? || @project.nil?
      @array_modules = Pemodule.defined
      @pemodules ||= Pemodule.defined

      #Max pos or 1
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max

      #When adding a module in the "timeline", it creates an entry in the table ModuleProject for the current project, at position 2 (the one being reserved for the input module).
      my_module_project = ModuleProject.new(:project_id => @project.id, :pemodule_id => params[:module_selected], :position_y => 1, :position_x => @module_positions_x.to_i+1)
      my_module_project.save

      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max

      #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
      my_module_project.pemodule.attribute_modules.each do |am|
        if am.in_out == 'both'
          ['input', 'output'].each do |in_out|
            mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
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
          mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
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

      #Link initialization module to other modules
      unless @initialization_module.nil?
        my_module_project.update_attribute('associated_module_project_ids', @initialization_module_project.id) unless @initialization_module_project.nil?
      end
    end
  end

  def select_pbs_project_elements
    #No authorize required
    @project = Project.find(params[:project_id])
    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @module_projects.find_by_pemodule_id(@initialization_module.id)

    if params[:pbs_project_element_id] && params[:pbs_project_element_id] != ''
      @pbs_project_element = PbsProjectElement.find(params[:pbs_project_element_id])
    else
      @pbs_project_element = @project.root_component
    end
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max
  end


  def read_tree_nodes(current_node)
    #No authorize required
    ordered_list_of_nodes = Array.new
    next_nodes = current_node.next.sort { |node1, node2| (node1.position_y <=> node2.position_y) && (node1.position_x <=> node2.position_x) }.uniq
    ordered_list_of_nodes = ordered_list_of_nodes + next_nodes
    ordered_list_of_nodes.uniq

    next_nodes.each do |n|
      read_tree_nodes(n)
    end
  end

  #Run estimation process
  def run_estimation(start_module_project = nil, pbs_project_element_id = nil, rest_of_module_projects = nil, set_attributes = nil)
    @project = current_project
    authorize! :execute_estimation_plan, @project

    @my_results = Hash.new
    @last_estimation_results = Hash.new
    set_attributes_name_list = {'low' => [], 'high' => [], 'most_likely' => []}

    if start_module_project.nil?
      pbs_project_element = current_component
      pbs_project_element_id = pbs_project_element.id
      start_module_project = current_module_project
      rest_of_module_projects = crawl_module_project(current_module_project, pbs_project_element)
      set_attributes = {'low' => {}, 'most_likely' => {}, 'high' => {}}


      ['low', 'most_likely', 'high'].each do |level|
        params[level].each do |key, hash|
          set_attributes[level][key] = hash[current_module_project.id.to_s]
        end
      end
    end

    # if the EffortBreakdown module is called, we need to have at least one Wbs-activity/Ratio defined in the PBS or in project level
    if start_module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      pe_wbs_activity = start_module_project.project.pe_wbs_projects.activities_wbs.first
      project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
      wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first
      if current_component.wbs_activity_ratio.nil? && wbs_project_elt_with_ratio.nil?
        flash[:notice] = "Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet"
        #return redirect_to(:back, :alert =>"Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet" )
        redirect_to(root_path(flash: { error: "Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet"})) and return
      end
    end

    # Execution of the first/current module-project
    ['low', 'most_likely', 'high'].each do |level|
      @my_results[level.to_sym] = run_estimation_plan(set_attributes[level], pbs_project_element_id, level, @project, start_module_project)
    end

    # Save output values: only for current pbs_project_element and for current module-project
    # Component parent estimation results is computed again in a asynchronous jobs processing in the "save_estimation_results" method
    save_estimation_results(start_module_project, set_attributes, @my_results)

    # Need to execute other module_projects if all required input attributes are present
    # Get all required attributes for each module (where)
    # Get all module_projects from the current_module_project : crawl_module_project(start_module_project)
    until rest_of_module_projects.empty?
      module_project = rest_of_module_projects.shift

      @module_project_results = Hash.new
      required_input_attributes = Array.new
      input_attribute_modules = module_project.estimation_values.where('in_out IN (?) AND is_mandatory = ?', %w(input both), true)
      input_attribute_modules.each do |attr_module|
        required_input_attributes << attr_module.pe_attribute.alias
      end

      # Verification will be done only if there are some required attribute for the module
      #unless required_input_attributes.empty?
      # Re-initialize the current module_project
      # @my_results is like that {:low => {:complexity_467 => 'organic', :sloc_467 => 10}, :most_likely => {:complexity_467 => 'organic', :sloc_467 => 10}, :hight => {:complexity_467 => 'organic', :sloc_467 => 10}}
      get_all_required_attributes = []

      ['low', 'most_likely', 'high'].each do |level|
        level_result = @my_results[level.to_sym]

        level_result.each do |key, value|
          attribute_alias = key.to_s.split("_#{start_module_project.id}").first

          # For modules with activities
          if start_module_project.pemodule.yes_for_output_with_ratio? || start_module_project.pemodule.yes_for_output_without_ratio? || start_module_project.pemodule.yes_for_input_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_without_ratio?
            value = value.inject({}) { |wbs_value, (k, v)| wbs_value[k.to_s] = v; wbs_value }
          end

          set_attributes[level][attribute_alias] = value
        end

        # Update the set_attributes_name_list with the last one,
        # Attribute is only added to the set_attributes_name_list if it's present
        set_attributes[level].keys.each { |key| set_attributes_name_list[level] << key }

        # Need to verify that all required attributes for this module are present
        # If all required attributes are present
        get_all_required_attributes << ((required_input_attributes & set_attributes_name_list[level]) == required_input_attributes)
      end

      at_least_one_all_required_attr = nil
      get_all_required_attributes.each do |elt|
        at_least_one_all_required_attr = elt
        break if at_least_one_all_required_attr == true
      end

      #Run the estimation until there is one module_project that doesn't has all required attributes
      catch (:done) do
        throw :done if !at_least_one_all_required_attr
        # Run estimation plan for the current module_project
        run_estimation(module_project, pbs_project_element_id, rest_of_module_projects, set_attributes)
      end
    end

    #flash.now[:notice] = "Finish to execute estimation"
    #respond_to do |format|
    #  format.js { render :partial => 'pbs_project_elements/refresh'}
    #end
  end


  # Function that save current module_project estimation result in DB
  #Save output values: only for current pbs_project_element
  def save_estimation_results(start_module_project, input_attributes, output_data)
    @project = current_project
    authorize! :alter_estimation_plan, @project

    @pbs_project_element = current_component

    # get the estimation_value for the current_pbs_project_element
    current_pbs_estimations = start_module_project.estimation_values
    current_pbs_estimations.each do |est_val|
      est_val_attribute_alias = est_val.pe_attribute.alias
      est_val_attribute_type = est_val.pe_attribute.attribute_type

      if est_val.in_out == 'output'
        out_result = Hash.new
        @my_results.each do |res|
          ['low', 'most_likely', 'high'].each do |level|
            # We don't have to replace the value, but we need to update them
            level_estimation_value = Hash.new
            level_estimation_value = est_val.send("string_data_#{level}")
            level_estimation_value_without_consistency = @my_results[level.to_sym]["#{est_val_attribute_alias}_#{start_module_project.id.to_s}".to_sym]

            # In case when module use the wbs_project_element, the is_consistent need to be set
            if start_module_project.pemodule.yes_for_output_with_ratio? || start_module_project.pemodule.yes_for_output_without_ratio? || start_module_project.pemodule.yes_for_input_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_without_ratio?
              psb_level_estimation = level_estimation_value[@pbs_project_element.id]
              level_estimation_value[@pbs_project_element.id] = set_element_value_with_activities(level_estimation_value_without_consistency, start_module_project)
            else
              level_estimation_value[@pbs_project_element.id] = level_estimation_value_without_consistency
            end

            out_result["string_data_#{level}"] = level_estimation_value
          end

          # compute the probable value for each node
          probable_estimation_value = Hash.new
          probable_estimation_value = est_val.send('string_data_probable')

          if est_val_attribute_type == 'numeric'

            probable_estimation_value[@pbs_project_element.id] = probable_value(@my_results, est_val)

            ######### if module_project use Ratio for output (like the Effort breakdown estimation module) ###############
            # Get the effort per Activity by profile
            if start_module_project.pemodule.yes_for_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_with_ratio?

              ####### Get the project referenced ratio #####

              # Project pe_wbs_activity
              pe_wbs_activity = @project.pe_wbs_projects.activities_wbs.first

              # Get the wbs_project_element which contain the wbs_activity_ratio
              project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
              #wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
              # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
              wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

              # By default, use the project default Ratio as Reference, unless PSB got its own Ratio,
              ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio

              # If Another default ratio was defined in PBS, it will override the one defined in module-project
              if !@pbs_project_element.wbs_activity_ratio.nil?
                ratio_reference = @pbs_project_element.wbs_activity_ratio
              end
              # Get the referenced ratio wbs_activity_ratio_profiles
              referenced_wbs_activity_ratio_profiles = ratio_reference.wbs_activity_ratio_profiles
              profiles_probable_value = {}
              parent_profile_est_value = {}

              # get the wbs_project_elements that have at least one child
              wbs_project_elt_with_children = pe_wbs_activity.wbs_project_elements.select{ |elt| elt.has_children? && !elt.is_root }.map(&:id)

              @project.organization.organization_profiles.each do |profile|
                profiles_probable_value["profile_id_#{profile.id}"] = Hash.new
                # Parent values are reset to zero
                wbs_project_elt_with_children.each{ |elt| parent_profile_est_value["#{elt}"] = 0 }

                probable_estimation_value[@pbs_project_element.id].each do |wbs_project_elt_id, hash_value|
                  # Get the probable value profiles values

                  if hash_value["profiles"].nil?
                    # create a new hash for profiles estimations results
                    probable_estimation_value[@pbs_project_element.id][wbs_project_elt_id]["profiles"] = Hash.new
                  end

                  current_probable_profiles = probable_estimation_value[@pbs_project_element.id][wbs_project_elt_id]["profiles"]

                  wbs_project_elt = WbsProjectElement.find(wbs_project_elt_id)
                  wbs_activity_elt_id = wbs_project_elt.wbs_activity_element_id

                  # Wbs_project_element root element doesn't have a wbs_activity_element
                  unless wbs_activity_elt_id.nil?
                    wbs_activity_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, wbs_activity_elt_id).first
                    if !wbs_activity_ratio_elt.nil?
                      # get the wbs_activity_ratio_profile
                      corresponding_ratio_profile = referenced_wbs_activity_ratio_profiles.where('wbs_activity_ratio_element_id = ? AND organization_profile_id = ?', wbs_activity_ratio_elt.id, profile.id).first
                      # Get current profile ratio value for the referenced ratio
                      corresponding_ratio_profile_value = corresponding_ratio_profile.nil? ? nil : corresponding_ratio_profile.ratio_value
                      estimation_value_profile = nil
                      unless corresponding_ratio_profile_value.nil?
                        estimation_value_profile = (hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100

                        #the update the parent's value
                        ###parent_profile_est_value["#{wbs_project_elt.parent_id}"] += estimation_value_profile
                        parent_profile_est_value["#{wbs_project_elt.parent_id}"] = parent_profile_est_value["#{wbs_project_elt.parent_id}"].to_f + estimation_value_profile
                      end

                      #if current_probable_profiles["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"].nil?
                        current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{ratio_reference.id}" => {:value => estimation_value_profile} }
                      #else
                        #current_probable_profiles["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"] = { :value => estimation_value_profile }
                      #end
                    end
                  end
                end
                #Need to calculate the parents effort by profile : addition of its children values
                wbs_project_elt_with_children.each do |wbs_project_elt_id|
                  probable_estimation_value[@pbs_project_element.id][wbs_project_elt_id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_project_elt_id}"]} }
                end
              end
            end

          else
            probable_estimation_value[@pbs_project_element.id] = @my_results[:most_likely]["#{est_val_attribute_alias}_#{est_val.module_project_id.to_s}".to_sym]
          end

          # Update the pbs probable value
          out_result['string_data_probable'] = probable_estimation_value
        end

        #Update current pbs estimation values
        est_val.update_attributes(out_result)

      elsif est_val.in_out == 'input'
        in_result = Hash.new

        ['low', 'most_likely', 'high'].each do |level|
          level_estimation_value = Hash.new
          level_estimation_value = est_val.send("string_data_#{level}")
          begin
            pbs_level_form_input = input_attributes[level][est_val_attribute_alias]
          rescue
            pbs_level_form_input = input_attributes[est_val_attribute_alias.to_sym]
          end

          wbs_root = start_module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.where('is_root = ?', true).first
          if start_module_project.pemodule.yes_for_input? || start_module_project.pemodule.yes_for_input_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_without_ratio?
            unless start_module_project.pemodule.alias == 'effort_balancing'
              level_estimation_value[@pbs_project_element.id] = compute_tree_node_estimation_value(wbs_root, pbs_level_form_input)
            end
          else
            level_estimation_value[@pbs_project_element.id] = pbs_level_form_input
          end

          in_result["string_data_#{level}"] = level_estimation_value

        end
        est_val.update_attributes(in_result)
      end

      # Save estimation for the current component parent
      if est_val.save
        EstimationsWorker.perform_async(@pbs_project_element.id, est_val.id)
        ###perform_test(@pbs_project_element.id, est_val.id)
      end
    end
  end


private

  # Breadth-First Traversal of a Tree
  # This function list the next module_projects according to the given (starting_node) module_project
  # compatibility between the module_projects with the current_component is verified
  # Then return the module_projects like Tree Breadth
  def crawl_module_project(starting_node, pbs_project_element)
    #No authorize required since this method is private and won't be call from any route
    list = []
    items=[starting_node]
    until items.empty?
      # Returns the first element of items and removes it (shifting all other elements down by one).
      item = items.shift

      # Get all next module_projects that are linked to the current item
      list << item unless list.include?(item)
      kids = item.next.select { |i| i.pbs_project_elements.map(&:id).include?(pbs_project_element.id) }
      kids = kids.sort { |mp1, mp2| (mp1.position_y <=> mp2.position_y) && (mp1.position_x <=> mp2.position_x) } #Get next module_project

      kids.each { |kid| items << kid }
    end
    list - [starting_node]
  end

  # Compute the input element value
  ## values_to_set : Hash
  def compute_tree_node_estimation_value(tree_root, values_to_set)
    #No authorize required since this method is private and won't be call from any route
    WbsProjectElement.rebuild_depth_cache!
    new_effort_person_hour = Hash.new

    tree_root.children.each do |node|
      # Sort node subtree by ancestry_depth
      sorted_node_elements = node.subtree.order('ancestry_depth desc')
      sorted_node_elements.each do |wbs_project_element|
        if wbs_project_element.is_childless?
          new_effort_person_hour[wbs_project_element.id] = values_to_set[wbs_project_element.id.to_s]
        else
          new_effort_person_hour[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, new_effort_person_hour)
        end
      end
    end

    new_effort_person_hour[tree_root.id] = compact_array_and_compute_node_value(tree_root, new_effort_person_hour) ###root_element_effort_person_hour
    new_effort_person_hour
  end


  #This method set result in DB with the :value key for node estimation value
  def set_element_value_with_activities(estimation_result, module_project)
    @project = current_project
    authorize! :alter_estimation_plan, @project

    result_with_consistency = Hash.new
    consistency = true
    if !estimation_result.nil? && !estimation_result.eql?('-')
      estimation_result.each do |wbs_project_elt_id, est_value|
        if module_project.pemodule.alias == 'wbs_activity_completion'
          wbs_project_elt = WbsProjectElement.find(wbs_project_elt_id)
          if wbs_project_elt.has_new_complement_child?
            consistency = set_wbs_completion_node_consistency(estimation_result, wbs_project_elt)
          end
          result_with_consistency[wbs_project_elt_id] = {:value => est_value, :is_consistent => consistency}
        elsif module_project.pemodule.alias == 'effort_balancing'
          result_with_consistency[wbs_project_elt_id] = {:value => est_value}
        else
          result_with_consistency[wbs_project_elt_id] = {:value => est_value}
        end

      end
    else
      result_with_consistency = nil
    end

    result_with_consistency
  end


  # After estimation, need to know if node value are consistent or not for WBS-Completion modules
  def set_wbs_completion_node_consistency(estimation_result, wbs_project_element)
    @project = current_project
    authorize! :alter_wbsproducts, @project

    consistency = true
    estimation_result_without_null_value = []

    wbs_project_element.child_ids.each do |child_id|
      value = estimation_result[child_id]
      if value.is_a?(Float) or value.is_a?(Integer)
        estimation_result_without_null_value << value
      end
    end
    if estimation_result[wbs_project_element.id].to_f != estimation_result_without_null_value.sum.to_f
      consistency = false
    end
    consistency
  end


public

  # This estimation plan method is called for each component
  def run_estimation_plan(input_data, pbs_project_element_id, level, project, current_mp_to_execute)
    @project = project #current_project
    authorize! :execute_estimation_plan, @project

    @result_hash = Hash.new
    inputs = Hash.new
    # Add the current project id in input data parameters
    input_data['current_project_id'.to_sym] = @project.id

    #Need to add input for pbs_project_element and module_project
    input_data['pbs_project_element_id'.to_sym] = pbs_project_element_id
    input_data['module_project_id'.to_sym] = current_mp_to_execute.id

    # For Balancing-Module : Estimation will be calculated only for the current selected balancing attribute
    if current_mp_to_execute.pemodule.alias.to_s == Projestimate::Application::BALANCING_MODULE
      balancing_attr_est_values = current_mp_to_execute.estimation_values.where('in_out = ? AND pe_attribute_id = ?', "output", current_balancing_attribute).last
      current_module = "#{current_mp_to_execute.pemodule.alias.camelcase.constantize}::#{current_mp_to_execute.pemodule.alias.camelcase.constantize}".gsub(' ', '').constantize
      input_data['pe_attribute_alias'.to_sym] = balancing_attr_est_values.pe_attribute.alias

      # Normally, the input data is commonly from the Expert Judgment Module on PBS (when running estimation on its product)
      cm = current_module.send(:new, input_data)
      #begin
        @result_hash["#{balancing_attr_est_values.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = cm.send("get_#{balancing_attr_est_values.pe_attribute.alias}", project.id, current_mp_to_execute.id, pbs_project_element_id, level)
      #rescue => e
      #  @result_hash["#{est_val.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = nil
      #  puts e.message
      #end

    # For others modules
    else
      #current_mp_to_execute.estimation_values.sort! { |a, b| a.in_out <=> b.in_out }.each do |est_val|
      current_mp_to_execute.estimation_values.each do |est_val|
        #if est_val.in_out == 'input' or est_val.in_out=='both'
        #  inputs[est_val.pe_attribute.alias.to_sym] = input_data[est_val.pe_attribute.alias] #[current_mp_to_execute.id.to_s]
        #end

        current_module = "#{current_mp_to_execute.pemodule.alias.camelcase.constantize}::#{current_mp_to_execute.pemodule.alias.camelcase.constantize}".gsub(' ', '').constantize

        input_data['pe_attribute_alias'.to_sym] = est_val.pe_attribute.alias

        # Normally, the input data is commonly from the Expert Judgment Module on PBS (when running estimation on its product)
        cm = current_module.send(:new, input_data)

        if est_val.in_out == 'output' or est_val.in_out=='both'
          #begin
              @result_hash["#{est_val.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = cm.send("get_#{est_val.pe_attribute.alias}", project.id, current_mp_to_execute.id, pbs_project_element_id, level)
          #rescue => e
          #  @result_hash["#{est_val.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = nil
          #  puts e.message
          #end
        end
      end
    end

    @result_hash
  end


  #Method to duplicate project and associated pe_wbs_project
  def duplicate
    #begin
      authorize! :create_project_from_template, Project

      old_prj = Project.find(params[:project_id])

      new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
      new_prj.ancestry = nil

      if new_prj.save
        old_prj.save #Original project copy number will be incremented to 1

        #Managing the component tree : PBS
        pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first
        pe_wbs_activity = new_prj.pe_wbs_projects.activities_wbs.first

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

            # For PBS-Project-Element Links with modules
            old_pbs = PbsProjectElement.find(new_c.copy_id)
            new_c.module_projects = old_pbs.module_projects

            new_c.save
          end
        end

        # For WBS
        new_prj_wbs = pe_wbs_activity.wbs_project_elements
        new_prj_wbs.each do |new_wbs|
          unless new_wbs.is_root?
            new_ancestor_ids_list = []
            new_wbs.ancestor_ids.each do |ancestor_id|
              ancestor_id = WbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_wbs.pe_wbs_project_id, ancestor_id).id
              new_ancestor_ids_list.push(ancestor_id)
            end
            new_wbs.ancestry = new_ancestor_ids_list.join('/')
            new_wbs.save
          end
        end

        # For ModuleProject associations
        old_prj.module_projects.group(:id).each do |old_mp|
          new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)
          old_mp.associated_module_projects.each do |associated_mp|
            new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
            new_mp.associated_module_projects << new_associated_mp
          end
        end
      end

      flash[:success] = I18n.t(:notice_project_successful_duplicated)
      redirect_to edit_project_path(new_prj) and return
    #rescue
    #  flash['Error'] = I18n.t(:error_project_duplication_failed)
    #  redirect_to '/projects'
    #end
  end


  def commit
    project = Project.find(params[:project_id])
    authorize! :commit_project, project
    project.commit!

    if params[:from_tree_history_view]
      redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history')
    else
      redirect_to '/projects'
    end
  end

  def activate
    project = Project.find(params[:project_id])
    authorize! :show_project, project

    u = current_user
    u.add_recent_project(params[:project_id])
    session[:current_project_id] = params[:project_id]
    session[:pbs_project_element_id] = project.root_component

    if params[:from_tree_history_view]
     redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history')
    else
      redirect_to '/dashboard', :notice => I18n.t('project_is_activated', :project_title => "#{project.title}")
    end
  end

  def find_use_project
    @project = Project.find(params[:project_id])
    authorize! :show_project, @project

    @related_projects = Array.new
    @related_projects_inverse = Array.new

    unless @project.nil?
      related_pe_wbs_project = @project.pe_wbs_projects.products_wbs
      related_pbs_projects = PbsProjectElement.where(:pe_wbs_project_id => related_pe_wbs_project)
      unless related_pe_wbs_project.empty?
        related_pbs_projects.each do |pbs|
          unless pbs.project_link.nil? or pbs.project_link.blank?
            p = Project.find_by_id(pbs.project_link)
            @related_projects << p
          end
        end
      end
    end

    related_pbs_project_elements = PbsProjectElement.where('project_link IN (?)', [params[:project_id]]).all
    related_pbs_project_elements.each do |i|
      @related_projects_inverse << i.pe_wbs_project.project
    end

    @related_users = @project.users
    @related_groups = @project.groups
  end

  def projects_global_params
    set_page_title 'Project global parameters'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def default_work_element_type
    wet = WorkElementType.find_by_alias('folder')
    return wet
  end

  #Add/Import a WBS-Activity template from Library to Project
  def add_wbs_activity_to_project
    @project = Project.find(params[:project_id])
    authorize! :alter_wbsactivities, @project

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @wbs_project_elements_root = @project.wbs_project_element_root

    selected_wbs_activity_elt = WbsActivityElement.find(params[:wbs_activity_element])

    wbs_project_element = WbsProjectElement.new(:pe_wbs_project_id => @pe_wbs_project_activity.id, :wbs_activity_element_id => selected_wbs_activity_elt.id,
                                                :wbs_activity_id => selected_wbs_activity_elt.wbs_activity_id, :name => selected_wbs_activity_elt.name,
                                                :description => selected_wbs_activity_elt.description, :ancestry => @wbs_project_elements_root.id,
                                                :author_id => current_user.id, :copy_number => 0,
                                                :wbs_activity_ratio_id => params[:project_default_wbs_activity_ratio], # Update Project default Wbs-Activity-Ratio
                                                :is_added_wbs_root => true)

    selected_wbs_activity_children = selected_wbs_activity_elt.children

    respond_to do |format|
      #wbs_project_element.transaction do
      if wbs_project_element.save
        selected_wbs_activity_children.each do |child|
          create_wbs_activity_from_child(child, @pe_wbs_project_activity, @wbs_project_elements_root)
        end

        #add some additional information for leaf element customization
        added_wbs_project_elements = WbsProjectElement.find_all_by_wbs_activity_id_and_pe_wbs_project_id(wbs_project_element.wbs_activity_id, @pe_wbs_project_activity.id)
        added_wbs_project_elements.each do |project_elt|
          if project_elt.has_children?
            project_elt.can_get_new_child = false
          else
            project_elt.can_get_new_child = true
          end
          project_elt.save
        end

        @project.included_wbs_activities.push(wbs_project_element.wbs_activity_id)
        if @project.save
          flash[:notice] = I18n.t(:notice_wbs_activity_successful_added)
        else
          flash[:error] = "#{@project.errors.full_messages.to_sentence}"
        end
      else
        flash[:error] = "#{wbs_project_element.errors.full_messages.to_sentence}"
      end
      #end
      format.html { redirect_to edit_project_path(@project, :anchor => 'tabs-3') }
      format.js { redirect_to edit_project_path(@project, :anchor => 'tabs-3') }
    end
  end


private

  def get_new_ancestors(node, pe_wbs_activity, wbs_elt_root)
    #No authorize required since this method is private and won't be call from any route
    node_ancestors = node.ancestry.split('/')
    new_ancestors = []
    new_ancestors << wbs_elt_root.id
    node_ancestors.each do |ancestor|
      corresponding_wbs_project = WbsProjectElement.where('wbs_activity_element_id = ? and pe_wbs_project_id = ?', ancestor, pe_wbs_activity.id).first
      new_ancestors << corresponding_wbs_project.id
    end
    new_ancestors.join('/')
  end

  def create_wbs_activity_from_child(node, pe_wbs_activity, wbs_elt_root)
    project = pe_wbs_activity.project
    authorize! :alter_wbsactivities, @project

    wbs_project_element = WbsProjectElement.new(:pe_wbs_project_id => pe_wbs_activity.id, :wbs_activity_element_id => node.id, :wbs_activity_id => node.wbs_activity_id, :name => node.name,
                                                :description => node.description, :ancestry => get_new_ancestors(node, pe_wbs_activity, wbs_elt_root), :author_id => current_user.id, :copy_number => 0)
    wbs_project_element.transaction do
      wbs_project_element.save

      if node.has_children?
        node_children = node.children
        node_children.each do |node_child|
          ActiveRecord::Base.transaction do
            create_wbs_activity_from_child(node_child, pe_wbs_activity, wbs_elt_root)
          end
        end
      end
    end
  end


public

  def refresh_wbs_project_elements
    @project = Project.find(params[:project_id])
    authorize! :edit_project, @project

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @show_hidden = params[:show_hidden]
    @is_project_show_view = params[:is_project_show_view]
  end

  #On edit page, select ratios according to the selected wbs_activity
  def refresh_wbs_activity_ratios
    authorize! :edit_wbs_activities, WbsActivity

    if params[:wbs_activity_element_id].empty? || params[:wbs_activity_element_id].nil?
      @wbs_activity_ratios = []
    else
      selected_wbs_activity_elt = WbsActivityElement.find(params[:wbs_activity_element_id])
      @wbs_activity = selected_wbs_activity_elt.wbs_activity
      @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    end
  end

  # On the project edit view, we are going to show to user the current selected WBS-Activity elements
  # without adding it to the project until it saves it with the "Add" button
  def render_selected_wbs_activity_elements
    @project = Project.find(params[:project_id])
    authorize! :edit_project, @project

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @show_hidden = params[:show_hidden]
    @is_project_show_view = params[:is_project_show_view]
  end

  def choose_project
    u = current_user
    project = Project.find(params[:project_id])
    authorize! :edit_project, project

    u.add_recent_project(params[:project_id])
    session[:current_project_id] = params[:project_id]
    redirect_to edit_project_path(params[:project_id])
  end

  def locked_plan
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @project.locked? ? @project.is_locked = false : @project.is_locked = true
    @project.save
    redirect_to edit_project_path(@project, :anchor => 'tabs-4')
  end

  def projects_from
    @projects = Project.where(:is_model => true)
    authorize! :create_project_from_template, Project
  end

  #Checkout the project
  def checkout
    old_prj = Project.find(params[:project_id])

    if old_prj.checkpoint? || old_prj.released?
      if can?(:commit_project, old_prj) || can?(:manage, old_prj)
        begin
          authorize! :commit_project, old_prj
          authorize!(:allow_to_create_branch, old_prj) if old_prj.has_children?

          # If project is not childless, a new branch need to be created
          # And user need have the "allow_to_create_branch" permission to create new branch
          if old_prj.has_children? && (cannot? :allow_to_create_branch, old_prj)
            redirect_to :back, :flash => {:warning => I18n.t('warning_not_allow_to_create_new_branch_of_project')} and return
          end

          old_prj_copy_number = old_prj.copy_number
          old_prj_pe_wbs_product_name = old_prj.pe_wbs_projects.products_wbs.first.name
          old_prj_pe_wbs_activity_name = old_prj.pe_wbs_projects.activities_wbs.first.name


          new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
          old_prj.copy_number = old_prj_copy_number

          new_prj.title = old_prj.title
          new_prj.alias = old_prj.alias
          new_prj.description = old_prj.description
          new_prj.state = 'preliminary'
          new_prj.version = set_project_version(old_prj)
          new_prj.parent_id = old_prj.id

          if new_prj.save
            old_prj.save #Original project copy number will be incremented to 1

            #Managing the component tree : PBS
            pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first
            pe_wbs_activity = new_prj.pe_wbs_projects.activities_wbs.first

            pe_wbs_product.name = old_prj_pe_wbs_product_name
            pe_wbs_activity.name = old_prj_pe_wbs_activity_name

            pe_wbs_product.save
            pe_wbs_activity.save

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

                # For PBS-Project-Element Links with modules
                old_pbs = PbsProjectElement.find(new_c.copy_id)
                new_c.module_projects = old_pbs.module_projects

                new_c.save
              end
            end

            # For WBS
            new_prj_wbs = pe_wbs_activity.wbs_project_elements
            new_prj_wbs.each do |new_wbs|
              unless new_wbs.is_root?
                new_ancestor_ids_list = []
                new_wbs.ancestor_ids.each do |ancestor_id|
                  ancestor_id = WbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_wbs.pe_wbs_project_id, ancestor_id).id
                  new_ancestor_ids_list.push(ancestor_id)
                end
                new_wbs.ancestry = new_ancestor_ids_list.join('/')
                new_wbs.save
              end
            end

            # For ModuleProject associations
            old_prj.module_projects.group(:id).each do |old_mp|
              new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)
              old_mp.associated_module_projects.each do |associated_mp|
                new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
                new_mp.associated_module_projects << new_associated_mp
              end
            end

            flash[:success] = I18n.t(:notice_project_successful_checkout)
            redirect_to (edit_project_path(new_prj, :anchor => "tabs-history")), :notice => I18n.t(:notice_project_successful_checkout) and return

            #raise "#{RuntimeError}"
          else
            flash[:error] = I18n.t(:error_project_checkout_failed)
            redirect_to '/projects', :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
          end

        rescue
          flash[:error] = I18n.t(:error_project_checkout_failed)
          redirect_to '/projects', :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
          ###redirect_to(edit_project_path(old_prj, :anchor => 'tabs-history'), :flash => {:error => I18n.t(:error_project_checkout_failed)} ) and return
        end
      else
        redirect_to "#{session[:return_to]}", :flash => {:warning => I18n.t('warning_checkout_unauthorized_action')}
      end # END commit or manage permissions
    else
      redirect_to "#{session[:return_to]}", :flash => {:warning => I18n.t('warning_project_cannot_be_checkout')}
    end  # END commit permission

  end

private

  # Set the new checked-outed project version
  def set_project_version(project_to_checkout)
    #No authorize is required as method is private and could not be accessed by any route
    new_version = ''
    parent_version = project_to_checkout.version

    # The new version number is calculated according to the parent project position (if parent project has children or not)
    if project_to_checkout.is_childless?
      # get the version last numerical value
      version_ended = parent_version.split(/(\d\d*)$/).last

      #Test if ended version value is a Integer
      if version_ended.valid_integer?
        new_version_ended = "#{ version_ended.to_i + 1 }"
        new_version = parent_version.gsub(/(\d\d*)$/, new_version_ended)
      else
        new_version = "#{ version_ended }.1"
      end
    else
      #That means project has successor(s)/children, and a new branch need to be created
      branch_version = 1
      branch_name = ''
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

      # If new_version is not available, then check for new available version
      until is_project_version_available?(project_to_checkout.title, project_to_checkout.alias, new_version)
        branch_version = branch_version+1
        new_version = "#{branch_name}-#{branch_version}.#{parent_version_ended_end}"
      end
    end
    new_version
  end

  #Function that check the couples (title,version) and (alias, version) availability
  def is_project_version_available?(parent_title, parent_alias, new_version)
    begin
      #No authorize required
      project = Project.where('(title=? AND version=?) OR (alias=? AND version=?)', parent_title, new_version, parent_alias, new_version).first
      if project
        false
      else
        true
      end
    rescue
      false
    end
  end


public

  #Filter the projects list according to version
  def add_filter_on_project_version
    #No authorize required
    selected_filter_version = params[:filter_selected]
    #"Display leaves projects only",1], ["Display all versions",2], ["Display root version only",3], ["Most recent version",4]

    # The current user can only see projects of its organizations
    @organization_user_projects = []
    current_user.organizations.each do |organization|
      @organization_user_projects << organization.projects.all
    end

    case params[:project_list_name]
      when "filter_projects_version"
        # Then only projects on which the current is authorise to see will be displayed
        @projects = @organization_user_projects.flatten & current_user.projects

      when "filter_user_projects_version"
        # The current_user organizations's projects
        @projects = @organization_user_projects.flatten

      when "filter_group_projects_version"
        # The current_user organizations's projects
        @projects = @organization_user_projects.flatten
      else
        @projects = @organization_user_projects.flatten & current_user.projects
    end

    unless selected_filter_version.empty?
      case selected_filter_version
        when '1' #Display leaves projects only
          @projects = @projects.reject { |i| !i.is_childless? }

        when '2' #Display all versions
          @projects = @projects

        when '3' #Display root version only
          @projects = @projects.reject { |i| !i.is_root? }

        when '4' #Most recent version
          #@projects = @projects.reorder('updated_at DESC').uniq_by(&:title)
          @projects = @projects.sort{ |x,y| y.updated_at <=> x.updated_at }.uniq(&:title)

        else
          @projects = @projects #Project.all
      end
    end
    @projects
  end

  #Function that manage link_to from project history graphical view
  def show_project_history
    #No authorize required as authorizations are manage  in each called function...
    @counter = params['counter']
    checked_node_ids = params['checked_node_ids']
    action_id = params['action_id']
    @string_url = ""
    if @counter.to_i > 0
      begin
        project_id = checked_node_ids.first
        case action_id
          when "edit_node_path"
            @string_url = edit_project_path(:id => project_id)
          when "delete_node_path"
            @string_url = confirm_deletion_path(:project_id => project_id, :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "activate_node_path"
            @string_url = activate_project_path(:project_id => project_id, :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "find_use_projects" #when "find_use_node_path"
            @string_url = find_use_project_path(:project_id => project_id)
          when "promote_node_path"
            @string_url = commit_path(:project_id => project_id, :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "duplicate_node_path"
            @string_url = "/projects/#{project_id}/duplicate"
          when "checkout_node_path"
            @string_url = checkout_path(:project_id => project_id)
          when "collapse_node_path"
            @string_url = collapse_project_version_path(:project_ids => params[:project_ids], :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          else
            @string_url = session[:return_to]
        end
      rescue
        @string_url = session[:return_to]
      end
    end
  end

  #Function for collapsing project version
  def collapse_project_version
    projects = Project.find_all_by_id(params[:project_ids])
    flash_error = ""
    Project.transaction do
      projects.each do |project|
        begin

          authorize! :delete_project, project

          if is_collapsible?(project.reload)
            project_parent =  project.parent
            project_child = project.children.first
            #delete link between project to delete and its parent and child
            new_ancestry = project_child.ancestor_ids.delete_if { |x| x == project.id }.join("/")
            #project_child.update_attribute project.class.ancestry_column, new_ancestry || nil
            project_child.update_attribute(:parent, project_parent)
            project_child.save
            project.destroy
            current_user.delete_recent_project(project.id)
            session[:current_project_id] = current_user.projects.first
          else
            flash_error += "\n\n" + I18n.t('project_is_not_collapsible', :project_title_version => "#{project.title}-#{project.version}")
            next
          end
        rescue CanCan::AccessDenied
          flash_error += "\n\n" + I18n.t('project_is_not_collapsible', :project_title_version => "#{project.title}-#{project.version}") + "," +  I18n.t(:error_access_denied)
          next
        end
      end
    end
    unless flash_error.blank?
      flash[:error] = flash_error + I18n.t('collapsible_project_only')
    end
    if params['current_showed_project_id'].nil? || (params['current_showed_project_id'] && params['current_showed_project_id'].in?(params[:project_ids]) )
      redirect_to projects_path, :notice => I18n.t('notice_successful_collapse_project_version')
    else
      redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'), :notice => I18n.t('notice_successful_collapse_project_version')
    end
  end

  #Function that check if project is collapsible
  def is_collapsible?(project)
    #No authorize is required
    begin
      if project.checkpoint?
        if !project.is_root? && project.child_ids.length==1
          true
        else
          false
        end
      else
        false
      end
    rescue
      false
    end
  end

  def show_module_configuration
  end


  # Display the estimation results with activities by profile
  def results_with_activities_by_profile
    @project = current_project
    authorize! :alter_estimation_plan, @project

    @current_component = current_component
    @project_organization = @project.organization
    @project_organization_profiles = @project_organization.organization_profiles
    @module_project = current_module_project

    # Project pe_wbs_activity
    pe_wbs_activity = @project.pe_wbs_projects.activities_wbs.first

    # Get the wbs_project_element which contain the wbs_activity_ratio
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
    #wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
    # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
    wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

    # By default, use the project default Ratio as Reference, unless PSB got its own Ratio,
    @ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio

    # If Another default ratio was defined in PBS, it will override the one defined in module-project
    if !@current_component.wbs_activity_ratio.nil?
      @ratio_reference = @current_component.wbs_activity_ratio
    end

    @attribute = PeAttribute.find_by_alias_and_record_status_id("effort", @defined_record_status)
    @estimation_values = @module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', @attribute.id, "output").first
    @estimation_probable_results = @estimation_values.send('string_data_probable')
    @estimation_pbs_probable_results = @estimation_probable_results[@current_component.id]
  end


  # Function that show the estimation graph
  def show_estimation_graph
    @timeline = []
    @project = current_project
    @current_module_project = current_module_project
    @component = current_component

    #unless @current_module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      delay = PeAttribute.where(alias: "delay").first
      end_date = PeAttribute.where(alias: "end_date").first
      staffing = PeAttribute.where(alias: "staffing").first
      effort = PeAttribute.where(alias: "effort").first

      products = @project.root_component.subtree.sort_by(&:position)
      products.each_with_index do |element, i|
        begin
          dev = EstimationValue.where(pe_attribute_id: delay.id, module_project_id: @current_module_project.id).first.string_data_probable[element.id]
          if !dev.nil?
            d = dev.to_f
            if d.nil?
              dh = 1.hours
            else
              dh = d.hours
            end

            ed = EstimationValue.where(pe_attribute_id: end_date.id, module_project_id: @current_module_project.id).first.string_data_probable[element.id]

            @component.end_date = ed
            @component.save

            unless dh.nan?
              @timeline << [element.name, element.start_date.nil? ? @project.start_date : element.start_date, element.start_date.nil? ? @project.start_date + dh : element.start_date + dh]
            else
              @timeline << [element.name, element.start_date.nil? ? @project.start_date : element.start_date, element.start_date.nil? ? @project.start_date : element.start_date]
            end
          end
        rescue

        end
      end

      #begin
      #  @timeline[0][2] = @timeline.map(&:last).max
      #rescue
      #end

    unless @current_module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      k = EstimationValue.where(pe_attribute_id: effort.id, module_project_id: @current_module_project.id).first.string_data_probable[current_component.id].to_i
      a = 2
      m = EstimationValue.where(module_project_id: current_module_project.id, pe_attribute_id: delay.id).first.string_data_probable[current_component.id] / current_project.organization.number_hours_per_month
      if !k.nil?
        @schedule_hash = {}
        ((0..m).to_a).each do |i|
          #@schedule_hash[i.to_s] = 3*i**0.33
          t = i/12.to_f
          @schedule_hash[i.to_s] = 2*k*a*t*Math.exp(-(a)*t*t)
        end
      end

      k = EstimationValue.where(pe_attribute_id: effort.id, module_project_id: @current_module_project.id).first.string_data_probable[current_component.id].to_i
      p k
      p effort
      p @current_module_project.id
      p current_component.id

      begin
        @schedule_hash2 = {}
        ((0..k).to_a).each do |i|
          @schedule_hash2[i.to_s] = 3*i**0.33
        end
      rescue
        @schedule_hash2 = {}
        ((0..100).to_a).each do |i|
          @schedule_hash2[i.to_s] = 3*i**0.33
        end
      end
    end


    #Barchart
    @efforts = Hash.new
    results = EstimationValue.where(module_project_id: @current_module_project.id, in_out: "output").all
    results.each do |result|
      level_values = []
      ["low", "most_likely", "high"].each do |level|
        level_values << [level, result.send("string_data_#{level}")[current_component.id]]
      end
      @efforts[result.pe_attribute.name] = level_values
    end


    @project_organization = @project.organization
    @project_module_projects = @project.module_projects
    # the current activated component (PBS)
    @current_component = current_component

    #get the current activated module project
    @current_mp_attributes = []
    @input_dataset = {}
    @all_cocomo_advanced_factors_names = []
    @complexities_name = []
    @organization_uow_complexities = []
    @cocomo_advanced_input_dataset = {}
    # Dataset of the effort-breakdown stacked bar chart
    @effort_breakdown_stacked_bar_dataset = {}
    # the Cocomo_advanced = Cocomo_Intermediate factors
    @cocomo_advanced_factor_corresponding = []
    # The CocomoII = Cocomo_Expert factors
    @cocomo2_factors_corresponding = []
    # Contains all attribute name according to their aliases
    @all_attributes_names = {"effort_person_hour" => I18n.t(:effort_person_hour), "effort" => I18n.t(:effort), "effort_person_week" => I18n.t(:effort_person_week), "cost" => I18n.t(:cost),
                            "delay" => I18n.t(:delay), "end_date" => I18n.t(:end_date), "staffing" => I18n.t(:staffing), "staffing_complexity" => I18n.t(:staffing_complexity), "duration" => I18n.t(:duration),
                            "effective_technology" => I18n.t(:effective_technology), "schedule" => I18n.t(:schedule), "defects"=>I18n.t(:defects), "note" => I18n.t(:note), "methodology" => I18n.t(:methodology),
                            "real_time_constraint" => I18n.t(:real_time_constraint), "platform_maturity" => I18n.t(:platform_maturity), "list_sandbox" => I18n.t(:list_sandbox), "date_sandbox"=>I18n.t(:date_sandbox),
                            "description_sandbox"=>I18n.t(:description_sandbox), "float_sandbox" =>I18n.t(:float_sandbox), "integer_sandbox"=> I18n.t(:integer_sandbox), "complexity"=>I18n.t(:complexity),
                            "sloc"=>I18n.t(:sloc), "sloc"=>I18n.t(:sloc), "size"=>I18n.t(:size)}

    # Attributes Unit : Table of Attributes units according to their aliases
    @attribute_yAxisUnit_array =  {
        'cost' => (@project_organization.currency.nil? ? "Unit" : @project_organization.currency.name.capitalize),
        'effort' => I18n.t(:unit_effort), 'effort_person_hour' =>  I18n.t(:unit_effort_person_hour),
        'delay' => I18n.t(:unit_delay), 'end_date' => I18n.t(:unit_end_date), 'staffing' => I18n.t(:unit_staffing),
        'sloc' => I18n.t(:unit_sloc), 'sloc' => I18n.t(:unit_sloc)
    }

    #========================================== CocomoIntermediate (CocomoAdvanced) AND CocomoII (CocomoExpert) modules data =============================================

    #if @current_module_project.pemodule.alias == Projestimate::Application::COCOMO_ADVANCED
    if @current_module_project.pemodule.alias.in? Projestimate::Application::MODULES_WITH_FACTORS
      # get the factors for the CocomoAdvanced and CocomoII estimation modules: the data are stored in the "input_cocomos" table that make links between the factors and the CocomoAdvanced module
      @complexities_name = @current_module_project.organization_uow_complexities.map(&:name).uniq
      @cocomo_advanced_factors =  @current_module_project.factors   #Factor.where('factor_type = ?', "advanced") #
      @all_cocomo_advanced_factors_names = @cocomo_advanced_factors.map(&:name)
      current_module_project_name = @current_module_project.pemodule.alias

      coefficients_hash = {"Extra Low" => 1, "Very Low" => 2, "Low" => 3, "Normal" => 4, "High" => 5, "Very High" => 6, "Extra High" => 7}
      # Median value correspond to the "Default" value defined by the Organization
      @cocomo_advanced_input_dataset["default"] = Array.new
      @cocomo_advanced_input_dataset["#{current_module_project_name}"] = Array.new

      factor_data = {}
      @complexities_name.each do |complexity_name|
        factor_data["#{complexity_name}"] = Array.new
      end

      project_organization =
      # dataset for the Radar chart about Factors
      @current_module_project.input_cocomos.where('pbs_project_element_id = ?', @current_component.id).each do |input_cocomo|
        @cocomo_advanced_factor_corresponding << input_cocomo.factor.name
        @cocomo_advanced_input_dataset["#{current_module_project_name}"] << coefficients_hash[input_cocomo.organization_uow_complexity.name]

        ###@cocomo_advanced_input_dataset["median"] << coefficients_hash["Normal"]
        # The Median value will be the value defined in the project's organization default factors values
        #org_factor_with_default_cplex = input_cocomo.factor.organization_uow_complexities.where('organization_id=? AND is_default = ?', @project_organization.id, true)
        org_factor_uow_with_default_cplex = input_cocomo.factor.organization_uow_complexities.where('organization_id=? AND is_default = ?', @project_organization.id, true).first
        if org_factor_uow_with_default_cplex.nil?
          # Median value will be set to 0
          @cocomo_advanced_input_dataset["default"] << 0
        else
          @cocomo_advanced_input_dataset["default"] << coefficients_hash[org_factor_uow_with_default_cplex.name]
        end
      end

      attr_staffing = PeAttribute.where('alias=? AND record_status_id=? ', "staffing", @defined_status).first
      staffing = @current_module_project.estimation_values.where(pe_attribute_id: attr_staffing.id).first.string_data_probable[current_component.id]
      @staffing_profile_data = []
      begin
        @staffing_profile_data <<  staffing.to_i
      rescue
        @staffing_profile_data << nil.to_i
      end

      #Rayleigh
      @staffing_profile_data = []
      @staffing_labels = []

      #begin
        attr_effort = PeAttribute.find_by_alias('effort')
        attr_delay = PeAttribute.find_by_alias('delay')

        delay = EstimationValue.where(module_project_id: current_module_project.id, pe_attribute_id: attr_delay.id).last.string_data_probable[current_component.id]
        effort = EstimationValue.where(module_project_id: current_module_project.id, pe_attribute_id: attr_effort.id).last.string_data_probable[current_component.id]

        m =  delay.to_f / current_project.organization.number_hours_per_month
        k = effort
        a = 2 #pente

        m.floor.times do |i|
          t = i/12.to_f
          @staffing_labels << i
          @staffing_profile_data << 2*k*a*t*Math.exp(-(a)*t*t)
        end
      #rescue
      #end

      puts "ALL FACTOR_DATA LAST = #{@cocomo_advanced_input_dataset}"
    end

    #======================================== CURRENT MODULE OUTPUTS DATA ==============================================
    @current_mp_outputs_dataset = {}
    @current_mp_effort_per_activity = Hash.new
    # get all current module_project attributes for outputs data
    end_date_attribute = PeAttribute.find_by_alias_and_record_status_id("end_date", @defined_status.id)
    #@current_mp_outputs_attr_modules = @current_module_project.pemodule.attribute_modules.where('in_out IN (?)', %w(output both))
    @current_mp_outputs_attr_modules = @current_module_project.pemodule.attribute_modules.where('in_out IN (?) AND pe_attribute_id != ?', %w(output both), end_date_attribute)
    # Outputs attributes array
    @current_mp_outputs_attributes = []

    # For the Balancing module, only selected balancing attribute results will be displayed in chart
    if @current_module_project.pemodule.alias == Projestimate::Application::BALANCING_MODULE
      @current_mp_outputs_attributes << current_balancing_attribute
    else
      @current_mp_outputs_attr_modules.each do |attr_module|
        @current_mp_outputs_attributes << attr_module.pe_attribute
      end
    end

    # get all project's wbs-project_elements
    @project_wbs_project_elts = @project.wbs_project_elements
    @project_wbs_project_elts.each do |wbs_project_elt|
      @effort_breakdown_stacked_bar_dataset["#{wbs_project_elt.name.parameterize.underscore}"] = Array.new
    end

    # get all Attributes aliases
    @current_mp_outputs_attributes_aliases = @current_mp_outputs_attributes.map(&:alias)
    puts "@current_mp_outputs_attributes_aliases = #{@current_mp_outputs_attributes_aliases}"

    # generate output attributes values
    @current_mp_outputs_attributes.each do |output_attr|
      attr_data = [] # [low_value, most_likely_value, high_value]
      attr_estimation_value = @current_module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', output_attr.id, "output").last
      if !attr_estimation_value.nil?
        #  attr_data = [attr_estimation_value.string_data_low[@current_component.id], attr_estimation_value.string_data_most_likely[@current_component.id], attr_estimation_value.string_data_high[@current_component.id], attr_estimation_value.string_data_probable[@current_component.id]]
        ["low", "most_likely", "high", "probable"].each do |level|
          level_value = attr_estimation_value.send("string_data_#{level}")
          if @current_module_project.pemodule.with_activities.in?(%w(yes_for_output_with_ratio yes_for_input_output_without_ratio yes_for_input_output_without_ratio yes_for_input_output_without_ratio))
            # module with activities
            @current_mp_effort_per_activity = { "low" => {}, "most_likely" => {}, "high" => {}, "probable" => {} }
            if level_value.nil?
              pbs_level_value=nil.to_i
              @project_wbs_project_elts.each do |elt|
                @effort_breakdown_stacked_bar_dataset["#{elt.name.parameterize.underscore}"] << 0
              end
            else
              # Data structure : test = {"5" => {"36" => {:value => 10} , "37"=> {:value => 20} },  "6" => {"36" => {:value => 5}, "37"=> {:value => 15} } }
              pbs_level_with_activities = level_value[@current_component.id]
              sum_of_value = 0.0
              if !pbs_level_with_activities.nil?
                pbs_level_with_activities.each do |wbs_activity_elt_id, hash_value|
                  sum_of_value = sum_of_value + hash_value[:value]
                  wbs_project_elt = WbsProjectElement.find(wbs_activity_elt_id)
                  unless wbs_project_elt.is_root || wbs_project_elt.has_children?
                    @current_mp_effort_per_activity[level]["#{wbs_project_elt.name.parameterize.underscore}"] = hash_value[:value]
                    @effort_breakdown_stacked_bar_dataset["#{wbs_project_elt.name.parameterize.underscore}"] << hash_value[:value]
                  end
                end
              end
              pbs_level_value = sum_of_value
            end
          else
            # Attribute for Date and Datetime need to be customized for the chart
            #if output_attr.attr_type == "date"
              #level_value.nil? ? (pbs_level_value=nil.to_i) : (pbs_level_value=level_value[@current_component.id].to_i)
            #else
              level_value.nil? ? (pbs_level_value=nil.to_i) : (pbs_level_value=level_value[@current_component.id].to_f)
            #end
          end
          attr_data << pbs_level_value
        end
      end
      #update the attribute array in dataset
      @current_mp_outputs_dataset["#{output_attr.alias}"] = attr_data
    end
    puts "OUTOUT_DATASET = #{@current_mp_outputs_dataset}"
    puts "STACKED_BAR = #{@effort_breakdown_stacked_bar_dataset}"

    #======================================== END CURRENT MODULE OUTPUTS DATA ==============================================

    # get all current module_project attribute value
    @current_module_project.pemodule.pe_attributes.each do |attr|
      attr_data = Array.new
      attr_estimation_value = @current_module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', attr.id, "input").last
      unless attr_estimation_value.nil?
        # on estimation, we have four (4) levels : (string_data_low, string_data_most_likely, string_data_high, string_data_probable)
        ["low", "most_likely", "high"].each do |level|
          #@current_mp_attributes << attr_estimation_value.pe_attribute
          string_data_level = attr_estimation_value.send("string_data_#{level}")
          if string_data_level.nil?
            attr_data << ""
          else
            attr_data << string_data_level[@current_component.id]
          end
          #@input_dataset["#{attr.alias}"] = attr_data
          @input_dataset["#{attr_estimation_value.pe_attribute.alias}"] = attr_data
        end
      end
    end
    puts "INPUT DATA = #{@input_dataset}"


    #=============================================  All project data (modules, attributes, ...)  ==========================================
    #================================ Initialization module data for all estimations chart (per attribute) ================================

    # When user selects the Initialization module from the Dashbord, chart will be displayed for all estimations

    # get the all project modules for the charts labels
    @project_modules = []
    @corresponding_attributes_aliases_for_init = %w(effort effort_person_hour effort_person_week cost delay staffing sloc)
    # contains all the modules attributes labels
    @init_attributes_labels = []
    @attributes = []
    @project_module_projects.each do |mp|
      @project_modules << mp.pemodule
      @attributes << mp.pemodule.pe_attributes.where('alias IN (?)', @corresponding_attributes_aliases_for_init)
      #@attributes_labels = @attributes_labels + mp.pemodule.pe_attributes.all.map(&:alias)
    end
    @attributes = @attributes.flatten.sort.uniq
    @init_attributes_labels = @attributes.map(&:alias).flatten.sort.uniq
    @init_project_modules = @project_modules.map(&:title)

    # get the project PBS root
    psb_root = @project.pbs_project_elements.first.root

    # generate the dataset for charts
    @init_module_dataset = {}
    # Dataset is get by attribute
    # one dataset data correspond of all modules values for this attribute
    @attributes.each do |attr|
      attr_data = Array.new
      @project_module_projects.each do |mp|
        attr_estimation_value = mp.estimation_values.where('pe_attribute_id = ? AND in_out = ?', attr.id, 'output').last
        pbs_level_value = nil.to_i
        ###==================
        if !attr_estimation_value.nil?
          #attr_data << attr_estimation_value.string_data_low[psb_root.id]
          #attr_data << attr_estimation_value.string_data_probable[@current_component.id]
          level_value = attr_estimation_value.send("string_data_probable")
          if mp.pemodule.with_activities.in?(%w(yes_for_output_with_ratio yes_for_input_output_without_ratio yes_for_input_output_without_ratio yes_for_input_output_without_ratio))
            # module with activities
            mp_value_per_activity = { "low" => {}, "most_likely" => {}, "high" => {}, "probable" => {} }
            if !level_value.nil?
              # Data structure : test = {"5" => {"36" => {:value => 10} , "37"=> {:value => 20} },  "6" => {"36" => {:value => 5}, "37"=> {:value => 15} } }
              pbs_level_with_activities = level_value[@current_component.id]
              sum_of_value = 0.0
              if !pbs_level_with_activities.nil?
                pbs_level_with_activities.each do |wbs_activity_elt_id, hash_value|
                  sum_of_value = sum_of_value + hash_value[:value]
                end
              end
              pbs_level_value = sum_of_value
            end
          else
            level_value.nil? ? (pbs_level_value=nil.to_i) : (pbs_level_value=level_value[@current_component.id].to_f)
          end
        end
        attr_data << pbs_level_value

        #========================
      end
      @init_module_dataset[:"#{attr.alias}"] = attr_data
    end
    puts "DATASET = #{@init_module_dataset}"
  end

  def load_setting_module
    @module_project = ModuleProject.find(params[:module_project_id])
    if @module_project.pemodule.alias == "guw"

    elsif @module_project.pemodule.alias == "uow"
      @pbs = current_component

      @uow_inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).order("display_order ASC").all
      if @uow_inputs.empty?
        @input = UowInput.new(module_project_id: @module_project.id, pbs_project_element_id: @pbs.id, display_order: 0)
        @input.save(validate: false)
        @inputs = UowInput.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).order("display_order ASC").all
      end

      @organization_technologies = current_project.organization.organization_technologies.map{|i| [i.name, i.id]}
      @unit_of_works = current_project.organization.unit_of_works.map{|i| [i.name, i.id]}
      #@complexities = []
      #organization_unit_of_works = current_project.organization.unit_of_works.first
      #if !organization_unit_of_works.nil?
      @complexities = current_component.organization_technology.organization_uow_complexities.map{|i| [i.name, i.id]}
      #end

      @module_project.pemodule.attribute_modules.each do |am|
        if am.pe_attribute.alias ==  "effort"
          @size = EstimationValue.where(:module_project_id => @module_project.id,
                                        :pe_attribute_id => am.pe_attribute.id,
                                        :in_out => "input" ).first

          @gross_size = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id).first
        end
      end

    elsif @module_project.pemodule.alias == "cocomo_advanced"

      @aprod = Array.new
      aliass = %w(rely data cplx ruse docu)
      aliass.each do |a|
        @aprod << Factor.where(alias: a, factor_type: "advanced").first
      end

      @aplat = Array.new
      aliass = %w(time stor pvol)
      aliass.each do |a|
        @aplat << Factor.where(alias: a, factor_type: "advanced").first
      end

      @apers = Array.new
      aliass = %w(acap aexp ltex pcap pexp pcon)
      aliass.each do |a|
        @apers << Factor.where(alias: a, factor_type: "advanced").first
      end

      @aproj = Array.new
      aliass = %w(tool site sced)
      aliass.each do |a|
        @aproj << Factor.where(alias: a, factor_type: "advanced").first
      end
    else
      set_breadcrumbs "Dashboard" => "/dashboard", "Cocomo Expert" => ""

      @sf = []
      @em = []

      aliass = %w(pers rcpx ruse pdif prex fcil sced)
      aliass.each do |a|
        @em << Factor.where(alias: a).first
      end

      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        @sf << Factor.where(alias: a).first
      end
    end
  end
end
