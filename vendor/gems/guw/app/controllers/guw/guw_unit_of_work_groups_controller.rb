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

class Guw::GuwUnitOfWorkGroupsController < ApplicationController

  def index
    @guw_unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id, module_project_id: current_module_project.id).all
    set_page_title I18n.t(:label_Group)
  end

  def new
    module_project = current_module_project
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.new
    @guw_model = module_project.guw_model

    @organization = @guw_model.organization
    @project = module_project.project

    set_page_title I18n.t(:new_group)
  end

  def edit
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
    module_project = current_module_project
    @guw_model = module_project.guw_model

    @organization = @guw_unit_of_work_group.organization rescue @guw_model.organization
    @project = @guw_unit_of_work_group.project rescue module_project.project

    set_page_title I18n.t(:edit_group, value: @guw_unit_of_work_group.name)
  end

  def create
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.new(params[:guw_unit_of_work_group])

    module_project = current_module_project
    @organization = @project.organization

    @guw_unit_of_work_group.module_project_id = module_project.id
    @guw_unit_of_work_group.pbs_project_element_id = current_component.id
    @guw_unit_of_work_group.save

    redirect_to main_app.dashboard_path(@project)
  end

  def create_group
    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.new

    module_project = current_module_project
    @organization = @project.organization

    @guw_unit_of_work_group.name = params[:name]
    @guw_unit_of_work_group.comments = params[:comments]
    @guw_unit_of_work_group.module_project_id = module_project.id
    @guw_unit_of_work_group.organization_id = params[:organization_id]
    @guw_unit_of_work_group.project_id = params[:project_id]
    @guw_unit_of_work_group.module_project_id = module_project.id
    @guw_unit_of_work_group.pbs_project_element_id = current_component.id

    @guw_unit_of_work_group.save

  end

  def update
    authorize! :execute_estimation_plan, @project

    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
    @organization = @guw_unit_of_work_group.organization

    if @guw_unit_of_work_group.update_attributes(params[:guw_unit_of_work_group])
      redirect_to main_app.dashboard_path(@project) and return
    else
      render :edit
    end
  end

  def destroy
    authorize! :execute_estimation_plan, @project

    @guw_unit_of_work_group = Guw::GuwUnitOfWorkGroup.find(params[:id])
    @guw_unit_of_work_group.destroy

    redirect_to main_app.dashboard_path(@project)
  end

end
