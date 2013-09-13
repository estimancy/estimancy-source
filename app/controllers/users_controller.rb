#encoding: utf-8
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

class UsersController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :verify_authentication, :except => [:show, :create_inactive_user]
  before_filter :load_data, :only => [:update, :edit, :new, :create, :create_inactive_user]
  #load_and_authorize_resource :except => [:edit, :show, :update, :create_inactive_user]
  load_resource

  def load_data
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.new :auth_type => AuthMethod.first.id, :user_status => 'active'
    end
    @projects = Project.all
    @organizations = Organization.all
    @groups = Group.defined_or_local
    @project_users = @user.projects
    @project_groups = @user.groups
    @org_users = @user.organizations
  end

  def index
    authorize! :manage, User

    set_page_title 'Users'
    @users = User.all
  end

  def new
    authorize! :manage, User

    set_page_title 'New user'

    @user = User.new(:auth_type => AuthMethod.first.id,
                     :user_status => 'active')
  end

  def create
    authorize! :manage, User

    set_page_title 'New user'

    @user = User.new(params[:user])
    @user.group_ids = Group.find_by_name('Everyone').id

    if @user.save
      redirect_to redirect_apply(edit_user_path(@user), new_user_path(:anchor => 'tabs-1'), users_path), :notice => "#{I18n.t (:notice_account_successful_created)}"
    else
      render(:new)
    end
  end

  def edit
    @user = User.find(params[:id])
    if current_user != @user
      authorize! :manage, User
    end

    set_page_title 'Edit user'
    @user = User.find(params[:id])
  end


  #Update user
  def update
    @user = User.find(params[:id])
    if current_user != @user
      authorize! :manage, User
    end

    set_page_title 'Edit user'

    params[:user][:group_ids] ||= []
    params[:user][:project_ids] ||= []

    # Get the Application authType
    application_auth_type = AuthMethod.where('name = ? AND record_status_id =?', 'Application', @defined_record_status.id).first

    if application_auth_type && params[:user][:auth_type].to_i != application_auth_type.id
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end

    if @user.update_attributes(params[:user])
      set_user_language
      flash[:notice] = I18n.t (:notice_account_successful_updated)
      redirect_to redirect_apply(edit_user_path(@user, :anchor => session[:anchor]), nil, users_path)
    else
      render(:edit)
    end

  end

  #Dashboard of the application
  def show
    #authorize! :manage, User

    set_page_title 'Dashboard'
    session[:anchor_value] = params[:anchor_value]

    if current_user
      if params[:project_id]
        session[:current_project_id] = params[:project_id]

        # tlp : ten latest projects
        tlp = User.first.ten_latest_projects || Array.new
        tlp = tlp.push(params[:project_id])
        User.first.update_attribute(:ten_latest_projects, tlp.uniq)
      end

      @user = current_user
      @project = current_project
      @pemodules ||= Pemodule.all
      @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first unless @project.nil?
      @show_hidden = 'true'

      if @project
        @module_projects ||= @project.module_projects
        #Get the capitalization module_project
        @capitalization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @capitalization_module.id, @project.id).first unless @capitalization_module.nil?

        @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
        @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max
      end
    else
      render :layout => 'login'
    end
  end

  def is_an_automatic_account_activation?()
    AdminSetting.where(:record_status_id => RecordStatus.find_by_name('Defined').id, :key => 'self-registration').first.value == 'automatic account activation'
  end

  #Create a inactive user if the demand is ok.
  def create_inactive_user
    unless (params[:email].blank? || params[:first_name].blank? || params[:last_name].blank? || params[:login_name].blank?)
      user = User.first(:conditions => ["login_name = '#{params[:login_name]}' or email = '#{params[:email]}'"])
      is_an_automatic_account_activation?() ? status = 'active' : 'pending'
      if !user.nil?
        redirect_to root_url, :warning => "#{I18n.t (:warning_email_or_username_already_exist)}"
      else
        user = User.new(:email => params[:email],
                        :first_name => params[:first_name],
                        :last_name => params[:last_name],
                        :login_name => params[:login_name],
                        :language_id => params[:language],
                        :initials => 'your_initials',
                        :user_status => status,
                        :auth_method => AuthMethod.find_by_name('Application'))

        user.password = Standards.random_string(8)
        user.group_ids = [Group.last.id]
        user.save(:validate => false)
        UserMailer.account_created(user).deliver
        if !user.active?
          UserMailer.account_request(@defined_record_status).deliver
          redirect_to root_url, :notice => "#{I18n.t (:ask_new_account_help)}"
        else
          UserMailer.account_validate(user).deliver
          redirect_to root_url, :notice => "#{I18n.t (:notice_account_successful_created)}, #{I18n.t(:ask_new_account_help2)}"
        end
      end
    else
      redirect_to root_url, :warning => "#{I18n.t (:warning_check_all_fields)}"
    end
  end

  def destroy
    authorize! :manage, User

    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_path
  end

  def find_use_user
    # No authorize required since everyone can find use for a user
    @user = User.find(params[:user_id])
    #@related_projects = @user.projects
    #Direct access project with Permissions
    @related_projects_securities = @user.project_securities

    #Indirect acceded project via groups
    @user.groups.each do |user_group|
      @related_projects_securities += user_group.project_securities
    end
    @related_projects_securities.sort_by(&:project_id)
  end

  def about
    # No authorize required since everyone can access the about page
    set_page_title 'About'
    latest_record_version = Version.last.nil? ? Version.create(:comment => 'No update data has been save') : Version.last
    @latest_repo_update = latest_record_version.repository_latest_update #Home::latest_repo_update
    @latest_local_update = latest_record_version.local_latest_update
    Rails.cache.write('latest_update', @latest_local_update)
  end

  def activate
    authorize! :manage, User

    @user = User.find(params[:id])
    unless @user.active?
      @user.user_status = 'active'
      @user.save(:validate => false)
    end
    redirect_to users_path
  end

  def display_states
    #TODO authorize

    unless params[:state] == ''
      @users = User.where(:user_status => params[:state]).page(params[:page])
    else
      @users = User.page(params[:page])
    end
  end

  def send_feedback
    # No authorize required since everyone can send a feedback if the feature have been enabled using the allow_feedback admin settings.
    latest_record_version = Version.last.nil? ? Version.create(:comment => 'No update data has been save') : Version.last
    @latest_repo_update = latest_record_version.repository_latest_update #Home::latest_repo_update
    @latest_local_update = latest_record_version.local_latest_update
    @projestimate_version=projestimate_version
    @ruby_version=ruby_version
    @rails_version=rails_version
    @environment=environment
    @database_adapter=database_adapter
    @browser=browser
    @version_browser=version_browser
    @platform=platform
    @os=os
    @server_name=server_name
    @root_url =root_url
    um = UserMailer.send_feedback(params[:send_feedback][:user_name],
                                  params[:send_feedback][:type],
                                  params[:send_feedback][:description],
                                  @latest_repo_update,
                                  @projestimate_version,
                                  @ruby_version,
                                  @rails_version,
                                  @environment,
                                  @database_adapter, @browser, @version_browser, @platform, @os, @server_name, @root_url, @defined_record_status)
    if um.deliver
      flash[:notice] = I18n.t (:notice_send_feedback_success)
      redirect_to session[:return_to]
    else
      flash[:error] = I18n.t (:error_send_feedback_failed)
    end

  end

end
