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

class OrganizationProfilesController < ApplicationController

  # GET /organization_profiles/new
  # GET /organization_profiles/new.json
  def new
    authorize! :manage, OrganizationProfile

    set_page_title I18n.t(:new_organization_profiles)
    @organization = Organization.find_by_id(params[:organization_id])
    @organization_profile = OrganizationProfile.new
    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('new_profile') => ""
  end

  # GET /organization_profiles/1/edit
  def edit
    authorize! :show_organization_profiles, OrganizationProfile
    set_page_title I18n.t(:edit_organization_profiles)
    @organization_profile = OrganizationProfile.find(params[:id])

    @organization = @organization_profile.organization

    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('organization_profiles_edition') => ""
  end

  # POST /organization_profiles
  # POST /organization_profiles.json
  def create
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:new_organization_profiles)

    @organization_profile = OrganizationProfile.new(params[:organization_profile])
    @organization = Organization.find_by_id(params['organization_profile']['organization_id'])

    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('new_profile') => ""

    if @organization_profile.save
      flash[:notice] = I18n.t(:notice_profile_successful_created)
     redirect_to redirect_apply(nil, new_organization_organization_profile_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-profile'))
    else
      flash[:error] = I18n.t(:error_profile_failed_created)
      render action: "new"
    end
  end

  # PUT /organization_profiles/1
  # PUT /organization_profiles/1.json
  def update
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:update_organization_profiles)

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('organization_profiles_edition') => ""

    respond_to do |format|
      if @organization_profile.update_attributes(params[:organization_profile])
        format.html { redirect_to redirect_apply(edit_organization_organization_profile_path(@organization, @organization_profile), nil, organization_setting_path(@organization, :anchor => 'tabs-profile') ), notice: I18n.t(:notice_profile_successful_updated) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_profiles/1
  # DELETE /organization_profiles/1.json
  def destroy
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:Delete_organization_profiles)

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @organization_profile.destroy

    respond_to do |format|
      format.html { redirect_to organization_setting_path(@organization, anchor: 'tabs-profile') }
      format.json { head :no_content }
    end
  end

  def refresh_organization_profiles
    if !params[:profile_category_id].nil?
      @profile_category = ProfileCategory.find(params[:profile_category_id])
      @profiles = @profile_category.profiles
    end
    #Voir si il faut modifier le cout horaire lorsqu'on change de profile
  end

  def refresh_organization_profile_data
    @profile_name = nil; @profile_description = nil; @profile_cost_per_hour= nil
    if !params[:profile_id].nil?
      @profile_for_organization = Profile.find(params[:profile_id])
      @profile_name = @profile_for_organization.name
      @profile_description = @profile_for_organization.description
      @profile_cost_per_hour = @profile_for_organization.cost_per_hour
    end
  end

end
