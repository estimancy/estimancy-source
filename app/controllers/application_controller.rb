#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = I18n.t(:error_access_denied)
    begin
      redirect_to :back
    rescue
      redirect_to root_path
    end
  end

  rescue_from Errno::ECONNREFUSED do |error|
    flash[:error] = I18n.t(:error_connection_refused)
  end

  helper_method :root_url
  helper_method :browser
  helper_method :version_browser
  helper_method :platform
  helper_method :os
  helper_method :security
  helper_method :server_name
  helper_method :projestimate_version
  helper_method :ruby_version
  helper_method :rails_version
  helper_method :environment
  helper_method :database_adapter
  helper_method :is_master_instance? #Identify if we are on Master or Local instance
  helper_method :send_feedback
  helper_method :allow_feedback?
  ###helper_method :current_user
  helper_method :current_project
  helper_method :current_component
  helper_method :current_module_project
  helper_method :load_admin_setting
  helper_method :get_record_statuses
  helper_method :set_locale_from_browser
  helper_method :set_user_language
  helper_method :capitalization_module

  before_filter :set_user_time_zone
  before_filter :set_user_language
  before_filter :set_return_to
  before_filter :previous_page
  ###before_filter :session_expiration
  before_filter :update_activity_time
  before_filter :capitalization_module

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
      unless session[:ctime] && (Time.now.utc.to_i - session[:ctime].to_i <= load_admin_setting('session_maximum_lifetime').to_i*60*60*24)
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


  #before_filter :session_expiry
  #before_filter :update_activity_time
  #
  #def session_expiry
  #  if current_user()
  #    unless load_admin_setting("session_inactivity_timeout")=="unset"
  #      if session[:expires]
  #        @time_left = (session[:expires] - Time.now).to_i
  #        unless @time_left > 0
  #          reset_session
  #          flash[:error] = I18n.t('session_inactivity_timeout_expire')
  #          redirect_to root_url
  #        end
  #      end
  #    end
  #  end
  #end
  #
  #def update_activity_time
  #  if current_user()
  #    unless load_admin_setting("session_inactivity_timeout")=="unset"
  #      if  load_admin_setting("session_inactivity_timeout")=="0.5"
  #        session[:expires] = 30.seconds.from_now
  #      else
  #        session[:expires] = load_admin_setting("session_inactivity_timeout").to_f.minutes.from_now
  #      end
  #    end
  #  end
  #end

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

  def verify_authentication
    unless self.request.format == 'application/json'
      if session[:current_user_id].nil?
        session[:remember_address] = self.request.fullpath
      end
    else
      session[:remember_address] = '/dashboard'
    end
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

  def current_user_SAVE
    begin
      (User.find(session[:current_user_id]) if session[:current_user_id]) || (User.find_by_email(cookies[:login]) if cookies[:login] || nil)
    rescue ActiveRecord::RecordNotFound
      reset_session
    end
  end

  def current_project
    prj = Project.where(:id => session[:current_project_id])
    if prj.nil?
      if current_user.nil?
        return nil
      else
        current_user.projects.first
      end
    else
      return prj.first
    end
  end

  # Get the selected Pbs_Project_Element
  def current_component
    return if current_project.nil?

    begin
      PbsProjectElement.find(session[:pbs_project_element_id])
    rescue
      @component = current_project.root_component
    end
  end


  def current_wbs_project_element
    if current_project
      session[:wbs_project_element_id].nil? ? current_project.wbs_project_element_root : WbsProjectElement.find(session[:wbs_project_element_id])
    end
  end


  def current_module_project
    @defined_record_status = RecordStatus.find_by_name('Defined')
    pemodule = Pemodule.find_by_alias_and_record_status_id('capitalization', @defined_record_status)
    default_current_module_project = ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, current_project.id).first

    if current_project.module_projects.map(&:id).include?(session[:module_project_id].to_i)
      session[:module_project_id].nil? ? default_current_module_project : ModuleProject.find(session[:module_project_id])
    else
      begin
        pemodule = Pemodule.find_by_alias('capitalization')
        ModuleProject.where('pemodule_id = ? AND project_id = ?', pemodule.id, current_project.id).first
      rescue
        current_project.module_projects.first
      end
    end
  end

  def capitalization_module
    @defined_record_status = RecordStatus.where('name = ?', 'Defined').last
    @capitalization_module = Pemodule.where(alias: 'capitalization', record_status_id: @defined_record_status.id).first unless @defined_record_status.nil?
  end

  def load_admin_setting(args)
    as = AdminSetting.find_by_key(args)
    r = RecordStatus.find_by_name('Defined')
    unless as.nil?
      AdminSetting.where(key: args, record_status_id: r.id).first.value
    end
  end

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

  #Get record statuses
  def get_record_statuses
    @retired_status = RecordStatus.find_by_name('Retired')
    @proposed_status = RecordStatus.find_by_name('Proposed')
    @defined_status = RecordStatus.find_by_name('Defined')
    @custom_status = RecordStatus.find_by_name('Custom')
    @local_status = RecordStatus.find_by_name('Local')
  end

  #before filter only pemodules move functions
  def project_locked?
    if current_project.locked?
      flash[:notice] = 'Project locked.'
      redirect_save(root_url)
    end
  end

  def set_locale_from_browser

    if  request.env['HTTP_ACCEPT_LANGUAGE'].nil?
      I18n.locale= 'en'
    else
      local_language=Language.find_by_locale(extract_locale_from_accept_language_header)
      if local_language.nil?
        I18n.locale= 'en'
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
    @projestimate_version="0.21.0-Beta.2+#{COMMIT_VERSION}"
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

end
