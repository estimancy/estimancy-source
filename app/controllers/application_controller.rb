#encoding: utf-8
#########################################################################
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
########################################################################

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!

  layout :layout_by_controller

  require 'socket'

  if Rails.env == "production"
    rescue_from StandardError do |exception|
      if exception.class == CanCan::AccessDenied
        flash[:error] = I18n.t(:error_access_denied)
        unless @current_organization.nil?
          redirect_to organization_estimations_path(@current_organization)
        else
          redirect_to root_path
        end
      elsif exception.class == Curl::Err::ConnectionFailedError
      elsif exception.class == Curl::Err::ConnectionFailedError
        flash[:error] = "Le serveur IA n'est pas démarré. Veuillez contactez un administrateur Estimancy."
        redirect_to :back and return
      elsif exception.class == ActiveRecord::RecordNotFound
        flash[:error] = I18n.t(:error_resource_not_found)
        redirect_to organization_estimations_path(@current_organization) and return
      elsif exception.message.include?("warden")
        # Que faire ?
      else
        UserMailer.crash_log(exception, current_user, @current_organization, @project).deliver
        render :template => "layouts/500.html", :status => 500
      end
    end
  end


  helper_method :root_url
  helper_method :browser
  helper_method :version_browser
  helper_method :platform
  helper_method :os
  helper_method :security
  helper_method :server_name
  helper_method :projestimate_version
  helper_method :update_date
  helper_method :update_date_timestamp
  helper_method :ruby_version
  helper_method :rails_version
  helper_method :environment
  helper_method :database_adapter
  helper_method :is_master_instance? #Identify if we are on Master or Local instance
  helper_method :send_feedback
  helper_method :allow_feedback?
  helper_method :current_component
  helper_method :current_module_project
  helper_method :current_balancing_attribute
  helper_method :load_admin_setting
  helper_method :set_locale_from_browser
  helper_method :set_user_language
  helper_method :initialization_module
  helper_method :user_number_precision

  before_filter :check_access
  before_filter :set_user_time_zone
  before_filter :set_user_language
  before_filter :set_return_to
  before_filter :previous_page
  before_filter :set_breadcrumbs
  before_filter :set_current_project
  before_filter :set_current_organization
  before_filter :update_activity_time
  before_filter :initialization_module
  before_filter :get_organizations

  def get_organizations
    if user_signed_in?
      if current_user.super_admin?
        @organizations = Organization.all
      elsif can?(:manage, :all)
        @organizations = Organization.all.reject{|org| org.is_image_organization}
      else
        @organizations = current_user.organizations.all.reject{|org| org.is_image_organization}
      end
    end
  end

  # skip_before_filter :set_paper_trail_whodunnit
  # before_filter :set_paper_trail_whodunnit

  # def set_paper_trail_whodunnit
    # PaperTrail.whodunnit = current_user
  # end

  #TODO : delete this function after deletion of the paper_trail gem
  def info_for_paper_trail_save_to_delete
    # initialisation des variables
    is_model = nil ; is_group_security = nil; is_user_security = nil; is_security_on_model=nil; is_security_on_created_from_model = nil

    if params[:project_id]
      project = Project.find(params[:project_id])
      if project && project.is_model
        is_model = true
        # securite sur le modele
        if params[:is_security_on_model]
          is_security_on_model = true
        end
        # securite sur les estimations créées à partir de ce modele
        if params[:is_security_on_created_from_model]
          is_security_on_created_from_model = true
        end
      end
    end

    # Differencier les permissions/group avec les permissions/users
    if params[:model_created_from_group_security_levels]
      is_group_security = true
      if is_model == true
        is_security_on_created_from_model = true
      end
    end

    if params[:model_group_security_levels]
      is_group_security = true
    end

    if params[:user_security_levels]
      is_user_security = true
    end

    { organization_id: session[:organization_id], is_model: is_model,
      is_group_security: is_group_security, is_user_security: is_user_security,
      is_security_on_model: is_security_on_model, is_security_on_created_from_model: is_security_on_created_from_model
    } if user_signed_in? rescue nil

  end

  def reset_button_action
    flash[:warning] = "L'action a été annulée avec succès"
    return render(:nothing => true, :status => 204)
  end

  def check_access
    begin
      @online_support = AdminSetting.where(key: "online_support").first.value
      @disable_access = AdminSetting.where(key: "disable_access").first.value
      @offline_message = AdminSetting.where(key: "offline_message").first.value
      @functional_version_number = AdminSetting.where(key: "functionnal_version_number").first.value
    rescue
      @online_support = "1"
      @disable_access = "0"
      @offline_message = "L'application est actuellement hors-ligne"
      @functional_version_number = "-"
    end

    if user_signed_in?
      unless current_user.super_admin == true || current_user.subscription_end_date.nil?
        if current_user.subscription_end_date < Time.now
          flash[:error] = "La licence de votre compte est expirée."
          sign_out current_user
          reset_session
          subscription_end_date_message = %Q[La licence de votre compte a expiré. Veuillez contacter l'administrateur de votre compte <a href="mailto:contact@estimancy.com">par mail</a>]

          redirect_to(sign_in_path, :flash => { :error => subscription_end_date_message, :warning => flash[:warning] }) and return
          #redirect_to(root_path, :flash => { :error => "La licence de votre compte est expirée." }) and return false
        elsif @disable_access == "1"
          sign_out current_user
          reset_session
          redirect_to(sign_in_path, :flash => { :error => @offline_message}) and return false
        end
      end
    end
  end

  def current_ability
    # unless @project.nil?
    #   if controller_name == "projects" and @project.persisted?
    #     @current_organization = @project.organization
    #   end
    # end
    #@current_ability ||= Ability.new(current_user, @current_organization, [@project])

    begin
      if current_user.organization_ids.include?(@current_organization.id)
        # Le code qui suit remplace les lignes du dessus
        case params[:action]
          when "estimations", "sort", "search", "add_filter_on_project_version"
            # Rails.cache.fetch("ability_#{@current_organization.id}_#{current_user}") do

              @current_ability ||= Ability.new(current_user, @current_organization, @current_organization.projects)

              # u = current_user
              # u.ability = @current_ability
              # u.save

            # end
          when "projects_from"
            estimation_models = Project.includes(:estimation_status, :project_area, :project_category, :platform_category, :acquisition_category).where(organization_id: @current_organization.id, is_model: true)
            @current_ability ||= Ability.new(current_user, @current_organization, estimation_models)
        else
          @current_ability ||= Ability.new(current_user, @current_organization, [@project])

          # u = current_user
          # u.ability = @current_ability
          # u.save

        end
      else
        @current_ability = Ability.new(current_user, nil, nil)
      end
    rescue
      @current_ability = Ability.new(current_user, nil, nil)
    end
  end


  def update_activity_time
    if current_user
      unless load_admin_setting('session_inactivity_timeout')=='unset'
        session[:atime] = Time.now.utc.to_i
      end
    end
  end

  def set_return_to
    #session[:return_to] = request.referer
    session[:anchor_value] ||= params[:anchor_value]
    session[:return_to] = "#{request.referer}#{session[:anchor_value]}"
    session[:anchor_value] ||= ''
    session[:anchor] = session[:anchor_value].to_s.split('#')[1]
  end

  def allow_feedback?
    @admin_setting=AdminSetting.find_by_key('allow_feedback')
    if @admin_setting.nil?
      return false
    else
      @admin_setting.value.to_i
      if @admin_setting.value == '0'
        return false
      else
        return true
      end
    end
  end

  #For some specific tables, we need to know if record is created on MasterData instance or on the local instance
  #This method test if we are on Master or Local instance
  def is_master_instance?
    true
  end

  def redirect_apply(edit=nil, new=nil, index=nil)
    begin
      if params[:commit] == "#{I18n.t 'save'}"
        index
      elsif params[:commit] == "#{I18n.t 'save_and_create'}"
        new
      elsif params[:commit] == "#{I18n.t 'apply'}"
        edit
      else
        session[:return_to]
      end
    rescue
      url
    end
  end

  def redirect_save(url, anchor=nil)
    begin
      if anchor.nil?
        (params[:commit] == "#{I18n.t 'save'}" or params[:commit] == 'Save') ? url : session[:return_to]
      else
        (params[:commit] == "#{I18n.t 'save'}" or params[:commit] == 'Save') ? url : anchor
      end
    rescue
      url
    end
  end

  def redirect(url)
    begin
      (params[:commit] == "#{I18n.t 'save'}" or params[:commit] == 'Save') ? url : session[:return_to]
    rescue
      url
    end
  end

  def previous_page
    session[:now] ||= ''
    session[:previous] = session[:now]
    session[:now] = request.referer
  end

  def set_current_project
    begin
      if params[:project_id].present? && !params[:project_id].nil?
        session[:project_id] = params[:project_id]
        @project = Project.find(params[:project_id])
      elsif !session[:project_id].blank?
        if user_signed_in? && !session[:project_id].nil?
          @project = Project.find(session[:project_id])
        else
          @project = current_user.organizations.map(&:projects).flatten.first
          session[:project_id] = @project.id
        end
      else
        # @project = current_user.organizations.first.projects.first
        @project = nil
      end
    rescue
      @project = nil
    end
  end

  def set_current_organization
    begin
      #Si ya un parametre
      if params[:organization_id].present?
        session[:organization_id] = params[:organization_id]
        @current_organization = Organization.find(session[:organization_id])
      #Sinon on prend, la sessions
      elsif session[:organization_id].present?

        if params[:project_id].present?
          session[:organization_id] = Project.find(params[:project_id]).organization_id
          @current_organization = Organization.find(session[:organization_id])
        else
          @current_organization = Organization.find(session[:organization_id])
        end

      #Si ya pas de sessions
      else
        # @current_organization = current_user.organizations.where(is_image_organization: false).first
        # if @current_organization.nil?
          # session[:organization_id] = current_user.organizations.first.id
          # @current_organization = nil # Organization.find(session[:organization_id])
        # else
        #   session[:organization_id] = @current_organization.id
        #   @current_organization = Organization.find(session[:organization_id])
        # end
        session[:organization_id] = current_user.organizations.first.id
        @current_organization = current_user.organizations.first
      end
    rescue
      flash[:warning] = "Veuillez contacter un administrateur Estimancy."
      sign_out current_user
      session[:organization_id] = nil
      @current_organization = nil
    end


    # Pour les Trigger
    User.current = current_user.id rescue nil
    Organization.current = @current_organization.id rescue nil
  end

  # Get the selected Pbs_Project_Element
  def current_component
    if @project
      begin
        pbs = PbsProjectElement.find_by_id(session[:pbs_project_element_id])
        if pbs.pe_wbs_project.project_id == @project.id
          @component = pbs
        else
          @component = @project.root_component
        end
      rescue
        @component = @project.root_component
      end
    end
  end

  # Get the current activated module project
  def current_module_project
    if @project.nil?
      return nil
    else
      pemodule = Pemodule.find_by_alias('initialization')
      default_current_module_project = ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, @project.id).first
      if @project.module_projects.map(&:id).include?(session[:module_project_id].to_i)
        return session[:module_project_id].nil? ? default_current_module_project : ModuleProject.find(session[:module_project_id])
      else
        begin
          # pemodule = Pemodule.find_by_alias('initialization')
          # return ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, @project.id).first
          return @project.module_projects.first
        rescue
          return @project.module_projects.first
        end
      end
    end
  end

  # Get the current selected attribute for the Balancing Module
  def current_balancing_attribute
    begin
      @default_balancing_attribute = current_module_project.pemodule.pe_attributes.where('alias = ?', Projestimate::Application::EFFORT).defined.last
      if current_module_project.pemodule.alias == Projestimate::Application::BALANCING_MODULE
        @current_balancing_attribute = session[:balancing_attribute_id].nil? ? @default_balancing_attribute : PeAttribute.find(session[:balancing_attribute_id])
      else
        nil
      end
    rescue
      nil
    end
  end

  # Get the initialization module (module that get attribute values from the project organization)
  def initialization_module
    @initialization_module = Pemodule.where(alias: 'initialization').first
  end

  # Get all the adminSetting parameters
  def load_admin_setting(args)
    as = AdminSetting.find_by_key(args)
    unless as.nil?
      AdminSetting.where(key: args).first.value
    end
  end

  # Get the user according to the user preferences settings or use the default one
  def set_user_language
    unless current_user.nil? || current_user.language.nil?
      session[:current_locale] = current_user.language.locale.downcase
    else
      session[:current_locale] = set_locale_from_browser
    end
    @current_locale = session[:current_locale]
    I18n.locale = session[:current_locale]
  end

  def set_user_time_zone
    if current_user
      unless current_user.time_zone.blank?
        Time.zone = current_user.time_zone
      end
    end
  end

  def set_page_title(page_title)
    @page_title = page_title
  end

  def set_breadcrumbs(*args)
    if args.empty?
      @breacrumbs = { :"Estimates" => main_app.root_url, :"#{action_name.humanize} #{controller_name.humanize}" => request.original_url }
    else
      @breacrumbs = args.first
    end
  end

  # Get the current_user number precision defined in the user preferences (default is 2)
  def user_number_precision
    if current_user && !current_user.number_precision.nil?
      current_user.number_precision
    else
      2
    end
  end

  def set_locale_from_browser
    if  request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      I18n.locale= 'frsncf'
    else
      local_language=Language.find_by_locale(extract_locale_from_accept_language_header)
      if local_language.nil?
        I18n.locale= 'frsncf'
      else
        I18n.locale = extract_locale_from_accept_language_header
      end
    end
  end

  private
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def projestimate_version
    @projestimate_version = VERSION
  end

  def update_date
    begin
      Time.parse(COMMIT_DATE).strftime("%d/%m/%Y à %H:%M")
    rescue
      "-"
    end
  end

  def update_date_timestamp
    begin
      Time.parse(COMMIT_DATE).strftime("%d/%m/%Y à %H:%M").to_time.to_i.to_s(36)
    rescue
      "-"
    end
  end

  def ruby_version
    @ruby_version="#{RUBY_ENGINE} #{RUBY_VERSION} #{RUBY_PATCHLEVEL} [#{RUBY_PLATFORM}]"
  end

  def rails_version
    @rails_version=Rails.version
  end

  def environment
    @environment= Rails.env
  end

  def database_adapter
    @database_adapter=ActiveRecord::Base.configurations[Rails.env]['adapter']
  end

  def browser
    string = request.env['HTTP_USER_AGENT']
    user_agent = UserAgent.parse(string)
    @browser=user_agent.browser
  end

  def version_browser
    string = request.env['HTTP_USER_AGENT']
    user_agent = UserAgent.parse(string)
    @version_browser=user_agent.version
  end

  def platform
    request.env['HTTP_USER_AGENT']
  end

  def os
    request.env['HTTP_USER_AGENT']
  end

  def server_name
    @server_name=Socket.gethostname
  end

  def root_url
    @root_url=request.env['HTTP_HOST']
  end

  protected

  def layout_by_controller
    devise_controller? ? 'devise' : 'application'
  end

  # After authentication, user need to change their password during the first connection
  # So user will be redirect to the "edit_user_registration_path"
  def after_sign_in_path_for(resource)
    saml_auth = AuthMethod.where(name: "SAML").first
    unless saml_auth.nil?
      saml_auth_id = saml_auth.id
    end
    # return the path based on resource
    if resource.password_changed == true || (resource.auth_type == saml_auth_id)
      # if user has no organization, this means that his has no group, so no right
      if resource.organizations.where(is_image_organization: [false, nil]).size == 0
        flash[:warning] = I18n.t(:you_have_no_right_to_continue)
        sign_out(resource)
        new_session_path(:user)
      elsif resource.organizations.where(is_image_organization: [false, nil]).size == 1
        organization_estimations_path(resource.organizations.where(is_image_organization: [false, nil]).first)
      else
        root_path
      end
    else
      edit_user_registration_path(resource, action_to_do: "update_password_first_connexion")
    end
  end

  def show

    respond_to do |format|
      format.html {render :show}
      format.pdf do
        render pdf: "show", :layout => 'pdf.html'
        # Excluding ".pdf" extension.
      end
    end
  end



  # effectue une recherche multiple
  def get_multiple_search_results(organization_id, projects, search_elements={})

    search_hash = session[:search_hash] || {}
    search_string = ""
    final_results = []

    if search_elements.blank?
      search_elements = (params['search'].blank? ? session[:search_hash] : params['search'])
    end

    if search_elements.blank?
      #organization_projects = projects
      organization_projects = @organization.organization_estimations.where(project_id: projects.all.map(&:id))
    else
      search_elements.each do |column_name, val|
        #val = search_elements[column_name]

        search_column = column_name
        search_value = val

        search_hash[column_name] = val
        search_string << "&search[#{column_name}]=#{val}"

        results = get_search_results(@organization.id, projects, column_name, val).all.map(&:id)

        a = results.flatten
        b = final_results.flatten

        if b.blank?
          final_results << a
        else
          final_results << a & b
        end
      end

      organization_projects = @organization.organization_estimations.where(project_id: final_results.inject(&:&))
    end

    session[:search_hash] = search_hash
    session[:search_string] = search_string

    organization_projects
  end


  # effectue une recherche avec nom de la colonne et sa valeur
  def get_search_results(organization_id, projects, search_column, search_value)

    k = search_column
    val = search_value

    if search_column.blank? || search_value.blank?
      results = projects
    else
      case k
        when "title"
          results = projects.where("title LIKE ?", "%#{val}%")
        when "creator"
          creator_ids = User.where("first_name LIKE ? OR last_name liKE ?", "%#{val}%", "%#{val}%").map(&:id)
          results = projects.where(creator_id: creator_ids)
        when "version_number"
          results = projects.where("version_number LIKE ?", "%#{val}%")
        when "business_need"
          results = projects.where("business_need LIKE ?", "%#{val}%")
        when "application"
          ids = Application.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(application_id: ids)
        when "description"
          results = projects.where("description LIKE ?", "%#{val}%")
        when "status_name"
          ids = EstimationStatus.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(estimation_status_id: ids, organization_id: organization_id)
        when "start_date"
          results = projects.where("start_date LIKE ?", "%#{val}%")
        when "created_at"
          results = projects.where("created_at LIKE ?", "%#{val}%")
        when "updated_at"
          results = projects.where("updated_at LIKE ?", "%#{val}%")
        when "project_area"
          ids = ProjectArea.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(project_area_id: ids, organization_id: organization_id)
        when "project_category"
          ids = ProjectCategory.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(project_category_id: ids, organization_id: organization_id)
        when "platform_category"
          ids = PlatformCategory.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(platform_category_id: ids, organization_id: organization_id)
        when "acquisition_category"
          ids = AcquisitionCategory.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(acquisition_category_id: ids, organization_id: organization_id)
        when "provider"
          ids = Provider.where("name LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(provider_id: ids, organization_id: organization_id)
        when "original_model"
          ids = Project.where("title LIKE ?", "%#{val}%").all.map(&:id)
          results = projects.where(original_model_id: ids, organization_id: organization_id)
        when "private"
          results = projects.where("private LIKE ?", "%#{val}%")
        when "request_number"
          results = projects.where("request_number LIKE ?", "%#{val}%")
        else
          #options[k] = v
          results = projects
      end
    end

    results
  end


  def get_sorted_estimations(organization_id, projects, sort_column, sort_order, search_hash={})
    # @projects = @organization.organization_estimations

    k = sort_column #params[:f]
    s = sort_order  #params[:s]

    # Execution de la recherche avant le Tri
    #unless search_column.blank? || search_value.blank? || search_hash.blank?
    unless search_hash.blank?
      ###projects = get_search_results(organization_id, projects, search_column, search_value)
      organization_projects = get_multiple_search_results(organization_id, projects, search_hash)
      projects = Project.where(id: organization_projects.map(&:id))
    end

    project_ids = projects.map(&:id)

    if k.blank?
      projects =  projects.reorder("start_date desc")
    else
      case k
        when "start_date"
          projects = projects.order("created_at DESC") #projects.reorder(k + ' ' + s)
        when "title" , "request_number", "business_need", "version_number", "description", "private", "updated_at", "created_at"
          projects = projects.reorder("#{k} #{s}") #projects.reorder(k + ' ' + s)
        when "application"
          projects = Project.unscoped
                          .joins("LEFT JOIN applications ON projects.application_id = applications.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("applications.name #{s}")

        when "original_model"
          #projects = Project.unscoped.joins(:original_model).order("original_model.title #{s}")
          #projects = Project.joins(:original_model).merge(Project.order(title: :desc))
          #projects = Project.unscoped
          #                 .includes(:original_model)
          #                 .joins("LEFT JOIN projects ON projects.original_model_id = original_model_id")
          #                 .where(organization_id: organization_id)
          #                 .order("original_model.title #{s}")
        when "project_area"
          projects = Project.unscoped
                          .joins("LEFT JOIN project_areas ON projects.project_area_id = project_areas.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("project_areas.name #{s}")
        when "project_category"
          projects = Project.unscoped
                          .joins("LEFT JOIN project_categories ON projects.project_category_id = project_categories.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("project_categories.name #{s}")
        when "platform_category"
          projects = Project.unscoped
                          .joins("LEFT JOIN platform_categories ON projects.platform_category_id = platform_categories.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("platform_categories.name #{s}")
        when "acquisition_category"
          projects = Project.unscoped
                          .joins("LEFT JOIN acquisition_categories ON projects.acquisition_category_id = acquisition_categories.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("acquisition_categories.name #{s}")
        when "status_name"
          projects = Project.unscoped
                          .joins("LEFT JOIN estimation_statuses ON projects.estimation_status_id = estimation_statuses.id")
                          .where(organization_id: @organization.id, id: project_ids)
                          .order("estimation_statuses.name #{s}")
        when "creator"
          projects = Project.unscoped
                          .joins("LEFT JOIN users ON projects.creator_id = users.id")
                          .where(organization_id: organization_id, id: project_ids)
                          .order("users.first_name #{s}, users.last_name #{s}")
        when "provider"
          projects = Project.unscoped
                         .joins("LEFT JOIN providers ON projects.provider_id = providers.id")
                         .where(organization_id: organization_id, id: project_ids)
                         .order("providers.name #{s}")
        else
          projects = projects.order(k + ' ' + s)
      end
    end

    projects = projects.where(:is_model => [nil, false])

    #projects
    #organization_estimations = @organization.organization_estimations.where(project_id: projects.all.map(&:id))
    # sort_project_ids = projects.all.map(&:id)
    # @organization.organization_estimations.find(sort_project_ids).index_by(&:id).values_at(*sort_project_ids)
    projects

    # res = []
    # projects.each do |p|
    #   if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
    #     res << p
    #   end
    # end
    # res
  end


  # Filter estimations according to the selection
  def filter_estimation_versions(projects_list, selected_filter_version)
    filtered_projects = projects_list

    unless selected_filter_version.blank?
      case selected_filter_version
        when '1' #Display leaves projects only
          filtered_projects = projects_list.reject { |i| !i.is_childless? }
        when '2' #Display all versions
          filtered_projects = projects_list
        when '3' #Display root version_number only
          filtered_projects = projects_list.reject { |i| !i.is_root? }
        when '4' #Most recent version_number
          #@projects = @projects.reorder('updated_at DESC').uniq_by(&:title)
          filtered_projects = projects_list.sort{ |x,y| y.updated_at <=> x.updated_at }.uniq(&:title)
        else
          filtered_projects = projects_list
      end
    end

    filtered_projects
  end

end
