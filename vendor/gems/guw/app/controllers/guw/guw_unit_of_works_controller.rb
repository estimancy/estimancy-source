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

class Guw::GuwUnitOfWorksController < ApplicationController

  include ModuleProjectsHelper

  def new
    @guw_unit_of_work = Guw::GuwUnitOfWork.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    @organization = @guw_model.organization
    @project = current_module_project.project

    set_page_title I18n.t(:New_Units_Of_Work)
  end

  def edit
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    @organization = @guw_unit_of_work.organization rescue @guw_model.organization
    @project = @guw_unit_of_work.project rescue current_module_project.project

    set_page_title I18n.t(:Edit_Units_Of_Work)
  end

  def create
    unless params[:guw_type_id].blank?
      @guw_type = Guw::GuwType.find(params[:guw_type_id])
    end

    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @organization = @guw_model.organization

    module_project = ModuleProject.where(organization_id: @organization.id, id: params[:module_project_id]).first #.find(params[:module_project_id])
    @project = module_project.project

    if module_project.guw_unit_of_works.where(guw_type_id: @guw_type.id).size >= @guw_type.maximum.to_i && !@guw_type.maximum.nil?
      render js: "alert('Vous ne pouvez pas créer plus de #{@guw_type.maximum.to_s} composants pour #{@guw_type.to_s}.')";
    else

      @guw_outputs = @guw_model.guw_outputs
      @guw_unit_of_work = Guw::GuwUnitOfWork.new(name: params[:name],
                                                 comments: params[:comments],
                                                 guw_type_id: params[:guw_type_id],
                                                 organization_id: params[:organization_id],
                                                 guw_model_id: @guw_model.id,
                                                 project_id: params[:project_id],
                                                 module_project_id: params[:module_project_id],
                                                 guw_unit_of_work_group_id: params[:guw_unit_of_work_group_id])

      @guw_unit_of_work.guw_model_id = @guw_model.id
      @guw_unit_of_work.pbs_project_element_id = current_component.id
      @guw_unit_of_work.selected = true

      @guw_unit_of_work.ajusted_size = {}
      @guw_unit_of_work.size = {}
      @guw_unit_of_work.effort = {}
      @guw_unit_of_work.cost = {}

      @group = @guw_unit_of_work.guw_unit_of_work_group

      @position = params[:hidden_position]

      if @position.blank?
        begin
          @guw_unit_of_work.display_order = @group.guw_unit_of_works.where(organization_id: @organization.id, guw_model_id: @guw_model.id).order("display_order ASC").last.display_order.to_i + 1
        rescue
          @guw_unit_of_work.display_order = 0
        end
      else
        @guw_unit_of_work.display_order = params[:hidden_position].to_i
      end

      @guw_unit_of_work.save

      reorder @group

      current_module_project_guw_unit_of_works = module_project.guw_unit_of_works.where(organization_id: @organization.id, guw_model_id: @guw_model.id, project_id: @project.id)
      @selected_of_unit_of_works = "#{current_module_project_guw_unit_of_works.where(selected: true).size} / #{current_module_project_guw_unit_of_works.size}"
      @group_selected_of_unit_of_works = "#{current_module_project_guw_unit_of_works.where(guw_unit_of_work_group_id: @group.id,
                                                                                           selected: true).size} / #{current_module_project_guw_unit_of_works.where(guw_unit_of_work_group_id: @group.id).size}"

      @guw_model.guw_attributes.where(organization_id: @organization.id, guw_model_id: @guw_model.id).all.each do |gac|
        Guw::GuwUnitOfWorkAttribute.create(organization_id: @organization.id,
                                           guw_model_id: @guw_model.id,
                                           project_id: @project.id,
                                           module_project_id: module_project.id,
                                           guw_type_id: @guw_type.nil? ? nil : @guw_type.id,
                                           guw_unit_of_work_id: @guw_unit_of_work.id,
                                           guw_attribute_id: gac.id)
      end
    end

    # redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])

    @organization = @guw_unit_of_work.organization
    @project = @guw_unit_of_work.project rescue current_module_project.project

    if @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
      redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}") and return
    else
      render :edit
    end

  end

  def destroy
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_model = @guw_unit_of_work.guw_model
    group = @guw_unit_of_work.guw_unit_of_work_group
    module_project = @guw_unit_of_work.module_project
    organization = module_project.organization
    component = current_component

    @guw_unit_of_work.delete

    reorder group

    # update_estimation_values
    # update_view_widgets_and_project_fields
    Guw::GuwUnitOfWork.update_estimation_values(module_project, component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(organization, module_project, component)
  end

  def up
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    display_order = @guw_unit_of_work.display_order.to_i

    @guw_unit_of_work.display_order = display_order - 2
    @guw_unit_of_work.save

    reorder @guw_unit_of_work.guw_unit_of_work_group

    @module_project = @guw_unit_of_work.module_project
    @project = @module_project.project
    @guw_model = @module_project.guw_model
    @component = current_component
    @organization = @guw_model.organization
  end

  def down
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order.to_i + 1
    @guw_unit_of_work.save

    reorder @guw_unit_of_work.guw_unit_of_work_group

    @module_project = @guw_unit_of_work.module_project
    @project = @module_project.project
    @guw_model = @module_project.guw_model
    @component = current_component
    @organization = @guw_model.organization
  end

  def load_cplx_comments
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @previousValue = params["previousValue"]
    @value = params["value"]
  end

  def save_cplx_comments
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    @module_project = @guw_unit_of_work.module_project

    @guw_model = @module_project.guw_model
    @organization = @guw_model.organization
    @project = @module_project.project
    @component = current_component

    @value = params[:value].blank? ? @guw_unit_of_work.intermediate_weight : params[:value]

    @guw_unit_of_work.cplx_comments = params[:cplx_comments]
    @guw_unit_of_work.intermediate_weight = @value.to_f
    @guw_unit_of_work.save

    # redirect_to main_app.dashboard_path(@project, recalculate: true)
  end

  def load_coefficient_comments
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_coefficient = Guw::GuwCoefficient.find(params[:coeff_id])
    @guw_coefficient_element = Guw::GuwCoefficientElement.find(params[:guw_coefficient_element_id])
    @value = params[:value].blank? ? @guw_coefficient_element.value : params[:value]
    @previousValue = params["previousValue"]
    @ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @guw_unit_of_work.organization_id,
                                                       guw_model_id: @guw_unit_of_work.guw_model_id,
                                                       guw_coefficient_id: @guw_coefficient.id,
                                                       project_id: @guw_unit_of_work.project_id,
                                                       module_project_id: @guw_unit_of_work.module_project_id,
                                                       guw_unit_of_work_id: @guw_unit_of_work.id).first
  end

  def save_coefficient_comments

    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @module_project = @guw_unit_of_work.module_project

    @guw_model = @module_project.guw_model
    @organization = @guw_model.organization
    @project = @module_project.project
    @component = current_component

    @guw_coefficient = Guw::GuwCoefficient.where(organization_id: @organization.id, guw_model_id: @guw_model.id, id: params[:guw_coefficient_id]).first  #.find(params[:guw_coefficient_id])
    @guw_coefficient_element = Guw::GuwCoefficientElement.where(organization_id: @organization.id, guw_model_id: @guw_model.id, id: params[:guw_coefficient_element_id]).first #.find(params[:guw_coefficient_element_id])

    @ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                       guw_model_id: @guw_model.id,
                                                       guw_coefficient_id: @guw_coefficient.id,
                                                       guw_coefficient_element_id: @guw_coefficient_element.id,
                                                       project_id: @project.id,
                                                       module_project_id: @module_project.id,
                                                       guw_unit_of_work_id: @guw_unit_of_work.id).first_or_create!

    @ceuw.percent = params["value"].to_f

    if @ceuw.percent == @guw_coefficient_element.value
      @ceuw.comments = nil
    else
      @ceuw.comments = params["comments"].to_s
    end

    @ceuw.save
    @guw_unit_of_work.save

    # redirect_to main_app.dashboard_path(@project, recalculate: true)
  end

  def load_cotations
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_model = @guw_unit_of_work.guw_model
  end

  def load_name
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  end

  def save_name
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:name].keys.first)
    @guw_unit_of_work.name = params[:name].values.first
    @guw_unit_of_work.save

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def load_trackings
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  end

  def load_comments
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  end

  def save_comments
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:comments].keys.first)

    @module_project = @guw_unit_of_work.module_project
    @project = @module_project.project
    @guw_model = @module_project.guw_model
    @component = current_component
    @organization = @guw_model.organization

    @guw_unit_of_work.name = params[:name].values.first
    @guw_unit_of_work.comments = params[:comments].values.first
    @guw_unit_of_work.tracking = params[:trackings].values.first
    @guw_unit_of_work.guw_unit_of_work_group_id = params[:guw_unit_of_work_group_id]
    @guw_unit_of_work.save
  end

  def save_uo

    guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @module_project = guw_unit_of_work.module_project
    @organization = @module_project.organization
    @project = @module_project.project
    @guw_model = @module_project.guw_model
    @component = current_component

    begin
      guw_type = Guw::GuwType.find(params[:guw_type]["#{guw_unit_of_work.id}"])
    rescue
      guw_type = guw_unit_of_work.guw_type
    end

    @lows = Array.new
    @mls = Array.new
    @highs = Array.new
    array_pert = Array.new

    guw_unit_of_work.off_line = false
    guw_unit_of_work.off_line_uo = false

    guw_unit_of_work.guw_unit_of_work_attributes.where(organization_id: @organization.id, guw_model_id: @guw_model.id).each do |guowa|
      calculate_guowa(guowa, guw_unit_of_work, guw_type)
    end

    if @lows.empty?
      guw_unit_of_work.guw_complexity_id = nil
      guw_unit_of_work.guw_original_complexity_id = nil
      guw_unit_of_work.result_low = nil
    else
      guw_unit_of_work.result_low = @lows.sum
    end

    if @mls.empty?
      guw_unit_of_work.guw_complexity_id = nil
      guw_unit_of_work.guw_original_complexity_id = nil
      guw_unit_of_work.result_most_likely = nil
    else
      guw_unit_of_work.result_most_likely = @mls.sum
    end

    if @highs.empty?
      guw_unit_of_work.guw_complexity_id = nil
      guw_unit_of_work.guw_original_complexity_id = nil
      guw_unit_of_work.result_high = nil
    else
      guw_unit_of_work.result_high = @highs.sum
    end

    begin
      guw_work_unit = Guw::GuwWorkUnit.find(params[:guw_work_unit]["#{guw_unit_of_work.id}"])
    rescue
      guw_work_unit = guw_unit_of_work.guw_work_unit
    end

    begin
      guw_weighting = Guw::GuwWeighting.find(params[:guw_weighting]["#{guw_unit_of_work.id}"])
    rescue
      guw_weighting = guw_unit_of_work.guw_weighting
    end

    begin
      guw_factor = Guw::GuwFactor.find(params[:guw_factor]["#{guw_unit_of_work.id}"])
    rescue
      guw_factor = guw_unit_of_work.guw_factor
    end

    guw_unit_of_work.guw_type_id ||= guw_type.id
    guw_unit_of_work.guw_work_unit_id = guw_work_unit.nil? ? nil : guw_work_unit.id
    guw_unit_of_work.guw_weighting_id = guw_weighting.nil? ? nil : guw_weighting.id
    guw_unit_of_work.guw_factor_id = guw_factor.nil? ? nil : guw_factor.id
    guw_unit_of_work.save

    unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
      guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
      guw_unit_of_work.guw_complexity_id = guw_complexity_id
      guw_unit_of_work.guw_original_complexity_id = guw_complexity_id
      guw_unit_of_work.save
    else
      guw_complexity_id = guw_unit_of_work.guw_complexity_id
    end

    if (guw_unit_of_work.guw_type.allow_complexity == true && guw_unit_of_work.guw_type.allow_criteria == false)

      tcplx = Guw::GuwComplexityTechnology.where(organization_id: @organization.id,
                                                 guw_model_id: @guw_model.id,
                                                 organization_technology_id: guw_unit_of_work.organization_technology_id,
                                                 guw_complexity_id: guw_complexity_id).first

      if guw_unit_of_work.guw_complexity.nil?
        array_pert << 0
      else
        array_pert << (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
      end
      guw_unit_of_work.save
    else
      if guw_unit_of_work.result_low.nil? or guw_unit_of_work.result_most_likely.nil? or guw_unit_of_work.result_high.nil?
        guw_unit_of_work.off_line_uo = nil
      else
        #Save if uo is simple/ml/high
        value_pert = compute_probable_value(guw_unit_of_work.result_low, guw_unit_of_work.result_most_likely, guw_unit_of_work.result_high)[:value]
        if (value_pert < guw_type.guw_complexities.map(&:bottom_range).min.to_f)
          guw_unit_of_work.off_line_uo = true
        elsif (value_pert >= guw_type.guw_complexities.map(&:top_range).max.to_f)
          guw_unit_of_work.off_line_uo = true
          cplx = guw_type.guw_complexities.last
          if cplx.nil?
            guw_unit_of_work.guw_complexity_id = nil
            guw_unit_of_work.guw_original_complexity_id = nil
          else
            guw_unit_of_work.guw_complexity_id = cplx.id
            guw_unit_of_work.guw_original_complexity_id = cplx.id
            array_pert << calculate_seuil(guw_unit_of_work, guw_type.guw_complexities.where(organization_id: @organization.id, guw_model_id: @guw_model.id).last, value_pert)
          end
        else
          guw_type.guw_complexities.each do |guw_c|
            array_pert << calculate_seuil(guw_unit_of_work, guw_c, value_pert)
          end
        end
      end
    end

    guw_unit_of_work.quantity = params["hidden_quantity"]["#{guw_unit_of_work.id}"].blank? ? 1 : params["hidden_quantity"]["#{guw_unit_of_work.id}"].to_f
    guw_unit_of_work.save

    final_value = (guw_unit_of_work.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f)
    # calculate_attributes(guw_unit_of_work, guw_factor, guw_weighting, guw_work_unit, tcplx, final_value, @guw_model)

    complexity_work_unit = Guw::GuwComplexityWorkUnit.where(organization_id: @organization.id,
                                                            guw_model_id: @guw_model.id,
                                                            guw_work_unit_id: guw_work_unit,
                                                            guw_complexity_id: guw_unit_of_work.guw_complexity).first

    complexity_weighting = Guw::GuwComplexityWeighting.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
                                                             guw_weighting_id: guw_weighting).first

    complexity_factor = Guw::GuwComplexityFactor.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
                                                       guw_factor_id: guw_factor).first

    type_attribute_array = []
    effort_array_value = []
    cost_array_value = []
    size_array_value = []

    ["effort", "size", "cost"].each do |ta|
      Guw::GuwScaleModuleAttribute.where(guw_model_id: @guw_model, type_attribute: ta).each do |gsma|
        type_attribute_array << gsma
      end
    end

    type_attribute_array.each do |taa|
      cts = eval("complexity_#{taa.type_scale}")
      sv = eval("guw_#{taa.type_scale}")

      eval("#{taa.type_attribute}_array_value") << (cts.nil? ? 1 : (cts.value.nil? ? 1 : cts.value)) * (sv.nil? ? 1 : (sv.value.nil? ? 1 : sv.value))
    end

    guw_unit_of_work.size = final_value.to_f *
        (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) *
        (size_array_value.inject(&:*).nil? ? 1 : size_array_value.inject(&:*))

    if guw_unit_of_work.guw_type.allow_retained == false
      guw_unit_of_work.size == guw_unit_of_work.ajusted_size
      guw_unit_of_work.save
    end

    if params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"].blank?
      guw_unit_of_work.ajusted_size = final_value
    elsif params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"] != array_pert.sum
      guw_unit_of_work.ajusted_size = params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"].to_f
    end

    guw_unit_of_work.flagged = false

    guw_unit_of_work.save

    if guw_unit_of_work.guw_type.allow_retained == false
      guw_unit_of_work.ajusted_size = guw_unit_of_work.size
    end

    guw_unit_of_work.save

    guw_unit_of_work.effort =  guw_unit_of_work.ajusted_size.nil? ? 1 : guw_unit_of_work.ajusted_size *
        (effort_array_value.inject(&:*).nil? ? 1 : effort_array_value.inject(&:*))

    guw_unit_of_work.cost = guw_unit_of_work.ajusted_size.nil? ? 1 : guw_unit_of_work.ajusted_size *
        (cost_array_value.inject(&:*).nil? ? 1 : cost_array_value.inject(&:*))

    guw_unit_of_work.save

    # update_estimation_values
    # update_view_widgets_and_project_fields
    Guw::GuwUnitOfWork.update_estimation_values(@module_project, @component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, @component)

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def duplicate
    @old_guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    @guw_type = @old_guw_unit_of_work.guw_type

    uo_guw_type = current_module_project.guw_unit_of_works.where(guw_type_id: @guw_type.id).first

    # if uo_guw_type.nil?
      @guw_unit_of_work = @old_guw_unit_of_work.amoeba_dup
      @guw_unit_of_work.save
    # else
    #   if uo_guw_type.size < @old_guw_unit_of_work.guw_type.maximum
    #     @guw_unit_of_work = @old_guw_unit_of_work.amoeba_dup
    #     @guw_unit_of_work.save
    #   else
    #     render js: "alert('Vous ne pouvez pas créer plus de #{@guw_type.maximum.to_s} composants pour #{@guw_type.to_s}.')";
    #   end
    # end

    @guw_model = @old_guw_unit_of_work.guw_model
    @guw_outputs = @guw_model.guw_outputs.where(organization_id: @guw_model.organization_id,
                                                guw_model_id: @guw_model.id)
  end

  # def save_guw_unit_of_works
  #   @module_project = current_module_project
  #   @organization = @module_project.organization
  #   @project = @module_project.project
  #   @guw_model = @module_project.guw_model
  #   @component = current_component
  #   @guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: @organization.id,
  #                                                 guw_model_id: @guw_model.id,
  #                                                 project_id: @project.id,
  #                                                 module_project_id: @module_project.id,
  #                                                 pbs_project_element_id: @component.id).order("name ASC")
  #
  #   @guw_unit_of_works.each_with_index do |guw_unit_of_work, i|
  #     array_pert = Array.new
  #     if !params[:selected].nil? && params[:selected].join(",").include?(guw_unit_of_work.id.to_s)
  #       guw_unit_of_work.selected = true
  #     else
  #       guw_unit_of_work.selected = false
  #     end
  #
  #     #reorder to keep good order
  #     # reorder guw_unit_of_work.guw_unit_of_work_group
  #
  #     begin
  #       guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id, id: params[:guw_type]["#{guw_unit_of_work.id}"]).first  #.find(params[:guw_type]["#{guw_unit_of_work.id}"])
  #     rescue
  #       guw_type = guw_unit_of_work.guw_type
  #     end
  #
  #     begin
  #       guw_work_unit = Guw::GuwWorkUnit.where(organization_id: @organization.id, guw_model_id: @guw_model.id, id: params[:guw_work_unit]["#{guw_unit_of_work.id}"]).first #.find(params[:guw_work_unit]["#{guw_unit_of_work.id}"])
  #     rescue
  #       guw_work_unit = guw_unit_of_work.guw_work_unit
  #     end
  #
  #     begin
  #       guw_weighting = Guw::GuwWeighting.find(params[:guw_weighting]["#{guw_unit_of_work.id}"])
  #     rescue
  #       guw_weighting = guw_unit_of_work.guw_weighting
  #     end
  #
  #     begin
  #       guw_factor = Guw::GuwFactor.find(params[:guw_factor]["#{guw_unit_of_work.id}"])
  #     rescue
  #       guw_factor = guw_unit_of_work.guw_factor
  #     end
  #
  #     if params[:guw_technology].present?
  #       guw_unit_of_work.organization_technology_id = params[:guw_technology]["#{guw_unit_of_work.id}"].to_i
  #     end
  #
  #     guw_unit_of_work.guw_type_id = guw_type.id
  #     guw_unit_of_work.guw_work_unit = guw_work_unit
  #     guw_unit_of_work.guw_weighting = guw_weighting
  #     guw_unit_of_work.guw_factor = guw_factor
  #
  #     @guw_model.guw_attributes.all.each do |gac|
  #       guw_unit_of_work.save
  #       finder = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
  #                                                  guw_model_id: @guw_model.id,
  #                                                  guw_attribute_id: gac.id,
  #                                                  guw_type_id: guw_type.id,
  #                                                  project_id: @project.id,
  #                                                  module_project_id: @module_project.id,
  #                                                  guw_unit_of_work_id: guw_unit_of_work.id).first_or_create
  #       finder.save
  #     end
  #
  #     if params["quantity"].present?
  #       guw_unit_of_work.quantity = params["quantity"]["#{guw_unit_of_work.id}"].nil? ? 1 : params["quantity"]["#{guw_unit_of_work.id}"].to_f
  #     else
  #       guw_unit_of_work.quantity = 1
  #     end
  #
  #     if guw_unit_of_work.guw_type.allow_complexity == true
  #       unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
  #         guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
  #         guw_unit_of_work.guw_complexity_id = guw_complexity_id
  #         guw_unit_of_work.save
  #       else
  #         guw_complexity_id = guw_unit_of_work.guw_complexity_id
  #       end
  #
  #       complexity_work_unit = Guw::GuwComplexityWorkUnit.where(organization_id: @organization.id,
  #                                                               guw_model_id: @guw_model.id,
  #                                                               guw_work_unit_id: guw_work_unit,
  #                                                               guw_complexity_id: guw_complexity_id).first
  #
  #       complexity_weighting = Guw::GuwComplexityWeighting.where(guw_complexity_id: guw_complexity_id,
  #                                                                guw_weighting_id: guw_weighting).first
  #
  #       complexity_factor = Guw::GuwComplexityFactor.where(guw_complexity_id: guw_complexity_id,
  #                                                          guw_factor_id: guw_factor).first
  #
  #       tcplx = Guw::GuwComplexityTechnology.where(organization_id: @organization.id,
  #                                                  guw_model_id: @guw_model.id,
  #                                                  organization_technology_id: guw_unit_of_work.organization_technology_id,
  #                                                  guw_complexity_id: guw_complexity_id,
  #                                                  guw_type_id: guw_unit_of_work.guw_type_id).first
  #
  #       guw_unit_of_work.save
  #     else
  #       unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
  #         guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
  #         guw_unit_of_work.guw_complexity_id = guw_complexity_id
  #         guw_unit_of_work.save
  #       else
  #         guw_complexity_id = guw_unit_of_work.guw_complexity_id
  #       end
  #     end
  #
  #     if guw_unit_of_work.guw_complexity.nil?
  #       final_value = nil
  #     else
  #       weight = (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
  #       if guw_unit_of_work.guw_complexity.enable_value == false
  #         final_value = weight
  #       else
  #         result_low = guw_unit_of_work.result_low.nil? ? 1 : guw_unit_of_work.result_low
  #         result_most_likely = guw_unit_of_work.result_most_likely.nil? ? 1 : guw_unit_of_work.result_most_likely
  #         result_high = guw_unit_of_work.result_high.nil? ? 1 : guw_unit_of_work.result_high
  #
  #         final_value = ((result_low + 4 * result_most_likely +  result_high) / 6) * (weight.nil? ? 1 : weight.to_f)
  #       end
  #     end
  #
  #     complexity_work_unit = Guw::GuwComplexityWorkUnit.where(organization_id: @organization.id,
  #                                                             guw_model_id: @guw_model.id,
  #                                                             guw_work_unit_id: guw_work_unit,
  #                                                             guw_complexity_id: guw_unit_of_work.guw_complexity).first
  #
  #     complexity_weighting = Guw::GuwComplexityWeighting.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
  #                                                              guw_weighting_id: guw_weighting).first
  #
  #     complexity_factor = Guw::GuwComplexityFactor.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
  #                                                        guw_factor_id: guw_factor).first
  #
  #     type_attribute_array = []
  #     effort_array_value = []
  #     cost_array_value = []
  #     size_array_value = []
  #
  #     ["effort", "size", "cost"].each do |ta|
  #       Guw::GuwScaleModuleAttribute.where(guw_model_id: @guw_model, type_attribute: ta).each do |gsma|
  #         type_attribute_array << gsma
  #       end
  #     end
  #
  #     type_attribute_array.each do |taa|
  #       cts = eval("complexity_#{taa.type_scale}")
  #       sv = eval("guw_#{taa.type_scale}")
  #
  #       eval("#{taa.type_attribute}_array_value") << (cts.nil? ? 1 : (cts.value.nil? ? 1 : cts.value)) * (sv.nil? ? 1 : (sv.value.nil? ? 1 : sv.value))
  #     end
  #
  #     if final_value.nil?
  #       guw_unit_of_work.size = nil
  #       if params["ajusted_size"].nil?
  #         guw_unit_of_work.ajusted_size = nil
  #       else
  #         guw_unit_of_work.ajusted_size = params["ajusted_size"]["#{guw_unit_of_work.id}"].to_f
  #       end
  #     else
  #       guw_unit_of_work.size = final_value.to_f *
  #           (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) *
  #           (size_array_value.inject(&:*).nil? ? 1 : size_array_value.inject(&:*))
  #
  #       if guw_unit_of_work.guw_type.allow_retained == false
  #         guw_unit_of_work.ajusted_size = guw_unit_of_work.size.to_f
  #       else
  #         if params["ajusted_size"]["#{guw_unit_of_work.id}"].blank?
  #           guw_unit_of_work.ajusted_size = guw_unit_of_work.size.to_f
  #         else
  #           guw_unit_of_work.ajusted_size = params["ajusted_size"]["#{guw_unit_of_work.id}"].to_f
  #         end
  #       end
  #     end
  #
  #     guw_unit_of_work.save
  #
  #     unless guw_unit_of_work.ajusted_size.nil?
  #       guw_unit_of_work.effort = guw_unit_of_work.ajusted_size *
  #           (effort_array_value.inject(&:*).nil? ? 1 : effort_array_value.inject(&:*))
  #
  #       guw_unit_of_work.cost = guw_unit_of_work.ajusted_size *
  #           (cost_array_value.inject(&:*).nil? ? 1 : cost_array_value.inject(&:*))
  #     end
  #
  #     if guw_unit_of_work.size.nil? || guw_unit_of_work.ajusted_size.nil?
  #       guw_unit_of_work.flagged = false
  #     else
  #       if guw_unit_of_work.off_line == true || guw_unit_of_work.off_line_uo == true
  #         guw_unit_of_work.flagged = true
  #       elsif guw_unit_of_work.size.to_f != guw_unit_of_work.ajusted_size.to_f
  #         guw_unit_of_work.flagged = true
  #       else
  #         guw_unit_of_work.flagged = false
  #       end
  #     end
  #
  #     guw_unit_of_work.save
  #   end
  #
  #   # update_estimation_values
  #   # update_view_widgets_and_project_fields
  #   Guw::GuwUnitOfWork.update_estimation_values(@module_project, @component)
  #   Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, @component)
  #
  #   if @guw_unit_of_works.last.nil?
  #     redirect_to main_app.dashboard_path(@project)
  #   else
  #     redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_works.last.guw_unit_of_work_group.id}")
  #   end
  # end

  def change_cotation
    authorize! :execute_estimation_plan, @project

    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_model = @guw_unit_of_work.guw_model
    @guw_type = Guw::GuwType.find(params[:guw_type_id])

    if @guw_unit_of_work.module_project.guw_unit_of_works.where(guw_type_id: @guw_type.id).size >= @guw_type.maximum.to_i && !@guw_type.maximum.nil?
      render js: "alert('Vous ne pouvez pas créer plus de #{@guw_type.maximum.to_s} composants pour #{@guw_type.to_s}.')";
    else

      @guw_model.guw_attributes.where(organization_id: @guw_model.organization_id, guw_model_id: @guw_model.id).all.each do |gac|
        finder = Guw::GuwUnitOfWorkAttribute.where(organization_id: @guw_model.organization_id,
                                                   guw_model_id: @guw_model.id,
                                                   guw_attribute_id: gac.id,
                                                   guw_type_id: @guw_type.id,
                                                   project_id: @guw_unit_of_work.project_id,
                                                   module_project_id: @guw_unit_of_work.module_project_id,
                                                   guw_unit_of_work_id: @guw_unit_of_work.id).first_or_create
        finder.save
      end


      # technology = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq.first
      # @guw_unit_of_work.organization_technology_id = technology.nil? ? nil : technology.id

      @guw_unit_of_work.guw_type_id = @guw_type.id
      @guw_unit_of_work.effort = nil
      @guw_unit_of_work.guw_complexity_id = nil

      @guw_unit_of_work.ajusted_size = nil
      @guw_unit_of_work.size = nil
    
      @guw_unit_of_work.save

      #Changer le libelle du popup avec la description du nouveau type d'UO sélectionne
      # @guw_types = @guw_model.guw_types.includes(:guw_complexities)
      # @new_popup_title = (@guw_type.description.blank? ? @guw_type.name : @guw_type.description)
    end
    #
    # respond_to do |format|
    #   format.html { redirect_to main_app.dashboard_path(@project,
    #                                                     mgli: @guw_unit_of_work.id,
    #                                                     anchor: "guw_type_#{@guw_unit_of_work.id}") and return }
    #
    #   format.js { render :js => "window.location.replace(main_app.dashboard_path(#{@project}, mgli: #{@guw_unit_of_work.id},
    #                                                     anchor: guw_type_#{@guw_unit_of_work.id}\"));"}
    # end
  end

  # def change_work_unit
  #   authorize! :execute_estimation_plan, @project
  #
  #   @guw_model = current_module_project.guw_model
  #   @guw_work_unit = Guw::GuwWorkUnit.find(params[:guw_work_unit_id])
  #   @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  #   @guw_unit_of_work.guw_work_unit_id = @guw_work_unit.id
  #   @guw_unit_of_work.save
  # end

  # def change_technology_form
  #   authorize! :execute_estimation_plan, @project
  #
  #   @guw_model = current_module_project.guw_model
  #   @guw_type = Guw::GuwType.find(params[:guw_type_id])
  #   @technologies = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq
  # end

  # Voir utlisation de la Vue
  def change_selected_state_save
    authorize! :execute_estimation_plan, @project

    module_project = current_module_project
    component = current_component
    number_precision = user_number_precision

    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    if @guw_unit_of_work.selected == false
      @guw_unit_of_work.selected = true
    else
      @guw_unit_of_work.selected = false
    end

    @guw_unit_of_work.save

    @group = Guw::GuwUnitOfWorkGroup.find(params[:guw_unit_of_work_group_id])
    @mp_guw_group = ModuleProjectGuwUnitOfWorkGroup.where(guw_unit_of_work_group_id: :@group.id, pbs_project_element_id: component.id)
    @group_module_project_guw_unit_of_works = @group.module_project_guw_unit_of_works.where(pbs_project_element_id: component.id,
                                                                                            guw_model_id: @guw_unit_of_work.guw_model.id)
    @group_number_of_unit_of_works = @group.number_of_uow_lines.to_f.round(number_precision)
    @group_selected_of_unit_of_works = @group.number_of_uow_selected_lines.to_f.round(number_precision)

    #For grouped unit of work
    @group_size_ajusted = @group_module_project_guw_unit_of_works.where(selected: true).map{ |i| (i.ajusted_size.is_a?(Numeric) ? i.ajusted_size.to_f : i.ajusted_size["#{guw_output.id}"].to_f) }.sum.to_f.round(number_precision)

    @group_size_theorical = @group_module_project_guw_unit_of_works.where(selected: true).map{|i| (i.size.is_a?(Numeric) ? i.size.to_f : i.size["#{guw_output.id}"].to_f)}.sum.to_f.round(number_precision)

    #For all unit of work
    @ajusted_size = Guw::GuwUnitOfWork.where(selected: true,
                                             organization_id: @project.organization_id,
                                             project_id: @project.id,
                                             module_project_id: module_project.id,
                                             pbs_project_element_id: component.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_size.to_f }.sum.to_f.round(user_number_precision)

    @theorical_size = Guw::GuwUnitOfWork.where(selected: true,
                                               pbs_project_element_id: component.id,
                                               module_project_id: module_project.id,
                                               guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.size.to_f }.sum.to_f.round(user_number_precision)

    @effort = Guw::GuwUnitOfWork.where(selected: true,
                                       organization_id: @project.organization_id,
                                       project_id: @project.id,
                                       module_project_id: module_project.id,
                                       pbs_project_element_id: component.id,
                                       guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.effort.to_f }.sum.to_f.round(user_number_precision)

    @cost = Guw::GuwUnitOfWork.where(selected: true,
                                     organization_id: @project.organization_id,
                                     project_id: @project.id,
                                     module_project_id: module_project.id,
                                     pbs_project_element_id: component.id,
                                     guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.cost.to_f }.sum.to_f.round(number_precision)

    @number_of_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: @project.organization_id,
                                                        project_id: @project.id,
                                                        module_project_id: module_project.id,
                                                        pbs_project_element_id: component.id,
                                                        guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum.to_f.round(number_precision)

    @selected_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                          organization_id: @project.organization_id,
                                                          project_id: @project.id,
                                                          module_project_id: module_project.id,
                                                          pbs_project_element_id: component.id,
                                                          guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum.to_f.round(number_precision)

    # update_estimation_values
    # update_view_widgets_and_project_fields
    Guw::GuwUnitOfWork.update_estimation_values(module_project, component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@project.organization, module_project, component)
  end

  def change_selected_state
    authorize! :execute_estimation_plan, @project

    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @module_project = @guw_unit_of_work.module_project

    @organization = @module_project.organization
    @guw_model = @module_project.guw_model
    @component = current_component
    @group = @guw_unit_of_work.guw_unit_of_work_group

    if @guw_unit_of_work.selected == false
      @guw_unit_of_work.selected = true
    else
      @guw_unit_of_work.selected = false
    end

    @guw_unit_of_work.save

    current_module_project_guw_unit_of_works = current_module_project.guw_unit_of_works
    @selected_of_unit_of_works = "#{current_module_project_guw_unit_of_works.where(selected: true).size} / #{current_module_project_guw_unit_of_works.size}"

    @group_selected_of_unit_of_works = "#{current_module_project_guw_unit_of_works.where(guw_unit_of_work_group_id: @group.id,
                                                                                         selected: true).size} / #{current_module_project_guw_unit_of_works.where(guw_unit_of_work_group_id: @group.id).size}"

    # update_estimation_values
    # update_view_widgets_and_project_fields
    Guw::GuwUnitOfWork.update_estimation_values(@module_project, @component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, @component)
  end

  def calculate_guowa(guowa, guw_unit_of_work, guw_type, guw_type_attributes_complexities=nil)

    organization_id = @guw_model.organization_id

    begin
      if params["most_likely"]["#{guw_unit_of_work.id}"].values.include?("")
        guw_unit_of_work.missing_value = true
      else
        guw_unit_of_work.missing_value = false
      end
    rescue
      #
    end

    #Peut être factorisé  dans une boucle !
    if @guw_model.three_points_estimation == true
      #Estimation 3 points
      if params["low"]["#{guw_unit_of_work.id}"].nil?
        low = guowa.low
        # guw_unit_of_work.flagged = true
      else
        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["most_likely"]["#{guw_unit_of_work.id}"].nil?
        most_likely = guowa.most_likely
        # guw_unit_of_work.flagged = true
      else
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["high"]["#{guw_unit_of_work.id}"].nil?
        high = guowa.high
        # guw_unit_of_work.flagged = true
      else
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end
    else
      begin
        #Estimation 1 point
        if params["most_likely"]["#{guw_unit_of_work.id}"].nil? or params["most_likely"]["#{guw_unit_of_work.id}"].values.map(&:to_f).flatten.sum.blank?
          low = most_likely = high = guowa.most_likely
          # guw_unit_of_work.flagged = true
        else
          if params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
            low = most_likely = high = nil
          else
            low = most_likely = high = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i
          end
        end
      rescue
        low = most_likely = high = guowa.most_likely
      end
    end

    if guw_type_attributes_complexities.nil?
      @guw_attribute_complexities = Guw::GuwAttributeComplexity.where(organization_id: organization_id,
                                                                      guw_model_id: @guw_model.id,
                                                                      guw_attribute_id: guowa.guw_attribute_id,
                                                                      guw_type_id: guw_type.id).all
    else
      @guw_attribute_complexities = guw_type_attributes_complexities[guowa.guw_attribute_id]
    end

    attr_complexities_bottom_range_min = @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i
    attr_complexities_top_range_max = @guw_attribute_complexities.map(&:top_range).compact.max.to_i

    sum_range = guowa.guw_attribute.guw_attribute_complexities.where(organization_id: organization_id,
                                                                     guw_model_id: @guw_model.id,
                                                                     guw_type_id: (guw_type.nil? ? nil : guw_type.id)).map{|i| [i.bottom_range, i.top_range]}.flatten.compact

    unless sum_range.blank? || sum_range == 0
      @guw_attribute_complexities.each do |guw_ac|

        guw_ac_guw_type_complexity = guw_ac.guw_type_complexity

        unless low.nil?
          unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
            if (low >= attr_complexities_bottom_range_min) and (low < attr_complexities_top_range_max)
              unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                if (low >= guw_ac.bottom_range) and (low < guw_ac.top_range)
                  if guw_ac.enable_value == true
                    @lows << (guw_ac.value.to_f * low.to_f + guw_ac.value_b.to_f) * guw_ac.guw_type_complexity.value.to_f
                  else
                    @lows << guw_ac.value.to_f * guw_ac_guw_type_complexity.value.to_f
                  end
                end
              end
            else
              guw_unit_of_work.off_line = true
              # guw_unit_of_work.flagged = true
            end
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end

        unless most_likely.nil?
          if (most_likely >= attr_complexities_bottom_range_min) and (most_likely < attr_complexities_top_range_max)
            unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
              if (most_likely >= guw_ac.bottom_range) and (most_likely < guw_ac.top_range)
                if guw_ac.enable_value == true
                  @mls << (guw_ac.value.to_f * most_likely.to_f + guw_ac.value_b.to_f) * guw_ac.guw_type_complexity.value.to_f
                else
                  @mls << guw_ac.value.to_f * guw_ac_guw_type_complexity.value.to_f
                end
              end
            end
          else
            guw_unit_of_work.off_line = true
            # guw_unit_of_work.flagged = true
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end

        unless high.nil?
          if (high >= attr_complexities_bottom_range_min) and (high < attr_complexities_top_range_max)
            unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
              if (high >= guw_ac.bottom_range) and (high < guw_ac.top_range)
                if guw_ac.enable_value == true
                  @highs << (guw_ac.value.to_f * high + guw_ac.value_b.to_f) * guw_ac.guw_type_complexity.value.to_f
                else
                  @highs << guw_ac.value.to_f * guw_ac_guw_type_complexity.value.to_f
                end
              end
            end
          else
            guw_unit_of_work.off_line = true
            # guw_unit_of_work.flagged = true
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end
      end
    end

    unless params["comments"].nil?
      comments = params["comments"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_s
      guowa.comments = comments
    end

    gat = Guw::GuwAttributeType.where(organization_id: organization_id, guw_model_id: @guw_model.id, guw_attribute_id: guowa.guw_attribute_id, guw_type_id: guw_type.id).first
    unless gat.nil?
      if gat.default_value != most_likely && (comments.blank? && guw_type.mandatory_comments==true)
        # ignored, on en sauvegarde pas les valeurs
      else
        guowa.low = low
        guowa.most_likely = most_likely
        guowa.high = high
      end
    end

    guowa.save
  end

  def calculate_seuil(guw_unit_of_work, guw_c, value_pert)

    guw_type = guw_unit_of_work.guw_type

    if (value_pert >= guw_c.bottom_range) and (value_pert < guw_c.top_range)
      guw_unit_of_work.guw_complexity_id = guw_c.id
      guw_unit_of_work.guw_original_complexity_id = guw_c.id
    end

    if (guw_unit_of_work.result_low.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_low.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_low = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        if guw_type.attribute_type == "Pourcentage"
          uo_weight_low = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * (1 + guw_unit_of_work.result_low.to_f / 100) + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        else
          uo_weight_low = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * guw_unit_of_work.result_low.to_f + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        end
      end
    end

    if (guw_unit_of_work.result_most_likely.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_most_likely.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_ml = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        if guw_type.attribute_type == "Pourcentage"
          uo_weight_ml = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * (1 + guw_unit_of_work.result_most_likely.to_f / 100) + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        else
          uo_weight_ml = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * guw_unit_of_work.result_most_likely.to_f + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        end
      end
    end

    if (guw_unit_of_work.result_high.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_high.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_high = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        if guw_type.attribute_type == "Pourcentage"
          uo_weight_high = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * (1 + guw_unit_of_work.result_high.to_f / 100) + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        else
          uo_weight_high = (guw_c.weight.nil? ? 1 : guw_c.weight.to_f) * guw_unit_of_work.result_high.to_f + (guw_c.weight_b.nil? ? 0 : guw_c.weight_b.to_f)
        end
      end
    end

    if guw_type.attribute_type == "Pourcentage"
      ipl = (1 + guw_unit_of_work.result_low.to_f / 100)
      ipm = (1 + guw_unit_of_work.result_most_likely.to_f / 100)
      iph = (1 + guw_unit_of_work.result_high.to_f / 100)
    else
      ipl = guw_unit_of_work.result_low.to_f
      ipm = guw_unit_of_work.result_most_likely.to_f
      iph = guw_unit_of_work.result_high.to_f
    end

    probable_value = compute_probable_value(ipl.to_f, ipm.to_f, iph.to_f)[:value] * 100
    guw_unit_of_work.intermediate_percent = probable_value
    guw_unit_of_work.intermediate_weight = probable_value
    guw_unit_of_work.save

    result = compute_probable_value(uo_weight_low.to_f, uo_weight_ml.to_f, uo_weight_high.to_f)[:value]

    return result
  end

  #/!\ NEW METHODS WITH MULTIPLES ATTRIBUTES /!\
  def save_guw_unit_of_works_with_multiple_outputs

    # @module_project = ModuleProject.find_by_id(params[:module_project_id])
    @module_project = current_module_project

    @guw_model = @module_project.guw_model
    @project = @module_project.project

    authorize! :execute_estimation_plan, @project

    @organization = @guw_model.organization
    @component = current_component
    @reload_partial = true

    if params['commit'].present?
      @modified_guw_line_ids = @module_project.guw_unit_of_work_ids
    else
      unless params["modified_guw_line_ids"].nil?
        @modified_guw_line_ids = params["modified_guw_line_ids"].split(",").uniq.compact
      else
        @modified_guw_line_ids = ""
      end
    end

    if @modified_guw_line_ids.blank?
      @reload_partial = false
      # @guw_unit_of_works = Guw::GuwUnitOfWork.where( organization_id: @organization.id,
      #                                                project_id: @project.id,
      #                                                module_project_id: @module_project.id,
      #                                                pbs_project_element_id: @component.id,
      #                                                guw_model_id: @guw_model.id).includes(:guw_type, :guw_complexity).order("name ASC")
    else
      @reload_partial = true
      @guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: @organization.id,
                                                    guw_model_id: @guw_model.id,
                                                    project_id:  @project.id,
                                                    module_project_id: @module_project.id,
                                                    id: @modified_guw_line_ids).includes(:guw_type, :guw_complexity).order("name ASC")

      @guw_coefficients = @guw_model.guw_coefficients.where(organization_id: @organization.id)
      @guw_outputs = @guw_model.guw_outputs.where(organization_id: @organization.id, guw_model_id: @guw_model.id).order("display_order ASC")

      # Recuperation de la criticité de l'application
      project_application = @project.application
      @coeff_elt_with_application_criticality = Hash.new
      @coeff_elts_with_application = Hash.new
      #guw_coefficient_for_application = @guw_coefficients.where(coefficient_type: "Application").first

      @guw_coefficients.where(coefficient_type: "Application").each do |guw_coefficient_for_application|
        @coeff_elt_with_application_criticality["#{guw_coefficient_for_application.id}"] = nil

        #unless guw_coefficient_for_application.nil?
          application_coefficient_elements = guw_coefficient_for_application.guw_coefficient_elements
          @coeff_elts_with_application["#{guw_coefficient_for_application.id}"] = application_coefficient_elements.map(&:id)

          if project_application && !project_application.criticality.blank?
            project_application_criticality = project_application.criticality
            @coeff_elt_with_application_criticality["#{guw_coefficient_for_application.id}"] = application_coefficient_elements.where(name: project_application_criticality).first
          else
            #get default criticality
            if guw_coefficient_for_application
              coeff_element_with_default_criticality = application_coefficient_elements.where(default: true).first
              if coeff_element_with_default_criticality.nil?
                #coeff_element_with_default_criticality = application_coefficient_elements.first
                @coeff_elt_with_application_criticality["#{guw_coefficient_for_application.id}"] = nil
              else
                project_application_criticality = coeff_element_with_default_criticality.name rescue nil
                @coeff_elt_with_application_criticality["#{guw_coefficient_for_application.id}"] = coeff_element_with_default_criticality
              end
            end
          end
        #end
      end
      # Fin Recuperation de la criticité de l'application

      @guw_unit_of_works.each_with_index do |guw_unit_of_work, i|

        guw_unit_of_work.ajusted_size = nil
        guw_unit_of_work.size = nil
        guw_unit_of_work.effort = nil
        guw_unit_of_work.cost = nil

        #guw_unit_of_work.save

        array_pert = Array.new
        if !params[:selected].nil? && params[:selected].join(",").include?(guw_unit_of_work.id.to_s)
          guw_unit_of_work.selected = true
        else
          # guw_unit_of_work.selected = false
        end

        #reorder to keep good order
        #reorder guw_unit_of_work.guw_unit_of_work_group

        if params[:guw_type]["#{guw_unit_of_work.id}"].nil?
          guw_type = guw_unit_of_work.guw_type
        else
          guw_type = Guw::GuwType.where(organization_id: @organization.id,
                                        guw_model_id: @guw_model.id,
                                        id: params[:guw_type]["#{guw_unit_of_work.id}"]).first  #.find(params[:guw_type]["#{guw_unit_of_work.id}"])
        end

        if params[:guw_technology].present?
          guw_unit_of_work.organization_technology_id = params[:guw_technology]["#{guw_unit_of_work.id}"].to_i
        end

        guw_unit_of_work.guw_type_id = guw_type.id

        if params["quantity"].present?
          guw_unit_of_work.quantity = params["quantity"]["#{guw_unit_of_work.id}"].nil? ? 1 : params["quantity"]["#{guw_unit_of_work.id}"].to_f
        else
          guw_unit_of_work.quantity = 1
        end

        unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
          guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
          guw_unit_of_work.guw_complexity_id = guw_complexity_id
          guw_unit_of_work.off_line_uo = false
          guw_unit_of_work.off_line = false
        else
          default_guw_complexity = guw_type.guw_complexities.where(organization_id: @organization.id, guw_model_id: @guw_model.id, default_value: true).first
          if default_guw_complexity.nil?
            guw_complexity = guw_type.guw_complexities.where(organization_id: @organization.id, guw_model_id: @guw_model.id).first
          else
            guw_complexity = default_guw_complexity
          end

          guw_unit_of_work.guw_complexity_id = guw_complexity.id
        end

        guw_unit_of_work_guw_complexity = guw_unit_of_work.guw_complexity

        #Pour le calcul des valeurs intermédiares, on prend uniquement le premier attributs (pour l'instant)
        tmp_hash_res = Hash.new
        tmp_hash_ares = Hash.new

        @ocs_hash = {}
        Guw::GuwOutputComplexity.where(organization_id: @organization.id,
                                       guw_model_id: @guw_model.id,
                                       guw_complexity_id: guw_unit_of_work.guw_complexity_id).where("value IS NOT NULL").each do |oc|
          @ocs_hash[oc.guw_output_id] = oc
        end

        @ocis_hash = {}
        Guw::GuwOutputComplexityInitialization.where(organization_id: @organization.id,
                                                     guw_model_id: @guw_model.id,
                                                     guw_complexity_id: guw_unit_of_work.guw_complexity_id).each do |oci|
          @ocis_hash[oci.guw_output_id] = oci
        end

        ceuws = {}
        ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id, guw_model_id: @guw_model.id).each do |gce|
          Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                     guw_model_id: @guw_model.id,
                                                     guw_coefficient_id: gce.guw_coefficient_id,
                                                     guw_coefficient_element_id: gce.id,
                                                     project_id: @project.id,
                                                     module_project_id: @module_project.id,
                                                     guw_unit_of_work_id: guw_unit_of_work.id).each do |ceuw|
            ceuws["#{ceuw.guw_coefficient_id}_#{gce.id}"] = ceuw
          end
        end

        ceuws_without_nil = {}
        Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: @module_project.id,
                                                   guw_unit_of_work_id: guw_unit_of_work.id).each do |ceuw|
          ceuws_without_nil[ceuw.guw_coefficient_id] = ceuw
        end

        ces = {}
        ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id, guw_model_id: @guw_model.id, default: true).each do |ce|
          ces[ce.guw_coefficient_id] = ce
        end

        @guw_outputs.each_with_index do |guw_output, index|

          @oc = @ocs_hash[guw_output.id]
          @oci = @ocis_hash[guw_output.id]

          # @oc = Guw::GuwOutputComplexity.where(guw_complexity_id: guw_unit_of_work_guw_complexity,
          #                                      guw_output_id: guw_output.id,
          #                                      value: 1).first
          # @oci = Guw::GuwOutputComplexityInitialization.where(guw_complexity_id: guw_unit_of_work.guw_complexity_id,
          #                                                     guw_output_id: guw_output.id).first

          #gestion des valeurs intermédiaires
          weight = (guw_unit_of_work_guw_complexity.nil? ? 1.0 : (guw_unit_of_work_guw_complexity.weight.nil? ? 1.0 : guw_unit_of_work_guw_complexity.weight.to_f))
          weight_b = (guw_unit_of_work_guw_complexity.nil? ? 0 : (guw_unit_of_work_guw_complexity.weight_b.nil? ? 0 : guw_unit_of_work_guw_complexity.weight_b.to_f))

          result_low = guw_unit_of_work.result_low.nil? ? 1 : guw_unit_of_work.result_low
          result_most_likely = guw_unit_of_work.result_most_likely.nil? ? 1 : guw_unit_of_work.result_most_likely
          result_high = guw_unit_of_work.result_high.nil? ? 1 : guw_unit_of_work.result_high

          if guw_unit_of_work.guw_complexity.nil?
            @final_value = nil
          else
            # weight = (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
            if guw_unit_of_work_guw_complexity.enable_value == false
              if @oc.nil?
                @final_value = 0
              else
                @final_value = (@oc.value.nil? ? 1 : @oc.value.to_f) * weight
              end
            else
              if params["complexity_coeff_ajusted"].present?
                if params["complexity_coeff_ajusted"]["#{guw_unit_of_work.id}"].blank?
                  cplx_coeff = params["complexity_coeff"]["#{guw_unit_of_work.id}"].to_f
                  guw_unit_of_work.intermediate_percent = cplx_coeff
                  guw_unit_of_work.intermediate_weight = cplx_coeff
                else
                  cplx_coeff = params["complexity_coeff_ajusted"]["#{guw_unit_of_work.id}"].to_f
                  guw_unit_of_work.intermediate_weight = cplx_coeff
                end
              end

              if guw_unit_of_work.intermediate_weight != guw_unit_of_work.intermediate_percent
                guw_unit_of_work.flagged = true
              else
                guw_unit_of_work.flagged = false
              end

              if cplx_coeff.nil?
                intermediate_percent = (1 + ((result_low + 4 * result_most_likely +  result_high) / 6) / 100)
              else
                intermediate_percent = (cplx_coeff.to_f / 100)
              end

              if @oc.nil?
                @final_value = 0
              else
                @final_value = (@oc.value.nil? ? 1 : @oc.value.to_f) * (weight.nil? ? 1 : weight.to_f) * (intermediate_percent.nil? ? 1 : intermediate_percent) + (weight_b.nil? ? 0 : weight_b.to_f)
              end

            end
          end

          cces = {}
          Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                     guw_model_id: @guw_model.id,
                                                     guw_output_id: guw_output.id).each do |cce|
            cces["#{cce.guw_coefficient_element_id}_#{cce.guw_complexity_id}"] = cce
          end

          coeffs = []
          percents = []
          selected_coefficient_values = Hash.new {|h,k| h[k] = [] }

          @guw_coefficients.each do |guw_coefficient|
            if guw_coefficient.coefficient_type == "Pourcentage"

              ceuw = ceuws[guw_coefficient.id]
              if ceuw.nil?
                ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_coefficient_id: guw_coefficient.id,
                                                                  guw_coefficient_element_id: nil,
                                                                  project_id: @project.id,
                                                                  module_project_id: @module_project.id,
                                                                  guw_unit_of_work_id: guw_unit_of_work.id).first_or_create(organization_id: @organization.id,
                                                                                                                            guw_model_id: @guw_model.id,
                                                                                                                            guw_coefficient_id: guw_coefficient.id,
                                                                                                                            guw_coefficient_element_id: nil,
                                                                                                                            project_id: @project.id,
                                                                                                                            module_project_id: @module_project.id,
                                                                                                                            guw_unit_of_work_id: guw_unit_of_work.id)
              end

              begin
                pc = params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].blank? ? 100 : params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
              rescue
                if ceuw.percent.nil?
                  ce = ces[guw_coefficient.id]
                  if ce.nil?
                    ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                          guw_model_id: @guw_model.id,
                                                          guw_coefficient_id: guw_coefficient.id).first
                  end

                  if ce.nil?
                    pc = 100
                  else
                    pc = ce.value.to_f
                  end

                else
                  pc = ceuw.percent.to_f
                end
              end

              guw_coefficient.guw_coefficient_elements.where(organization_id: @organization.id, guw_model_id: @guw_model.id).each do |guw_coefficient_element|

                if pc.to_f == guw_coefficient_element.value.to_f
                  guw_unit_of_work.flagged = false
                else
                  guw_unit_of_work.flagged = true
                end

                cce = cces["#{guw_coefficient_element.id}_#{guw_unit_of_work.guw_complexity_id}"]
                if cce.nil?
                  cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                                   guw_model_id: @guw_model.id,
                                                                   guw_output_id: guw_output.id,
                                                                   guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                                                   guw_coefficient_element_id: guw_coefficient_element.id).first
                end

                # ceuw.guw_coefficient_element_id = guw_coefficient_element.id

                unless cce.blank?
                  percents << (pc.to_f / 100)
                  percents << (cce.value.nil? ? 1 : cce.value.to_f)

                  v = (guw_coefficient_element.value.nil? ? 1 : guw_coefficient_element.value).to_f
                  selected_coefficient_values["#{guw_output.id}"] << (v / 100)

                else
                  percents << 1
                end
              end

              ceuw.percent = pc.to_f
              ceuw.guw_coefficient_id = guw_coefficient.id
              ceuw.guw_unit_of_work_id = guw_unit_of_work.id
              ceuw.module_project_id = @module_project.id

              if ceuw.changed?
                ceuw.save
              end

            elsif guw_coefficient.coefficient_type == "Coefficient"

              ceuw = ceuws[guw_coefficient.id]
              if ceuw.nil?
                ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_coefficient_id: guw_coefficient.id,
                                                                  guw_coefficient_element_id: nil,
                                                                  project_id: @project.id,
                                                                  module_project_id: @module_project.id,
                                                                  guw_unit_of_work_id: guw_unit_of_work.id).first_or_create
              end

              # ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_unit_of_work,
              #                                                   guw_coefficient_id: guw_coefficient.id,
              #                                                   guw_coefficient_element_id: nil).first_or_create(guw_unit_of_work_id: guw_unit_of_work,
              #                                                                                                    guw_coefficient_id: guw_coefficient.id,
              #                                                                                                    guw_coefficient_element_id: nil)
              begin
                pc = params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].blank? ? 1 : params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
              rescue
                if ceuw.percent.nil?
                  # ce = Guw::GuwCoefficientElement.where(guw_coefficient_id: guw_coefficient.id,
                  #                                       guw_model_id: @guw_model.id,
                  #                                       default: true).first
                  ce = ces[guw_coefficient.id]
                  if ce.nil?
                    ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                          guw_model_id: @guw_model.id,
                                                          guw_coefficient_id: guw_coefficient.id).first
                  end

                  if ce.nil?
                    pc = 1
                  else
                    pc = ce.value.to_f
                  end
                else
                  pc = ceuw.percent.to_f
                end
              end

              # cces = {}
              # Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id).each do |cce|
              #   cces["#{cce.guw_coefficient_element_id}_#{cce.guw_complexity_id}"] = cce
              # end

              guw_coefficient.guw_coefficient_elements.where(organization_id: @organization.id, guw_model_id: @guw_model.id).each do |guw_coefficient_element|

                if pc.to_f == guw_coefficient_element.value.to_f
                  guw_unit_of_work.flagged = false
                else
                  guw_unit_of_work.flagged = true
                end

                # cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                #                                                  guw_coefficient_element_id: guw_coefficient_element.id,
                #                                                  guw_complexity_id: guw_unit_of_work.guw_complexity_id).all

                cce = cces["#{guw_coefficient_element.id}_#{guw_unit_of_work.guw_complexity_id}"]

                # if cce.nil?
                #   cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                #                                                    guw_model_id: @guw_model.id,
                #                                                    guw_output_id: guw_output.id,
                #                                                    guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                #                                                    guw_coefficient_element_id: guw_coefficient_element.id).first_or_create
                # end
                #
                # ceuw.guw_coefficient_element_id = guw_coefficient_element.id

                unless cce.nil?
                  unless cce.value.blank?
                    coeffs << pc.to_f
                    coeffs << cce.value.to_f

                    v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                    selected_coefficient_values["#{guw_output.id}"] << v

                  else
                    coeffs << 1
                  end
                end
              end

              ceuw.percent = pc.to_f
              ceuw.guw_coefficient_id = guw_coefficient.id
              ceuw.guw_unit_of_work_id = guw_unit_of_work.id
              ceuw.module_project_id = @module_project.id

              if ceuw.changed?
                ceuw.save
              end

            elsif guw_coefficient.coefficient_type == "Application"

              ce = @coeff_elt_with_application_criticality["#{guw_coefficient.id}"]
              # ce = Guw::GuwCoefficientElement.find_by_id(params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"])

              if ce.nil?
                #selected_coefficient_values["#{guw_output.id}"] << 0

                # savoir si l'uo utilise l'application ou non
                guw_type = guw_unit_of_work.guw_type
                cplx_coeff_elements = guw_type.guw_complexity_coefficient_elements.where(organization_id: @organization.id,
                                                                                         guw_model_id: @guw_model.id,
                                                                                         guw_output_id: guw_output.id,
                                                                                         guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                                                                         guw_coefficient_element_id: @coeff_elts_with_application["#{guw_coefficient.id}"])
                if cplx_coeff_elements.size >= 1
                  selected_coefficient_values["#{guw_output.id}"] << 0
                end
              else
                cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                                 guw_model_id: @guw_model.id,
                                                                 guw_output_id: guw_output.id,
                                                                 guw_coefficient_element_id: ce.id,
                                                                 guw_complexity_id: guw_unit_of_work.guw_complexity_id).first
                # unless cce.nil?
                #   selected_coefficient_values["#{guw_output.id}"] << (cce.value.nil? ? 0 : cce.value) * (@project.application.coefficient.nil? ? 1 : @project.application.coefficient.to_f)
                # end
                unless cce.nil?
                  unless cce.value.blank?
                    selected_coefficient_values["#{guw_output.id}"] <<  cce.value * (project_application.coefficient.nil? ? 1 : project_application.coefficient.to_f)
                  end
                end
              end


              ceuw = ceuws_without_nil[guw_coefficient.id]
              if ceuw.nil?
                ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_coefficient_id: guw_coefficient.id,
                                                                  project_id: @project.id,
                                                                  module_project_id: @module_project.id,
                                                                  guw_unit_of_work_id: guw_unit_of_work.id).first
                if ceuw.nil?
                  ceuw = Guw::GuwCoefficientElementUnitOfWork.create(organization_id: @organization.id,
                                                                     guw_model_id: @guw_model.id,
                                                                     guw_coefficient_id: guw_coefficient.id,
                                                                     project_id: @project.id,
                                                                     module_project_id: @module_project.id,
                                                                     guw_unit_of_work_id: guw_unit_of_work.id)

                end
              end

              unless ceuw.nil?
                ceuw.guw_coefficient_id = guw_coefficient.id
                ceuw.guw_unit_of_work_id = guw_unit_of_work.id
                ceuw.module_project_id = @module_project.id
                if ceuw.changed?
                  ceuw.save
                end
              end

            else

              begin
                unless params['deported_guw_coefficient'].nil?
                  ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                        guw_model_id: @guw_model.id,
                                                        id: params['deported_guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i).first
                else
                  ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                        guw_model_id: @guw_model.id,
                                                        id: params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i).first
                end
              rescue
                ce = nil
              end

              if ce.nil?
                ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                      guw_model_id: @guw_model.id,
                                                      guw_coefficient_id: guw_coefficient.id,
                                                      default: true).first
                if ce.nil?
                  ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                        guw_model_id: @guw_model.id,
                                                        guw_coefficient_id: guw_coefficient.id).first
                end
              end

              unless ce.nil?

                ceuw = ceuws_without_nil[guw_coefficient.id]
                if ceuw.nil?
                  ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                    guw_model_id: @guw_model.id,
                                                                    guw_coefficient_id: guw_coefficient.id,
                                                                    project_id: @project.id,
                                                                    module_project_id: @module_project.id,
                                                                    guw_unit_of_work_id: guw_unit_of_work.id).first
                  if ceuw.nil?
                    ceuw = Guw::GuwCoefficientElementUnitOfWork.create(organization_id: @organization.id,
                                                                       guw_model_id: @guw_model.id,
                                                                       guw_coefficient_id: guw_coefficient.id,
                                                                       project_id: @project.id,
                                                                       module_project_id: @module_project.id,
                                                                       guw_unit_of_work_id: guw_unit_of_work.id)

                  end
                end

                unless ceuw.nil?
                  begin
                    unless params['deported_guw_coefficient'].nil?
                      unless params['deported_guw_coefficient']["#{guw_unit_of_work.id}"].nil?
                        v = params['deported_guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                        unless v.nil?
                          ceuw.guw_coefficient_element_id = v.to_i
                        end
                      end
                    else
                      v = params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                      unless v.nil?
                        ceuw.guw_coefficient_element_id = v.to_i
                      end
                    end
                  rescue
                    # Ne rien faire
                  end

                  ceuw.guw_coefficient_id = guw_coefficient.id
                  ceuw.guw_unit_of_work_id = guw_unit_of_work.id
                  ceuw.module_project_id = @module_project.id

                  if ceuw.changed?
                    ceuw.save
                  end
                end

                cce = cces["#{ce.id}_#{guw_unit_of_work.guw_complexity_id}"]

                unless cce.nil?
                  selected_coefficient_values["#{guw_output.id}"] << (cce.value.nil? ? 1 : cce.value)
                  unless cce.value.nil?
                    selected_coefficient_values["#{guw_output.id}"] << (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value)
                  end
                end
              end
            end
          end

          scv = selected_coefficient_values["#{guw_output.id}"].compact.inject(&:*)
          pct = percents.compact.inject(&:*)
          coef = coeffs.compact.inject(&:*)

          oa_value = []
          Guw::GuwOutputAssociation.where(organization_id: @organization.id,
                                          guw_model_id: @guw_model.id,
                                          guw_output_id: guw_output.id,
                                          guw_complexity_id: guw_unit_of_work.guw_complexity_id).each do |goa|
            unless goa.value.to_f == 0
              unless goa.aguw_output.nil?
                oa_value << tmp_hash_ares["#{goa.aguw_output.id}"].to_f * goa.value.to_f
              end
            end
          end

          inter_value = oa_value.compact.sum.to_f + (@oci.nil? ? 0 : @oci.init_value.to_f)

          #Attention changement, a confirmer
          unless @final_value.nil?
            if inter_value == 0
              tmp = @final_value.to_f * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
            else
              if @final_value == 0
                tmp = inter_value * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
              else
                tmp = @final_value.to_f * inter_value * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
              end
            end
          else
            tmp = inter_value.to_f * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
          end

          if params["ajusted_size"].present?
            if params["ajusted_size"]["#{guw_unit_of_work.id}"].nil?
              tmp_hash_res["#{guw_output.id}"] = tmp
              tmp_hash_ares["#{guw_output.id}"] = tmp
            else
              if params["ajusted_size"]["#{guw_unit_of_work.id}"]["#{guw_output.id}"].blank?
                tmp_hash_res["#{guw_output.id}"] = tmp
                tmp_hash_ares["#{guw_output.id}"] = tmp
              else

                if tmp == 0
                  tmp_hash_res["#{guw_output.id}"] = params["ajusted_size"]["#{guw_unit_of_work.id}"]["#{guw_output.id}"].to_f
                else
                  tmp_hash_res["#{guw_output.id}"] = tmp
                end

                tmp_hash_ares["#{guw_output.id}"] = params["ajusted_size"]["#{guw_unit_of_work.id}"]["#{guw_output.id}"].to_f

              end
            end
          else
            tmp_hash_res["#{guw_output.id}"] = tmp
            tmp_hash_ares["#{guw_output.id}"] = tmp
          end

          guw_unit_of_work.size = tmp_hash_res
          guw_unit_of_work.ajusted_size = tmp_hash_ares
        end

        reorder guw_unit_of_work.guw_unit_of_work_group

        if guw_unit_of_work.changed?
          guw_unit_of_work.save
        end
      end

      # update_estimation_values
      # update_view_widgets_and_project_fields
      Guw::GuwUnitOfWork.update_estimation_values(@module_project, @component)
      Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, @component)

    end

    # update_estimation_values
    # update_view_widgets_and_project_fields

    # if @guw_unit_of_works.last.nil?
    #   redirect_to main_app.dashboard_path(@project)
    # else
    #   redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_works.last.guw_unit_of_work_group.id}")
    # end
  end

  def save_uo_with_multiple_outputs
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    @organization = @guw_unit_of_work.organization
    # @module_project = ModuleProject.find_by_id(params[:module_project_id])
    @module_project = @guw_unit_of_work.module_project

    @guw_model = @guw_unit_of_work.guw_model
    @guw_outputs = @guw_model.guw_outputs
    @project = @module_project.project

    authorize! :execute_estimation_plan, @project

    @component = current_component

    @guw_unit_of_work.ajusted_size = {}
    @guw_unit_of_work.size = {}
    @guw_unit_of_work.effort = {}
    @guw_unit_of_work.cost = {}

    begin
      guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id, id: params[:guw_type]["#{guw_unit_of_work.id}"]).first #.find(params[:guw_type]["#{guw_unit_of_work.id}"])
    rescue
      guw_type = @guw_unit_of_work.guw_type
    end

    @lows = Array.new
    @mls = Array.new
    @highs = Array.new
    array_pert = Array.new

    @guw_unit_of_work.off_line = false
    @guw_unit_of_work.off_line_uo = false

    @guw_unit_of_work.guw_unit_of_work_attributes.where(organization_id: @organization.id, guw_model_id: @guw_model.id, guw_type_id: guw_type.id).each do |guowa|
      calculate_guowa(guowa, @guw_unit_of_work, guw_type)
    end

    if @lows.empty?
      @guw_unit_of_work.guw_complexity_id = nil
      @guw_unit_of_work.guw_original_complexity_id = nil
      @guw_unit_of_work.result_low = nil
    else
      @guw_unit_of_work.result_low = @lows.sum
    end

    if @mls.empty?
      @guw_unit_of_work.guw_complexity_id = nil
      @guw_unit_of_work.guw_original_complexity_id = nil
      @guw_unit_of_work.result_most_likely = nil
    else
      @guw_unit_of_work.result_most_likely = @mls.sum
    end

    if @highs.empty?
      @guw_unit_of_work.guw_complexity_id = nil
      @guw_unit_of_work.guw_original_complexity_id = nil
      @guw_unit_of_work.result_high = nil
    else
      @guw_unit_of_work.result_high = @highs.sum
    end

    @guw_unit_of_work.guw_type_id ||= guw_type.id
    # @guw_unit_of_work.guw_work_unit_id = guw_work_unit.nil? ? nil : guw_work_unit.id
    # @guw_unit_of_work.guw_weighting_id = guw_weighting.nil? ? nil : guw_weighting.id
    # @guw_unit_of_work.guw_factor_id = guw_factor.nil? ? nil : guw_factor.id

    unless params["guw_complexity_#{@guw_unit_of_work.id}"].nil?
      guw_complexity_id = params["guw_complexity_#{@guw_unit_of_work.id}"].to_i
      @guw_unit_of_work.guw_complexity_id = guw_complexity_id
      @guw_unit_of_work.guw_original_complexity_id = guw_complexity_id
      if @guw_unit_of_work.changed?
        @guw_unit_of_work.save
      end
    else
      guw_complexity_id = @guw_unit_of_work.guw_complexity_id
    end

    if (guw_type.allow_complexity == true && guw_type.allow_criteria == false)

      # tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
      #                                            organization_technology_id: @guw_unit_of_work.organization_technology_id).first

      guw_unit_of_work_guw_complexity = @guw_unit_of_work.guw_complexity

      if guw_unit_of_work_guw_complexity.nil?
        array_pert << 0
      else
        array_pert << (guw_unit_of_work_guw_complexity.weight.nil? ? 1 : guw_unit_of_work_guw_complexity.weight.to_f)
      end

      if @guw_unit_of_work.changed?
        @guw_unit_of_work.save
      end
    else
      if @guw_unit_of_work.result_low.nil? or @guw_unit_of_work.result_most_likely.nil? or @guw_unit_of_work.result_high.nil?
        @guw_unit_of_work.off_line_uo = nil
      else
        #Save if uo is simple/ml/high
        value_pert = compute_probable_value(@guw_unit_of_work.result_low, @guw_unit_of_work.result_most_likely, @guw_unit_of_work.result_high)[:value]
        guw_type_guw_complexities = guw_type.guw_complexities
        if (value_pert < guw_type_guw_complexities.map(&:bottom_range).min.to_f)
          @guw_unit_of_work.off_line_uo = true
        elsif (value_pert >= guw_type_guw_complexities.map(&:top_range).max.to_f)
          @guw_unit_of_work.off_line_uo = true
          cplx = guw_type_guw_complexities.last
          if cplx.nil?
            @guw_unit_of_work.guw_complexity_id = nil
            @guw_unit_of_work.guw_original_complexity_id = nil
          else
            @guw_unit_of_work.guw_complexity_id = cplx.id
            @guw_unit_of_work.guw_original_complexity_id = cplx.id
            array_pert << calculate_seuil(@guw_unit_of_work, guw_type_guw_complexities.last, value_pert)
          end
        else
          guw_type_guw_complexities.each do |guw_c|
            array_pert << calculate_seuil(@guw_unit_of_work, guw_c, value_pert)
          end
        end
      end
    end

    @guw_unit_of_work.quantity = params["hidden_quantity"]["#{@guw_unit_of_work.id}"].blank? ? 1 : params["hidden_quantity"]["#{@guw_unit_of_work.id}"].to_f

    if @guw_unit_of_work.changed?
      @guw_unit_of_work.save
    end

    tmp_hash_res = Hash.new
    tmp_hash_ares = Hash.new

    @guw_model.guw_outputs.where(organization_id: @organization.id).order("display_order ASC").each_with_index do |guw_output, index|

      @oc = Guw::GuwOutputComplexity.where(organization_id: @organization.id,
                                           guw_model_id: @guw_model.id,
                                           guw_output_id: guw_output.id,
                                           guw_complexity_id: @guw_unit_of_work.guw_complexity_id,
                                           value: 1).first

      @oci = Guw::GuwOutputComplexityInitialization.where(organization_id: @organization.id,
                                                          guw_model_id: @guw_model.id,
                                                          guw_output_id: guw_output.id,
                                                          guw_complexity_id: @guw_unit_of_work.guw_complexity_id).first


      if @oc.nil?
        @final_value = (@oci.nil? ? 0 : @oci.init_value.to_f)
      else
        @final_value = (@guw_unit_of_work.off_line? ? nil : (array_pert.empty? ? nil : array_pert.sum.to_f)) + (@oci.nil? ? 0 : @oci.init_value.to_f)
      end

      coeffs = []
      percents = []
      selected_coefficient_values = Hash.new {|h,k| h[k] = [] }
      @guw_model.guw_coefficients.each do |guw_coefficient|
        if guw_coefficient.coefficient_type == "Pourcentage"

          ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                            guw_model_id: @guw_model.id,
                                                            guw_coefficient_id: guw_coefficient.id,
                                                            guw_coefficient_element_id: nil,
                                                            project_id: @project.id,
                                                            module_project_id: @module_project.id,
                                                            guw_unit_of_work_id: @guw_unit_of_work.id).first_or_create(organization_id: @organization.id,
                                                                                                                       guw_model_id: @guw_model.id,
                                                                                                                       guw_coefficient_id: guw_coefficient.id,
                                                                                                                       guw_coefficient_element_id: nil,
                                                                                                                       project_id: @project.id,
                                                                                                                       module_project_id: @module_project.id,
                                                                                                                       guw_unit_of_work_id: @guw_unit_of_work.id)

          guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
            cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                             guw_model_id: @guw_model.id,
                                                             guw_output_id: guw_output.id,
                                                             guw_complexity_id: @guw_unit_of_work.guw_complexity_id,
                                                             guw_coefficient_element_id: guw_coefficient_element.id).first
            unless cce.nil?
              unless cce.value.blank?
                pc = params["hidden_coefficient_percent"]["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                percents << (pc.blank? ? 1.0 : (pc.to_f / 100))
                percents << cce.value.to_f

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << (v / 100)

              else
                percents << 1
              end

              ceuw.guw_coefficient_element_id = guw_coefficient_element.id

            end
          end

          ceuw.percent = params["hidden_coefficient_percent"]["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
          ceuw.guw_coefficient_id = guw_coefficient.id
          ceuw.guw_unit_of_work_id = @guw_unit_of_work.id
          ceuw.module_project_id = @module_project.id

          if ceuw.changed?
            ceuw.save
          end

        elsif guw_coefficient.coefficient_type == "Coefficient"

          ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                            guw_model_id: @guw_model.id,
                                                            guw_coefficient_id: guw_coefficient.id,
                                                            guw_coefficient_element_id: nil,
                                                            project_id: @project.id,
                                                            module_project_id: @module_project.id,
                                                            guw_unit_of_work_id: @guw_unit_of_work).first_or_create(organization_id: @organization.id,
                                                                                                                    guw_model_id: @guw_model.id,
                                                                                                                    guw_coefficient_id: guw_coefficient.id,
                                                                                                                    guw_coefficient_element_id: nil,
                                                                                                                    project_id: @project.id,
                                                                                                                    module_project_id: @module_project.id,
                                                                                                                    guw_unit_of_work_id: @guw_unit_of_work)

          guw_coefficient.guw_coefficient_elements.where(organization_id: @organization.id,
                                                         guw_model_id: @guw_model.id).each do |guw_coefficient_element|

            cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                             guw_model_id: @guw_model.id,
                                                             guw_output_id: guw_output.id,
                                                             guw_complexity_id: @guw_unit_of_work.guw_complexity_id,
                                                             guw_coefficient_element_id: guw_coefficient_element.id).first
            unless cce.nil?
              unless cce.value.blank?
                pc = params["hidden_coefficient_percent"]["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                coeffs << (pc.blank? ? 1 : pc.to_f)

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << v

                selected_coefficient_values["#{guw_output.id}"] << (cce.value.nil? ? 1 : cce.value)

              else
                coeffs << 1
              end
            end
          end

          ceuw.percent = params["hidden_coefficient_percent"]["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
          ceuw.guw_coefficient_id = guw_coefficient.id
          ceuw.guw_unit_of_work_id = @guw_unit_of_work.id
          ceuw.module_project_id = @module_project.id

          if ceuw.changed?
            ceuw.save
          end

        else
          unless params['hidden_coefficient_element'].nil?
            unless params['hidden_coefficient_element']["#{@guw_unit_of_work.id}"].nil?
              #ce = Guw::GuwCoefficientElement.find_by_id(params['hidden_coefficient_element']["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)
              ce = Guw::GuwCoefficientElement.where(organization_id: @organization.id,
                                                    guw_model_id: @guw_model.id,
                                                    id: params['hidden_coefficient_element']["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i).first
            end
          end

          unless ce.nil?

            # cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
            #                                                  guw_model_id: @guw_model.id,
            #                                                  guw_output_id: guw_output.id,
            #                                                  guw_complexity_id: @guw_unit_of_work.guw_complexity_id,
            #                                                  guw_coefficient_element_id: ce.id).first_or_create!

            cce = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                             guw_model_id: @guw_model.id,
                                                             guw_output_id: guw_output.id,
                                                             guw_complexity_id: @guw_unit_of_work.guw_complexity_id,
                                                             guw_coefficient_element_id: ce.id).first

            ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                              guw_model_id: @guw_model.id,
                                                              guw_coefficient_id: guw_coefficient.id,
                                                              project_id: @project.id,
                                                              module_project_id: @module_project.id,
                                                              guw_unit_of_work_id: @guw_unit_of_work.id).first_or_create(organization_id: @organization.id,
                                                                                                                         guw_model_id: @guw_model.id,
                                                                                                                         guw_coefficient_id: guw_coefficient.id,
                                                                                                                         project_id: @project.id,
                                                                                                                         module_project_id: @module_project.id,
                                                                                                                         guw_unit_of_work_id: @guw_unit_of_work.id)
          end

          unless ceuw.nil?

            v = params['hidden_coefficient_element']["#{@guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
            ceuw.guw_coefficient_element_id = v.nil? ? nil : v.to_i

            ceuw.guw_coefficient_id = guw_coefficient.id
            ceuw.guw_unit_of_work_id = @guw_unit_of_work.id
            ceuw.module_project_id = @module_project.id

            if ceuw.changed?
              ceuw.save
            end
          end

          unless cce.nil?
            selected_coefficient_values["#{guw_output.id}"] << (cce.value.nil? ? 1 : cce.value)
            unless cce.value.nil?
              selected_coefficient_values["#{guw_output.id}"] << (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value)
            end
          end

        end
      end

      if @final_value.nil?
        @guw_unit_of_work.size = nil
        if params["hidden_ajusted_size"].nil?
          tmp_hash_res["#{guw_output.id}"] = nil
        else
          tmp_hash_res["#{guw_output.id}"] = params["hidden_ajusted_size"]["#{@guw_unit_of_work.id}"]["#{guw_output.id}"].to_f
        end
        @guw_unit_of_work.ajusted_size = tmp_hash_res
        @guw_unit_of_work.size = tmp_hash_res
      else

        scv = selected_coefficient_values["#{guw_output.id}"].compact.inject(&:*)
        pct = percents.compact.inject(&:*)
        coef = coeffs.compact.inject(&:*)

        inter_value = nil
        oa_value = []
        Guw::GuwOutputAssociation.where(organization_id: @organization.id,
                                        guw_model_id: @guw_model.id,
                                        guw_output_id: guw_output.id,
                                        guw_complexity_id: @guw_unit_of_work.guw_complexity_id).all.each do |goa|
          unless goa.value.to_f == 0
            unless goa.aguw_output.nil?
              oa_value << tmp_hash_res["#{goa.aguw_output.id}"].to_f * goa.value.to_f
            end
          end

          inter_value = oa_value.compact.sum.to_f
        end

        #Attention changement, a confirmer
        unless @final_value.nil?
          if inter_value.to_f == 0
            tmp = @final_value.to_f * (@guw_unit_of_work.quantity.nil? ? 1 : @guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
          else
            tmp = inter_value.to_f * (@guw_unit_of_work.quantity.nil? ? 1 : @guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
          end
        else
          tmp = inter_value.to_f * (@guw_unit_of_work.quantity.nil? ? 1 : @guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
        end

        tmp_hash_res["#{guw_output.id}"] = tmp
        tmp_hash_ares["#{guw_output.id}"] = tmp

        @guw_unit_of_work.ajusted_size = tmp_hash_res
        @guw_unit_of_work.size = tmp_hash_res
      end
    end

    if @guw_unit_of_work.changed?
      @guw_unit_of_work.save
    end

    # update_estimation_values
    # update_view_widgets_and_project_fields
    Guw::GuwUnitOfWork.update_estimation_values(@module_project, @component)
    Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, @module_project, @component)

    # redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def extract_from_url

    pages = Array.new
    agent = Mechanize.new

    default_group = params[:group_name]

    @module_project = current_module_project
    @guw_model = @module_project.guw_model
    @organization = @guw_model.organization
    @project = @module_project.project
    @component = current_component
    @guw_model = @module_project.guw_model
    @guw_model_guw_attributes = @guw_model.guw_attributes.all

    if params[:from] == "Excel"
      if params[:kind_excel] == "Données"
        extract_data_from_excel(default_group)
      elsif params[:kind_excel] == "Traitements"
        extract_trt_from_excel(default_group)
      elsif params[:kind_excel] == "Données + Traitements"
        extract_trt_from_excel("T - #{default_group}")
        extract_data_from_excel("D - #{default_group}")
      elsif params[:kind_excel] == "Aucun"
        import!("", "", "", default_group, "Excel", "#")
      else
        import!("", "", "", default_group, "Excel", "#")
      end
    elsif params[:from] == "Jira"
      (1..5).step(1).each do |i|
        url = "https://issues.apache.org/jira/issues/?filter=-4&startIndex=#{i}"
        agent.get(url)
        page = agent.page
        pages << page.search("//@data-issue-key").map(&:value)
      end

      pages.uniq.flatten.take(5).each_with_index do |val, j|
        id = val
        title = ""
        description = ""

        url = "https://issues.apache.org/jira/browse/#{val}"
        agent = Mechanize.new
        agent.get(url)
        agent.page.search("#summary-val").each do |item|
          title << item.text
        end

        agent.page.search(".user-content-block p").each do |item|
          description << item.text
        end

        unless description.blank?
          if params[:kind_jira] == "Données"
            results = get_data(id, title, description, url, default_group, "Jira", j)
          elsif params[:kind_jira] == "Traitements"
            results = get_trt(id, title, description, url, default_group, "Jira")
          elsif params[:kind_jira] == "Données + Traitements"
            a = get_trt(id, title, description, url, "T - #{default_group}", "Jira")
            b = get_data(id, title, description, url, "D - #{default_group}", "Jira", j)
            results = a + b
          else
            results = import!(id, title, description, default_group, "Jira", url)
          end
        end

        results.each do |uo|
          @guw_model_guw_attributes.each do |gac|
            guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: uo.guw_type_id,
                                                      guw_attribute_id: gac.id,
                                                      guw_unit_of_work_id: uo.id).first_or_create
            guowa.save
          end
        end
      end

    elsif params[:from] == "Redmine"

      (1..8).each do |i|

        pages = []

        url = "#{params[:url]}?page=#{i}"
        agent.get(url) do |page|
          pages << page.search("//tr[@id]").map{|j| j.attributes["id"].value.to_s.gsub("issue-","") }
        end

        pages.uniq.flatten.each_with_index do |val, j|
          id = val
          agent = Mechanize.new
          url = "http://forge.estimancy.com/issues/#{val}"
          agent.get(url) do |page|
            title = page.search(".subject h3").text
            description = page.search(".description").text.gsub("\n", "").gsub("        Description    ", "").lstrip

            unless description.blank?
              if params[:kind_redmine] == "Données"
                results = get_data(id, title, description, url, default_group, "Redmine", j)
              elsif params[:kind_redmine] == "Traitements"
                results = get_trt(id, title, description, url, default_group, "Redmine")
              elsif params[:kind_redmine] == "Données + Traitements"
                a = get_trt(id, title, description, url, "T - #{default_group}", "Redmine")
                b = get_data(id, title, description, url, "D - #{default_group}", "Redmine", j)
                results = a + b
              else
                results = import!(id, title, description, default_group, "Redmine", url)
              end

              results.each do |uo|
                @guw_model_guw_attributes.each do |gac|
                  guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: uo.guw_type_id,
                                                            guw_attribute_id: gac.id,
                                                            guw_unit_of_work_id: uo.id).first_or_create
                  guowa.save
                end
              end
            end
          end
        end
      end
    end

    redirect_to main_app.dashboard_path(@project, recalculate: true)
  end

  def extract_trt_from_excel(default_group)
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    if params[:file].present?
      if (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")

        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]
        tab = worksheet
        tab.each_with_index do |row, index|

          if index > 0
            unless row.nil?
              unless row[5].blank?

                results = get_trt("", row[4].value, row[5].value, "", default_group, "Excel")

                results.each do |guw_uow|
                  @guw_model.guw_attributes.each_with_index do |gac, jj|
                    jj_size =  @guw_model.orders.size + jj
                    tmp_val = row[15 + jj_size]
                    unless tmp_val.nil?
                      val = (tmp_val == "N/A" || tmp_val.to_i < 0) ? nil : row[15 + jj_size].value

                      if gac.name == (tab[0][15 + jj_size].nil? ? '' : tab[0][15 + jj_size].value)
                        unless @guw_type.nil?
                          guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: guw_uow.guw_type_id,
                                                                    guw_attribute_id: gac.id,
                                                                    guw_unit_of_work_id: guw_uow.id).first_or_create
                          guowa.low = val.to_i
                          guowa.most_likely = val.to_i
                          guowa.high = val.to_i
                          guowa.save
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  private def get_data(id, title, description, url, default_group, data_type, j)

    results = []

    if j == 0

      module_project = current_module_project
      component = current_component
      @guw_model = module_project.guw_model
      @organization = @guw_model.organization
      @project = module_project.project
      txt = description

      if data_type == "Excel"
        server_url = @guw_model.excel_ml_server
      elsif data_type == "Redmine"
        server_url = @guw_model.redmine_ml_server
      elsif data_type == "Jira"
        server_url = @guw_model.jira_ml_server
      end

      @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id, name: "GDI").first
      if @guw_type.nil?
        @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id).last
      end

      if default_group == ""
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: component.id,
                                                   name: 'Données').first_or_create
      else
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: component.id,
                                                   name: default_group).first_or_create
      end

      unless txt.blank?

        @http = Curl.post("http://#{server_url}/estimate_data", { txt: txt })

        JSON.parse(@http.body_str).each do |output|

          data_array = output.scan(/<data=(.*?)>/)
          attr_array = output.scan(/<attribut=(.*?)>/)

          data_array.each do |d|

            t = d.first

            unless t.nil?
              v = d.first.gsub(/#[ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøôÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ]+/, '').gsub(' et', '').gsub(',', '').gsub('/', '').gsub('/\"', '').gsub('/\/', '').delete('\\"')
            end

            guw_uow = Guw::GuwUnitOfWork.where(name: v.singularize.lstrip,
                                               guw_model_id: @guw_model.id,
                                               module_project_id: module_project.id).first_or_create(
                comments: attr_array.uniq.join(", "),
                guw_unit_of_work_group_id: @guw_group.id,
                organization_id: @organization.id,
                project_id: @project.id,
                pbs_project_element_id: component.id,
                display_order: nil,
                tracking: nil,
                quantity: 1,
                selected: true,
                guw_type_id: @guw_type.nil? ? nil : @guw_type.id,
                url: url)

            calculate_attribute(guw_uow)

            results << guw_uow

            @guw_model.guw_attributes.where(name: ["DET", "RET", "FTR"]).all.each do |gac|

              guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
                                                        guw_attribute_id: gac.id,
                                                        guw_unit_of_work_id: guw_uow.id).first_or_create
              if gac.name == "DET"
                guowa.low = attr_array.size
                guowa.most_likely = attr_array.size
                guowa.high = attr_array.size
                guowa.comments = attr_array.join(", ")
              elsif gac.name == "RET"
                guowa.low = 1
                guowa.most_likely = 1
                guowa.high = 1
              else
                guowa.low = 0
                guowa.most_likely = 0
                guowa.high = 0
              end

              guowa.save

            end

          end
        end
      end
    end

    return results.sort! { |a, b|  b.name <=> a.name }
  end

  private def get_trt(id, title, description, url, default_group, trt_type)
    module_project = current_module_project
    component = current_component
    @guw_model = module_project.guw_model
    @guw_model_guw_attributes = @guw_model.guw_attributes
    @organization = @guw_model.organization
    @project = module_project.project

    if trt_type == "Excel"
      url_server = @guw_model.excel_ml_server
    elsif trt_type == "Redmine"
      url_server = @guw_model.redmine_ml_server
    elsif trt_type == "Jira"
      url_server = @guw_model.jira_ml_server
    end

    @http = Curl.post("http://#{url_server}/estimate_trt", { us: description } )

    unless id.blank?
      title = "##{id} - #{title}"
    end

    description = description.to_s

    results = []

    JSON.parse(@http.body_str).each do |output|

      if default_group == ""
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: component.id,
                                                   name: 'Traitements').first_or_create
      else
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: component.id,
                                                   name: default_group).first_or_create
      end

      unless output.blank? || output == "NULL"
        @guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: output).first
      else
        @guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id, is_default: true).first
        if @guw_type.nil?
          @guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id).last
        end
      end

      results << Guw::GuwUnitOfWork.create(name: title.blank? ? description.truncate(50) : title,
                                           comments: description,
                                           guw_unit_of_work_group_id: @guw_group.id,
                                           organization_id: @organization.id,
                                           guw_model_id: @guw_model.id,
                                           project_id: @project.id,
                                           module_project_id: module_project.id,
                                           pbs_project_element_id: component.id,
                                           guw_model_id: @guw_model.id,
                                           display_order: nil,
                                           tracking: "",
                                           quantity: 1,
                                           selected: true,
                                           guw_type_id: @guw_type.nil? ? nil : @guw_type.id,
                                           url: url)

      results.each do |uo|
        @guw_model_guw_attributes.all.each do |gac|
          guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
                                                    guw_model_id: @guw_model.id,
                                                    guw_attribute_id: gac.id,
                                                    guw_type_id: uo.guw_type_id,
                                                    project_id: @project.id,
                                                    module_project_id: module_project.id,
                                                    guw_unit_of_work_id: uo.id).first_or_create
        end
      end

    end

    return results.sort! { |a, b|  b.name <=> a.name }
  end

  def extract_data_from_excel(default_group)
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    id = ""
    title = ""
    description = ""
    url = ""

    if params[:file].present?
      if (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")

        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]

        tab = worksheet
        tab.each_with_index do |row, index|
          title << row[4].value.to_s
          description << row[5].value.to_s
        end

        get_data(id, title, description, url, default_group, "Excel", 0)
      end
    end
  end

  def deported
    @guw_unit_of_work = Guw::GuwUnitOfWork.where(id: params[:guw_unit_of_work_id]).first
    @guw_type = @guw_unit_of_work.guw_type
    @guw_model = @guw_unit_of_work.guw_model
  end

  # def old_import_guw
  #
  #   module_project = current_module_project
  #   @guw_model = module_project.guw_model
  #   @component = current_component
  #   @project = module_project.project
  #   @organization = @project.organization
  #   @guw_attributes = @guw_model.guw_attributes
  #   @guw_coefficients = @guw_model.guw_coefficients
  #   @guw_outputs = @guw_model.guw_outputs
  #
  #   if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
  #     workbook = RubyXL::Parser.parse(params[:file].path)
  #     worksheet = workbook[0]
  #     tab = worksheet
  #
  #     tab.each_with_index do |row, index|
  #       unless row.nil?
  #         unless row[4].nil?
  #           if index > 0
  #
  #             guw_uow_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
  #                                                           project_id: @project.id,
  #                                                           module_project_id: module_project.id,
  #                                                           pbs_project_element_id: @component.id,
  #                                                           name: row[2].nil? ? '-' : row[2].value).first_or_create
  #
  #             tmp_hash_res = Hash.new
  #             tmp_hash_ares  = Hash.new
  #
  #             guw_uow = Guw::GuwUnitOfWork.create(selected: row[3].value.to_i == 1,
  #                                                 name: row[4].value,
  #                                                 comments: row[5].value,
  #                                                 guw_unit_of_work_group_id: guw_uow_group.id,
  #                                                 organization_id: @organization.id,
  #                                                 project_id: @project.id,
  #                                                 module_project_id: module_project.id,
  #                                                 pbs_project_element_id: @component.id,
  #                                                 guw_model_id: @guw_model.id,
  #                                                 tracking: row[12].value,
  #                                                 quantity: row[11].nil? ? 1 : row[11].value,
  #                                                 size: row[14].nil? ? nil : row[14].value,
  #                                                 ajusted_size: row[15].nil? ? nil : row[15].value,
  #                                                 intermediate_percent: row[16].nil? ? nil : row[16].value,
  #                                                 intermediate_weight: row[16].nil? ? nil : row[16].value)
  #
  #             if !row[7].nil?
  #               @guw_model.guw_work_units.each do |wu|
  #                 if wu.name == row[7].value
  #                   guw_uow.guw_work_unit_id = wu.id
  #                   break
  #                 end
  #               end
  #             else
  #               first_work_unit = @guw_model.guw_work_units.order("display_order ASC").first
  #               unless first_work_unit.nil?
  #                 guw_uow.guw_work_unit_id = @guw_model.guw_work_units.order("display_order ASC").first.id
  #               else
  #                 guw_uow.guw_work_unit_id = nil
  #               end
  #             end
  #
  #             if !row[8].nil?
  #               @guw_model.guw_weightings.each do |wu|
  #                 if wu.name == row[8].value
  #                   guw_uow.guw_weighting_id = wu.id
  #                   break
  #                 end
  #               end
  #             else
  #               first_weighting = @guw_model.guw_weightings.order("display_order ASC").first
  #               unless first_weighting.nil?
  #                 guw_uow.guw_weighting_id = @guw_model.guw_weightings.order("display_order ASC").first.id
  #               else
  #                 guw_uow.guw_weighting_id = nil
  #               end
  #             end
  #
  #             if !row[9].nil?
  #               @guw_model.guw_factors.each do |wu|
  #                 if wu.name == row[9].value
  #                   guw_uow.guw_factor_id = wu.id
  #                   break
  #                 end
  #               end
  #             else
  #               first_factor = @guw_model.guw_factors.order("display_order ASC").first
  #               unless first_factor.nil?
  #                 guw_uow.guw_factor_id = @guw_model.guw_factors.order("display_order ASC").first.id
  #               else
  #                 guw_uow.guw_factor_id = nil
  #               end
  #             end
  #
  #             guw_uow.save(validate: false)
  #
  #             @guw_type = Guw::GuwType.where(name: row[6].value,
  #                                            guw_model_id: @guw_model.id).first
  #
  #             @guw_attributes.each_with_index do |gac, ii|
  #
  #               unless @guw_type.nil?
  #                 if @guw_type.allow_criteria == true
  #                   @guw_attributes.size.times do |jj|
  #
  #                     ind = 18 + @guw_outputs.size + @guw_coefficients.size + jj
  #                     tmp_val = row[ind]
  #
  #                     unless tmp_val.nil?
  #
  #                       val = (tmp_val == "N/A" || tmp_val.to_i < 0) ? nil : row[ind].to_i
  #
  #                       if gac.name == (tab[0][ind].nil? ? '' : tab[0][ind].value)
  #                         unless @guw_type.nil?
  #                           guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
  #                                                                     guw_attribute_id: gac.id,
  #                                                                     guw_unit_of_work_id: guw_uow.id).first_or_create
  #                           guowa.low = val
  #                           guowa.most_likely = val
  #                           guowa.high = val
  #                           guowa.save
  #                         end
  #                       end
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #
  #             unless @guw_type.nil?
  #               if @guw_type.allow_criteria == true
  #
  #                 @lows = Array.new
  #                 @mls = Array.new
  #                 @highs = Array.new
  #                 array_pert = Array.new
  #
  #                 guw_uow.off_line = false
  #                 guw_uow.off_line_uo = false
  #
  #                 guw_uow.guw_unit_of_work_attributes.each do |guowa|
  #                   calculate_guowa(guowa, guw_uow, @guw_type)
  #                 end
  #
  #                 if @lows.empty?
  #                   guw_uow.guw_complexity_id = nil
  #                   guw_uow.guw_original_complexity_id = nil
  #                   guw_uow.result_low = nil
  #                 else
  #                   guw_uow.result_low = @lows.sum
  #                 end
  #
  #                 if @mls.empty?
  #                   guw_uow.guw_complexity_id = nil
  #                   guw_uow.guw_original_complexity_id = nil
  #                   guw_uow.result_most_likely = nil
  #                 else
  #                   guw_uow.result_most_likely = @mls.sum
  #                 end
  #
  #                 if @highs.empty?
  #                   guw_uow.guw_complexity_id = nil
  #                   guw_uow.guw_original_complexity_id = nil
  #                   guw_uow.result_high = nil
  #                 else
  #                   guw_uow.result_high = @highs.sum
  #                 end
  #               end
  #             end
  #
  #             guw_uow.guw_type_id ||= (@guw_type.nil? ? nil : @guw_type.id)
  #
  #             begin
  #               unless params["guw_complexity_#{guw_uow.id}"].nil?
  #                 guw_complexity_id = params["guw_complexity_#{guw_uow.id}"].to_i
  #                 guw_uow.guw_complexity_id = guw_complexity_id
  #                 guw_uow.guw_original_complexity_id = guw_complexity_id
  #               else
  #                 unless row[13].blank?
  #                   unless @guw_type.nil?
  #                     guw_complexity = Guw::GuwComplexity.where(guw_type_id: @guw_type.id,
  #                                                               name: row[13].value).first
  #                   end
  #                 end
  #
  #                 guw_uow.guw_complexity_id = guw_complexity.nil? ? nil : guw_complexity.id
  #               end
  #             rescue
  #               # ignored
  #             end
  #
  #             if guw_uow.changed?
  #               guw_uow.save
  #             end
  #
  #             unless @guw_type.nil?
  #               if (@guw_type.allow_complexity == true && @guw_type.allow_criteria == false)
  #
  #                 tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
  #                                                            organization_technology_id: guw_uow.organization_technology_id).first
  #
  #                 if array_pert.nil?
  #                   array_pert = []
  #                 end
  #
  #                 if guw_uow.guw_complexity.nil?
  #                   array_pert << 0
  #                 else
  #                   array_pert << (guw_uow.guw_complexity.weight.nil? ? 1 : guw_uow.guw_complexity.weight.to_f)
  #                 end
  #                 if guw_uow.changed?
  #                   guw_uow.save
  #                 end
  #               else
  #                 if guw_uow.result_low.nil? or guw_uow.result_most_likely.nil? or guw_uow.result_high.nil?
  #                   guw_uow.off_line_uo = nil
  #                 else
  #                   #Save if uo is simple/ml/high
  #                   value_pert = compute_probable_value(guw_uow.result_low, guw_uow.result_most_likely, guw_uow.result_high)[:value]
  #                   if (value_pert < @guw_type.guw_complexities.map(&:bottom_range).min.to_f)
  #                     guw_uow.off_line_uo = true
  #                   elsif (value_pert >= @guw_type.guw_complexities.map(&:top_range).max.to_f)
  #                     guw_uow.off_line_uo = true
  #                     cplx = @guw_type.guw_complexities.last
  #                     if cplx.nil?
  #                       guw_uow.guw_complexity_id = nil
  #                       guw_uow.guw_original_complexity_id = nil
  #                     else
  #                       guw_uow.guw_complexity_id = cplx.id
  #                       guw_uow.guw_original_complexity_id = cplx.id
  #                       array_pert << calculate_seuil(guw_uow, @guw_type.guw_complexities.last, value_pert)
  #                     end
  #                   else
  #                     @guw_type.guw_complexities.each do |guw_c|
  #                       array_pert << calculate_seuil(guw_uow, guw_c, value_pert)
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #
  #             unless @guw_type.nil?
  #               if @guw_type.allow_criteria == true
  #                 begin
  #                   #gestion des valeurs intermédiaires
  #                   @final_value = (guw_uow.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f)
  #                 rescue
  #                   @final_value = nil
  #                 end
  #
  #                 guw_uow.quantity = 1
  #
  #                 if guw_uow.changed?
  #                   guw_uow.save
  #                 end
  #
  #                 guw_uow.ajusted_size = nil
  #                 guw_uow.size = nil
  #
  #                 if guw_uow.changed?
  #                   guw_uow.save
  #                 end
  #
  #                 # update_estimation_values
  #                 # update_view_widgets_and_project_fields
  #                 Guw::GuwUnitOfWork.update_estimation_values(module_project, @component)
  #                 Guw::GuwUnitOfWork.update_view_widgets_and_project_fields(@organization, module_project, @component)
  #               end
  #             end
  #
  #             @guw_model.orders.sort_by { |k, v| v.to_f }.each_with_index do |i, j|
  #
  #               guw_coefficient = Guw::GuwCoefficient.where(guw_model_id: @guw_model.id, name: i[0]).first
  #
  #               if guw_coefficient.class == Guw::GuwCoefficient
  #
  #                 (16..60).to_a.each do |k|
  #                   if guw_coefficient.name == (tab[0][k].nil? ? '' : tab[0][k].value)
  #
  #                     ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_uow.id,
  #                                                                       guw_coefficient_id: guw_coefficient.id).first_or_create
  #
  #
  #                     if row[k].blank?
  #                       ce = guw_coefficient.guw_coefficient_elements.where(default: true).first
  #                     else
  #                       ce = guw_coefficient.guw_coefficient_elements.where(name: row[k].value).first
  #                     end
  #
  #                     unless ce.nil?
  #                       ceuw.guw_coefficient_element_id = ce.id
  #                     else
  #                       ceuw.percent = row[k].value.to_f
  #                     end
  #
  #                     unless guw_uow.changed?
  #                       ceuw.save
  #                     end
  #                   end
  #                 end
  #               elsif Guw::GuwOutput.where(name: i[0]).first.class == Guw::GuwOutput
  #
  #                 guw_output = Guw::GuwOutput.where(guw_model_id: @guw_model.id, name: i[0]).first
  #
  #                 unless guw_output.nil?
  #                   (16..60).to_a.each do |k|
  #                     if guw_output.name == tab[0][k].nil? ? '' : tab[0][k].value
  #                       # tmp_hash_res["#{guw_output.id}"] = row[k].value
  #                       tmp_hash_ares["#{guw_output.id}"] = row[k].nil? ? nil : row[k].value
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #
  #             guw_uow.size = tmp_hash_res
  #             guw_uow.ajusted_size = tmp_hash_ares
  #
  #             unless guw_uow.changed?
  #               guw_uow.save
  #             end
  #
  #             unless @guw_type.nil?
  #               if @guw_type.allow_criteria == true
  #                 @guw_attributes.all.each do |gac|
  #                   unless @guw_type.nil?
  #                     finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
  #                                                                guw_attribute_id: gac.id,
  #                                                                guw_unit_of_work_id: guw_uow.id).first_or_create
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  #   redirect_to :back
  # end

  private def import!(id, title, description, default_group, source, url)

    module_project = current_module_project
    @guw_model = module_project.guw_model
    @component = current_component
    @organization = @guw_model.organization
    @project = module_project.project
    @guw_attributes = @guw_model.guw_attributes
    @guw_coefficients = @guw_model.guw_coefficients
    @guw_outputs = @guw_model.guw_outputs
    @all_guw_attribute_complexities = Hash.new

    results = []

    if params[:import_type] == "Remplacer"
      Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                    guw_model_id: @guw_model.id,
                                    project_id: @project,
                                    module_project_id: module_project.id).delete_all
      Guw::GuwUnitOfWork.where(organization_id: @organization.id,
                               guw_model_id: @guw_model.id,
                               project_id: @project,
                               module_project_id: module_project.id).delete_all
    end

    if source == "Excel"
      if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]
        tab = worksheet

        tab.each_with_index do |row, index|
          unless row.nil?
            unless row[12].nil?
              if index > 0

                if default_group.blank?
                  guw_uow_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                                guw_model_id: @guw_model.id,
                                                                project_id: @project.id,
                                                                module_project_id: module_project.id,
                                                                pbs_project_element_id: @component.id,
                                                                name: row[10].nil? ? '-' : row[10].value).first_or_create
                else
                  guw_uow_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                                guw_model_id: @guw_model.id,
                                                                project_id: @project.id,
                                                                module_project_id: module_project.id,
                                                                pbs_project_element_id: @component.id,
                                                                name: default_group).first_or_create
                end

                tmp_hash_res = Hash.new
                tmp_hash_ares  = Hash.new

                @guw_type = Guw::GuwType.where(organization_id: @organization.id,
                                               guw_model_id: @guw_model.id,
                                               name: row[13].nil? ? '' : row[13].value).first
                if @guw_type.nil?
                  @guw_type = Guw::GuwType.where(organization_id: @organization.id,
                                                 guw_model_id: @guw_model.id,
                                                 is_default: true).first
                  if @guw_type.nil?
                    @guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id).last
                  end
                end

                unless @guw_type.nil?
                  if @all_guw_attribute_complexities[@guw_type.id].nil?
                    @all_guw_attribute_complexities[@guw_type.id] = Hash.new
                  end
                end

                guw_uow = Guw::GuwUnitOfWork.new( selected: ((row[11].nil? ? nil : row[11].value).to_i == 1),
                                                  name: row[12].nil? ? nil : row[12].value,
                                                  comments: row[14].nil? ? nil : row[14].value,
                                                  guw_unit_of_work_group_id: guw_uow_group.id,
                                                  organization_id: @organization.id,
                                                  guw_model_id: @guw_model.id,
                                                  project_id: @project.id,
                                                  module_project_id: module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  tracking: row[16].nil? ? 1 : row[16].value,
                                                  quantity: 1,
                                                  size: nil,
                                                  ajusted_size: nil,
                                                  intermediate_percent: row[18].nil? ? nil : row[18].value,
                                                  intermediate_weight: row[18].nil? ? nil : row[18].value,
                                                  guw_type_id: @guw_type.id)

                uo_type = module_project.guw_unit_of_works.where(guw_type_id: @guw_type.id)
                if uo_type.nil?
                  guw_uow.selected = true
                else
                  if module_project.guw_unit_of_works.where(guw_type_id: @guw_type.id).size >= @guw_type.maximum.to_i && !@guw_type.maximum.nil?
                    guw_uow.selected = false
                  else
                    guw_uow.selected = true
                  end
                end


                guw_uow.save(validate: false)

                #Je dois le retirer, a tester avant
                unless row[17].blank?
                  unless @guw_type.nil?
                    guw_complexity = Guw::GuwComplexity.where(organization_id: @organization.id,
                                                              guw_model_id: @guw_model.id,
                                                              guw_type_id: @guw_type.id,
                                                              name: row[17].value).first
                  end
                  guw_uow.guw_complexity_id = guw_complexity.nil? ? nil : guw_complexity.id
                  guw_uow.save(validate: false)
                end

                @guw_attributes.each_with_index do |gac, ii|
                  #update attributes complexities
                  if @all_guw_attribute_complexities[@guw_type.id][gac.id].nil?
                    @all_guw_attribute_complexities[@guw_type.id][gac.id] = Guw::GuwAttributeComplexity.where(organization_id: @organization.id,
                                                                                                              guw_model_id: @guw_model.id,
                                                                                                              guw_attribute_id: gac.id,
                                                                                                              guw_type_id: (@guw_type.nil? ? nil : @guw_type.id)).all
                  end
                end

                @guw_attributes.each do |gac|

                  ((17 + @guw_outputs.size + @guw_coefficients.size)..100).each do |ind|

                    unless row[ind].nil?

                      tmp_val = row[ind].value

                      val = (tmp_val == "N/A" || tmp_val.to_i < 0) ? nil : tmp_val.to_i

                      if gac.name == (tab[0][ind].nil? ? '' : tab[0][ind].value)
                        unless @guw_type.nil?
                          guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
                                                                    guw_model_id: @guw_model.id,
                                                                    guw_attribute_id: gac.id,
                                                                    guw_type_id: @guw_type.id,
                                                                    project_id: @project.id,
                                                                    module_project_id: module_project.id,
                                                                    guw_unit_of_work_id: guw_uow.id).first_or_create
                          guowa.low = val
                          guowa.most_likely = val
                          guowa.high = val
                          guowa.comments = row[ind + 1].value.to_s rescue nil
                          guowa.save
                        end
                      end
                    end
                  end
                end


                array_pert = Array.new

                if @guw_type.allow_criteria == true

                  @lows = Array.new
                  @mls = Array.new
                  @highs = Array.new

                  guw_uow.off_line = false
                  guw_uow.off_line_uo = false

                  guw_uow.guw_unit_of_work_attributes.where(organization_id: @organization.id, guw_model_id: @guw_model.id).each do |guowa|
                    calculate_guowa(guowa, guw_uow, @guw_type, @all_guw_attribute_complexities[@guw_type.id])
                  end

                  if @lows.empty?
                    guw_uow.guw_complexity_id = nil
                    guw_uow.guw_original_complexity_id = nil
                    guw_uow.result_low = nil
                  else
                    guw_uow.result_low = @lows.sum
                  end

                  if @mls.empty?
                    guw_uow.guw_complexity_id = nil
                    guw_uow.guw_original_complexity_id = nil
                    guw_uow.result_most_likely = nil
                  else
                    guw_uow.result_most_likely = @mls.sum
                  end

                  if @highs.empty?
                    guw_uow.guw_complexity_id = nil
                    guw_uow.guw_original_complexity_id = nil
                    guw_uow.result_high = nil
                  else
                    guw_uow.result_high = @highs.sum
                  end
                end

                if guw_uow.changed?
                  guw_uow.save
                end

                unless @guw_type.nil?
                  if (@guw_type.allow_complexity == true && (@guw_type.allow_criteria == false || @guw_type.allow_criteria == nil))
                    if guw_uow.guw_complexity.nil?
                      array_pert << 0
                    else
                      array_pert << (guw_uow.guw_complexity.weight.nil? ? 1 : guw_uow.guw_complexity.weight.to_f)
                    end
                  else
                    if guw_uow.result_low.nil? or guw_uow.result_most_likely.nil? or guw_uow.result_high.nil?
                      guw_uow.off_line_uo = nil
                    else
                      #Save if uo is simple/ml/high
                      guw_type_guw_complexities = @guw_type.guw_complexities.where(organization_id: @organization.id, guw_model_id: @guw_model.id)
                      value_pert = compute_probable_value(guw_uow.result_low, guw_uow.result_most_likely, guw_uow.result_high)[:value]
                      if (value_pert < guw_type_guw_complexities.map(&:bottom_range).min.to_f)
                        guw_uow.off_line_uo = true
                      elsif (value_pert >= guw_type_guw_complexities.map(&:top_range).max.to_f)
                        guw_uow.off_line_uo = true
                        cplx = guw_type_guw_complexities.last
                        if cplx.nil?
                          guw_uow.guw_complexity_id = nil
                          guw_uow.guw_original_complexity_id = nil
                        else
                          guw_uow.guw_complexity_id = cplx.id
                          guw_uow.guw_original_complexity_id = cplx.id
                          if @guw_type.allow_complexity == false
                            array_pert << calculate_seuil(guw_uow, guw_type_guw_complexities.last, value_pert)
                          end
                        end
                      else
                        guw_type_guw_complexities.each do |guw_c|
                          # if @guw_type.allow_complexity == false
                          array_pert << calculate_seuil(guw_uow, guw_c, value_pert)
                          # end
                        end
                      end
                    end
                  end
                end

                # gestion des valeurs intermédiaires
                @final_value = (guw_uow.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f)

                guw_uow.quantity = 1
                guw_uow.ajusted_size = nil
                guw_uow.size = nil

                if guw_uow.changed?
                  guw_uow.save
                end

                @guw_model.orders.sort_by { |k, v| v.to_f }.each_with_index do |i, j|

                  guw_coefficient = Guw::GuwCoefficient.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: i[0]).first
                  guw_output = Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: i[0]).first

                  unless guw_coefficient.nil?
                    if guw_coefficient.class == Guw::GuwCoefficient

                      guw_coefficient_guw_coefficient_elements = guw_coefficient.guw_coefficient_elements.where(organization_id: @organization.id, guw_model_id: @guw_model.id)
                      default_guw_coefficient_guw_coefficient_element = guw_coefficient_guw_coefficient_elements.where(default: true).first

                      (16..60).to_a.each do |k|
                        if guw_coefficient.name == (tab[0][k].nil? ? '' : tab[0][k].value)

                          ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                            guw_model_id: @guw_model.id,
                                                                            guw_coefficient_id: guw_coefficient.id,
                                                                            project_id: @project.id,
                                                                            module_project_id: module_project.id,
                                                                            guw_unit_of_work_id: guw_uow.id).first_or_create


                          if row[k].blank?
                            ce = default_guw_coefficient_guw_coefficient_element
                          else
                            ce = guw_coefficient_guw_coefficient_elements.where(name: row[k].value).first
                          end

                          unless ce.nil?
                            ceuw.guw_coefficient_element_id = ce.id
                          else
                            ceuw.percent = row[k].value.to_f rescue nil
                            unless worksheet.data_validations.nil?
                              worksheet.data_validations.each do |dv|
                                if dv.sqref.first.col_range.first == k
                                  ceuw.comments = dv.prompt.to_s
                                end
                              end
                            end
                            ceuw.guw_coefficient_element_id = default_guw_coefficient_guw_coefficient_element.nil? ? guw_coefficient_guw_coefficient_elements.first : default_guw_coefficient_guw_coefficient_element.id
                          end

                          unless guw_uow.changed?
                            ceuw.save
                          end
                        end
                      end
                    end
                  end

                  unless guw_output.nil?
                    if guw_output.class == Guw::GuwOutput

                      unless guw_output.nil?
                        (16..60).to_a.each do |k|
                          if guw_output.name == (tab[0][k].nil? ? '' : tab[0][k].value)
                            # if @guw_type.allow_criteria == true
                            tmp_hash_res["#{guw_output.id}"] = row[k].value rescue nil
                            tmp_hash_ares["#{guw_output.id}"] = row[k].value rescue nil
                            # end
                          end
                        end
                      end
                    end
                  end
                end

                guw_uow.size = tmp_hash_res
                guw_uow.ajusted_size = tmp_hash_ares

                # unless guw_uow.changed?
                  guw_uow.save
                # end

                @guw_attributes.all.each do |gac|
                  unless @guw_type.nil?
                    finder = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
                                                               guw_model_id: @guw_model.id,
                                                               guw_attribute_id: gac.id,
                                                               guw_type_id: @guw_type.id,
                                                               project_id: @project.id,
                                                               module_project_id: module_project.id,
                                                               guw_unit_of_work_id: guw_uow.id).first_or_create
                  end
                end

                if @guw_type.allow_complexity == true
                  unless row[17].blank? || row[17].nil?
                    unless @guw_type.nil?
                      guw_complexity = Guw::GuwComplexity.where(organization_id: @organization.id,
                                                                guw_model_id: @guw_model.id,
                                                                guw_type_id: @guw_type.id,
                                                                name: row[17].nil? ? nil : row[17].value).first
                    end

                    guw_uow.guw_complexity_id = guw_complexity.nil? ? nil : guw_complexity.id
                    guw_uow.off_line = false
                    guw_uow.save(validate: false)
                  end
                end

              end

            end

          end
        end
      end
    else

      if default_group == ""
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: @component.id,
                                                   name: 'Données').first_or_create
      else
        @guw_group = Guw::GuwUnitOfWorkGroup.where(organization_id: @organization.id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: module_project.id,
                                                   pbs_project_element_id: @component.id,
                                                   name: default_group).first_or_create
      end

      @guw_type = Guw::GuwType.where(organization_id: @organization.id,
                                     guw_model_id: @guw_model.id,
                                     is_default: true).first

      if @guw_type.nil?
        @guw_type = Guw::GuwType.where(organization_id: @organization.id, guw_model_id: @guw_model.id).last
      end

      unless id.blank?
        title = "##{id} - #{title}"
      end

      @guw_complexity = Guw::GuwComplexity.where(organization_id: @organization.id,
                                                 guw_model_id: @guw_model.id,
                                                 guw_type_id: @guw_type.id,
                                                 default_value: true).first

      guw_uow = Guw::GuwUnitOfWork.create(selected: true,
                                          name: title.truncate(254),
                                          comments: description,
                                          tracking: "",
                                          guw_unit_of_work_group_id: @guw_group.id,
                                          organization_id: @organization.id,
                                          guw_model_id: @guw_model.id,
                                          project_id: @project.id,
                                          module_project_id: module_project.id,
                                          pbs_project_element_id: @component.id,
                                          guw_type_id: @guw_type.id,
                                          guw_complexity_id:  @guw_complexity.nil? ? nil : @guw_complexity.id,
                                          url: url)

      guw_uow.save(validate: false)

      results << guw_uow
    end

    results.each do |uo|
      @guw_model.guw_attributes.all.each do |gac|
        guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
                                                  guw_model_id: @guw_model.id,
                                                  guw_attribute_id: gac.id,
                                                  guw_type_id: uo.guw_type_id,
                                                  project_id: @project.id,
                                                  module_project_id: module_project.id,
                                                  guw_unit_of_work_id: uo.id).first_or_create
        guowa.save
      end
    end

    return results.sort! { |a, b|  b.name <=> a.name }
  end

  def calculate_attribute(guw_uow)

    @guw_type = guw_uow.guw_type

    @lows = Array.new
    @mls = Array.new
    @highs = Array.new
    array_pert = Array.new

    guw_uow.off_line = false
    guw_uow.off_line_uo = false

    guw_uow.guw_unit_of_work_attributes.where(organization_id: guw_uow.organization_id, guw_model_id: guw_uow.guw_model_id).each do |guowa|
      calculate_guowa(guowa, guw_uow, @guw_type)
    end

    if @lows.empty?
      guw_uow.guw_complexity_id = nil
      guw_uow.guw_original_complexity_id = nil
      guw_uow.result_low = nil
    else
      guw_uow.result_low = @lows.sum
    end

    if @mls.empty?
      guw_uow.guw_complexity_id = nil
      guw_uow.guw_original_complexity_id = nil
      guw_uow.result_most_likely = nil
    else
      guw_uow.result_most_likely = @mls.sum
    end

    if @highs.empty?
      guw_uow.guw_complexity_id = nil
      guw_uow.guw_original_complexity_id = nil
      guw_uow.result_high = nil
    else
      guw_uow.result_high = @highs.sum
    end

    if guw_uow.changed?
      guw_uow.save
    end

    unless @guw_type.nil?
      if guw_uow.result_low.nil? or guw_uow.result_most_likely.nil? or guw_uow.result_high.nil?
        guw_uow.off_line_uo = nil
      else
        #Save if uo is simple/ml/high
        value_pert = compute_probable_value(guw_uow.result_low, guw_uow.result_most_likely, guw_uow.result_high)[:value]
        if (value_pert < @guw_type.guw_complexities.where(organization_id: guw_uow.organization_id, guw_model_id: guw_uow.guw_model_id).map(&:bottom_range).min.to_f)
          guw_uow.off_line_uo = true
        elsif (value_pert >= @guw_type.guw_complexities.where(organization_id: guw_uow.organization_id, guw_model_id: guw_uow.guw_model_id).map(&:top_range).max.to_f)
          guw_uow.off_line_uo = true
          cplx = @guw_type.guw_complexities.last
          if cplx.nil?
            guw_uow.guw_complexity_id = nil
            guw_uow.guw_original_complexity_id = nil
          else
            guw_uow.guw_complexity_id = cplx.id
            guw_uow.guw_original_complexity_id = cplx.id
            array_pert << calculate_seuil(guw_uow, @guw_type.guw_complexities.last, value_pert)
          end
        else
          @guw_type.guw_complexities.where(organization_id: guw_uow.organization_id, guw_model_id: guw_uow.guw_model_id).each do |guw_c|
            array_pert << calculate_seuil(guw_uow, guw_c, value_pert)
          end
        end
      end
    end

    # update_estimation_values
    # update_view_widgets_and_project_fields

    unless guw_uow.changed?
      guw_uow.save
    end
  end

  private

  def reorder(group)
    group.guw_unit_of_works.order("display_order ASC").each_with_index do |u, i|
      u.display_order = i
      u.save
    end
  end


end

# Guw::GuwComplexityCoefficientElement.where(value: nil).each do |gcce|
#   gcce.delete
# end