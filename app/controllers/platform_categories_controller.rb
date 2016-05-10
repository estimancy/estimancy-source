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

class PlatformCategoriesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  load_resource

  #before_filter :get_record_statuses

  def new
    authorize! :manage, PlatformCategory

    set_page_title I18n.t(:label_PlatformCategory)
    @platform_category = PlatformCategory.new
    @organization = Organization.find(params[:organization_id])

    set_breadcrumbs I18n.t(:label_PlatformCategory) => organization_setting_path(@current_organization, anchor: "tabs-platform-categories"), I18n.t('new_platform_category') => ""
  end

  def edit
    authorize! :show_platform_categories, PlatformCategory

    @platform_category = PlatformCategory.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:label_PlatformCategory)
    set_breadcrumbs I18n.t(:label_PlatformCategory) => organization_setting_path(@organization, anchor: "tabs-platform-categories"), I18n.t(:platform_category_edition) => ""
  end

  def create
    authorize! :manage, PlatformCategory

    @organization = Organization.find(params[:organization_id])
    @platform_category = PlatformCategory.new(params[:platform_category])
    @platform_category.owner_id = current_user.id

    set_page_title I18n.t(:label_PlatformCategory)
    set_breadcrumbs I18n.t(:label_PlatformCategory) => organization_setting_path(@current_organization, anchor: "tabs-platform-categories"), I18n.t('new_platform_category') => ""

    if @platform_category.save
      flash[:notice] = I18n.t (:notice_platform_category_successful_created)
      redirect_to redirect_apply(nil, new_organization_platform_category_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-platform-categories'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, PlatformCategory

    @organization = Organization.find(params[:organization_id])
    @platform_category = PlatformCategory.find(params[:id])

    set_page_title I18n.t(:label_PlatformCategory)
    set_breadcrumbs I18n.t(:label_PlatformCategory) => organization_setting_path(@organization, anchor: "tabs-platform-categories"), I18n.t(:platform_category_edition) => ""

    if @platform_category.update_attributes(params[:platform_category])
      flash[:notice] = I18n.t (:notice_platform_category_successful_updated)
      redirect_to redirect_apply(edit_organization_platform_category_path(@organization, @platform_category), nil, organization_setting_path(@organization, :anchor => 'tabs-platform-categories'))
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, PlatformCategory

    @platform_category = PlatformCategory.find(params[:id])
    organization_id = @platform_category.organization_id
    @platform_category.destroy

    flash[:notice] = I18n.t (:notice_platform_category_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-platform-categories')
  end
end
