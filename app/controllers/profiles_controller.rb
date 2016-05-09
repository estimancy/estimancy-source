# encoding: UTF-8
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

class ProfilesController < ApplicationController

  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  # GET /profiles
  # GET /profiles.json
  def index
    authorize! :manage_master_data, :all

    @profiles = Profile.all
    set_page_title I18n.t(:profiles)
    set_breadcrumbs I18n.t(:profiles) => profiles_path, I18n.t('profiles_list') => ""
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    authorize! :manage_master_data, :all
    set_page_title I18n.t(:new_profile)
    set_breadcrumbs I18n.t(:profiles) => profiles_path, I18n.t('new_profile') => ""
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
    authorize! :manage_master_data, :all

    @profile = Profile.find(params[:id])
    set_page_title I18n.t(:edit_profile, value: @profile.name)
    set_breadcrumbs I18n.t(:profiles) => profiles_path, I18n.t('profile_edition') => ""

    unless @profile.child_reference.nil?
      if @profile.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_profile_cant_be_edit)
        redirect_to profiles_path
      end
    end

  end

  # POST /profiles
  # POST /profiles.json
  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:new_profile)
    set_breadcrumbs I18n.t(:profiles) => profiles_path, I18n.t('new_profile') => ""

    @profile = Profile.new(params[:profile])
    @profile.owner_id = current_user.id

    @profile.record_status = @proposed_status
    if @profile.save
      flash[:notice] = I18n.t (:notice_profile_successful_created)
      redirect_to redirect_apply(nil, new_profile_path(), profiles_path)
    else
      render action: 'new'
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    authorize! :manage_master_data, :all

    @profile = nil
    current_profile = Profile.find(params[:id])
    set_page_title I18n.t(:update_profile, value: current_profile.name)
    set_breadcrumbs I18n.t(:profiles) => profiles_path, I18n.t('profile_edition') => ""

    if current_profile.is_defined?
      @profile = current_profile.amoeba_dup
      @profile.owner_id = current_user.id
    else
      @profile = current_profile
    end

    if @profile.update_attributes(params[:profile])
      flash[:notice] = I18n.t (:notice_profile_successful_updated)
      redirect_to redirect_apply(edit_profile_path(@profile), nil, profiles_path)
    else
      flash[:error] = I18n.t(:error_profile_failed_update)
      render action: 'edit'
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    authorize! :manage_master_data, :all

    @profile = Profile.find(params[:id])
    set_page_title I18n.t(:delete_profile, value: @profile.name)

    if @profile.is_custom?
      #logical deletion  delete don't have to suppress records anymore on Defined record
      @profile.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      flash[:notice] = I18n.t (:notice_profile_successful_deleted)
    elsif @profile.is_defined?
      flash[:warning] = I18n.t(:defined_profile_not_deletable)
    else
      @profile.destroy
      flash[:notice] = I18n.t (:notice_profile_successful_deleted)
    end

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end

end