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

class UsersController < ApplicationController
  require 'securerandom'

  #before_filter :verify_authentication, :except => [:show, :create_inactive_user]
  before_filter :load_data, :only => [:update, :edit, :new, :create, :create_inactive_user]
  #load_and_authorize_resource :except => [:edit, :show, :update, :create_inactive_user]
  load_resource

protected

  def load_data
    #No authorize required since this method is protected and won't be call from any route
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.new
      @user.auth_type = AuthMethod.first.id
    end
  end

public

  def index
    #authorize! :manage, User
    #all users menu/page is only visible by master users
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:users)
    @users = User.all
    @audits = Audit.all
  end

  def new
    authorize! :manage, User

    set_page_title I18n.t(:new_user)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @current_organization => "#!", I18n.t(:new_user) => ""

    @organization_id = params[:organization_id]
    unless @organization_id.nil? || @organization_id.empty?
      @organization = Organization.find_by_id(params[:organization_id])
      @user_group = @organization.groups.where(name: '*USER').first_or_create(organization_id: @organization.id, name: "*USER")
    end

    @user = User.new
    @user.auth_type = AuthMethod.first.id
    @generated_password = SecureRandom.hex(4)
    @organizations = current_user.organizations
  end

  def create
    authorize! :manage, User

    set_page_title I18n.t(:new_user)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @current_organization => "#!", I18n.t(:new_user) => ""

    auth_type = AuthMethod.find(params[:user][:auth_type])

    @user = User.new(params[:user])
    @user.auth_type = params[:user][:auth_type]
    @user.language_id = params[:user][:language_id]
    @user.project_ids = params[:user][:project_ids]

    if auth_type.name == "SAML"
      @user.skip_confirmation!
    end

    if params[:organization_id].present?
      @organization = Organization.find(params[:organization_id])
      if @organization
        @organization_id = @organization.id
        OrganizationsUsers.create(user_id: @user.id, organization_id: @organization.id)

        @user_group = @organization.groups.where(name: '*USER').first_or_create(organization_id: @organization.id, name: "*USER")
        @user.groups << @user_group
      else
        if params[:organizations]
          params[:organizations].keys.each do |organization_id|
            OrganizationsUsers.create(user_id: @user.id, organization_id: organization_id)
          end
        end
      end
    end

    unless params[:groups].nil?
      @user.group_ids = params[:groups].keys
      @user.save
    end

    if @user.save
      flash[:notice] = I18n.t(:notice_account_successful_created)
      if @organization.nil?
        redirect_to(redirect_apply(edit_user_path(@user), users_path, users_path)) and return
      else
        redirect_to redirect_apply(edit_organization_user_path(@organization, @user), organization_users_path(@organization), organization_users_path(@organization)) and return
      end

    else
      render(:new, organization_id: @organization_id)
    end

  end

  def edit

    @user = User.find(params[:id])

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @current_organization => "#!", I18n.t(:edit_user, value: @user) => ""

    if params[:organization_id].present?
      @organization = Organization.find(params[:organization_id])
    end

    if current_user == @user
      set_page_title I18n.t(:edit_my_account)
    else
      authorize! :show_organization_users, User
      set_page_title I18n.t(:edit_user, :value => @user.name)
    end
  end


  #Update user
  def update
    specific_message = ""
    @user = User.find(params[:id])
    if current_user != @user
      authorize! :manage, User
    end

    set_page_title I18n.t(:edit_user, value: @user.name)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @current_organization => "#!", I18n.t(:edit_user, value: @user) => ""

    if params[:organization_id].present?
      @organization = Organization.find(params[:organization_id])
    end

    if @organization.nil?
      if params[:organizations].nil?

        @user.organizations.each do |organization|
          organization.groups.each do |group|
            if @user.estimations.where(organization_id: organization.id).empty?
              GroupsUsers.delete_all("user_id = #{@user.id} and group_id = #{group.id}")
              @user.organization_ids = []
            else
              specific_message = "L'utilisateur est propriétaire de plusieurs estimations privées et modèles d'estimations (#{@user.estimations.where(organization_id: organization.id).join(', ')})"
            end
          end
        end

        @user.save

      elsif current_user.super_admin == true

        old_organizations = @user.organization_ids - params[:organizations].keys.map(&:to_i)
        new_organizations_array = params[:organizations].keys.map(&:to_i)

        old_organizations.each do |organization_id|
          organization = Organization.find(organization_id)
          organization.groups.each do |group|
            if @user.estimations.where(organization_id: organization.id).empty?
              GroupsUsers.delete_all("user_id = #{@user.id} and group_id = #{group.id}")
            else
              new_organizations_array << organization_id
              specific_message = "L'utilisateur est propriétaire de plusieurs estimations privées et modèles d'estimations (#{@user.estimations.where(organization_id: organization.id).join(', ')})"
            end
          end
        end

        @user.organization_ids = new_organizations_array.uniq
        @user.save
      else
        #il ne se passe rien, un user non super admin ne peux pas décoché un autre utilisateur d'une organisation
      end
    else
      if params[:groups].nil?
        @organization.groups.each do |group|
          GroupsUsers.delete_all("user_id = #{@user.id} and group_id = #{group.id}")
        end
      else

        @organization.groups.each do |group|
          GroupsUsers.delete_all("user_id = #{@user.id} and group_id = #{group.id}")
        end

        params[:groups].keys.each do |group_id|
          GroupsUsers.create(user_id: @user.id, group_id: group_id)
        end
      end
    end

    # Get the Application authType
    application_auth_type = AuthMethod.where('name = ? AND record_status_id =?', 'Application', @defined_record_status.id).first

    if application_auth_type && params[:user][:auth_type].to_i != application_auth_type.id
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end

    @user.auth_type = params[:user][:auth_type]
    @user.language_id = params[:user][:language_id]

    #validation conditions
    if params[:user][:password].blank?
      # User is not updating his password
      @user.updating_password = false
    else
      # User is updating his password
      @user.updating_password = true
    end

    successfully_updated = if @user.updating_password
                             @user.update_with_password(params[:user])
                           else
                             params[:user].delete(:current_password)
                             @user.update_without_password(params[:user])
                           end

    if successfully_updated
      set_user_language
      flash[:notice] = I18n.t (:notice_account_successful_updated)

      unless specific_message.blank?
        flash[:error] = specific_message
      end

      @user_current_password = nil;  @user_password = nil; @user_password_confirmation = nil

      if @organization.nil?
        redirect_to redirect_apply(edit_user_path(@user), new_user_path(:anchor => 'tabs-1'), users_path) and return
      else
        redirect_to redirect_apply(edit_organization_user_path(@organization, @user), new_user_path(:anchor => 'tabs-1'), organization_users_path(@organization))
      end

    else
      @user_current_password = params[:user][:current_password];  @user_password = params[:user][:password]; @user_password_confirmation = params[:user][:password_confirmation]
      render(:edit, organization_id: @organization_id)
    end
  end

  def unlock_user
    @user = User.find(params[:id])
    if @user.locked_at.nil?
      @user.lock_access!(send_instructions: false)
    else
      @user.unlock_access!
    end
    redirect_to :back
  end

  #Create a inactive user if the demand is ok.
  def create_inactive_user
    #No authorize required since everyone can ask for new account which will be validated by an Admin

    unless (params[:email].blank? || params[:first_name].blank? || params[:last_name].blank? || params[:login_name].blank?)
      user = User.where('login_name = ? OR email = ?', params[:login_name], params[:email]).first
      is_an_automatic_account_activation? ? status = 'active' : status = 'pending'

      if !user.nil?
        redirect_to :back, :flash => {:warning => "#{I18n.t (:warning_email_or_username_already_exist)}"}
      else
        user = User.new(:email => params[:email],
                        :first_name => params[:first_name],
                        :last_name => params[:last_name],
                        :login_name => params[:login_name],
                        :language_id => params[:language],
                        :initials => 'your_initials',
                        :auth_type => AuthMethod.find_by_name('Application').id)

        user.password = Standards.random_string(8)

        user.group_ids = [Group.last.id]

        user.save(:validate => false)

        UserMailer.account_created(user).deliver
        if !user.active?
          UserMailer.account_request(@defined_record_status).deliver
          redirect_to :back, :notice => "#{I18n.t (:ask_new_account_help)}"
        else
          UserMailer.account_validate(user).deliver
          redirect_to :back, :notice => "#{I18n.t (:notice_account_successful_created)}, #{I18n.t(:ask_new_account_help2)}"
        end
      end
    else
      redirect_to :back, :flash => {:warning => "#{I18n.t (:warning_check_all_fields)}"}
    end
  end

  def destroy
    authorize! :manage, User

    @user = User.find(params[:id])

    if @user.estimations.where(organization_id: params[:organization_id].to_i).empty?
      @user.destroy
      if params[:organization_id]
        redirect_to organization_users_path(organization_id: params[:organization_id]) and return
      elsif current_user.super_admin?
        redirect_to users_path and return
      else
        redirect_to :back
      end
      flash[:success] = "L'utilisateur a bien été supprimé"
    else
      flash[:error] = "L'utilisateur est propriétaire de plusieurs estimations privées et modèles d'estimations (#{@user.estimations.where(organization_id: params[:organization_id]).join(', ')})"
      if params[:organization_id]
        redirect_to organization_users_path(organization_id: params[:organization_id]) and return
      else
        redirect_to users_path and return
      end
    end
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
    set_page_title I18n.t(:about)
    latest_record_version = Version.last.nil? ? Version.create(:comment => 'No update data has been save') : Version.last
    @latest_repo_update = latest_record_version.repository_latest_update #Home::latest_repo_update
    @latest_local_update = latest_record_version.local_latest_update
    Rails.cache.write('latest_update', @latest_local_update)
  end

  def display_states
    #No authorize required since this method is not used since now
    @users = User.page(params[:page])
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
      redirect_to root_url
    else
      flash[:error] = I18n.t (:error_send_feedback_failed)
    end

  end

  protected
  def is_an_automatic_account_activation?
    #No authorize required since this method is protected and won't be call from any route
    AdminSetting.where(:record_status_id => RecordStatus.find_by_name('Defined').id, :key => 'self-registration').first.value == 'automatic account activation'
  end

end
