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
    module_project = current_module_project
    @guw_unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(organization_id: module_project.organization_id,
                                                             project_id: module_project.project_id,
                                                             module_project_id: module_project.id,
                                                             pbs_project_element_id: current_component.id).all
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
    @guw_unit_of_work_group.guw_model_id = module_project.guw_model_id
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
    @guw_unit_of_work_group.guw_model_id = module_project.guw_model_id
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

    @module_project = @guw_unit_of_work_group.module_project
    @guw_model = @module_project.guw_model
    @organization = @module_project.organization
    #component = @guw_unit_of_work_group.pbs_project_element
    component = current_component

    @guw_unit_of_work_group.destroy

    Guw::GuwUnitOfWork.update_estimation_values(@module_project, component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, component)

    redirect_to main_app.dashboard_path(@project)
  end

  # ModuleProject.all.each do |mp|
  #   mp.guw_unit_of_work_groups.each do |group|
  #
  #     group.organization_id = mp.organization_id
  #     group.guw_model_id = mp.guw_model_id
  #     group.project_id = mp.project_id
  #
  #     group.save
  #   end
  # end

end
