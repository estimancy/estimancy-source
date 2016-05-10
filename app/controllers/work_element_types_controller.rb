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

class WorkElementTypesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  #before_filter :get_record_statuses

  load_resource

  def new
    authorize! :manage, WorkElementType

    @work_element_type = WorkElementType.new
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:work_element_type)
    set_breadcrumbs I18n.t(:work_element_type) => organization_setting_path(@current_organization, anchor: "tabs-wet"), I18n.t('new_work_element_type') => ""
  end

  # GET /work_element_types/1/edit
  def edit
    authorize! :show_work_element_types, WorkElementType

    @work_element_type = WorkElementType.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:work_element_type)
    set_breadcrumbs I18n.t(:work_element_type) => organization_setting_path(@organization, anchor: "tabs-wet"), I18n.t(:work_element_type_edition) => ""
  end

  def create
    authorize! :manage, WorkElementType
    @work_element_type = WorkElementType.new(params[:work_element_type])
    @organization = @work_element_type.organization

    set_page_title I18n.t(:work_element_type)
    set_breadcrumbs I18n.t(:work_element_type) => organization_setting_path(@current_organization, anchor: "tabs-wet"), I18n.t('new_work_element_type') => ""

    if @work_element_type.save
      flash[:notice] = I18n.t(:notice_work_element_type_successful_created)
      redirect_to redirect_apply(nil, new_organization_work_element_type_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-wet'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, WorkElementType
    @work_element_type = WorkElementType.find(params[:id])
    @organization = @work_element_type.organization

    set_page_title I18n.t(:work_element_type)
    set_breadcrumbs I18n.t(:work_element_type) => organization_setting_path(@organization, anchor: "tabs-wet"), I18n.t(:work_element_type_edition) => ""

    if @work_element_type.update_attributes(params[:work_element_type])
      flash[:notice] =  I18n.t(:notice_work_element_type_successful_updated)
      redirect_to redirect_apply(edit_organization_work_element_type_path(@organization, @work_element_type), nil, organization_setting_path(@organization, anchor: "tabs-wet"))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, WorkElementType
    @work_element_type = WorkElementType.find(params[:id])
    organization_id = @work_element_type.organization
    @work_element_type.destroy

    redirect_to organization_setting_path(organization_id, anchor: "tabs-wet")
  end
end
