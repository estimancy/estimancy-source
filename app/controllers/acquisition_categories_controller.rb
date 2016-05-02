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

class AcquisitionCategoriesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation
  #before_filter :get_record_statuses

  load_resource

  def new
    authorize! :manage, AcquisitionCategory

    set_page_title I18n.t (:acquisition_categories)
    set_breadcrumbs I18n.t(:acquisition_categories) => organization_setting_path(@current_organization, anchor: "tabs-acquisition-categories"), I18n.t('new_acquisition_category') => ""

    @acquisition_category = AcquisitionCategory.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_acquisition_categories, AcquisitionCategory

    @acquisition_category = AcquisitionCategory.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:acquisition_categories)
    set_breadcrumbs I18n.t(:acquisition_categories) => organization_setting_path(@organization, anchor: "tabs-acquisition-categories"), I18n.t(:acquisition_category_edition) => ""
  end

  def create
    authorize! :manage, AcquisitionCategory

    @acquisition_category = AcquisitionCategory.new(params[:acquisition_category])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t (:acquisition_categories)
    set_breadcrumbs I18n.t(:acquisition_categories) => organization_setting_path(@current_organization, anchor: "tabs-acquisition-categories"), I18n.t('new_acquisition_category') => ""

    if @acquisition_category.save
      flash[:notice] = I18n.t (:notice_acquisition_category_successful_created)
      redirect_to redirect_apply(nil, new_organization_acquisition_category_path(@organization), organization_setting_path(@organization, anchor: "tabs-acquisition-categories"))
    else
      render action: "edit"
    end
  end

  def update
    authorize! :manage, AcquisitionCategory

    @organization = Organization.find(params[:organization_id])
    @acquisition_category = AcquisitionCategory.find(params[:id])

    set_page_title I18n.t(:acquisition_categories)
    set_breadcrumbs I18n.t(:acquisition_categories) => organization_setting_path(@organization, anchor: "tabs-acquisition-categories"), I18n.t(:acquisition_category_edition) => ""

    if @acquisition_category.update_attributes(params[:acquisition_category])
      flash[:notice] = I18n.t (:notice_acquisition_category_successful_updated)
      redirect_to redirect_apply(edit_organization_acquisition_category_path(@organization, @acquisition_category), nil, organization_setting_path(@organization, anchor: "tabs-acquisition-categories"))
    else
      render action: "edit"
    end
  end

  def destroy
    authorize! :manage, AcquisitionCategory

    @acquisition_category = AcquisitionCategory.find(params[:id])
    organization_id = @acquisition_category.organization_id
    @acquisition_category.destroy

    flash[:notice] = I18n.t (:notice_acquisition_category_successful_destroyed)
    redirect_to organization_setting_path(organization_id, :anchor => "tabs-acquisition-categories")
  end
end
