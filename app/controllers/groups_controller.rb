#encoding: utf-8
#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012 Spirula (http://www.spirula.fr)
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
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def index
    authorize! :edit_groups, Group
    set_page_title "Groups"
    @groups = Group.all
  end

  def new
    authorize! :edit_groups, Group
    set_page_title "New group"
    @group = Group.new
    @users = User.all
    @projects = Project.all
  end

  def edit
    authorize! :edit_groups, Group
    set_page_title "Edit group"
    @group = Group.find(params[:id])
    @users = User.all
    @projects = Project.all

    if is_master_instance?
      @group.record_status = @proposed_status

      unless @group.child_reference.nil?
        if @group.child_reference.is_proposed_or_custom?
          flash[:notice] = "This Group can't be edited, because the previous changes have not yet been validated."
          redirect_to groups_path and return
        end
      end
    else
      if @group.is_local_record?
        @group.record_status = @local_status
      else
        flash[:error] = "Master record can not be deleted, it is required for the proper functioning of the application"
        redirect_to redirect(groups_path) and return
      end
    end
  end

  def create
    authorize! :edit_groups, Group
    @users = User.all
    @projects = Project.all
    @group = Group.new(params[:group])

    #If we are on local instance, Status is set to "Local"
    if is_master_instance?
      @group.record_status = @proposed_status
    else
      @group.record_status = @local_status
    end

    if @group.save
      redirect_to redirect(groups_path)
    else
      render action: "new"
    end
  end

  def update
    @users = User.all
    @projects = Project.all
    @group = nil
    current_group = Group.find(params[:id])

    if current_group.is_defined?
      @group = current_group.amoeba_dup
      @group.owner_id = current_user.id
    else
      @group = current_group
    end

    unless is_master_instance?
      if @group.is_local_record?
        @group.custom_value = "Locally edited"
      end
    end

    if @group.update_attributes(params[:group])
      redirect_to redirect(groups_path)
    else
      render action: "edit"
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if is_master_instance?
      if @group.is_defined? || @group.is_custom?
        #logical deletion: delete don't have to suppress records anymore on defined record
        @group.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      else
        @group.destroy
      end
    else
      if @group.is_local_record?
        @group.destroy
      else
        flash[:error] = "Master record can not be deleted, it is required for the proper functioning of the application"
        redirect_to redirect(groups_path)  and return
      end
    end

    flash[:notice] = "Group was successfully deleted."
    redirect_to groups_url
  end
end
