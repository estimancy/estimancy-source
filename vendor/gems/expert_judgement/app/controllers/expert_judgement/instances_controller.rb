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

class ExpertJudgement::InstancesController < ApplicationController

  def index
    authorize! :show_modules_instances, ModuleProject

    ExpertJudgement::Instance.all
  end

  def show
    authorize! :show_modules_instances, ModuleProject
    @instance = ExpertJudgement::Instance.find(params[:id])
    @organization = @instance.organization

    set_page_title @instance.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:expert_judgement_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @instance.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.new
    @organization = Organization.find(params['organization_id'])

    set_page_title I18n.t(:New_model_of_Judgment_Expert)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:expert_judgement_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject
    @instance = ExpertJudgement::Instance.find(params[:id])
    @organization = @instance.organization

    set_page_title I18n.t(:Edit_model_of_Judgment_Expert)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}",  @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:expert_judgement_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @instance.name => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.new(params[:instance])
    @instance.organization_id = params[:instance][:organization_id].to_i
    @organization = Organization.find(params[:instance][:organization_id])

    if @instance.save
      redirect_to main_app.organization_module_estimation_path(@instance.organization_id, anchor: "effort")
    else
      render action: :new
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.find(params[:id])
    @organization = @instance.organization

    if @instance.update_attributes(params[:instance])
      redirect_to main_app.organization_module_estimation_path(@instance.organization_id, anchor: "effort")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.find(params[:id])
    organization_id = @instance.organization_id

    @instance.instance_estimates.each do |ie|
      ie.destroy
    end

    @instance.delete
    redirect_to main_app.organization_module_estimation_path(@instance.organization_id, anchor: "effort")
  end

  def save_efforts
    @expert_judgement_instance = ExpertJudgement::Instance.find(params[:instance_id])
    params[:values].each do |value|
      attr_id = value.first

      # ["input", "output"].each do |in_out|
      #   ["low", "high", "most_likely"].each do |level|
      #   end
      # end

      attr_unit_coefficient = 1
      pe_attribute = PeAttribute.find(attr_id)
      if pe_attribute
        if pe_attribute.alias == "effort"
          attr_unit_coefficient = @expert_judgement_instance.effort_unit_coefficient.to_f
        elsif pe_attribute.alias == "cost"
          attr_unit_coefficient = @expert_judgement_instance.cost_unit_coefficient.to_f
        end
      end


      most_likely_input = params[:values][attr_id]["most_likely"]["input"].to_f * attr_unit_coefficient
      most_likely_output = params[:values][attr_id]["most_likely"]["output"].to_f * attr_unit_coefficient

      if @expert_judgement_instance.three_points_estimation?
        low_input = params[:values][attr_id]["low"]["input"].to_f * attr_unit_coefficient
        high_input = params[:values][attr_id]["high"]["input"].to_f * attr_unit_coefficient

        low_output = params[:values][attr_id]["low"]["output"].to_f * attr_unit_coefficient
        high_output = params[:values][attr_id]["high"]["output"].to_f * attr_unit_coefficient

      else
        low_input = most_likely_input
        high_input = most_likely_input

        low_output = most_likely_output
        high_output = most_likely_output
      end

      ejie = ExpertJudgement::InstanceEstimate.where(pbs_project_element_id: current_component.id,
                                                     module_project_id: current_module_project.id,
                                                     expert_judgement_instance_id: @expert_judgement_instance.id,
                                                     pe_attribute_id: attr_id.to_i).first

      if ejie.nil?
        ejie = ExpertJudgement::InstanceEstimate.create(pbs_project_element_id: current_component.id,
                                                       module_project_id: current_module_project.id,
                                                       expert_judgement_instance_id: @expert_judgement_instance.id,
                                                       pe_attribute_id: attr_id.to_i,
                                                       low_input: low_input, #params[:values][attr_id]["low"]["input"].to_f,
                                                       most_likely_input: most_likely_input, #params[:values][attr_id]["most_likely"]["input"].to_f,
                                                       high_input: high_input, #params[:values][attr_id]["high"]["input"].to_f,
                                                       low_output: low_output, #params[:values][attr_id]["low"]["output"].to_f,
                                                       most_likely_output: most_likely_output, #params[:values][attr_id]["most_likely"]["output"].to_f,
                                                       high_output: high_output) #params[:values][attr_id]["high"]["output"].to_f)
      else
        ejie.tracking = params[:tracking][attr_id]
        ejie.comments = params[:comments][attr_id]
        ejie.description = params[:description][attr_id]

        if @expert_judgement_instance.three_points_estimation?
          ejie.low_input = low_input #params[:values][attr_id]["low"]["input"].to_f
          ejie.most_likely_input = most_likely_input  #params[:values][attr_id]["most_likely"]["input"].to_f
          ejie.high_input = high_input  #params[:values][attr_id]["high"]["input"].to_f

          ejie.low_output = low_output  #params[:values][attr_id]["low"]["output"].to_f
          ejie.most_likely_output = most_likely_output  #params[:values][attr_id]["most_likely"]["output"].to_f
          ejie.high_output = high_output  #params[:values][attr_id]["high"]["output"].to_f
        else
          in_value = most_likely_input  #params[:values][attr_id]["most_likely"]["input"].to_f
          out_value = most_likely_output  #params[:values][attr_id]["most_likely"]["output"].to_f

          ejie.low_input = ejie.most_likely_input = ejie.high_input = in_value
          ejie.low_output = ejie.most_likely_output = ejie.high_output = out_value
        end

        ejie.save
      end

      ["input", "output"].each do |io|

        tmp_prbl = Array.new

        ["low", "most_likely", "high"].each do |level|
          ev = EstimationValue.where(module_project_id: current_module_project.id,
                                     pe_attribute_id: attr_id.to_i,
                                     in_out: io).first

          if @expert_judgement_instance.three_points_estimation?
            ev.send("string_data_#{level}")[current_component.id] = params[:values][attr_id][level][io].to_f * attr_unit_coefficient
          else
            ev.send("string_data_#{level}")[current_component.id] = params[:values][attr_id]["most_likely"][io].to_f * attr_unit_coefficient
          end

          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]

          ev.save
        end

        ev = EstimationValue.where(module_project_id: current_module_project.id,
                                   pe_attribute_id: attr_id.to_i,
                                   in_out: io).first
        ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
      end
    end

    ViewsWidget::update_field(current_module_project, @current_organization, @project, current_component)

    # Reset all view_widget results
    ViewsWidget.reset_nexts_mp_estimation_values(current_module_project, current_component)
    current_module_project.all_nexts_mp_with_links.each do |module_project|
      ViewsWidget::update_field(module_project, @current_organization, @project, current_component, true)
    end

    redirect_to main_app.dashboard_path(@project)
  end


  def duplicate_expert_judgment

  end

end
