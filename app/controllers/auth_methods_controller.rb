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

class AuthMethodsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  def index
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:Authentications_method)
    set_breadcrumbs I18n.t(:auth_methods) => auth_methods_path, I18n.t('auth_methods_list') => ""

    @auth_methods = AuthMethod.all
  end

  def edit
    authorize! :manage_master_data, :all

    @auth_method = AuthMethod.find(params[:id])
    set_page_title I18n.t(:edit_auth_method, parameter: @auth_method.name)
    set_breadcrumbs I18n.t(:auth_methods) => auth_methods_path, I18n.t('auth_method_edition') => ""

    if is_master_instance?
      unless @auth_method.child_reference.nil?
        if @auth_method.child_reference.is_proposed_or_custom?
          flash[:warning] = I18n.t (:warning_auth_method_cant_be_edit)
          redirect_to auth_methods_path and return
        end
      end
    else
      if @auth_method.is_local_record?
        @auth_method.record_status = @local_status
      else
        flash[:warning] = I18n.t (:warning_master_record_cant_be_edit)
        redirect_to auth_methods_path
      end
    end
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:Authentications_method)
    set_breadcrumbs I18n.t(:auth_methods) => auth_methods_path, I18n.t('new_auth_method') => ""

    @auth_method = AuthMethod.new
  end

  def update
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:auth_methods)
    set_breadcrumbs I18n.t(:auth_methods) => auth_methods_path, I18n.t('auth_method_edition') => ""

    @auth_method = nil
    current_auth_method = AuthMethod.find(params[:id])

    if current_auth_method.is_defined?
      @auth_method = current_auth_method.amoeba_dup
      @auth_method.owner_id = current_user.id
    else
      @auth_method = current_auth_method
    end

    unless is_master_instance?
      if @auth_method.is_local_record?
        @auth_method.custom_value = 'Locally edited'
      end
    end

    if @auth_method.update_attributes(params[:auth_method])
      flash[:notice] = I18n.t (:notice_auth_method_successful_updated)
      redirect_to redirect_apply(edit_auth_method_path(@auth_method), nil, auth_methods_path)
    else
      render action: 'edit'
    end
  end

  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:auth_methods)
    set_breadcrumbs I18n.t(:auth_methods) => auth_methods_path, I18n.t('new_auth_method') => ""

    @auth_method = AuthMethod.new(params[:auth_method])
    #If we are on local instance, Status is set to "Local"
    if is_master_instance?
      @auth_method.record_status = @proposed_status
    else
      @auth_method.record_status = @local_status
    end

    if @auth_method.save
      flash[:notice] = I18n.t (:notice_auth_method_successful_created)
      redirect_to redirect_apply(nil, new_auth_method_path(), auth_methods_path)
    else
      render(:new)
    end
  end

  def destroy
    authorize! :manage_master_data, :all

    @auth_method = AuthMethod.find(params[:id])
    if is_master_instance?
      if @auth_method.is_defined? || @auth_method.is_custom?
        #logical deletion  delete don't have to suppress records anymore on Defined record
        @auth_method.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      else
        @auth_method.destroy
      end
    else
      if @auth_method.is_local_record? || @auth_method.is_retired?
        @auth_method.destroy
      else
        flash[:warning] = I18n.t (:warning_master_record_cant_be_delete)
        redirect_to redirect(auth_methods_path)  and return
      end
    end

    respond_to do |format|
      format.html { redirect_to auth_methods_url, notice: "#{I18n.t (:notice_auth_method_successful_deleted)}"}
    end
  end
end
