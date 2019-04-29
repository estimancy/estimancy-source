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

class ProjectSecuritiesController < ApplicationController
  load_resource

  def new
    set_page_title I18n.t(:new_project_security)
    @project_security = ProjectSecurity.new
    @projects = Project.all.map{|i| [i.title, i.id]}
    @users = []
  end

  def edit
    set_page_title I18n.t(:edit_project_security)
    @project_security = ProjectSecurity.find(params[:id])
    @projects = Project.all.map{|i| [i.title, i.id]}
    @users = Project.find(@project_security.project.id).users.map{|i| [i.name, i.id]}
  end

  def create
    @project_security = ProjectSecurity.new(params[:project_security])
    @project_security.organization_id = @current_organization.id
    @project_security.project_id = params[:project_security][:project_id]
    @project_security.user_id = params[:project_security][:user_id]
    @project_security.project_security_level = params[:project_security_level]

    if @project_security.save
      redirect_to redirect(project_securities_url), notice: "#{I18n.t (:notice_project_securities_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    @project_security = ProjectSecurity.find(params[:id])
    @project_security.project_id = params[:project_security][:project_id]
    @project_security.user_id = params[:project_security][:user_id]
    @project_security.project_security_level = params[:project_security_level]

    if @project_security.save
      redirect_to project_securities_url, notice: "#{I18n.t (:notice_project_securities_successful_updated)}"
    else
      render action: 'edit'
    end

  end

  def destroy
    @project_security = ProjectSecurity.find(params[:id])
    @project_security.destroy

    redirect_to redirect(project_securities_url)
  end

  #Selected users depending of selected project
  def select_users
    @users = Project.find(params[:project_selected]).users.map{|i| [i.name, i.id]}
  end
end
