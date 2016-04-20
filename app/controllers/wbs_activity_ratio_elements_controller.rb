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

class WbsActivityRatioElementsController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  #before_filter :get_record_statuses

  def edit
    authorize! :manage_modules_instances, ModuleProject
    set_page_title I18n.t(:Edit_wbs_activity_ratio)
    @wbs_activity_ratio_element = WbsActivityRatioElement.find(params[:id])
  end

  def new
    authorize! :manage_modules_instances, ModuleProject
    set_page_title I18n.t(:new_wbs_activity_ratio)
    @wbs_activity_ratio_element = WbsActivityRatioElement.new
  end

  def save_values
    authorize! :manage_modules_instances, ModuleProject
    #set ratio values
    ratio_values = params[:ratio_values]
    ratio_values.each do |key, value|
      w = WbsActivityRatioElement.find(key)
      #if w.wbs_activity_ratio.is_All_Activity_Elements?
      unless value.blank?
        if value.to_f <= 0 or value.to_f > 100
          flash.now[:warning] = I18n.t(:warning_wbs_activity_ratio_elt_value_range)
        end
      end
      w.ratio_value = value
      w.save(:validate => false)
    end

    @wbs_activity = WbsActivity.find(params[:wbs_activity_id])

    #Select ratio and elements
    wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    wbs_activity_ratio.update_attribute(:use_base_100, params[:use_base_100])  ###wbs_activity_ratio.update_attribute(:use_base_100, params[:wbs_activity_ratio][:use_base_100])

    #set ratio reference (all to false then one to true)
    wbs_activity_ratio.wbs_activity_ratio_elements.each do |wbs_activity_ratio_element|
      wbs_activity_ratio_element.update_attribute('simple_reference',  false)
      wbs_activity_ratio_element.update_attribute('multiple_references',  false)
    end

    if params[:multiple_references]
        params[:multiple_references].each do |p|
          new_ref = WbsActivityRatioElement.find_by_id(p)
          new_ref.update_attribute('multiple_references', true)
        end
    end
    if params[:simple_reference]
      new_ref = WbsActivityRatioElement.find_by_id_and_wbs_activity_ratio_id(params[:simple_reference], params[:wbs_activity_ratio_id])
      new_ref.update_attribute('simple_reference', true)
    end

    #keep current ratio
    @selected_ratio = wbs_activity_ratio
    # @wbs_activity_ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements.all
    ###@wbs_activity_ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).order("abs(wbs_activity_elements.dotted_id) ASC").all
    ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
    @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

    #sum total ratio_value
    @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)

    #we test total
    if @total != 100
      flash.now[:warning] = I18n.t (:warning_sum_ratio_different_100)
    else
      flash.now[:notice] = I18n.t (:notice_ratio_successful_saved)
    end

    respond_to do |format|
      @redirect_url_apply_or_save_path = redirect_apply(main_app.edit_organization_wbs_activity_path(@wbs_activity.organization_id, @wbs_activity.id, anchor: "tabs-4"), nil, main_app.organization_module_estimation_path(@wbs_activity.organization_id, anchor: "activite"))

      format.js { }
    end
  end


  # Profiles per activity(phase)
  def save_wbs_activity_ratio_per_profile
    authorize! :manage_modules_instances, ModuleProject

    @wbs_activity = WbsActivity.find(params[:wbs_activity_id])
    @wbs_activity_organization = @wbs_activity.organization
    @wbs_organization_profiles = @wbs_activity.organization_profiles #@wbs_activity_organization.organization_profiles  #now only the selected profiles from the WBS'organization profiles list will be used

    #Select ratio and elements
    wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    ###@wbs_activity_ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements
    ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
    @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

    @wbs_activity_ratio_elements.each do |activity|
      @wbs_organization_profiles.each do |profile|
        percentage = params["activity_profile_percentage"]["#{activity.id}"]["#{profile.id}"].empty? ? nil : params["activity_profile_percentage"]["#{activity.id}"]["#{profile.id}"].to_f
        activity_profile = WbsActivityRatioProfile.where(wbs_activity_ratio_element_id: activity.id, organization_profile_id: profile.id).first
        if percentage.nil?
          if activity_profile
            activity_profile.destroy
          end
        else
          activity_profile = activity_profile.nil? ? WbsActivityRatioProfile.create(wbs_activity_ratio_element_id: activity.id, organization_profile_id: profile.id) : activity_profile
          activity_profile.ratio_value = percentage
          activity_profile.save
        end
      end
    end

    #redirect_to edit_wbs_activity_path(@wbs_activity, :anchor => 'tabs-4')
    respond_to do |format|
      @redirect_url_apply_or_save_path = redirect_apply(main_app.edit_organization_wbs_activity_path(@wbs_activity.organization_id, @wbs_activity.id, anchor: "tabs-4"), nil, main_app.organization_module_estimation_path(@wbs_activity.organization_id, anchor: "activite"))

      format.js { }
    end
  end

end