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

require 'will_paginate/array'

class WbsActivitiesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation
  include ModuleProjectsHelper
  load_resource

  #Import a new WBS-Activities from a CVS file
  def import

    begin
      WbsActivityElement.import(params[:file], params[:separator])
      flash[:notice] = I18n.t (:notice_wbs_activity_element_import_successful)
    rescue => e
      flash[:error] = I18n.t (:error_wbs_activity_failed_file_integrity)
      flash[:warning] = "#{e}"
    end

    redirect_to :back
  end

  def refresh_ratio_elements

    # @wbs_activity_ratio_elements = []
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    @wbs_activity = @wbs_activity_ratio.wbs_activity
    @wbs_activity_organization = @wbs_activity.organization
    @selected_ratio = @wbs_activity_ratio

    #now only the selected profiles from the WBS'organization profiles list will be used
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity.organization_profiles  #@wbs_activity_organization.organization_profiles

    @wbs_activity_elements_list = WbsActivityElement.where(:wbs_activity_id => @wbs_activity_ratio.wbs_activity.id).all
    ###@wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity_elements_list)
    ###@wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity_elements_list.arrange(order: :position))
    @wbs_activity_elements = @wbs_activity_elements_list.first.root.descendants.arrange(:order => :position)

    ###@wbs_activity_ratio_elements = @wbs_activity_ratio.wbs_activity_ratio_elements.all#.joins(:wbs_activity_element).order("abs(wbs_activity_elements.dotted_id) ASC").all
    ratio_elements = @wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
    @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

    @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
  end

  def index
    #No authorize required since everyone can access the list of ABS
    set_page_title I18n.t(:WBS_activities)

    #@wbs_activities = WbsActivity.all
    # Need to show only wbs-activities of current_user's organizations
    @wbs_activities = WbsActivity.where('organization_id IN (?)', current_user.organizations)
  end

  def edit

    #no authorize required since everyone can show this object

    @wbs_activity = WbsActivity.find(params[:id])
    @organization_id = @wbs_activity.organization_id
    @organization = @wbs_activity.organization

    set_page_title I18n.t(:edit_wbs_activity, value: @wbs_activity.name)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:wbs_modules) => main_app.organization_module_estimation_path(@organization, anchor: "activite"), @wbs_activity.name => ""

    @wbs_activity_elements_list = @wbs_activity.wbs_activity_elements
    #@wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity_elements_list)
    @wbs_activity_elements = @wbs_activity_elements_list.first.root.descendants.arrange(:order => :position)

    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    @selected_ratio = @wbs_activity_ratios.first

    unless @wbs_activity_ratios.empty?
      @wbs_activity_organization = @wbs_activity_ratios.first.wbs_activity.organization
    end
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity.organization_profiles #@wbs_activity_organization.organization_profiles

    @wbs_activity_ratio_elements = []
    unless @wbs_activity.wbs_activity_ratios.empty?
      ###@wbs_activity_ratio_elements = @wbs_activity.wbs_activity_ratios.first.wbs_activity_ratio_elements.all
      ratio_elements = @wbs_activity_ratios.first.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
      @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

      @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
    else
      @total = 0
    end
  end

  def update
    @wbs_activity = WbsActivity.find(params[:id])
    params[:wbs_activity][:organization_profile_ids] ||= []

    @wbs_activity_elements = @wbs_activity.wbs_activity_elements
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    @selected_ratio = @wbs_activity_ratios.first
    @wbs_activity_organization = @wbs_activity.organization || Organization.find(params[:wbs_activity][:organization_id])
    @wbs_organization_profiles =  @wbs_activity.organization_profiles # @wbs_activity_organization.organization_profiles
    @organization_id = @wbs_activity_organization.id

    unless @wbs_activity.wbs_activity_ratios.empty?
      ###@wbs_activity_ratio_elements = @wbs_activity.wbs_activity_ratios.first.wbs_activity_ratio_elements
      ratio_elements = @wbs_activity_ratios.first.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
      @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)
    end

    #check if wbs selected profiles has changed
    wbs_old_organization_profile_ids = @wbs_activity.organization_profile_ids
    wbs_new_organization_profile_ids_params = params['wbs_activity']['organization_profile_ids']
    wbs_new_organization_profile_ids = wbs_new_organization_profile_ids_params.map{ |val| val.to_i }
    unchecked_profiles  = wbs_old_organization_profile_ids - wbs_new_organization_profile_ids

    if @wbs_activity.update_attributes(params[:wbs_activity])

      #Lorsque la liste des profils actifs a changé, on envoie un message d'avertissement
      if wbs_old_organization_profile_ids != wbs_new_organization_profile_ids
        flash[:warning] = 'Vous avez modifié la liste des profils, vérifier la contribution des profils par phase (onglet "Elements des Ratios").'
      end

      #remove all wbs_activity_ratio_profiles
      unless unchecked_profiles.empty?
        activity_ratio_profiles_to_delete = @wbs_activity.wbs_activity_ratio_profiles.where(organization_profile_id: unchecked_profiles)
        activity_ratio_profiles_to_delete.each do |ratio_profile|
          ratio_profile.delete
        end
      end

      #redirect_to redirect(wbs_activities_path), :notice => "#{I18n.t(:notice_wbs_activity_successful_updated)}"
      ###redirect_to main_app.organization_module_estimation_path(@organization_id, anchor: "activite")
      redirect_to redirect_apply(main_app.edit_organization_wbs_activity_path(@organization_id, @wbs_activity.id), nil, main_app.organization_module_estimation_path(@organization_id, anchor: "activite"))
    else
      @organization = @wbs_activity_organization
      @wbs_activity_elements_list = @wbs_activity.wbs_activity_elements
      render :edit
    end
  end

  def new
    @wbs_activity = WbsActivity.new
    @organization_id = params['organization_id']
    @organization = Organization.find(params[:organization_id])
    set_page_title I18n.t(:new_wbs_activity)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:wbs_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "activite"), I18n.t(:new) => ""
  end

  def create
    @wbs_activity = WbsActivity.new(params[:wbs_activity])
    @organization_id = params['wbs_activity']['organization_id']
    @organization = Organization.find(@organization_id)

    if @wbs_activity.save
      @wbs_activity_element = WbsActivityElement.new(:name => @wbs_activity.name, :wbs_activity_id => @wbs_activity.id, :description => 'Root Element', :is_root => true)
      @wbs_activity_element.save
      redirect_to main_app.organization_module_estimation_path(@organization_id, anchor: "activite")
    else
      render :new
    end
  end

  def destroy
    @wbs_activity = WbsActivity.find(params[:id])
    @organization_id = @wbs_activity.organization_id

    @wbs_activity.module_projects.each do |mp|
      mp.destroy
    end

    @wbs_activity.destroy

    flash[:notice] = I18n.t(:notice_wbs_activity_successful_deleted)
    redirect_to main_app.organization_module_estimation_path(@organization_id, anchor: "activite")
  end


  #Method to duplicate WBS-Activity and associated WBS-Activity-Elements
  def duplicate_wbs_activity
    #Update ancestry depth caching
    WbsActivityElement.rebuild_depth_cache!

    begin
      old_wbs_activity = WbsActivity.find(params[:wbs_activity_id])
      new_wbs_activity = old_wbs_activity.amoeba_dup   #amoeba gem is configured in WbsActivity class model
      #new_wbs_activity.name = "Copy_#{ old_wbs_activity.copy_number.to_i+1} of #{old_wbs_activity.name}"
      new_wbs_activity.name = "#{old_wbs_activity.name}(#{ old_wbs_activity.copy_number.to_i+1})"

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
                ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
              end

              new_elt.save(:validate => false)
            end
          end
        else
          flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
        end
      end

      #redirect_to('/wbs_activities', :notice  =>  "#{I18n.t(:notice_wbs_activity_successful_duplicated)}") and return
      flash[:notice] = I18n.t(:notice_wbs_activity_successful_duplicated)
      redirect_to main_app.organization_module_estimation_path(new_wbs_activity.organization_id, anchor: "activite") and return

    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"

    rescue
      flash[:error] = I18n.t(:error_wbs_activity_failed_duplicate) + "#{new_wbs_activity.errors.full_messages.to_sentence.to_s}"
      #redirect_to '/wbs_activities'
      redirect_to main_app.organization_module_estimation_path(new_wbs_activity.organization_id, anchor: "activite")
    end
  end

  #This function will validate the WBS-Activity and all its elements
  def validate_change_with_children
    begin
      wbs_activity = WbsActivity.find(params[:id])
      wbs_activity_root_element = WbsActivityElement.where('wbs_activity_id = ? and is_root = ?', wbs_activity.id, true).first

      wbs_activity.transaction do
        if wbs_activity.save

          wbs_activity_root_element.transaction do
            subtree = wbs_activity_root_element.subtree #all descendants (direct and indirect children) and itself
          end

          #TODO : Validate also Ratio and Ratio_Element of each wbs_activity_element
          wbs_activity_ratios = wbs_activity.wbs_activity_ratios
          wbs_activity_ratios.each do |ratio|
            ratio.transaction do
              #ratio.record_status = @defined_status
              if ratio.save
                wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements
                #wbs_activity_ratio_elements.update_all(:record_status_id => @defined_status.id)
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

  def save_effort_breakdown
    authorize! :execute_estimation_plan, @project

    @pbs_project_element = current_component

    @ratio_reference = WbsActivityRatio.find(params[:ratio])

    # Project wbs_activity
    @wbs_activity = current_module_project.wbs_activity
    effort_unit_coefficient = @wbs_activity.effort_unit_coefficient.to_f


    level_estimation_value = Hash.new
    current_pbs_estimations = current_module_project.estimation_values
    current_pbs_estimations.each do |est_val|

      @tmp_results = Hash.new

      if est_val.pe_attribute.alias == "ratio_name"
        ratio_name = @ratio_reference.name
        est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_name })
      elsif est_val.pe_attribute.alias == "effort" || est_val.pe_attribute.alias == "cost"
        if est_val.in_out == 'output'

          @results = Hash.new
          tmp_prbl = Array.new

          ["low", "most_likely", "high"].each do |level|

            if @wbs_activity.three_points_estimation?
              eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values][level].to_f * effort_unit_coefficient, @ratio_reference)
            else
              eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference)
            end

            @tmp_results[level.to_sym] = { "#{est_val.pe_attribute.alias}_#{current_module_project.id}".to_sym => eb.send("get_#{est_val.pe_attribute.alias}") }

            level_estimation_value[@pbs_project_element.id] = @tmp_results[level.to_sym]["#{est_val.pe_attribute.alias}_#{current_module_project.id.to_s}".to_sym]

            @results["string_data_#{level}"] = level_estimation_value
          end

          probable_estimation_value = Hash.new
          probable_estimation_value = est_val.send('string_data_probable')
          probable_estimation_value[@pbs_project_element.id] = probable_value(@tmp_results, est_val)
          #probable_estimation_value[@pbs_project_element.id] = est_val.send('string_data_most_likely')

          ####### Get the project referenced ratio #####
          # Get the wbs_project_element which contain the wbs_activity_ratio
          wbs_activity_root = @wbs_activity.wbs_activity_elements.first.root
          # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)

          # Get the referenced ratio wbs_activity_ratio_profiles
          referenced_wbs_activity_ratio_profiles = @ratio_reference.wbs_activity_ratio_profiles
          profiles_probable_value = {}
          parent_profile_est_value = {}

          # get the wbs_project_elements that have at least one child
          wbs_activity_elements = @wbs_activity.wbs_activity_elements#.select{ |elt| elt.has_children? && !elt.is_root }.map(&:id)

          #@project.organization.organization_profiles.each do |profile|
          @wbs_activity.organization_profiles.each do |profile|
            profiles_probable_value["profile_id_#{profile.id}"] = Hash.new
            # Parent values are reset to zero
            wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt}"] = 0 }

            probable_estimation_value[@pbs_project_element.id].each do |wbs_activity_elt_id, hash_value|
              # Get the probable value profiles values

              if hash_value["profiles"].nil?
                # create a new hash for profiles estimations results
                probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"] = Hash.new
              end

              current_probable_profiles = probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"]

              wbs_activity_element = WbsActivityElement.find(wbs_activity_elt_id)
              wbs_activity_elt_id = wbs_activity_element.id

              # Wbs_project_element root element doesn't have a wbs_activity_element
              #if !wbs_activity_elt_id.nil? ||
              wbs_activity_ratio_elt = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: wbs_activity_elt_id).first
              unless wbs_activity_ratio_elt.nil?
                # get the wbs_activity_ratio_profile
                corresponding_ratio_profile = referenced_wbs_activity_ratio_profiles.where('wbs_activity_ratio_element_id = ? AND organization_profile_id = ?', wbs_activity_ratio_elt.id, profile.id).first
                # Get current profile ratio value for the referenced ratio
                corresponding_ratio_profile_value = corresponding_ratio_profile.nil? ? nil : corresponding_ratio_profile.ratio_value
                estimation_value_profile = nil
                tmp = Hash.new
                unless corresponding_ratio_profile_value.nil?

                  if est_val.pe_attribute.alias == "cost"
                    eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"] * effort_unit_coefficient, @ratio_reference)
                    efforts_man_month = eb.get_effort
                    res = Hash.new
                    efforts_man_month.each do |key, value|
                      tmp = Hash.new
                      wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: key).first
                      unless wbs_activity_ratio_element.nil?
                        wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                          tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * (efforts_man_month[key].to_f * @wbs_activity.effort_unit_coefficient.to_f) * (warp.ratio_value / 100)
                        end
                      end
                      res[key] = tmp

                      if WbsActivityElement.find(key).root?
                        res[key] = tmp.values.sum
                      else
                        res[key] = tmp
                      end

                    end

                    estimation_value_profile = res

                  else
                    estimation_value_profile = (hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100
                    #the update the parent's value
                    parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile
                  end
                end

                current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => estimation_value_profile} }
              end
              #  end
            end

            #Need to calculate the parents effort by profile : addition of its children values
            wbs_activity_elements.each do |wbs_activity_element_id|
              begin
                probable_estimation_value[@pbs_project_element.id][wbs_activity_element_id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element_id}"]} }
              rescue

              end
            end
          end

          @results['string_data_probable'] = probable_estimation_value
          #Update current pbs estimation values
          est_val.update_attributes(@results)
        elsif est_val.in_out == 'input'
          in_result = Hash.new
          tmp_prbl = Array.new
          ['low', 'most_likely', 'high'].each do |level|
            level_estimation_value = Hash.new

            if @wbs_activity.three_points_estimation?
              level_estimation_value[@pbs_project_element.id] = params[:values][level].to_f * effort_unit_coefficient
              in_result["string_data_#{level}"] = level_estimation_value
            else
              level_estimation_value[@pbs_project_element.id] = params[:values]["most_likely"].to_f * effort_unit_coefficient
              in_result["string_data_most_likely"] = level_estimation_value
            end

            tmp_prbl << level_estimation_value[@pbs_project_element.id]
          end

          est_val.update_attributes(in_result)
          est_val.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
        end
      elsif est_val.pe_attribute.alias == "ratio"
        ratio_global = @ratio_reference.wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
        est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_global })
      end
    end

    wai = WbsActivityInput.where(module_project_id: current_module_project.id,
                                 wbs_activity_id: @wbs_activity.id).first
    wai.wbs_activity_ratio_id = @ratio_reference.id.to_i
    wai.comment = params[:comment][wai.id.to_s]
    wai.save

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    current_module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project, current_component)
    end

    redirect_to dashboard_path(@project)
  end

protected

  def wbs_record_statuses_collection
    #No authorize required since this method is protected and won't be call from route
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

  #Function that enable/disable to update
  def enable_update_in_local?
    #No authorize required since this method is protected and won't be call from route
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
