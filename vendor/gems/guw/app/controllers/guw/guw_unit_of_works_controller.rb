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
    set_page_title I18n.t(:New_Units_Of_Work)
  end

  def edit
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title I18n.t(:Edit_Units_Of_Work)
  end

  def create
    unless params[:guw_unit_of_work][:guw_type_id].blank?
      @guw_type = Guw::GuwType.find(params[:guw_unit_of_work][:guw_type_id])
    end
    @guw_model = Guw::GuwModel.find(params[:guw_unit_of_work][:guw_model_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.new(params[:guw_unit_of_work])

    @guw_unit_of_work.guw_model_id = @guw_model.id
    @guw_unit_of_work.module_project_id = current_module_project.id
    @guw_unit_of_work.pbs_project_element_id = current_component.id
    @guw_unit_of_work.selected = true

    @guw_unit_of_work.ajusted_size = {}
    @guw_unit_of_work.size = {}
    @guw_unit_of_work.effort = {}
    @guw_unit_of_work.cost = {}

    if params[:position].blank?
      @guw_unit_of_work.display_order = @guw_unit_of_work.guw_unit_of_work_group.guw_unit_of_works.size.to_i + 1
    else
      @guw_unit_of_work.display_order = params[:position].to_i
    end

    @guw_unit_of_work.save

    reorder(@guw_unit_of_work.guw_unit_of_work_group)

    @guw_model.guw_attributes.all.each do |gac|
      Guw::GuwUnitOfWorkAttribute.create(
          guw_type_id: @guw_type.nil? ? nil : @guw_type.id,
          guw_unit_of_work_id: @guw_unit_of_work.id,
          guw_attribute_id: gac.id)
    end

    expire_fragment "guw"

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    if @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
      redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}") and return
    else
      render :edit
    end

    expire_fragment "guw"
  end

  def destroy
    @guw_model = current_module_project.guw_model
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    group = @guw_unit_of_work.guw_unit_of_work_group
    @guw_unit_of_work.delete

    expire_fragment "guw"

    update_estimation_values
    update_view_widgets_and_project_fields

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{group.id}")
  end

  def up
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order - 2
    @guw_unit_of_work.save

    expire_fragment "guw"

    redirect_to :back
  end

  def down
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order + 1
    @guw_unit_of_work.save

    expire_fragment "guw"

    redirect_to :back
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
    @guw_unit_of_work.name = params[:name].values.first
    @guw_unit_of_work.comments = params[:comments].values.first
    @guw_unit_of_work.tracking = params[:trackings].values.first
    @guw_unit_of_work.save

    expire_fragment "guw"

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def save_uo
    @project = current_module_project.project
    @guw_model = current_module_project.guw_model
    @component = current_component
    guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
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

    guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|
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

      tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
                                                 organization_technology_id: guw_unit_of_work.organization_technology_id).first

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
            array_pert << calculate_seuil(guw_unit_of_work, guw_type.guw_complexities.last, value_pert)
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

    final_value = (guw_unit_of_work.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f.round(3))
    # calculate_attributes(guw_unit_of_work, guw_factor, guw_weighting, guw_work_unit, tcplx, final_value, @guw_model)

    complexity_work_unit = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
                                                            guw_work_unit_id: guw_work_unit).first

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
      guw_unit_of_work.ajusted_size = params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"].to_f.round(3)
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

    update_estimation_values
    update_view_widgets_and_project_fields

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def duplicate
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    # La copie des #guw_unit_of_work_attributes sera geree dans le amoeba_dup
    @new_guw_unit_of_work = @guw_unit_of_work.amoeba_dup
    @new_guw_unit_of_work.save

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def save_guw_unit_of_works
    @guw_model = current_module_project.guw_model
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id)

    @guw_unit_of_works.each_with_index do |guw_unit_of_work, i|
      array_pert = Array.new
      if !params[:selected].nil? && params[:selected].join(",").include?(guw_unit_of_work.id.to_s)
        guw_unit_of_work.selected = true
      else
        guw_unit_of_work.selected = false
      end

      #reorder to keep good order
      reorder guw_unit_of_work.guw_unit_of_work_group

      begin
        guw_type = Guw::GuwType.find(params[:guw_type]["#{guw_unit_of_work.id}"])
      rescue
        guw_type = guw_unit_of_work.guw_type
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

      if params[:guw_technology].present?
        guw_unit_of_work.organization_technology_id = params[:guw_technology]["#{guw_unit_of_work.id}"].to_i
      end

      guw_unit_of_work.guw_type_id = guw_type.id
      guw_unit_of_work.guw_work_unit = guw_work_unit
      guw_unit_of_work.guw_weighting = guw_weighting
      guw_unit_of_work.guw_factor = guw_factor

      @guw_model.guw_attributes.all.each do |gac|
        guw_unit_of_work.save
        finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: guw_type.id,
                                                   guw_unit_of_work_id: guw_unit_of_work.id,
                                                   guw_attribute_id: gac.id).first_or_create
        finder.save
      end

      if params["quantity"].present?
        guw_unit_of_work.quantity = params["quantity"]["#{guw_unit_of_work.id}"].nil? ? 1 : params["quantity"]["#{guw_unit_of_work.id}"].to_f
      else
        guw_unit_of_work.quantity = 1
      end

      if guw_unit_of_work.guw_type.allow_complexity == true
        unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
          guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
          guw_unit_of_work.guw_complexity_id = guw_complexity_id
          guw_unit_of_work.save
        else
          guw_complexity_id = guw_unit_of_work.guw_complexity_id
        end

        complexity_work_unit = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity_id,
                                               guw_work_unit_id: guw_work_unit).first

        complexity_weighting = Guw::GuwComplexityWeighting.where(guw_complexity_id: guw_complexity_id,
                                               guw_weighting_id: guw_weighting).first

        complexity_factor = Guw::GuwComplexityFactor.where(guw_complexity_id: guw_complexity_id,
                                               guw_factor_id: guw_factor).first

        tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
                                                   organization_technology_id: guw_unit_of_work.organization_technology_id,
                                                   guw_type_id: guw_unit_of_work.guw_type_id).first

        guw_unit_of_work.save
      else
        unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
          guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
          guw_unit_of_work.guw_complexity_id = guw_complexity_id
          guw_unit_of_work.save
        else
          guw_complexity_id = guw_unit_of_work.guw_complexity_id
        end
      end

      if guw_unit_of_work.guw_complexity.nil?
        final_value = nil
      else
        weight = (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
        if guw_unit_of_work.guw_complexity.enable_value == false
          final_value = weight
        else
          result_low = guw_unit_of_work.result_low.nil? ? 1 : guw_unit_of_work.result_low
          result_most_likely = guw_unit_of_work.result_most_likely.nil? ? 1 : guw_unit_of_work.result_most_likely
          result_high = guw_unit_of_work.result_high.nil? ? 1 : guw_unit_of_work.result_high

          final_value = ((result_low + 4 * result_most_likely +  result_high) / 6) * (weight.nil? ? 1 : weight.to_f)
        end
      end

      complexity_work_unit = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_unit_of_work.guw_complexity,
                                                              guw_work_unit_id: guw_work_unit).first

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

      if final_value.nil?
        guw_unit_of_work.size = nil
        if params["ajusted_size"].nil?
          guw_unit_of_work.ajusted_size = nil
        else
          guw_unit_of_work.ajusted_size = params["ajusted_size"]["#{guw_unit_of_work.id}"].to_f.round(3)
        end
      else
        guw_unit_of_work.size = final_value.to_f *
            (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) *
            (size_array_value.inject(&:*).nil? ? 1 : size_array_value.inject(&:*))

        if guw_unit_of_work.guw_type.allow_retained == false
          guw_unit_of_work.ajusted_size = guw_unit_of_work.size.round(3)
        else
          if params["ajusted_size"]["#{guw_unit_of_work.id}"].blank?
            guw_unit_of_work.ajusted_size = guw_unit_of_work.size.round(3)
          else
            guw_unit_of_work.ajusted_size = params["ajusted_size"]["#{guw_unit_of_work.id}"].to_f.round(3)
          end
        end
      end

      guw_unit_of_work.save

      unless guw_unit_of_work.ajusted_size.nil?
        guw_unit_of_work.effort = guw_unit_of_work.ajusted_size *
            (effort_array_value.inject(&:*).nil? ? 1 : effort_array_value.inject(&:*))

        guw_unit_of_work.cost = guw_unit_of_work.ajusted_size *
            (cost_array_value.inject(&:*).nil? ? 1 : cost_array_value.inject(&:*))
      end

      if guw_unit_of_work.size.nil? || guw_unit_of_work.ajusted_size.nil?
        guw_unit_of_work.flagged = false
      else
        if guw_unit_of_work.off_line == true || guw_unit_of_work.off_line_uo == true
          guw_unit_of_work.flagged = true
        elsif guw_unit_of_work.size.to_f.round(3) != guw_unit_of_work.ajusted_size.round(3)
          guw_unit_of_work.flagged = true
        else
          guw_unit_of_work.flagged = false
        end
      end

      guw_unit_of_work.save
    end

    update_estimation_values
    update_view_widgets_and_project_fields

    if @guw_unit_of_works.last.nil?
      redirect_to main_app.dashboard_path(@project)
    else
      redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_works.last.guw_unit_of_work_group.id}")
    end
  end

  def change_cotation
    authorize! :execute_estimation_plan, @project

    @guw_model = current_module_project.guw_model
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    @guw_model.guw_attributes.all.each do |gac|
      finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
                                                 guw_unit_of_work_id: @guw_unit_of_work.id,
                                                 guw_attribute_id: gac.id).first_or_create
      finder.save
    end


    technology = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq.first
    @guw_unit_of_work.organization_technology_id = technology.nil? ? nil : technology.id

    @guw_unit_of_work.guw_type_id = @guw_type.id
    @guw_unit_of_work.effort = nil
    @guw_unit_of_work.guw_complexity_id = nil
    @guw_unit_of_work.save
  end

  def change_work_unit
    authorize! :execute_estimation_plan, @project

    @guw_model = current_module_project.guw_model
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:guw_work_unit_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.guw_work_unit_id = @guw_work_unit.id
    @guw_unit_of_work.save
  end

  def change_technology_form
    authorize! :execute_estimation_plan, @project

    @guw_model = current_module_project.guw_model
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @technologies = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq
  end

  def change_selected_state
    authorize! :execute_estimation_plan, @project

    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    if @guw_unit_of_work.selected == false
      @guw_unit_of_work.selected = true
    else
      @guw_unit_of_work.selected = false
    end

    @guw_unit_of_work.save

    @group = Guw::GuwUnitOfWorkGroup.find(params[:guw_unit_of_work_group_id])

    #For grouped unit of work
    @group_size_ajusted = Guw::GuwUnitOfWork.where(selected: true,
                                             guw_unit_of_work_group_id: @group.id,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{ |i| (i.ajusted_size.is_a?(Numeric) ? i.ajusted_size.to_f : i.ajusted_size["#{guw_output.id}"].to_f) }.sum.to_f.round(user_number_precision)

    @group_size_theorical = Guw::GuwUnitOfWork.where(selected: true,
                                                     guw_unit_of_work_group_id: @group.id,
                                                     pbs_project_element_id: current_component.id,
                                                     module_project_id: current_module_project.id,
                                                     guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| (i.size.is_a?(Numeric) ? i.size.to_f : i.size["#{guw_output.id}"].to_f)}.sum.to_f.round(user_number_precision)

    @group_number_of_unit_of_works = Guw::GuwUnitOfWork.where(guw_unit_of_work_group_id: @group.id,
                                                              pbs_project_element_id: current_component.id,
                                                              module_project_id: current_module_project.id,
                                                              guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum.to_f.round(user_number_precision)

    @group_selected_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                                guw_unit_of_work_group_id: @group.id,
                                                                pbs_project_element_id: current_component.id,
                                                                module_project_id: current_module_project.id,
                                                                guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum.to_f.round(user_number_precision)

    @group_flagged_unit_of_works = Guw::GuwUnitOfWork.where(flagged: true,
                                                            guw_unit_of_work_group_id: @group.id,
                                                            pbs_project_element_id: current_component.id,
                                                            module_project_id: current_module_project.id,
                                                            guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum.to_f.round(user_number_precision)


    #For all unit of work
    @ajusted_size = Guw::GuwUnitOfWork.where(selected: true,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_size.to_f }.sum.to_f.round(user_number_precision)

    @theorical_size = Guw::GuwUnitOfWork.where(selected: true,
                                               pbs_project_element_id: current_component.id,
                                               module_project_id: current_module_project.id,
                                               guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.size.to_f }.sum.to_f.round(user_number_precision)

    @effort = Guw::GuwUnitOfWork.where(selected: true,
                                       pbs_project_element_id: current_component.id,
                                       module_project_id: current_module_project.id,
                                       guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.effort.to_f }.sum.to_f.round(user_number_precision)

    @cost = Guw::GuwUnitOfWork.where(selected: true,
                                     pbs_project_element_id: current_component.id,
                                     module_project_id: current_module_project.id,
                                     guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.cost.to_f }.sum.to_f.round(user_number_precision)

    @number_of_unit_of_works = Guw::GuwUnitOfWork.where(pbs_project_element_id: current_component.id,
                                                        module_project_id: current_module_project.id,
                                                        guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum.to_f.round(user_number_precision)

    @selected_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                          pbs_project_element_id: current_component.id,
                                                          module_project_id: current_module_project.id,
                                                          guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum.to_f.round(user_number_precision)

    @flagged_unit_of_works = Guw::GuwUnitOfWork.where(flagged: true,
                                                      pbs_project_element_id: current_component.id,
                                                      module_project_id: current_module_project.id,
                                                      guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum.to_f.round(user_number_precision)

    update_estimation_values
    update_view_widgets_and_project_fields
  end

  def calculate_guowa(guowa, guw_unit_of_work, guw_type)

    if params["most_likely"]["#{guw_unit_of_work.id}"].values.include?("")
      guw_unit_of_work.missing_value = true
    else
      guw_unit_of_work.missing_value = false
    end

    #Peut être factorisé  dans une boucle !
    if @guw_model.three_points_estimation == true
      #Estimation 3 points
      if params["low"]["#{guw_unit_of_work.id}"].nil?
        low = guowa.low
        guw_unit_of_work.flagged = true
      else
        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["most_likely"]["#{guw_unit_of_work.id}"].nil?
        most_likely = guowa.most_likely
        guw_unit_of_work.flagged = true
      else
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["high"]["#{guw_unit_of_work.id}"].nil?
        high = guowa.high
        guw_unit_of_work.flagged = true
      else
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end
    else
      begin
        #Estimation 1 point
        if params["most_likely"]["#{guw_unit_of_work.id}"].nil? or params["most_likely"]["#{guw_unit_of_work.id}"].values.map(&:to_f).flatten.sum.blank?
          low = most_likely = high = guowa.most_likely
          guw_unit_of_work.flagged = true
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

    @guw_attribute_complexities = Guw::GuwAttributeComplexity.where(guw_type_id: (guw_type.nil? ? nil : guw_type.id),
                                                                    guw_attribute_id: guowa.guw_attribute_id).all

    sum_range = guowa.guw_attribute.guw_attribute_complexities.where(guw_type_id: guw_type.nil? ? nil : guw_type.id).map{|i| [i.bottom_range, i.top_range]}.flatten.compact

    unless sum_range.nil? || sum_range.blank? || sum_range == 0
      @guw_attribute_complexities.each do |guw_ac|

        guw_ac_guw_type_complexity = guw_ac.guw_type_complexity

        unless low.nil?
          unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
            if (low >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (low < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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
              guw_unit_of_work.flagged = true
            end
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end

        unless most_likely.nil?
          if (most_likely >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (most_likely < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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
            guw_unit_of_work.flagged = true
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end

        unless high.nil?
          if (high >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (high < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
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
            guw_unit_of_work.flagged = true
          end
          # guw_unit_of_work.missing_value = false
        else
          # guw_unit_of_work.missing_value = true
        end
      end
    end

    unless params["comments"].nil?
      guowa.comments = params["comments"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_s
    end

    guowa.low = low
    guowa.most_likely = most_likely
    guowa.high = high
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


    guw_unit_of_work.intermediate_percent = compute_probable_value(ipl.to_f, ipm.to_f, iph.to_f)[:value] * 100
    # if guw_unit_of_work.intermediate_weight.nil?
      guw_unit_of_work.intermediate_weight = compute_probable_value(ipl.to_f, ipm.to_f, iph.to_f)[:value] * 100
    # end

    guw_unit_of_work.save

    result = compute_probable_value(uo_weight_low.to_f, uo_weight_ml.to_f, uo_weight_high.to_f)[:value]

    return result
  end

  #/!\ NEW METHODS WITH MULTIPLES ATTRIBUTES /!\
  def save_guw_unit_of_works_with_multiple_outputs
    @guw_model = current_module_project.guw_model
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id).includes(:guw_type, :guw_complexity)

    @guw_coefficients = @guw_model.guw_coefficients
    @guw_outputs = @guw_model.guw_outputs.order("display_order ASC")

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
        guw_unit_of_work.selected = false
      end

      #reorder to keep good order
      reorder guw_unit_of_work.guw_unit_of_work_group

      if params[:guw_type]["#{guw_unit_of_work.id}"].nil?
        guw_type = guw_unit_of_work.guw_type
      else
        guw_type = Guw::GuwType.find(params[:guw_type]["#{guw_unit_of_work.id}"])
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
      end

      #Pour le calcul des valeurs intermédiares, on prend uniquement le premier attributs (pour l'instant)
      tmp_hash_res = Hash.new
      tmp_hash_ares = Hash.new

      @guw_outputs.each_with_index do |guw_output, index|

        @oc = Guw::GuwOutputComplexity.where(guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                             guw_output_id: guw_output.id,
                                             value: 1).first

        @oci = Guw::GuwOutputComplexityInitialization.where(guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                                            guw_output_id: guw_output.id).first

        #gestion des valeurs intermédiaires
        weight = (guw_unit_of_work.guw_complexity.nil? ? 1.0 : (guw_unit_of_work.guw_complexity.weight.nil? ? 1.0 : guw_unit_of_work.guw_complexity.weight.to_f))
        weight_b = (guw_unit_of_work.guw_complexity.nil? ? 0 : (guw_unit_of_work.guw_complexity.weight_b.nil? ? 0 : guw_unit_of_work.guw_complexity.weight_b.to_f))

        result_low = guw_unit_of_work.result_low.nil? ? 1 : guw_unit_of_work.result_low
        result_most_likely = guw_unit_of_work.result_most_likely.nil? ? 1 : guw_unit_of_work.result_most_likely
        result_high = guw_unit_of_work.result_high.nil? ? 1 : guw_unit_of_work.result_high

        if guw_unit_of_work.guw_complexity.nil?
          @final_value = nil
        else
          # weight = (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
          if guw_unit_of_work.guw_complexity.enable_value == false
            if @oc.nil?
              @final_value = (@oci.nil? ? 0 : @oci.init_value.to_f)
            else
              @final_value = (@oci.nil? ? 0 : @oci.init_value.to_f) + (@oc.value.nil? ? 1 : @oc.value.to_f) * weight
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
              @final_value = (@oci.nil? ? 0 : @oci.init_value.to_f)
            else
              @final_value = (@oci.nil? ? 0 : @oci.init_value.to_f) + (@oc.value.nil? ? 1 : @oc.value.to_f) * (weight.nil? ? 1 : weight.to_f) * (intermediate_percent.nil? ? 1 : intermediate_percent) + (weight_b.nil? ? 0 : weight_b.to_f)
            end

          end
        end

        coeffs = []
        percents = []
        selected_coefficient_values = Hash.new {|h,k| h[k] = [] }

        @guw_coefficients.each do |guw_coefficient|
          if guw_coefficient.coefficient_type == "Pourcentage"

            ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_unit_of_work,
                                                              guw_coefficient_id: guw_coefficient.id).first_or_create(guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                      guw_coefficient_id: guw_coefficient.id)

            begin
              pc = params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
            rescue
              pc = 100
            end

            guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
              cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                               guw_coefficient_element_id: guw_coefficient_element.id,
                                                               guw_complexity_id: guw_unit_of_work.guw_complexity_id).first_or_create

              unless cce.value.blank?
                percents << (pc.to_f / 100)
                percents << cce.value.to_f

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << (v / 100)

              else
                percents << 1
              end
            end

            ceuw.percent = pc
            ceuw.guw_coefficient_id = guw_coefficient.id
            ceuw.guw_unit_of_work_id = guw_unit_of_work.id
            ceuw.module_project_id = current_module_project.id

            ceuw.save

          elsif guw_coefficient.coefficient_type == "Coefficient"

            ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_unit_of_work,
                                                              guw_coefficient_id: guw_coefficient.id).first_or_create(guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                      guw_coefficient_id: guw_coefficient.id)

            begin
              pc = params["guw_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
            rescue
              pc = 1
            end

            guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|

              cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                               guw_coefficient_element_id: guw_coefficient_element.id,
                                                               guw_complexity_id: guw_unit_of_work.guw_complexity_id).first_or_create

              unless cce.value.blank?
                coeffs << pc
                coeffs << cce.value.to_f

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << v

              else
                coeffs << 1
              end
            end

            ceuw.percent = pc
            ceuw.guw_coefficient_id = guw_coefficient.id
            ceuw.guw_unit_of_work_id = guw_unit_of_work.id
            ceuw.module_project_id = current_module_project.id

            ceuw.save
          else

            unless params['guw_coefficient'].nil?
              unless params['guw_coefficient']["#{guw_unit_of_work.id}"].nil?
                begin
                  unless params['deported_guw_coefficient'].nil?
                    ce = Guw::GuwCoefficientElement.find_by_id(params['deported_guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)
                  else
                    ce = Guw::GuwCoefficientElement.find_by_id(params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)
                  end
                rescue
                  ce = nil
                end
              end
            end

            unless ce.nil?
              cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                               guw_coefficient_element_id: ce.id,
                                                               guw_complexity_id: guw_unit_of_work.guw_complexity_id).first

              ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_coefficient_id: guw_coefficient,
                                                                guw_unit_of_work_id: guw_unit_of_work).first_or_create(guw_coefficient_id: guw_coefficient,
                                                                                                                       guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                       guw_coefficient_id: params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)

              unless ceuw.nil?
                unless params['deported_guw_coefficient'].nil?
                  v = params['deported_guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                  ceuw.guw_coefficient_element_id = v.nil? ? nil : v.to_i
                else
                  v = params['guw_coefficient']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
                  ceuw.guw_coefficient_element_id = v.nil? ? nil : v.to_i
                end
                ceuw.guw_coefficient_id = guw_coefficient.id
                ceuw.guw_unit_of_work_id = guw_unit_of_work.id
                ceuw.module_project_id = current_module_project.id

                ceuw.save
              end

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
        Guw::GuwOutputAssociation.where(guw_output_id: guw_output.id,
                                        guw_complexity_id: guw_unit_of_work.guw_complexity_id).all.each do |goa|
          unless goa.value.to_f == 0
            unless goa.aguw_output.nil?
              oa_value << tmp_hash_ares["#{goa.aguw_output.id}"].to_f * goa.value.to_f
            end
          end
        end

        inter_value = oa_value.compact.sum.to_f

        unless @final_value.nil?
          if inter_value == 0
            tmp = @final_value.to_f * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
          else
            tmp = inter_value * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)
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

    update_estimation_values
    update_view_widgets_and_project_fields

    if @guw_unit_of_works.last.nil?
      redirect_to main_app.dashboard_path(@project)
    else
      redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_works.last.guw_unit_of_work_group.id}")
    end
  end

  def save_uo_with_multiple_outputs
    @project = current_module_project.project
    @guw_model = current_module_project.guw_model
    @component = current_component

    guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    guw_unit_of_work.ajusted_size = {}
    guw_unit_of_work.size = {}
    guw_unit_of_work.effort = {}
    guw_unit_of_work.cost = {}

    # guw_unit_of_work.save

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

    guw_unit_of_work.guw_unit_of_work_attributes.where(guw_type_id: guw_type.id).each do |guowa|
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

    guw_unit_of_work.guw_type_id ||= guw_type.id
    # guw_unit_of_work.guw_work_unit_id = guw_work_unit.nil? ? nil : guw_work_unit.id
    # guw_unit_of_work.guw_weighting_id = guw_weighting.nil? ? nil : guw_weighting.id
    # guw_unit_of_work.guw_factor_id = guw_factor.nil? ? nil : guw_factor.id

    unless params["guw_complexity_#{guw_unit_of_work.id}"].nil?
      guw_complexity_id = params["guw_complexity_#{guw_unit_of_work.id}"].to_i
      guw_unit_of_work.guw_complexity_id = guw_complexity_id
      guw_unit_of_work.guw_original_complexity_id = guw_complexity_id
      if guw_unit_of_work.changed?
        guw_unit_of_work.save
      end
    else
      guw_complexity_id = guw_unit_of_work.guw_complexity_id
    end

    if (guw_unit_of_work.guw_type.allow_complexity == true && guw_unit_of_work.guw_type.allow_criteria == false)

      tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
                                                 organization_technology_id: guw_unit_of_work.organization_technology_id).first

      if guw_unit_of_work.guw_complexity.nil?
        array_pert << 0
      else
        array_pert << (guw_unit_of_work.guw_complexity.weight.nil? ? 1 : guw_unit_of_work.guw_complexity.weight.to_f)
      end
      if guw_unit_of_work.changed?
        guw_unit_of_work.save
      end
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
            array_pert << calculate_seuil(guw_unit_of_work, guw_type.guw_complexities.last, value_pert)
          end
        else
          guw_type.guw_complexities.each do |guw_c|
            array_pert << calculate_seuil(guw_unit_of_work, guw_c, value_pert)
          end
        end
      end
    end

    #gestion des valeurs intermédiaires
    @final_value = (guw_unit_of_work.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f.round(3))

    guw_unit_of_work.quantity = params["hidden_quantity"]["#{guw_unit_of_work.id}"].blank? ? 1 : params["hidden_quantity"]["#{guw_unit_of_work.id}"].to_f

    if guw_unit_of_work.changed?
      guw_unit_of_work.save
    end

    tmp_hash_res = Hash.new
    tmp_hash_ares = Hash.new

    @guw_model.guw_outputs.order("display_order ASC").each_with_index do |guw_output, index|

      @oc = Guw::GuwOutputComplexity.where( guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                            guw_output_id: guw_output.id,
                                            value: 1).first

      @oci = Guw::GuwOutputComplexityInitialization.where(guw_complexity_id: guw_unit_of_work.guw_complexity_id,
                                                          guw_output_id: guw_output.id).first

      coeffs = []
      percents = []
      selected_coefficient_values = Hash.new {|h,k| h[k] = [] }
      @guw_model.guw_coefficients.each do |guw_coefficient|
        if guw_coefficient.coefficient_type == "Pourcentage"

          ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_unit_of_work,
                                                            guw_coefficient_id: guw_coefficient.id).first_or_create(guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                    guw_coefficient_id: guw_coefficient.id)

          guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
            cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                             guw_coefficient_element_id: guw_coefficient_element.id,
                                                             guw_complexity_id: guw_unit_of_work.guw_complexity_id).first
            unless cce.nil?
              unless cce.value.blank?
                pc = params["hidden_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
                percents << (pc.to_f / 100)
                percents << cce.value.to_f

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << (v / 100)

              else
                percents << 1
              end
            end
          end

          ceuw.percent = params["hidden_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
          ceuw.guw_coefficient_id = guw_coefficient.id
          ceuw.guw_unit_of_work_id = guw_unit_of_work.id
          ceuw.module_project_id = current_module_project.id

          if ceuw.changed?
            ceuw.save
          end

        elsif guw_coefficient.coefficient_type == "Coefficient"

        ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_unit_of_work,
                                                          guw_coefficient_id: guw_coefficient.id).first_or_create(guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                  guw_coefficient_id: guw_coefficient.id)

          guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
            cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                             guw_coefficient_element_id: guw_coefficient_element.id,
                                                             guw_complexity_id: guw_unit_of_work.guw_complexity_id).first
            unless cce.nil?
              unless cce.value.blank?
                pc = params["hidden_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
                coeffs << pc.to_f

                v = (cce.guw_coefficient_element.value.nil? ? 1 : cce.guw_coefficient_element.value).to_f
                selected_coefficient_values["#{guw_output.id}"] << v

              else
                coeffs << 1
              end
            end
          end

          ceuw.percent = params["hidden_coefficient_percent"]["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_f
          ceuw.guw_coefficient_id = guw_coefficient.id
          ceuw.guw_unit_of_work_id = guw_unit_of_work.id
          ceuw.module_project_id = current_module_project.id

          if ceuw.changed?
            ceuw.save
          end

        else
          unless params['hidden_coefficient_element'].nil?
            unless params['hidden_coefficient_element']["#{guw_unit_of_work.id}"].nil?
              ce = Guw::GuwCoefficientElement.find_by_id(params['hidden_coefficient_element']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)
            end
          end

          unless ce.nil?
            cce = Guw::GuwComplexityCoefficientElement.where(guw_output_id: guw_output.id,
                                                             guw_coefficient_element_id: ce.id,
                                                             guw_complexity_id: guw_unit_of_work.guw_complexity_id).first_or_create!

            ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_coefficient_id: guw_coefficient,
                                                              guw_unit_of_work_id: guw_unit_of_work).first_or_create(guw_coefficient_id: guw_coefficient,
                                                                                                                     guw_unit_of_work_id: guw_unit_of_work,
                                                                                                                     guw_coefficient_id: params['hidden_coefficient_element']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"].to_i)
          end

          unless ceuw.nil?

            v = params['hidden_coefficient_element']["#{guw_unit_of_work.id}"]["#{guw_coefficient.id}"]
            ceuw.guw_coefficient_element_id = v.nil? ? nil : v.to_i

            ceuw.guw_coefficient_id = guw_coefficient.id
            ceuw.guw_unit_of_work_id = guw_unit_of_work.id
            ceuw.module_project_id = current_module_project.id

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
        guw_unit_of_work.size = nil
        if params["hidden_ajusted_size"].nil?
          tmp_hash_res["#{guw_output.id}"] = nil
        else
          tmp_hash_res["#{guw_output.id}"] = params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"]["#{guw_output.id}"].to_f.round(3)
        end
        guw_unit_of_work.ajusted_size = tmp_hash_res
        guw_unit_of_work.size = tmp_hash_res
      else

        scv = selected_coefficient_values["#{guw_output.id}"].compact.inject(&:*)
        pct = percents.compact.inject(&:*)
        coef = coeffs.compact.inject(&:*)

        tmp_hash_res["#{guw_output.id}"] = (@oci.nil? ? 0 : @oci.init_value.to_f) + @final_value.to_f * (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) * (scv.nil? ? 1 : scv.to_f) * (pct.nil? ? 1 : pct.to_f) * (coef.nil? ? 1 : coef.to_f)

        guw_unit_of_work.ajusted_size = tmp_hash_res
        guw_unit_of_work.size = tmp_hash_res
      end
    end

    if guw_unit_of_work.changed?
      guw_unit_of_work.save
    end

    update_estimation_values
    update_view_widgets_and_project_fields

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def extract_from_url

    myTab = Array.new
    agent = Mechanize.new

    default_group = params[:group_name]

    if params[:from] == "Excel"
      if params[:kind] == "Données"
        ml_data(default_group)
      elsif params[:kind] == "Traitements"
        ml_trt(default_group)
      elsif params[:kind] == "Manuel"
        import_guw
      end
    elsif params[:from] == "Jira"
      (0..2).step(1).each do |i|
        url = "https://issues.apache.org/jira/issues/?filter=-4&startIndex=#{i}"
        agent.get(url)
        page = agent.page
        myTab << page.search("//@data-issue-key").map(&:value)
      end

      myTab.flatten.take(50).each do |val|
        nom = ""
        description = ""
        url = "https://issues.apache.org/jira/browse/#{val}"
        agent = Mechanize.new
        agent.get(url)
        agent.page.search("#summary-val").each do |item|
          nom << item.text
        end

        agent.page.search(".user-content-block p").each do |item|
          description << item.text
        end

        text = "#{nom} #{description}"
        results = get_trt(text, default_group, "Jira")

        results.each do |uo|
          @guw_model.guw_attributes.all.each do |gac|
            guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: uo.guw_type_id,
                                                      guw_unit_of_work_id: uo.id,
                                                      guw_attribute_id: gac.id).first_or_create
            guowa.save
          end
        end

      end

    else params[:from] = "Redmine"
      (0..2).each do |i|
        url = "#{params[:url]}?page=#{i}"
        agent.get(url) do |page|
          myTab = page.search("//tr[@id]").map{|i| i.attributes["id"].value.to_s.gsub("issue-","") }
        end

        myTab.flatten.take(7).each do |val|
          agent = Mechanize.new
          url = "http://forge.estimancy.com/issues/#{val}"
          agent.get(url) do |page|
            nom = page.search(".subject h3").text
            description = page.search(".description").text

            text = description

            if params[:kind] == "Données"
              results = get_data(text, default_group, "Redmine")
            elsif params[:kind] == "Traitements"
              results = get_trt(text, default_group, "Redmine")
            end

            @guw_model_guw_attributes = @guw_model.guw_attributes.all

            results.each do |uo|
              @guw_model_guw_attributes.each do |gac|
                guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: uo.guw_type_id,
                                                          guw_unit_of_work_id: uo.id,
                                                          guw_attribute_id: gac.id).first_or_create
                guowa.save
              end
            end
          end
        end
      end
    end

    redirect_to :back
  end

  def ml_trt(default_group)
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    results =[]
    if params[:file].present?
      if (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")

        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]
        tab = worksheet.extract_data
        tab.each_with_index do |row, index|

          if index > 0
            unless row.nil?
              unless row[5].blank?

                results = get_trt(row[5], default_group, "Excel")

                results.each do |guw_uow|
                  @guw_model.guw_attributes.each_with_index do |gac, jj|
                    tmp_val = row[15 + @guw_model.orders.size + jj]
                    unless tmp_val.nil?
                      val = (tmp_val == "N/A" || tmp_val.to_i < 0) ? nil : row[15 + @guw_model.orders.size + jj]

                      if gac.name == tab[0][15 + @guw_model.orders.size + jj]
                        unless @guw_type.nil?
                          guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: guw_uow.guw_type_id,
                                                                    guw_unit_of_work_id: guw_uow.id,
                                                                    guw_attribute_id: gac.id).first_or_create
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
      redirect_to :back and return
    end
  end

  private def get_data(user_story, default_group, data_type)

    results = []

    @guw_model = current_module_project.guw_model
    txt = user_story

    if data_type == "Excel"
      url = @guw_model.excel_ml_server
    elsif data_type == "Redmine"
      url = @guw_model.redmine_ml_server
    elsif data_type == "Jira"
      url = @guw_model.jira_ml_server
    end

    @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id, is_default: true).first
    if @guw_type.nil?
      @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id).last
    end

    if default_group == ""
      @guw_group = Guw::GuwUnitOfWorkGroup.where(name: 'Données',
                                                 module_project_id: current_module_project.id,
                                                 pbs_project_element_id: current_component.id).first_or_create
    else
      @guw_group = Guw::GuwUnitOfWorkGroup.where(name: default_group,
                                                 module_project_id: current_module_project.id,
                                                 pbs_project_element_id: current_component.id).first_or_create
    end

    unless txt.blank?

      @http = Curl.post("http://#{url}/estimate_data", { txt: txt })

      JSON.parse(@http.body_str).each do |output|

        data_array = output.scan(/<data=(.*?)>/)
        attr_array = output.scan(/<attribut=(.*?)>/)

        data_array.each do |d|
          t = d.first
          unless t.nil?
            v = d.first.gsub(/#[ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøôÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ]+/, '').gsub(' et', '').gsub(',', '').gsub('/', '').gsub('/\"', '').gsub('/\/', '').delete('\\"')
          end
          guw_uow = Guw::GuwUnitOfWork.where(name: v.singularize,
                                             guw_model_id: @guw_model.id).first_or_create(
                                                                      comments: attr_array.uniq.join(", "),
                                                                      guw_unit_of_work_group_id: @guw_group.id,
                                                                      module_project_id: current_module_project.id,
                                                                      pbs_project_element_id: current_component.id,
                                                                      display_order: nil,
                                                                      tracking: nil,
                                                                      quantity: 1,
                                                                      selected: true,
                                                                      guw_type_id: @guw_type.nil? ? nil : @guw_type.id)

          results << guw_uow

          @guw_model.guw_attributes.where(name: ["DET", "RET", "FTR"]).all.each do |gac|

            guowa = Guw::GuwUnitOfWorkAttribute.create(guw_type_id: @guw_type.id,
                                                       guw_unit_of_work_id: guw_uow.id,
                                                       guw_attribute_id: gac.id)
            if gac.name == "DET"
              guowa.low = attr_array.size
              guowa.most_likely = attr_array.size
              guowa.high = attr_array.size
              guowa.comments = attr_array.join(", ")
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

    return results
  end

  private def get_trt(user_story, default_group, trt_type)
    @guw_model = current_module_project.guw_model
    @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id).last

    if trt_type == "Excel"
      url = @guw_model.excel_ml_server
    elsif trt_type == "Redmine"
      url = @guw_model.redmine_ml_server
    elsif trt_type == "Jira"
      url = @guw_model.jira_ml_server
    end

    @http = Curl.post("http://#{url}/estimate_trt", { us: user_story } )

    complete_str = user_story.to_s
    reduce_str = user_story.to_s.truncate(60)

    results = []

    JSON.parse(@http.body_str).each do |output|

      if default_group == ""
        @guw_group = Guw::GuwUnitOfWorkGroup.where(name: 'Traitements',
                                                   module_project_id: current_module_project.id,
                                                   pbs_project_element_id: current_component.id).first_or_create
      else
        @guw_group = Guw::GuwUnitOfWorkGroup.where(name: default_group,
                                                   module_project_id: current_module_project.id,
                                                   pbs_project_element_id: current_component.id).first_or_create
      end

      unless output.blank? || output == "NULL"
        @guw_type = Guw::GuwType.where(name: output, guw_model_id: @guw_model.id).first
      else
        @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id, is_default: true).first
        if @guw_type.nil?
          @guw_type = Guw::GuwType.where(guw_model_id: @guw_model.id).last
        end
      end

      results << Guw::GuwUnitOfWork.create( name: reduce_str,
                                            comments: complete_str,
                                            guw_unit_of_work_group_id: @guw_group.id,
                                            module_project_id: current_module_project.id,
                                            pbs_project_element_id: current_component.id,
                                            guw_model_id: @guw_model.id,
                                            display_order: nil,
                                            tracking: complete_str,
                                            quantity: 1,
                                            selected: true,
                                            guw_type_id: @guw_type.nil? ? nil : @guw_type.id)

    end

    return results
  end

  def ml_data(default_group)
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    txt = ""

    if params[:file].present?
      if (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")

        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]

        tab = worksheet.extract_data
        tab.each_with_index do |row, index|
          begin
            txt << row[5]
          rescue
            #
          end
        end

        get_data(txt, default_group, "Excel")
      end
    end
    redirect_to :back
  end

  def deported
    @guw_unit_of_work = Guw::GuwUnitOfWork.where(id: params[:guw_unit_of_work_id]).first
    @guw_type = @guw_unit_of_work.guw_type
    @guw_model = current_module_project.guw_model
  end

  private def import_guw

    @guw_model = current_module_project.guw_model
    @component = current_component
    @project = current_module_project.project
    @guw_attributes = @guw_model.guw_attributes
    @guw_coefficients = @guw_model.guw_coefficients
    @guw_outputs = @guw_model.guw_outputs

    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      worksheet = workbook[0]
      tab = worksheet.extract_data

      tab.each_with_index do |row, index|
        unless row.nil?
          unless row[4].nil?
            if index > 0

              guw_uow_group = Guw::GuwUnitOfWorkGroup.where(name: row[2].nil? ? '-' : row[2],
                                                            module_project_id: current_module_project.id,
                                                            pbs_project_element_id: @component.id).first_or_create

              tmp_hash_res = Hash.new
              tmp_hash_ares  = Hash.new

              guw_uow = Guw::GuwUnitOfWork.create(selected: row[3].to_i == 1,
                                                  name: row[4],
                                                  comments: row[5],
                                                  guw_unit_of_work_group_id: guw_uow_group.id,
                                                  module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id,
                                                  tracking: row[12],
                                                  quantity: row[11].nil? ? 1 : row[11],
                                                  size: row[14].nil? ? nil : row[14],
                                                  ajusted_size: row[15].nil? ? nil : row[15],
                                                  intermediate_percent: row[16].nil? ? nil : row[16],
                                                  intermediate_weight: row[16].nil? ? nil : row[16])

              guw_uow.save(validate: false)

              @guw_attributes.each_with_index do |gac, ii|

                @guw_type = Guw::GuwType.where(name: row[6],
                                               guw_model_id: @guw_model.id).first

                @guw_attributes.size.times do |jj|

                  ind = 18 + @guw_outputs.size + @guw_coefficients.size + jj

                  tmp_val = row[ind]

                  unless tmp_val.nil?

                    val = (tmp_val == "N/A" || tmp_val.to_i < 0) ? nil : row[ind].to_i

                    if gac.name == tab[0][ind]
                      unless @guw_type.nil?
                        guowa = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
                                                                  guw_unit_of_work_id: guw_uow.id,
                                                                  guw_attribute_id: gac.id).first_or_create
                        guowa.low = val
                        guowa.most_likely = val
                        guowa.high = val
                        guowa.save
                      end
                    end
                  end
                end
              end

              @lows = Array.new
              @mls = Array.new
              @highs = Array.new
              array_pert = Array.new

              guw_uow.off_line = false
              guw_uow.off_line_uo = false

              guw_uow.guw_unit_of_work_attributes.each do |guowa|
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

              guw_uow.guw_type_id ||= (@guw_type.nil? ? nil : @guw_type.id)

              begin
                unless params["guw_complexity_#{guw_uow.id}"].nil?
                  guw_complexity_id = params["guw_complexity_#{guw_uow.id}"].to_i
                  guw_uow.guw_complexity_id = guw_complexity_id
                  guw_uow.guw_original_complexity_id = guw_complexity_id
                else
                  unless row[13].blank?
                    unless @guw_type.nil?
                      guw_complexity = Guw::GuwComplexity.where(guw_type_id: @guw_type.id,
                                                              name: row[13]).first
                    end
                  end

                  guw_uow.guw_complexity_id = guw_complexity.nil? ? nil : guw_complexity.id
                end
              rescue
              end

              if guw_uow.changed?
                guw_uow.save
              end

              unless @guw_type.nil?
                if (@guw_type.allow_complexity == true && @guw_type.allow_criteria == false)

                  tcplx = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity_id,
                                                             organization_technology_id: guw_uow.organization_technology_id).first

                  if guw_uow.guw_complexity.nil?
                    array_pert << 0
                  else
                    array_pert << (guw_uow.guw_complexity.weight.nil? ? 1 : guw_uow.guw_complexity.weight.to_f)
                  end
                  if guw_uow.changed?
                    guw_uow.save
                  end
                else
                  if guw_uow.result_low.nil? or guw_uow.result_most_likely.nil? or guw_uow.result_high.nil?
                    guw_uow.off_line_uo = nil
                  else
                    #Save if uo is simple/ml/high
                    value_pert = compute_probable_value(guw_uow.result_low, guw_uow.result_most_likely, guw_uow.result_high)[:value]
                    if (value_pert < @guw_type.guw_complexities.map(&:bottom_range).min.to_f)
                      guw_uow.off_line_uo = true
                    elsif (value_pert >= @guw_type.guw_complexities.map(&:top_range).max.to_f)
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
                      @guw_type.guw_complexities.each do |guw_c|
                        array_pert << calculate_seuil(guw_uow, guw_c, value_pert)
                      end
                    end
                  end
                end
              end

              #gestion des valeurs intermédiaires
              @final_value = (guw_uow.off_line? ? nil : array_pert.empty? ? nil : array_pert.sum.to_f.round(3))

              guw_uow.quantity = 1

              if guw_uow.changed?
                guw_uow.save
              end

              guw_uow.ajusted_size = nil
              guw_uow.size = nil

              if guw_uow.changed?
                guw_uow.save
              end

              update_estimation_values
              update_view_widgets_and_project_fields

              @guw_model.orders.sort_by { |k, v| v.to_f }.each_with_index do |i, j|

                guw_coefficient = Guw::GuwCoefficient.where(name: i[0],
                                                            guw_model_id: @guw_model.id).first

                if guw_coefficient.class == Guw::GuwCoefficient

                  (16..60).to_a.each do |k|
                    if guw_coefficient.name == tab[0][k]

                      ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guw_uow.id,
                                                                        guw_coefficient_id: guw_coefficient.id).first_or_create


                      if row[k].blank?
                        ce = guw_coefficient.guw_coefficient_elements.where(default: true).first
                      else
                        ce = guw_coefficient.guw_coefficient_elements.where(name: row[k]).first
                      end

                      unless ce.nil?
                        ceuw.guw_coefficient_element_id = ce.id
                      else
                        ceuw.percent = row[k].to_f
                      end

                      unless guw_uow.changed?
                        ceuw.save
                      end
                    end
                  end
                elsif Guw::GuwOutput.where(name: i[0]).first.class == Guw::GuwOutput

                  guw_output = Guw::GuwOutput.where(name: i[0],
                                                    guw_model_id: @guw_model.id).first

                  unless guw_output.nil?
                    (16..60).to_a.each do |k|
                      if guw_output.name == tab[0][k]
                        # tmp_hash_res["#{guw_output.id}"] = row[k]
                        tmp_hash_ares["#{guw_output.id}"] = row[k]
                      end
                    end
                  end
                end
              end

              guw_uow.size = tmp_hash_res
              guw_uow.ajusted_size = tmp_hash_ares

              unless guw_uow.changed?
                guw_uow.save
              end

              @guw_attributes.all.each do |gac|
                unless @guw_type.nil?
                  finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: @guw_type.id,
                                                           guw_unit_of_work_id: guw_uow.id,
                                                           guw_attribute_id: gac.id).first_or_create
                end
              end

            end
          end
        end
      end
    end
  end

  private
  def update_estimation_values
    #we save the effort now in estimation values
    @guw_model = current_module_project.guw_model

    if @guw_model.config_type == "old"
      @module_project = current_module_project
      @module_project.guw_model_id = @guw_model.id
      @module_project.save

      retained_size = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                               pbs_project_element_id: current_component.id,
                                               guw_model_id: @guw_model.id,
                                               selected: true).map(&:ajusted_size).compact.sum

      theorical_size = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                                pbs_project_element_id: current_component.id,
                                                guw_model_id: @guw_model.id,
                                                selected: true).map(&:size).compact.sum

      effort = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                        pbs_project_element_id: current_component.id,
                                        guw_model_id: @guw_model.id,
                                        selected: true).map(&:effort).compact.sum

      cost = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                      pbs_project_element_id: current_component.id,
                                      guw_model_id: @guw_model.id,
                                      selected: true).map(&:cost).compact.sum

      number_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                             module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works}.flatten.size

      selected_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                               module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(selected: true)}.flatten.size

      offline_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                           module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(off_line: true)}.flatten.size

      flagged_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                           module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(flagged: true)}.flatten.size


      @module_project.pemodule.attribute_modules.each do |am|
        unless am.pe_attribute.nil?
          @evs = EstimationValue.where(:module_project_id => @module_project.id,
                                       :pe_attribute_id => am.pe_attribute.id).all
          @evs.each do |ev|
            tmp_prbl = Array.new
            ["low", "most_likely", "high"].each do |level|


              if am.pe_attribute.alias == "retained_size"
                ev.send("string_data_#{level}")[current_component.id] = retained_size
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "effort"
                ev.send("string_data_#{level}")[current_component.id] = effort.to_f * (@guw_model.hour_coefficient_conversion.nil? ? 1 : @guw_model.hour_coefficient_conversion)
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "theorical_size"
                ev.send("string_data_#{level}")[current_component.id] = theorical_size
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              end

              guw = Guw::Guw.new(theorical_size, retained_size, params["complexity_#{level}"], @project)

              if am.pe_attribute.alias == "cost"
                ev.send("string_data_#{level}")[@component.id] = cost
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "introduced_defects"
                ev.send("string_data_#{level}")[@component.id] = guw.get_defects(retained_size, current_component, current_module_project)
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "number_of_unit_of_work"
                ev.send("string_data_#{level}")[@component.id] = number_of_unit_of_work
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "offline_unit_of_work"
                ev.send("string_data_#{level}")[@component.id] = offline_unit_of_work
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "flagged_unit_of_work"
                ev.send("string_data_#{level}")[@component.id] = flagged_unit_of_work
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              elsif am.pe_attribute.alias == "selected_of_unit_of_work"
                ev.send("string_data_#{level}")[@component.id] = selected_of_unit_of_work
                tmp_prbl << ev.send("string_data_#{level}")[@component.id]
              end
              ev.update_attribute(:"string_data_#{level}", ev.send("string_data_#{level}"))
            end

            if ev.in_out == "output"

              h = Hash.new
              h = {
                  :"string_data_low" => { @component.id => tmp_prbl[0] },
                  :"string_data_most_likely" => { @component.id => tmp_prbl[1].to_f },
                  :"string_data_high" => { @component.id => tmp_prbl[2].to_f },
                  :"string_data_probable" => { @component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) }
              }

              ev.update_attributes(h)
            end
          end
        end
      end
    else
      @module_project = current_module_project
      @module_project.guw_model_id = @guw_model.id
      @module_project.save
      @guw_outputs = @guw_model.guw_outputs.order("display_order ASC")

      number_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                             module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works}.flatten.size

      selected_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                               module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(selected: true)}.flatten.size

      offline_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                           module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(off_line: true)}.flatten.size

      flagged_unit_of_work = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id,
                                                           module_project_id: current_module_project.id).all.map{|i| i.guw_unit_of_works.where(flagged: true)}.flatten.size


      @module_project.pemodule.attribute_modules.each do |am|

        unless am.pe_attribute.nil?

          @evs = EstimationValue.where(:module_project_id => @module_project.id,
                                       :pe_attribute_id => am.pe_attribute.id).all
          @evs.each do |ev|
            @guw_outputs.each do |guw_output|

              value = Guw::GuwUnitOfWork.where(module_project_id: @module_project.id,
                                               pbs_project_element_id: current_component.id,
                                               guw_model_id: @guw_model.id,
                                               selected: true).map{ |i|
                i.ajusted_size.nil? ? nil :
                    (i.ajusted_size.is_a?(Numeric) ?
                        i.ajusted_size.to_f :
                        i.ajusted_size["#{guw_output.id}"].to_f)}.compact.sum

              tmp_prbl = Array.new
              ["low", "most_likely", "high"].each do |level|

                if am.pe_attribute.alias == guw_output.name.underscore.gsub(" ", "_")
                  ev.send("string_data_#{level}")[current_component.id] = value.to_f.round(user_number_precision)
                  if guw_output.output_type == "Effort"
                    tmp_prbl << ev.send("string_data_#{level}")[@component.id] * (guw_output.standard_coefficient.nil? ? 1 : guw_output.standard_coefficient.to_f )
                  else
                    tmp_prbl << ev.send("string_data_#{level}")[@component.id]
                  end
                end

                if am.pe_attribute.alias == "number_of_unit_of_work"
                  ev.send("string_data_#{level}")[@component.id] = number_of_unit_of_work
                  tmp_prbl << ev.send("string_data_#{level}")[@component.id]
                elsif am.pe_attribute.alias == "offline_unit_of_work"
                  ev.send("string_data_#{level}")[@component.id] = offline_unit_of_work
                  tmp_prbl << ev.send("string_data_#{level}")[@component.id]
                elsif am.pe_attribute.alias == "flagged_unit_of_work"
                  ev.send("string_data_#{level}")[@component.id] = flagged_unit_of_work
                  tmp_prbl << ev.send("string_data_#{level}")[@component.id]
                elsif am.pe_attribute.alias == "selected_of_unit_of_work"
                  ev.send("string_data_#{level}")[@component.id] = selected_of_unit_of_work
                  tmp_prbl << ev.send("string_data_#{level}")[@component.id]
                end

                ev.send(:"string_data_#{level}=", ev.send("string_data_#{level}"))
              end

              if ev.in_out == "output" && am.pe_attribute.alias == guw_output.name.underscore.gsub(" ", "_")
                h = Hash.new
                h = {
                    :"string_data_low" => { @component.id => tmp_prbl[0] },
                    :"string_data_most_likely" => { @component.id => tmp_prbl[1].to_f },
                    :"string_data_high" => { @component.id => tmp_prbl[2].to_f },
                    :"string_data_probable" => { @component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) }
                }
                ev.update_attributes(h)
              end
            end
          end
        end
      end
    end

    @module_project.nexts.each do |n|
      ModuleProject::common_attributes(@module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(module_project_id: n.id,
                                pe_attribute_id: ca.id).first.update_attribute(:"string_data_#{level}", { @component.id => nil } )
          EstimationValue.where(module_project_id: n.id, pe_attribute_id: ca.id).first.update_attribute(:"string_data_probable", { @component.id => nil } )
        end
      end
    end

  end

  def update_view_widgets_and_project_fields
    @module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, @module_project.project, current_component)
    end
  end

  def reorder(group)
    group.guw_unit_of_works.order("display_order asc, updated_at asc").each_with_index do |u, i|
      u.display_order = i
      if u.changed?
        u.save
      end
    end
  end
end


