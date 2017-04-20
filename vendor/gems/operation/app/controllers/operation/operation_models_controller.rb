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

    @operation_inputs = @operation_model.operation_inputs

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
      #redirect_to main_app.organization_module_estimation_path(@operation_model.organization_id, anchor: "effort")
      redirect_to operation.edit_operation_model_path(@operation_model, organization_id: @organization.id, anchor: "tabs-1")
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
    #new_operation_model.transaction do
    ActiveRecord::Base.transaction do
      if new_operation_model.save
        @operation_model.save
        new_operation_model.terminate_operation_model_duplication

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
    if @operation_model.nil?
      @operation_model = current_module_project.operation_model
    end

    module_project_attributes = current_module_project.pemodule.pe_attributes
    input_attribute_ids = module_project_attributes.where(operation_model_id: @operation_model.id).map(&:id).flatten
    #output_attribute_ids = PeAttribute.where(alias: Operation::OperationModel::OUTPUT_ATTRIBUTES_ALIAS).map(&:id).flatten
    output_attribute_ids = module_project_attributes.where(operation_model_id: @operation_model.id).map(&:id).flatten

    # if input_attribute_ids.empty?
    #   input_attribute_ids = PeAttribute.where(alias: Operation::OperationModel::DEFAULT_INPUT_ATTRIBUTES_ALIAS).map(&:id).flatten
    # end

    current_mp_estimation_values = current_module_project.estimation_values
    input_evs = current_mp_estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")
    output_evs = current_mp_estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")

    # Gestion des entrées
    input_am = current_module_project.pemodule.attribute_modules.where(operation_model_id: @operation_model.id)
    output_am = input_am #current_module_project.pemodule.attribute_modules

    input_size_data = Hash.new
    input_data_for_outputs = Hash.new
    output_evs.each do |output_ev|
      input_data_for_outputs["#{output_ev.pe_attribute.id}"] = Hash.new
    end

    inputs_array_to_compute = Hash.new
    ["low", "most_likely", "high"].each do |level|
      inputs_array_to_compute[level] = Array.new
    end

    unless input_am.nil?

      unless input_evs.nil? || input_evs.empty?
        input_evs.each do |input_ev|

          tmp_prbl = Array.new

          input_size_data["#{input_ev.id}"] = Hash.new
          input_data_for_outputs["#{input_ev.pe_attribute.id}"] = Hash.new

          ["low", "most_likely", "high"].each do |level|

            if @operation_model.three_points_estimation?
              size_brut = params["retained_size_#{level}"]["#{input_ev.id}"]
            else
              size_brut = params["retained_size_most_likely"]["#{input_ev.id}"]
            end

            # We should multiply with the standard_unit_coeff before saving the value in DB
            operation_input = input_ev.pe_attribute.operation_input

            input_effort_unit_coefficient = operation_input.nil? ? 1 : operation_input.send("standard_unit_coefficient")
            input_effort_unit_coefficient.nil? ? (input_effort_unit_coefficient = 1) : (input_effort_unit_coefficient = input_effort_unit_coefficient.to_f)

            size = size_brut.blank? ? nil : (size_brut.to_f * input_effort_unit_coefficient)

            input_size_data["#{input_ev.id}"][level] = size
            input_data_for_outputs["#{input_ev.pe_attribute.id}"][level] = size

            unless size_brut.blank?
              inputs_array_to_compute[level] << size
            end

            input_ev.send("string_data_#{level}")[current_component.id] = size
            input_ev.save
            tmp_prbl << input_ev.send("string_data_#{level}")[current_component.id]
          end

          input_probable_value = ((tmp_prbl[0].to_f + (4 * tmp_prbl[1].to_f) + tmp_prbl[2].to_f)/6)
          input_ev.update_attribute(:"string_data_probable", { current_component.id => input_probable_value } )
        end


        ############# Effectuer les calculs pour la ou les sortie(s)  #############

        #output_ev = output_evs.first

        output_evs.each do |output_ev|
          output_tmp_prbl = Array.new

          operation_input = output_ev.pe_attribute.operation_input
          output_unit_coefficient = operation_input.nil? ? 1 : operation_input.send("standard_unit_coefficient")
          output_unit_coefficient = output_unit_coefficient.nil? ? 1 : output_unit_coefficient.to_f

          operation_type = @operation_model.operation_type

          case operation_type

            when "addition"
              ["low", "most_likely", "high"].each do |level|
                level_sum = inputs_array_to_compute[level].sum
                result_value = level_sum.to_f * output_unit_coefficient

                output_ev.send("string_data_#{level}")[current_component.id] = result_value
                output_tmp_prbl << result_value
              end
              
            when "moyenne"

              ["low", "most_likely", "high"].each do |level|
                level_sum = inputs_array_to_compute[level].sum
                number_of_inputs = inputs_array_to_compute[level].empty? ? 1 : inputs_array_to_compute[level].size
                result_value = (level_sum / number_of_inputs).to_f * output_unit_coefficient

                output_ev.send("string_data_#{level}")[current_component.id] = result_value
                output_tmp_prbl << result_value
              end
              
            when "multiplication"

              ["low", "most_likely", "high"].each do |level|
                level_sum = inputs_array_to_compute[level].compact.inject(:*)
                result_value = level_sum.to_f * output_unit_coefficient

                output_ev.send("string_data_#{level}")[current_component.id] = result_value
                output_tmp_prbl << result_value
              end
          end

          output_probable_value = ((output_tmp_prbl[0].to_f + (4 * output_tmp_prbl[1].to_f) + output_tmp_prbl[2].to_f)/6)
          #output_ev.update_attribute(:"string_data_probable", { current_component.id => output_probable_value } )
          output_ev.send("string_data_probable")[current_component.id] = output_probable_value
          output_ev.save
        end

      end
    end

    redirect_to main_app.dashboard_path(@project)
  end


  def save_efforts_save
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
      cpt = vw.pbs_project_element.nil? ? current_component : vw.pbs_project_element
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project, cpt)
    end
    #end

    redirect_to main_app.dashboard_path(@project)
  end

end
