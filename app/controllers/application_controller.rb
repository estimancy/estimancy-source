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
      elsif exception.class == ActiveRecord::RecordNotFound
        flash[:error] = I18n.t(:error_resource_not_found)
        redirect_to organization_estimations_path(@current_organization) and return
      else
        UserMailer.crash_log(exception, current_user).deliver
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
  helper_method :get_record_statuses
  helper_method :set_locale_from_browser
  helper_method :set_user_language
  helper_method :initialization_module
  helper_method :user_number_precision
  helper_method :display_badge

  before_filter :check_access
  before_filter :set_user_time_zone
  before_filter :set_user_language
  before_filter :set_return_to
  before_filter :previous_page
  before_filter :set_breadcrumbs
  before_filter :set_current_project
  before_filter :set_current_organization
  ###before_filter :session_expiration
  before_filter :update_activity_time
  before_filter :initialization_module

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
      unless current_user.super_admin == true
        if current_user.subscription_end_date < Time.now
          flash[:error] = "La licence de votre compte est expirée."
          reset_session
          redirect_to(root_path)
        elsif @disable_access == "1"
          reset_session
          redirect_to(root_path)
        end
      end
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, @current_organization)
  end

  # Organization verification: user need to have at least one organization before continue
  def check_user_organization
    if current_user.organizations.empty?
      redirect_to(new_organization_path, flash: { warning: I18n.t(:user_need_at_least_one_organization)})
    end
  end

  def session_expiration
    unless load_admin_setting('session_maximum_lifetime').nil? && load_admin_setting('session_inactivity_timeout').nil?
      if current_user
        if session_expired?
          reset_session
          flash[:error] = I18n.t(:error_session_expired)
          redirect_to root_path(:return_to => session[:return_to])
        end
      end
    end
  end

  def session_expired?
    unless load_admin_setting('session_maximum_lifetime')=='unset'
      setting_session_maximum_lifetime = load_admin_setting('session_maximum_lifetime').to_i*60*60*24
      unless session[:ctime] && (Time.now.utc.to_i - session[:ctime].to_i <= setting_session_maximum_lifetime)
        return true
      end
    end

    unless load_admin_setting('session_inactivity_timeout')=='unset'
      if load_admin_setting('session_inactivity_timeout').to_i==30
        unless session[:atime] && (Time.now.utc.to_i - session[:atime].to_i <= load_admin_setting('session_inactivity_timeout').to_i*60)
          return true
        end
      else
        unless session[:atime] && (Time.now.utc.to_i - session[:atime].to_i <= load_admin_setting('session_inactivity_timeout').to_i*60*60)
          return true
        end
      end

    end
    false
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
    @admin_setting=AdminSetting.find_by_key_and_record_status_id('allow_feedback', @defined_record_status)
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
    defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
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
        @project = current_user.organizations.first.projects.first
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
        @current_organization = Organization.find(session[:organization_id])
      #Si ya pas de sessions
      else
        @current_organization = current_user.organizations.where(is_image_organization: false).first
        if
        @current_organization.nil?
          session[:organization_id] = current_user.organizations.first.id
          @current_organization = Organization.find(session[:organization_id])
        else
          session[:organization_id] = @current_organization.id
          @current_organization = Organization.find(session[:organization_id])
        end
      end
    rescue
      session[:organization_id] = nil
      @current_organization = nil
    end

  end

  # Get the selected Pbs_Project_Element
  def current_component
    if @project
      begin
        pbs = PbsProjectElement.find(session[:pbs_project_element_id])
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
      nil
    else
      @defined_record_status = RecordStatus.find_by_name('Defined')
      pemodule = Pemodule.find_by_alias_and_record_status_id('initialization', @defined_record_status)
      default_current_module_project = ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, @project.id).first
      if @project.module_projects.map(&:id).include?(session[:module_project_id].to_i)
        session[:module_project_id].nil? ? default_current_module_project : ModuleProject.find(session[:module_project_id])
      else
        begin
          pemodule = Pemodule.find_by_alias('initialization')
          ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, @project.id).first
        rescue
          @project.module_projects.first
        end
      end
    end
  end

  # Get the current selected attribute for the Balancing Module
  def current_balancing_attribute
    @defined_record_status = RecordStatus.find_by_name('Defined')
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
    @defined_record_status = RecordStatus.where('name = ?', 'Defined').last
    @initialization_module = Pemodule.where(alias: 'initialization', record_status_id: @defined_record_status.id).first unless @defined_record_status.nil?
  end

  # Get all the adminSetting parameters
  def load_admin_setting(args)
    as = AdminSetting.find_by_key(args)
    r = RecordStatus.find_by_name('Defined')
    unless as.nil?
      AdminSetting.where(key: args, record_status_id: r.id).first.value
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
      @breacrumbs = { "Estimates" => main_app.root_url, "#{action_name.humanize} #{controller_name.humanize}" => request.original_url }
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


  #Get record statuses
  def get_record_statuses
    @retired_status = RecordStatus.find_by_name('Retired')
    @proposed_status = RecordStatus.find_by_name('Proposed')
    @defined_status = RecordStatus.find_by_name('Defined')
    @custom_status = RecordStatus.find_by_name('Custom')
    @local_status = RecordStatus.find_by_name('Local')
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

  # Get the bootstraap badge class
  def display_badge(state)
    badge = "badge-default"
    case state
      when "preliminary"
        badge = "badge-default" #Gris
      when ":in_progress"
        badge = "badge-info"  #Bleu
      when "in_review"
        badge = "badge-warning" #Orange
      when "checkpoint"
        badge = "badge-important" #Rouge
      when "released"
        badge = "badge-success" #Vert
      when "rejected"
        badge = "badge-inverse" #Noir
      else
        badge = "badge-default"
    end

    return badge
  end


  private
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def projestimate_version
    @projestimate_version = VERSION
  end

  def update_date
    Time.parse(COMMIT_DATE).strftime("%d/%m/%Y à %H:%M")
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
    string = request.env['HTTP_USER_AGENT']
    user_agent = UserAgent.parse(string)
    platform=user_agent.platform
  end

  def os
    string = request.env['HTTP_USER_AGENT']
    user_agent = UserAgent.parse(string)
    os=user_agent.os
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
    if resource.password_changed || (resource.auth_type == saml_auth_id)
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


end
