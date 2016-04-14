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
    @guw_type = Guw::GuwType.find(params[:guw_unit_of_work][:guw_type_id])
    @guw_model = Guw::GuwModel.find(params[:guw_unit_of_work][:guw_model_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.new(params[:guw_unit_of_work])

    @guw_unit_of_work.guw_model_id = @guw_model.id
    @guw_unit_of_work.module_project_id = current_module_project.id
    @guw_unit_of_work.pbs_project_element_id = current_component.id
    @guw_unit_of_work.selected = true

    if params[:position].blank?
      @guw_unit_of_work.display_order = @guw_unit_of_work.guw_unit_of_work_group.guw_unit_of_works.size.to_i + 1
    else
      @guw_unit_of_work.display_order = params[:position].to_i - 1
    end

    @guw_unit_of_work.save

    reorder @guw_unit_of_work.guw_unit_of_work_group

    @guw_unit_of_work.save

    @guw_model.guw_attributes.all.each do |gac|
      Guw::GuwUnitOfWorkAttribute.create(
          guw_type_id: @guw_type.id,
          guw_unit_of_work_id: @guw_unit_of_work.id,
          guw_attribute_id: gac.id)
    end

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}")
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    if @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
      redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_work.guw_unit_of_work_group.id}") and return
    else
      render :edit
    end
  end

  def destroy
    @guw_model = current_module_project.guw_model
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    group = @guw_unit_of_work.guw_unit_of_work_group
    @guw_unit_of_work.delete
    reorder group

    update_estimation_values
    update_view_widgets_and_project_fields

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{group.id}")
  end

  def up
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order - 2
    @guw_unit_of_work.save
    reorder @guw_unit_of_work.guw_unit_of_work_group

    redirect_to :back
  end

  def down
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.display_order = @guw_unit_of_work.display_order + 1
    @guw_unit_of_work.save
    reorder @guw_unit_of_work.guw_unit_of_work_group

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

    if @guw_model.allow_technology == true
      tcplx_value = (tcplx.nil? ? 1 : (tcplx.coefficient.nil? ? 1 : tcplx.coefficient.to_f))
    else
      tcplx_value = 1
    end

    guw_unit_of_work.size = final_value.to_f *
        (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) *
        (size_array_value.inject(&:*).nil? ? 1 : size_array_value.inject(&:*)) *
        tcplx_value

    if guw_unit_of_work.guw_type.allow_retained == false
      guw_unit_of_work.size == guw_unit_of_work.ajusted_size
      guw_unit_of_work.save
    end

    if params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"].blank?
      guw_unit_of_work.ajusted_size = final_value
    elsif params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"] != array_pert.sum
      guw_unit_of_work.ajusted_size = params["hidden_ajusted_size"]["#{guw_unit_of_work.id}"].to_f.round(3)
    end

    guw_unit_of_work.save

    if guw_unit_of_work.guw_type.allow_retained == false
      guw_unit_of_work.ajusted_size = guw_unit_of_work.size
    end

    guw_unit_of_work.save

    if guw_unit_of_work.off_line == true || guw_unit_of_work.off_line_uo == true
      guw_unit_of_work.flagged = true
    elsif guw_unit_of_work.size != guw_unit_of_work.ajusted_size
      guw_unit_of_work.flagged = true
    else
      guw_unit_of_work.flagged = false
    end

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

    @new_guw_unit_of_work = @guw_unit_of_work.dup
    @new_guw_unit_of_work.save

    @guw_unit_of_work.guw_unit_of_work_attributes.each do |guowa|
      nguowa = guowa.dup
      nguowa.guw_unit_of_work_id = @new_guw_unit_of_work.id
      nguowa.save
    end

    reorder @new_guw_unit_of_work.guw_unit_of_work_group

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
      end

      if guw_unit_of_work.guw_complexity.nil?
        final_value = 0
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

      if @guw_model.allow_technology == true
        tcplx_value = (tcplx.nil? ? 1 : (tcplx.coefficient.nil? ? 1 : tcplx.coefficient.to_f))
      else
        tcplx_value = 1
      end

      guw_unit_of_work.size = final_value.to_f *
          (guw_unit_of_work.quantity.nil? ? 1 : guw_unit_of_work.quantity.to_f) *
          (size_array_value.inject(&:*).nil? ? 1 : size_array_value.inject(&:*)) *
          tcplx_value

      if guw_unit_of_work.guw_type.allow_retained == false
        guw_unit_of_work.ajusted_size = guw_unit_of_work.size.round(3)
      else
        if params["ajusted_size"]["#{guw_unit_of_work.id}"].blank?
          guw_unit_of_work.ajusted_size = guw_unit_of_work.size.round(3)
        else
          guw_unit_of_work.ajusted_size = params["ajusted_size"]["#{guw_unit_of_work.id}"].to_f.round(3)
        end
      end

      guw_unit_of_work.save

      guw_unit_of_work.effort = guw_unit_of_work.ajusted_size *
          (effort_array_value.inject(&:*).nil? ? 1 : effort_array_value.inject(&:*))

      guw_unit_of_work.cost = guw_unit_of_work.ajusted_size *
          (cost_array_value.inject(&:*).nil? ? 1 : cost_array_value.inject(&:*))

      if guw_unit_of_work.off_line == true || guw_unit_of_work.off_line_uo == true
        guw_unit_of_work.flagged = true
      elsif guw_unit_of_work.size.round(3) != guw_unit_of_work.ajusted_size.round(3)
        guw_unit_of_work.flagged = true
      else
        guw_unit_of_work.flagged = false
      end

      guw_unit_of_work.save
    end

    update_estimation_values
    update_view_widgets_and_project_fields

    redirect_to main_app.dashboard_path(@project, anchor: "accordion#{@guw_unit_of_works.last.guw_unit_of_work_group.id}")
  end

  def change_cotation
    @guw_model = current_module_project.guw_model
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])

    technology = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq.first
    @guw_unit_of_work.organization_technology_id = technology.nil? ? nil : technology.id

    @guw_unit_of_work.guw_type_id = @guw_type.id
    @guw_unit_of_work.effort = nil
    @guw_unit_of_work.guw_complexity_id = nil
    @guw_unit_of_work.save
  end

  def change_work_unit
    @guw_model = current_module_project.guw_model
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:guw_work_unit_id])
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
    @guw_unit_of_work.guw_work_unit_id = @guw_work_unit.id
    @guw_unit_of_work.save
  end

  # def change_complexity
  #   @guw_model = current_module_project.guw_model
  #   @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  #   @guw_unit_of_work.save
  # end
  #
  # def change_technology
  #   @guw_model = current_module_project.guw_model
  #   @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:guw_unit_of_work_id])
  #   @organization_technology = OrganizationTechnology.find(params[:guw_technology_id])
  #   @guw_unit_of_work.organization_technology_id = @organization_technology.id
  #   @guw_unit_of_work.effort = nil
  #   @guw_unit_of_work.guw_complexity_id = nil
  #   @guw_unit_of_work.save
  # end

  def change_technology_form
    @guw_model = current_module_project.guw_model
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @technologies = @guw_type.guw_complexity_technologies.select{|ct| ct.coefficient != nil }.map{|i| i.organization_technology }.uniq
  end

  def change_selected_state
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
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_size.to_f }.sum

    @group_size_theorical = Guw::GuwUnitOfWork.where(selected: true,
                                                     guw_unit_of_work_group_id: @group.id,
                                                     pbs_project_element_id: current_component.id,
                                                     module_project_id: current_module_project.id,
                                                     guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.size.to_f }.sum

    @group_number_of_unit_of_works = Guw::GuwUnitOfWork.where(guw_unit_of_work_group_id: @group.id,
                                                              pbs_project_element_id: current_component.id,
                                                              module_project_id: current_module_project.id,
                                                              guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum

    @group_selected_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                                guw_unit_of_work_group_id: @group.id,
                                                                pbs_project_element_id: current_component.id,
                                                                module_project_id: current_module_project.id,
                                                                guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum

    @group_flagged_unit_of_works = Guw::GuwUnitOfWork.where(flagged: true,
                                                            guw_unit_of_work_group_id: @group.id,
                                                            pbs_project_element_id: current_component.id,
                                                            module_project_id: current_module_project.id,
                                                            guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).compact.sum


    #For all unit of work
    @ajusted_size = Guw::GuwUnitOfWork.where(selected: true,
                                             pbs_project_element_id: current_component.id,
                                             module_project_id: current_module_project.id,
                                             guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.ajusted_size.to_f }.sum

    @theorical_size = Guw::GuwUnitOfWork.where(selected: true,
                                               pbs_project_element_id: current_component.id,
                                               module_project_id: current_module_project.id,
                                               guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.size.to_f }.sum

    @effort = Guw::GuwUnitOfWork.where(selected: true,
                                       pbs_project_element_id: current_component.id,
                                       module_project_id: current_module_project.id,
                                       guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.effort.to_f }.sum

    @cost = Guw::GuwUnitOfWork.where(selected: true,
                                     pbs_project_element_id: current_component.id,
                                     module_project_id: current_module_project.id,
                                     guw_model_id: @guw_unit_of_work.guw_model.id).map{|i| i.cost.to_f }.sum

    @number_of_unit_of_works = Guw::GuwUnitOfWork.where(pbs_project_element_id: current_component.id,
                                                        module_project_id: current_module_project.id,
                                                        guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum

    @selected_of_unit_of_works = Guw::GuwUnitOfWork.where(selected: true,
                                                          pbs_project_element_id: current_component.id,
                                                          module_project_id: current_module_project.id,
                                                          guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum

    @flagged_unit_of_works = Guw::GuwUnitOfWork.where(flagged: true,
                                                      pbs_project_element_id: current_component.id,
                                                      module_project_id: current_module_project.id,
                                                      guw_model_id: @guw_unit_of_work.guw_model.id).map(&:quantity).sum

    update_estimation_values
    update_view_widgets_and_project_fields
  end

  def calculate_guowa(guowa, guw_unit_of_work, guw_type)

    #Peut être factorisé  dans une boucle !
    if @guw_model.three_points_estimation == true
      #Estimation 3 points
      if params["low"]["#{guw_unit_of_work.id}"].nil?
        low = 0
        guw_unit_of_work.flagged = true
      else
        low = params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["low"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["most_likely"]["#{guw_unit_of_work.id}"].nil?
        most_likely = 0
        guw_unit_of_work.flagged = true
      else
        most_likely = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end

      if params["high"]["#{guw_unit_of_work.id}"].nil?
        high = 0
        guw_unit_of_work.flagged = true
      else
        high = params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["high"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
      end
    else
      begin
        #Estimation 1 point
        if params["most_likely"]["#{guw_unit_of_work.id}"].nil? or params["most_likely"]["#{guw_unit_of_work.id}"].values.sum.blank?
          low = most_likely = high = nil
          guw_unit_of_work.flagged = true
        else
          low = most_likely = high = params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].to_i unless params["most_likely"]["#{guw_unit_of_work.id}"]["#{guowa.id}"].blank?
        end
      rescue
        low = most_likely = high = nil
      end
    end

    @guw_attribute_complexities = Guw::GuwAttributeComplexity.where(guw_type_id: guw_type.id,
                                                                    guw_attribute_id: guowa.guw_attribute_id).all

    sum_range = guowa.guw_attribute.guw_attribute_complexities.where(guw_type_id: guw_type.id).map{|i| [i.bottom_range, i.top_range]}.flatten.compact

    unless sum_range.nil? || sum_range.blank? || sum_range == 0
      @guw_attribute_complexities.each do |guw_ac|
        unless low.nil?
          unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
            if (low >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (low < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
              unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
                if (low >= guw_ac.bottom_range) and (low < guw_ac.top_range)
                  if guw_ac.enable_value == true
                    @lows << guw_ac.value.to_f * low * guw_ac.guw_type_complexity.value.to_f
                  else
                    @lows << guw_ac.value.to_f * guw_ac.guw_type_complexity.value.to_f
                  end
                  guw_unit_of_work.missing_value = false
                end
              end
            else
              guw_unit_of_work.off_line = true
              guw_unit_of_work.flagged = true
            end
          end
        else
          guw_unit_of_work.missing_value = true
        end

        unless most_likely.nil?
          if (most_likely >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (most_likely < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
            unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
              if (most_likely >= guw_ac.bottom_range) and (most_likely < guw_ac.top_range)
                if guw_ac.enable_value == true
                  @mls << guw_ac.value.to_f * most_likely * guw_ac.guw_type_complexity.value.to_f
                else
                  @mls << guw_ac.value.to_f * guw_ac.guw_type_complexity.value.to_f
                end
                guw_unit_of_work.missing_value = false
              end
            end
          else
            guw_unit_of_work.off_line = true
            guw_unit_of_work.flagged = true
          end
        else
          guw_unit_of_work.missing_value = true
        end

        unless high.nil?
          if (high >= @guw_attribute_complexities.map(&:bottom_range).compact.min.to_i) and (high < @guw_attribute_complexities.map(&:top_range).compact.max.to_i)
            unless guw_ac.bottom_range.nil? || guw_ac.top_range.nil?
              if (high >= guw_ac.bottom_range) and (high < guw_ac.top_range)
                if guw_ac.enable_value == true
                  @highs << guw_ac.value.to_f * high * guw_ac.guw_type_complexity.value.to_f
                else
                  @highs << guw_ac.value.to_f * guw_ac.guw_type_complexity.value.to_f
                end
                guw_unit_of_work.missing_value = false
              end
            end
          else
            guw_unit_of_work.off_line = true
            guw_unit_of_work.flagged = true
          end
        else
          guw_unit_of_work.missing_value = true
        end
      end
    end

    guowa.low = low
    guowa.most_likely = most_likely
    guowa.high = high
    guowa.save
  end

  def calculate_seuil(guw_unit_of_work, guw_c, value_pert)

    if (value_pert >= guw_c.bottom_range) and (value_pert < guw_c.top_range)
      guw_unit_of_work.guw_complexity_id = guw_c.id
      guw_unit_of_work.guw_original_complexity_id = guw_c.id
    end

    guw_unit_of_work.save

    #Save effective size (or weight) of uo
    # guw_unit_of_work.guw_work_unit_id = guw_work_unit.id

    if (guw_unit_of_work.result_low.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_low.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_low = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        uo_weight_low = guw_unit_of_work.result_low.to_f * (guw_c.weight.nil? ? 1 : guw_c.weight.to_f)
      end
    end

    if (guw_unit_of_work.result_most_likely.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_most_likely.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_ml = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        uo_weight_ml = guw_unit_of_work.result_most_likely.to_f * (guw_c.weight.nil? ? 1 : guw_c.weight.to_f)
      end
    end

    if (guw_unit_of_work.result_high.to_f >= guw_c.bottom_range) and (guw_unit_of_work.result_high.to_i < guw_c.top_range)
      if guw_c.enable_value == false
        uo_weight_high = guw_c.weight.nil? ? 1 : guw_c.weight.to_f
      else
        uo_weight_high = guw_unit_of_work.result_high.to_f * (guw_c.weight.nil? ? 1 : guw_c.weight.to_f)
      end
    end

    return compute_probable_value(uo_weight_low.to_f, uo_weight_ml.to_f, uo_weight_high.to_f)[:value]
  end


  private
  def reorder(group)
    group.guw_unit_of_works.order("display_order asc, updated_at asc").each_with_index do |u, i|
      u.display_order = i
      u.save
    end
  end

  def update_estimation_values
    #we save the effort now in estimation values
    @guw_model = current_module_project.guw_model
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

    @module_project.nexts.each do |n|
      ModuleProject::common_attributes(@module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { @component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { @component.id => nil } )
        end
      end
    end
  end

  def update_view_widgets_and_project_fields
    @module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, @module_project.project, current_component)
    end
  end

  def calculate_attributes(guw_unit_of_work, guw_factor, guw_weighting, guw_work_unit, tcplx, final_value, guw_model)

  end

end
