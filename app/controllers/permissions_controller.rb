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

class PermissionsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  def index
    authorize! :manage, Permission

    set_page_title 'Permissions'
    @permissions = Permission.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def globals_permissions
    set_page_title 'Globals Permissions'
    @permissions = Permission.order('object_associated').defined.select{|i| !i.is_permission_project }
    @permissions_classes = @permissions.map(&:object_associated).uniq

    @groups = Group.defined_or_local

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    authorize! :manage, Permission

    set_page_title 'Permissions'
    @permission = Permission.new
  end

  def edit
    authorize! :manage, Permission

    set_page_title 'Permissions'
    @permission = Permission.find(params[:id])

    unless @permission.child_reference.nil?
      if @permission.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_permission_cant_be_edit)
        redirect_to permissions_path
      end
    end
  end

  def create
    authorize! :manage, Permission

    @permission = Permission.new(params[:permission])

    @groups = Group.defined_or_local

    @permission.name = params[:permission][:name].underscore.gsub(' ', '_')

    if @permission.save
      redirect_to redirect_apply(nil, new_permission_path(), permissions_path), notice: "#{I18n.t (:notice_permission_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, Permission

    @permission = nil
    current_permission = Permission.find(params[:id])
    if current_permission.is_defined?
      @permission = current_permission.amoeba_dup
      @permission.owner_id = current_user.id
    else
      @permission = current_permission
    end

    if @permission.update_attributes(params[:permission])
      redirect_to redirect_apply(edit_permission_path(@permission), nil, permissions_path ), notice: "#{I18n.t (:notice_function_successful_updated)}"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, Permission

    @permission = Permission.find(params[:id])
    if @permission.is_defined? || @permission.is_custom?
      @permission.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @permission.destroy
    end

    respond_to do |format|
      format.html { redirect_to permissions_path, notice: "#{I18n.t (:notice_permission_successful_deleted)}" }
      format.json { head :ok }
    end
  end

  #Set all global rights
  def set_rights
    authorize! :manage_roles, Permission

    @groups = Group.defined_or_local
    @permissions = Permission.defined

    @groups.each do |group|
      group.update_attribute('permission_ids', params[:permissions][group.id.to_s])
    end

    respond_to do |format|
      format.html { redirect_to '/globals_permissions', :notice => "#{I18n.t (:notice_permission_successful_saved)}" }
    end

  end

  def set_rights_project_security
    authorize! :manage_roles, Permission

    @project_security_levels = ProjectSecurityLevel.defined
    @permissions = Permission.defined

    @project_security_levels.each do |psl|
      psl.update_attribute('permission_ids', params[:permissions][psl.id.to_s])
    end

    respond_to do |format|
      format.html { redirect_to project_securities_path, :notice => "#{I18n.t (:notice_permission_successful_saved)}" }
    end

  end
end
