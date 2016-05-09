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

class ProjectSecurityLevelsController < ApplicationController
  load_resource

  def new
    authorize! :manage, ProjectSecurityLevel

    set_page_title I18n.t(:new_project_security_level)
    @project_security_level = ProjectSecurityLevel.new
    @organization = Organization.find(params[:organization_id])
    set_breadcrumbs I18n.t(:security_level) => organization_setting_path(@organization, anchor: "tabs-project-security-levels"), I18n.t('new_project_security_level') => ""
  end

  def edit
    authorize! :show_project_security_levels, ProjectSecurityLevel
    @project_security_level = ProjectSecurityLevel.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:edit_project_security_level, value: @organization.name)
    set_breadcrumbs I18n.t(:security_level) => organization_setting_path(@organization, anchor: "tabs-project-security-levels"), I18n.t('project_security_level_edition') => ""
  end

  def create
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = ProjectSecurityLevel.new(params[:project_security_level])
    @organization = @current_organization

    set_page_title I18n.t(:new_project_security_level)
    set_breadcrumbs I18n.t(:security_level) => organization_setting_path(@current_organization, anchor: "tabs-project-security-levels"), I18n.t('new_project_security_level') => ""

    if @project_security_level.save
      redirect_to redirect_apply(nil, new_organization_project_security_level_path(), organization_authorization_path(@project_security_level.organization_id, anchor: "tabs-project-security-levels")), notice: "#{I18n.t (:notice_project_securities_level_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = ProjectSecurityLevel.find(params[:id])
    @organization = @project_security_level.organization

    set_page_title I18n.t(:edit_project_security_level, value: @organization.name)
    set_breadcrumbs I18n.t(:security_level) => organization_setting_path(@organization, anchor: "tabs-project-security-levels"), I18n.t('project_security_level_edition') => ""

    if @project_security_level.update_attributes(params[:project_security_level])
      #redirect_to organization_authorization_path(@project_security_level.organization_id, anchor: "tabs-project-security-levels"), notice: "#{I18n.t (:notice_project_securities_level_successful_updated)}"
      redirect_to redirect_apply(edit_organization_project_security_level_path(@organization, @project_security_level), nil, organization_authorization_path(@organization, :anchor => 'tabs-project-security-levels')), notice: "#{I18n.t (:notice_project_securities_level_successful_updated)}"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, ProjectSecurityLevel

    @project_security_level = ProjectSecurityLevel.find(params[:id])
    organization_id = @project_security_level.organization_id
    @project_security_level.destroy

    redirect_to organization_authorization_path(organization_id, anchor: "tabs-project-security-levels")
  end
end
