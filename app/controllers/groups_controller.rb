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

class GroupsController < ApplicationController
  load_resource

  def new
    authorize! :manage, Group

    set_page_title I18n.t(:new_group)
    @group = Group.new
    @organization = Organization.find_by_id(params[:organization_id])

    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
    set_breadcrumbs I18n.t(:groups) => organization_setting_path(@organization, anchor: "tabs-group"), I18n.t('new_group') => ""

    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @enable_update_in_local = true
  end

  def edit
    authorize! :show_groups, Group

    @group = Group.find(params[:id])
    @organization = @group.organization
    set_page_title I18n.t(:edit_group, value: @group.name)
    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", "#{@organization.to_s} / #{I18n.t(:groups)} / #{@group.to_s}" => edit_organization_path(@organization)
    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
  end

  def create
    authorize! :manage, Group

    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @group = Group.new(params[:group])
    @enable_update_in_local = true
    @organization = Organization.find_by_id(params['group']['organization_id'])

    # for Trigger
    @group.originator_id = @current_user.id
    @group.event_organization_id = @organization.id

    set_page_title I18n.t(:new_group)
    set_breadcrumbs I18n.t(:groups) => organization_setting_path(@organization, anchor: "tabs-group"), I18n.t('new_group') => ""

    if @group.save
      redirect_to organization_authorization_path(@organization, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), anchor: "tabs-group")
    else
      render action: 'new'
    end
  end

  #Update the selected users in the group's securities
  def update_selected_users
    authorize! :manage, Group

    @group = Group.find(params[:group_id])
    user_ids = params[:group][:user_ids].reject { |e| e.to_s.empty? } rescue []

    # @group.users.each do |u|
    #   gu = GroupsUsers.where(:group_id => @group.id, :user_id => u.id) unless u.blank?
    #   gu.delete_all
    # end
    #
    # user_ids.each do |u|
    #   GroupsUsers.create(:group_id => @group.id, :user_id => u)
    # end

    # # Trigger : Gestion historique des evenements et MAJ des users du group
    @group.transaction_id = @group.transaction_id.nil? ? "#{@group.id}_1" : @group.transaction_id.next rescue "#{@group.id}_1"
    group_users_before = @group.users.map(&:id)
    group_users_after = user_ids.map(&:to_i)
    groups_to_delete = group_users_before - group_users_after
    users_to_add = group_users_after - group_users_before
    new_user_group_ids = group_users_before - groups_to_delete + users_to_add
    @group.user_ids = new_user_group_ids.map(&:to_i).uniq

    @group.projects(force_reload = true)
    if @group.save
      flash[:notice] = I18n.t(:notice_group_successful_updated)
    else
      flash[:notice] = I18n.t(:error_group_failed_update)
    end

    redirect_to redirect_apply(edit_organization_group_path(@group.organization, @group, anchor: "tabs-2"), nil, organization_authorization_path(@group.organization_id, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), :anchor => 'tabs-group'))
  end

  # #Update the selected users in the project's securities
  def update_selected_projects
    authorize! :manage, User

    @group = Group.find(params[:group_id])
    project_ids = params[:group][:project_ids]

    @group.projects.each do |p|
      gp = GroupsProjects.where(:group_id => @group.id, :project_id => p.id)
      gp.delete_all
    end

    project_ids.each do |g|
      GroupsProjects.create(:group_id => @group.id, :project_id => g) unless g.blank?
    end

    @group.projects(force_reload = true)

    if @group.save
      flash[:notice] = I18n.t(:notice_group_successful_updated)
    else
      flash[:notice] = I18n.t(:error_group_failed_update)
    end

    redirect_to root_url
  end


  def update
    authorize! :manage, Group

    @users = User.all
    @projects = Project.all.reject { |i| !i.is_childless? }
    @group = Group.find(params[:id])
    @organization = @group.organization

    set_page_title I18n.t(:edit_group, value: @group.name)
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", "#{@organization.to_s} / #{I18n.t(:groups)} / #{@group.to_s}" => edit_organization_path(@organization)

    if @group.update_attributes(params[:group].merge(originator_id: @current_user.id, event_organization_id: @organization.id))
      #redirect_to redirect(groups_path), :notice => "#{I18n.t (:notice_group_successful_updated)}"
      flash[:notice] =  "#{I18n.t (:notice_group_successful_updated)}"
      #redirect_to edit_organization_path(@organization)
      redirect_to redirect_apply(edit_organization_group_path(@organization, @group, anchor: "tabs-1"), nil, organization_authorization_path(@organization, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), :anchor => 'tabs-group'))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, Group

    @group = Group.find(params[:id])
    @organization = @group.organization

    GroupsUsers.delete_all(group_id: @group.id)

    @group.destroy

    flash[:notice] = I18n.t (:notice_group_successful_deleted)
    redirect_to organization_authorization_path(@organization, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), anchor: "tabs-group")
  end

end
