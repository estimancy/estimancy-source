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

class WbsActivityElementsController < ApplicationController
  include PeWbsHelper

  def new
    authorize! :manage_modules_instances, ModuleProject

    set_page_title I18n.t(:wbs_activity_elements)
    @wbs_activity_element = WbsActivityElement.new
    if params[:activity_id]
      @wbs_activity = WbsActivity.find(params[:activity_id])
      @organization = @wbs_activity.organization
      @potential_parents = @wbs_activity.wbs_activity_elements
    else
      @organization = @current_organization
    end

    @selected_parent ||= WbsActivityElement.find(params[:selected_parent_id])
  end

  def edit
    authorize! :manage_modules_instances, ModuleProject

    set_page_title I18n.t(:wbs_activity_elements)
    @wbs_activity_element = WbsActivityElement.find(params[:id])
    @organization = @wbs_activity_element.wbs_activity.organization

    if params[:activity_id]
      @wbs_activity = WbsActivity.find(params[:activity_id])
      if @wbs_activity_element.ancestry.nil?
        @potential_parents = []
      else
        @potential_parents = @wbs_activity.wbs_activity_elements
      end
    end

    @selected_parent = @wbs_activity_element.parent
  end

  def create
    authorize! :manage_modules_instances, ModuleProject
    @wbs_activity_element = WbsActivityElement.new(params[:wbs_activity_element])

    @selected_parent ||= WbsActivityElement.find(params[:wbs_activity_element][:parent_id])
    @wbs_activity = @wbs_activity_element.wbs_activity
    @potential_parents = @wbs_activity.wbs_activity_elements
    @organization = @wbs_activity.organization

    #update phase short name
    phases_short_name_number = @wbs_activity.phases_short_name_number+1
    @wbs_activity_element.phase_short_name = "P#{phases_short_name_number}"

    if @wbs_activity_element.save
      unless @wbs_activity_element.is_root?
        @wbs_activity.phases_short_name_number = phases_short_name_number
      end

      @wbs_activity.save

      @wbs_activity.wbs_activity_ratios.each do |wbs_activity_ratio|
        @wbs_activity_ratio_element = WbsActivityRatioElement.new(:ratio_value => nil,
                                                                  :wbs_activity_ratio_id => wbs_activity_ratio.id,
                                                                  :wbs_activity_element_id => @wbs_activity_element.id,
                                                                  :organization_id => @organization.id, wbs_activity_id: @wbs_activity.id)
                                                                  ###:dotted_id => @wbs_activity_element.dotted_id)
        @wbs_activity_ratio_element.save(:validate => false)
      end
      redirect_to edit_wbs_activity_path(@wbs_activity, :anchor => 'tabs-2'), notice: "#{I18n.t (:notice_wbs_activity_element_successful_created)}"
    else
      selected = WbsActivityElement.find(params[:wbs_activity_element][:parent_id]) #@selected = @wbs_activity_element.parent
      render action: 'new'
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject
    @wbs_activity_element = WbsActivityElement.find(params[:id])
    @organization = @wbs_activity_element.wbs_activity.organization

    @wbs_activity ||= WbsActivity.find_by_id(params[:wbs_activity_element][:wbs_activity_id])
    @potential_parents = @wbs_activity.wbs_activity_elements if @wbs_activity
    @selected_parent = @wbs_activity_element.parent

    if params[:wbs_activity_element][:wbs_activity_id]
      @wbs_activity = WbsActivity.find(params[:wbs_activity_element][:wbs_activity_id])
    end

    #update phase short name
    if @wbs_activity_element.phase_short_name.nil?
      phases_short_name_number = @wbs_activity.phases_short_name_number.to_i+1
      element_phases_short_name_number = "P#{phases_short_name_number}"
      @wbs_activity.phases_short_name_number = phases_short_name_number
    else
      element_phases_short_name_number = @wbs_activity_element.phase_short_name
    end

    if @wbs_activity_element.update_attributes(params[:wbs_activity_element].merge(phase_short_name: element_phases_short_name_number))
      @wbs_activity.save

      redirect_to edit_wbs_activity_path(@wbs_activity, :anchor => 'tabs-2'), :notice => "#{I18n.t (:notice_wbs_activity_element_successful_updated)}"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @wbs_activity_element = WbsActivityElement.find(params[:id])
    @wbs_activity_element.destroy

    redirect_to edit_wbs_activity_path(@wbs_activity_element.wbs_activity, :anchor => 'tabs-2')
  end

  def show
    #No authorize required since everyone can access the list of ABS
    @wbs_activity_element = WbsActivityElement.find(params[:id])
    @organization = @wbs_activity_element.organization

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @wbs_activity_element }
      format.js
    end
  end
end
