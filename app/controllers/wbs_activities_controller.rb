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

require 'will_paginate/array'

class WbsActivitiesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  load_resource

  helper_method :wbs_record_statuses_collection
  helper_method :enable_update_in_local?

  before_filter :get_record_statuses

  def import
    authorize! :create_edit_wbs_activities, WbsActivity

    begin
      WbsActivityElement.import(params[:file], params[:separator])
      flash[:notice] = I18n.t (:notice_wbs_activity_element_import_successful)
    rescue Exception => e
      flash[:error] = I18n.t (:error_wbs_activity_failed_file_integrity)
      flash[:warning] = "#{e}"
    end
    redirect_to wbs_activities_path
  end

  def refresh_ratio_elements
    authorize! :edit_wbs_activities, WbsActivity

    @wbs_activity_ratio_elements = []
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    wbs_activity_elements_list = WbsActivityElement.where(:wbs_activity_id => @wbs_activity_ratio.wbs_activity.id).all
    @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity_elements_list)

    @wbs_activity_elements.each do |wbs|
      @wbs_activity_ratio_elements += wbs.wbs_activity_ratio_elements.where(:wbs_activity_ratio_id => params[:wbs_activity_ratio_id]).all
    end

    @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
  end

  def index
    #No authorize required since everyone can access the list of ABS
    set_page_title 'WBS activities'
    @wbs_activities = WbsActivity.all
  end

  def edit
    authorize! :edit_wbs_activities, WbsActivity

    set_page_title 'WBS activities'
    @wbs_activity = WbsActivity.find(params[:id])

    @wbs_activity_elements_list = @wbs_activity.wbs_activity_elements
    @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity_elements_list)
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios

    @wbs_activity_ratio_elements = []
    @total = 0
    if params[:Ratio]
      @wbs_activity_elements.each do |wbs|
        @wbs_activity_ratio_elements += wbs.wbs_activity_ratio_elements.where(:wbs_activity_ratio_id => params[:Ratio])
        @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
      end
    else
      unless @wbs_activity.wbs_activity_ratios.empty?
        @wbs_activity_elements.each do |wbs|
            @wbs_activity_ratio_elements += wbs.wbs_activity_ratio_elements.where(:wbs_activity_ratio_id => @wbs_activity.wbs_activity_ratios.first.id)
        end
        @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
      end
    end

  end

  def update
    authorize! :edit_wbs_activities, WbsActivity

    @wbs_activity = WbsActivity.find(params[:id])
    @wbs_activity_elements = @wbs_activity.wbs_activity_elements
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    unless @wbs_activity.wbs_activity_ratios.empty?
      @wbs_activity_ratio_elements = @wbs_activity.wbs_activity_ratios.first.wbs_activity_ratio_elements
    end

    if is_master_instance?
      if @wbs_activity.is_defined?
        @wbs_activity.owner_id = current_user.id
      end
    else
      if @wbs_activity.is_local_record?
        @wbs_activity.custom_value = 'Locally edited'
      end
    end

    if @wbs_activity.update_attributes(params[:wbs_activity])
      redirect_to redirect(wbs_activities_path), :notice => "#{I18n.t(:notice_wbs_activity_successful_updated)}"
    else
      render :edit
    end
  end

  def new
    authorize! :create_wbs_activities, WbsActivity

    set_page_title 'WBS activities'
    @wbs_activity = WbsActivity.new
  end

  def create
    authorize! :create_wbs_activities, WbsActivity

    @wbs_activity = WbsActivity.new(params[:wbs_activity])
    #If we are on local instance, Status is set to "Local"
    if is_master_instance?
      @wbs_activity.record_status = @proposed_status
      @wbs_activity.state = 'defined'
     else #so not on master
      @wbs_activity.record_status = @local_status
    end

    if @wbs_activity.save
      if @wbs_activity.is_local_record?
        @wbs_activity_element = WbsActivityElement.new(:name => @wbs_activity.name, :wbs_activity => @wbs_activity, :description => 'Root Element', :record_status => @local_status, :is_root => true)
      else
        @wbs_activity_element = WbsActivityElement.new(:name => @wbs_activity.name, :wbs_activity => @wbs_activity, :description => 'Root Element', :record_status => @proposed_status, :is_root => true)
      end

      @wbs_activity_element.save

      redirect_to redirect_apply(edit_wbs_activity_path(@wbs_activity)), :notice => "#{I18n.t(:notice_wbs_activity_successful_added)}"
    else
      render :new
    end
  end

  def destroy
    authorize! :manage, WbsActivity

    @wbs_activity = WbsActivity.find(params[:id])

    if is_master_instance?
      if @wbs_activity.is_defined?
        @wbs_activity.update_attribute(:record_status_id, @retired_status.id)
      else
        @wbs_activity.destroy
      end
    else
      if @wbs_activity.is_local_record? #|| @wbs_activity.is_retired?
        if @wbs_activity.defined?
          @wbs_activity.update_attribute(:state, 'retired')
        else
            @wbs_activity.destroy
        end
      else
        flash[:warning] = I18n.t(:warning_master_record_cant_be_delete)
        redirect_to redirect(wbs_activities_path)  and return
      end
    end

    flash[:notice] = I18n.t(:notice_wbs_activity_successful_deleted)
    redirect_to wbs_activities_path
  end


  #Method to duplicate WBS-Activity and associated WBS-Activity-Elements
  def duplicate_wbs_activity
    authorize! :create_wbs_activities, WbsActivity

    #Update ancestry depth caching
    WbsActivityElement.rebuild_depth_cache!

    begin
      old_wbs_activity = WbsActivity.find(params[:wbs_activity_id])
      new_wbs_activity = old_wbs_activity.amoeba_dup   #amoeba gem is configured in WbsActivity class model

      if is_master_instance?
        new_wbs_activity.record_status = @proposed_status
        new_wbs_activity.state = 'defined'
      else
        new_wbs_activity.record_status = @local_status
        new_wbs_activity.state = 'draft'
      end

      new_wbs_activity.uuid =  UUIDTools::UUID.random_create.to_s
      new_wbs_activity.transaction do
        if new_wbs_activity.save(:validate => false)
          old_wbs_activity.save  #Original WbsActivity copy number will be incremented to 1

          #we also have to save to wbs_activity_ratio
          old_wbs_activity.wbs_activity_ratios.each do |ratio|
            ratio.save
          end

          #get new WBS Ratio elements
          new_wbs_activity_ratio_elts = []
          new_wbs_activity.wbs_activity_ratios.each do |ratio|
            ratio.wbs_activity_ratio_elements.each do |ratio_elt|
              new_wbs_activity_ratio_elts << ratio_elt
            end
          end

          #Managing the component tree
          old_wbs_activity_elements = old_wbs_activity.wbs_activity_elements.order('ancestry_depth asc')
          old_wbs_activity_elements.each do |old_elt|
            new_elt = old_elt.amoeba_dup
            new_elt.wbs_activity_id = new_wbs_activity.id
            new_elt.save(:validate => false)

            unless new_elt.is_root?
              new_ancestor_ids_list = []
              new_elt.ancestor_ids.each do |ancestor_id|
                #ancestor_id = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id).id
                ancestor = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id)
                ancestor_id = ancestor.id
                new_ancestor_ids_list.push(ancestor_id)
              end
              new_elt.ancestry = new_ancestor_ids_list.join('/')

              corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
                ratio_elt.update_attribute("wbs_activity_element_id", new_elt.id)
              end

              new_elt.save(:validate => false)
            end
          end
        else
          flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
        end
      end

      redirect_to('/wbs_activities', :notice  =>  "#{I18n.t(:notice_wbs_activity_successful_duplicated)}") and return

    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"

    rescue
      flash[:error] = I18n.t(:error_wbs_activity_failed_duplicate) + "#{new_wbs_activity.errors.full_messages.to_sentence.to_s}"
      redirect_to '/wbs_activities'
    end
  end

  def wbs_record_statuses_collection
    #TODO authorize
    if @wbs_activity.new_record?
      if is_master_instance?
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Proposed').defined
      else
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Local').defined
      end
    else
      @wbs_record_status_collection = []
      if @wbs_activity.is_defined?
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Defined').defined
      else
        @wbs_record_status_collection = RecordStatus.where('name <> ?', 'Defined').defined
      end
    end
  end

  #This function will validate the WBS-Activity and all its elements
  def validate_change_with_children
    authorize! :manage, WbsActivity
    begin
      wbs_activity = WbsActivity.find(params[:id])
      wbs_activity.record_status = @defined_status
      wbs_activity_root_element = WbsActivityElement.where('wbs_activity_id = ? and is_root = ?', wbs_activity.id, true).first

      wbs_activity.transaction do
        if wbs_activity.save

          wbs_activity_root_element.transaction do
            subtree = wbs_activity_root_element.subtree #all descendants (direct and indirect children) and itself
            subtree_for_validation = subtree.is_ok_for_validation(@defined_status.id, @retired_status.id)
            subtree_for_validation.update_all(:record_status_id => @defined_status.id)
            #flash[:notice] =  "Wbs-Activity-Element and all its children were successfully validated."
          end

          #TODO : Validate also Ratio and Ratio_Element of each wbs_activity_element
          wbs_activity_ratios = wbs_activity.wbs_activity_ratios
          wbs_activity_ratios.each do |ratio|
            ratio.transaction do
              ratio.record_status = @defined_status
              if ratio.save
                wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements
                wbs_activity_ratio_elements.update_all(:record_status_id => @defined_status.id)
              end
            end
          end

          flash[:notice] =I18n.t(:notice_wbs_activity_successful_updated)
        else
          flash[:error] = I18n.t(:error_wbs_activity_failed_update)+ ' ' +wbs_activity_root_element.errors.full_messages.to_sentence+'.'
        end
      end

      redirect_to :back

    rescue ActiveRecord::StatementInvalid => error
      put "#{error.message}"
      flash[:error] = "#{error.message}"
      redirect_to :back and return
    rescue ActiveRecord::RecordInvalid => err
      flash[:error] = "#{err.message}"
      redirect_to :back
    end
  end

  #Function that enable/disable to update
  def enable_update_in_local?
    #TODO authorize
    if is_master_instance?
      true
    else
      if params[:action] == 'new'
        true
      elsif params[:action] == 'edit'
        @wbs_activity = WbsActivity.find(params[:id])
        #if @wbs_activity.is_local_record? && @wbs_activity.defined?
        if @wbs_activity.is_defined? || @wbs_activity.defined?
          false
        else
          true
        end
      end
    end
  end

end
