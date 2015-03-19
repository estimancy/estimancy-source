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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.new
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.find(params[:id])
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.new(params[:instance])
    @instance.organization_id = params[:instance][:organization_id].to_i
    @instance.save
    redirect_to main_app.organization_module_estimation_path(@instance.organization_id)
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.find(params[:id])
    @instance.update_attributes(params[:instance])

    redirect_to main_app.organization_module_estimation_path(@instance.organization_id)
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @instance = ExpertJudgement::Instance.find(params[:id])
    organization_id = @instance.organization_id

    @instance.instance_estimates.each do |ie|
      ie.destroy
    end

    @instance.delete
    redirect_to main_app.organization_module_estimation_path(@instance.organization_id)
  end

  def save_efforts
    @expert_judgement_instance = ExpertJudgement::Instance.find(params[:instance_id])
    params[:values].each do |value|
      attr_id = value.first
      ejie = ExpertJudgement::InstanceEstimate.where(pbs_project_element_id: current_component.id,
                                                     module_project_id: current_module_project.id,
                                                     expert_judgement_instance_id: @expert_judgement_instance.id,
                                                     pe_attribute_id: attr_id.to_i).first

      if ejie.nil?
        ejie = ExpertJudgement::InstanceEstimate.create(pbs_project_element_id: current_component.id,
                                                       module_project_id: current_module_project.id,
                                                       expert_judgement_instance_id: @expert_judgement_instance.id,
                                                       pe_attribute_id: attr_id.to_i,
                                                       low_input: params[:values][attr_id]["low"]["input"].to_f,
                                                       most_likely_input: params[:values][attr_id]["most_likely"]["input"].to_f,
                                                       high_input: params[:values][attr_id]["high"]["input"].to_f,
                                                       low_output: params[:values][attr_id]["low"]["output"].to_f,
                                                       most_likely_output: params[:values][attr_id]["most_likely"]["output"].to_f,
                                                       high_output: params[:values][attr_id]["high"]["output"].to_f)
      else
        ejie.tracking = params[:tracking][attr_id]
        ejie.comments = params[:comments][attr_id]
        ejie.description = params[:description][attr_id]

        if @expert_judgement_instance.three_points_estimation?
          ejie.low_input = params[:values][attr_id]["low"]["input"].to_f
          ejie.most_likely_input = params[:values][attr_id]["most_likely"]["input"].to_f
          ejie.high_input = params[:values][attr_id]["high"]["input"].to_f

          ejie.low_output = params[:values][attr_id]["low"]["output"].to_f
          ejie.most_likely_output = params[:values][attr_id]["most_likely"]["output"].to_f
          ejie.high_output = params[:values][attr_id]["high"]["output"].to_f
        else
          in_value = params[:values][attr_id]["most_likely"]["input"].to_f
          out_value = params[:values][attr_id]["most_likely"]["output"].to_f

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
            ev.send("string_data_#{level}")[current_component.id] = params[:values][attr_id][level][io].to_f
          else
            ev.send("string_data_#{level}")[current_component.id] = params[:values][attr_id]["most_likely"][io].to_f
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

    current_module_project.next.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end
    session[:module_project_id] = current_module_project.nexts.first.id

    redirect_to main_app.dashboard_path(@project)
  end

end
