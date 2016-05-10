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

class ProjectAreasController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  load_resource

  before_filter :get_record_statuses
  before_filter :get_associations_records, :only => [:new, :edit, :create, :update]

  def get_associations_records
    #no authorize required since everyone can show this object
    @acquisition_categories = AcquisitionCategory.all
    @platform_categories = PlatformCategory.all
    @project_categories = ProjectCategory.all
    @labor_categories = []
  end

  def new
    authorize! :manage, ProjectArea

    set_page_title I18n.t(:project_areas)
    set_breadcrumbs I18n.t(:project_areas) => organization_setting_path(@current_organization, anchor: "tabs-project-areas"), I18n.t('new_project_area') => ""
    @project_area = ProjectArea.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_project_areas, ProjectArea

    @project_area = ProjectArea.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:project_areas)
    set_breadcrumbs I18n.t(:project_areas) => organization_setting_path(@organization, anchor: "tabs-project-areas"), I18n.t(:project_area_edition) => ""
  end

  def create
    authorize! :manage, ProjectArea

    set_page_title I18n.t(:project_areas)
    set_breadcrumbs I18n.t(:project_areas) => organization_setting_path(@current_organization, anchor: "tabs-project-areas"), I18n.t('new_project_area') => ""

    @project_area = ProjectArea.new(params[:project_area])
    @project_area.owner_id = current_user.id
    @organization = Organization.find(params[:organization_id])

    if @project_area.save
      flash[:notice] = I18n.t (:notice_project_area_successful_created)
      redirect_to redirect_apply(nil, new_organization_project_area_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-project-areas') )
    else
       render action: 'new'
    end
  end

  def update
    authorize! :manage, ProjectArea
    @organization = Organization.find(params[:organization_id])
    @project_area = ProjectArea.find(params[:id])

    set_page_title I18n.t(:project_areas)
    set_breadcrumbs I18n.t(:project_areas) => organization_setting_path(@organization, anchor: "tabs-project-areas"), I18n.t(:project_area_edition) => ""

    if @project_area.update_attributes(params[:project_area])
      flash[:notice] = I18n.t (:notice_project_area_successful_updated)
      redirect_to redirect_apply(edit_organization_project_area_path(@organization, @project_area), nil, organization_setting_path(@organization, :anchor => 'tabs-project-areas') )
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, ProjectArea

    @project_area = ProjectArea.find(params[:id])
    organization_id = @project_area.organization_id
    @project_area.destroy

    flash[:notice] = I18n.t (:notice_project_area_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-project-areas')
  end
end
