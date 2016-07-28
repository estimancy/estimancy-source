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


class Operation::OperationModelsController < ApplicationController

  def show
    authorize! :show_modules_instances, ModuleProject

    @operation_model = Operation::OperationModel.find(params[:id])
    @organization = @operation_model.organization

    set_page_title @operation_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @operation_model.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @operation_model = Operation::OperationModel.new

    set_page_title I18n.t(:new_instance_of_effort)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:operation_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @operation_model = Operation::OperationModel.find(params[:id])
    @organization = @operation_model.organization

    set_page_title I18n.t(:new_instance_of_effort)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:operation_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @operation_model.name => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:operation_model][:organization_id])

    @operation_model = Operation::OperationModel.new(params[:operation_model])
    @operation_model.organization_id = params[:operation_model][:organization_id].to_i
    if @operation_model.save
      redirect_to main_app.organization_module_estimation_path(@operation_model.organization_id, anchor: "effort")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @operation_model = Operation::OperationModel.find(params[:id])
    @organization = @operation_model.organization

    if @operation_model.update_attributes(params[:operation_model])
      redirect_to main_app.organization_module_estimation_path(@operation_model.organization_id, anchor: "effort")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @operation_model = Operation::OperationModel.find(params[:id])
    organization_id = @operation_model.organization_id

    @operation_model.module_projects.each do |mp|
      mp.destroy
    end

    @operation_model.delete
    redirect_to main_app.organization_module_estimation_path(@operation_model.organization_id, anchor: "effort")
  end

  #duplicate OperationModel
  def duplicate
    @operation_model = Operation::OperationModel.find(params[:operation_model_id])
    new_operation_model = @operation_model.amoeba_dup


    new_copy_number = @operation_model.copy_number.to_i+1
    new_operation_model.name = "#{@operation_model.name}(#{new_copy_number})"
    new_operation_model.copy_number = 0
    @operation_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_operation_model.transaction do
      if new_operation_model.save
        @operation_model.save
        flash[:notice] = "Modèle copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie du modèle"
      end
    end
    redirect_to main_app.organization_module_estimation_path(@operation_model.organization_id, anchor: "effort")
  end

  def save_efforts
    authorize! :execute_estimation_plan, @project

    @operation_model = Operation::OperationModel.find(params[:operation_model_id])
    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id, in_out: "output").first
      ["low", "most_likely", "high"].each do |level|

        if @operation_model.three_points_estimation?
          effort = params[:"effort_#{level}"].to_f
        else
          effort = params[:"effort_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          total_effort = effort * @operation_model.standard_unit_coefficient
          ev.send("string_data_#{level}")[current_component.id] = total_effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @operation_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )

    end

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    #@current_organization.fields.each do |field|
    current_module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project)
    end
    #end

    redirect_to main_app.dashboard_path(@project)
  end

end
