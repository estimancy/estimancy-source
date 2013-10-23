#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

class WbsActivityRatioElementsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def edit
    authorize! :edit_wbs_activities, WbsActivity
    set_page_title 'Edit wbs-activity ratio'
    @wbs_activity_ratio_element = WbsActivityRatioElement.find(params[:id])
  end

  def new
    authorize! :edit_wbs_activities, WbsActivity
    set_page_title 'New wbs-activity ratio'
    @wbs_activity_ratio_element = WbsActivityRatioElement.new
  end

  def save_values
    authorize! :edit_wbs_activities, WbsActivity
    #set ratio values
    ratio_values = params[:ratio_values]
    ratio_values.each do |key, value|
      w = WbsActivityRatioElement.find(key)
      #if w.wbs_activity_ratio.is_All_Activity_Elements?
      unless value.blank?
        if value.to_f <=0 or value.to_f>100
          flash.now[:warning] = I18n.t(:warning_wbs_activity_ratio_elt_value_range)
        end
      end
      w.ratio_value = value
      w.save(:validate => false)
    end

    #Select ratio and elements
    wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

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
    @wbs_activity_ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements.all
    #@wbs_activity_ratio_elements = WbsActivityRatioElement.where(:wbs_activity_ratio_id => wbs_activity_ratio.id).all

    #sum total ratio_value
    @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)

    #we test total
    if @total != 100
      flash.now[:warning] = I18n.t (:warning_sum_ratio_different_100)
    else
      flash.now[:notice] = I18n.t (:notice_ratio_successful_saved)
    end

    respond_to do |format|
      format.js
    end
  end

end
