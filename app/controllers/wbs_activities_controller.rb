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
require 'dentaku'

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

    @wbs_activity_ratio_variables =  @selected_ratio.wbs_activity_ratio_variables
    if @wbs_activity_ratio_variables.all.empty?
      @wbs_activity_ratio_variables = @selected_ratio.get_wbs_activity_ratio_variables
    end


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

    unless @selected_ratio.nil?
      @wbs_activity_ratio_variables =  @selected_ratio.wbs_activity_ratio_variables
      if @wbs_activity_ratio_variables.all.empty?
        @wbs_activity_ratio_variables = @selected_ratio.get_wbs_activity_ratio_variables
      end
    end

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
            end

            corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
              ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
            end
            new_elt.save(:validate => false)
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
    effort_unit_coefficient = @wbs_activity.effort_unit_coefficient.nil? ? 1 : @wbs_activity.effort_unit_coefficient.to_f

    @module_project = current_module_project

    #======================  DEBUT create or save module_project Ratio Element Values =========================
    # Save/Created the module_project Ratio Element Values
    @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@ratio_reference, @pbs_project_element, false)

    # To delete after verif
    # @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)
    # #Create the ratio-elements if there is no ratio-elements for the current module_project
    # if @module_project_ratio_elements.nil? || @module_project_ratio_elements.empty?
    #   #create module_project ratio-elements for the current ratio-reference
    #   @ratio_reference.wbs_activity_ratio_elements.each do |ratio_element|
    #     mp_ratio_element = ModuleProjectRatioElement.new(pbs_project_element_id: @pbs_project_element.id, module_project_id: @module_project.id, wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_ratio_element_id: ratio_element.id,
    #                                    multiple_references: ratio_element.multiple_references, name: ratio_element.wbs_activity_element.name, description: ratio_element.wbs_activity_element.description, selected: true,
    #                                    is_optional: ratio_element.is_optional, ratio_value: ratio_element.ratio_value, wbs_activity_element_id: ratio_element.wbs_activity_element_id, position: ratio_element.wbs_activity_element.position)
    #     mp_ratio_element.save
    #   end
    #   @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)
    # end
    #=== FIN create or save module_project Ratio Element Values =====


    #======= Voir si les attributs theoretical_effort et theoretical_cost existe sinon les créer ============
    # Update the Activity module-project attributes if they don't exist (theoretical_effort, theoretical_cost)
    unless @module_project.wbs_activity.nil?
      theoretical_effort = PeAttribute.find_by_alias("theoretical_effort")
      theoretical_cost = PeAttribute.find_by_alias("theoretical_cost")

      [theoretical_effort, theoretical_cost].compact.each do |theoretical_attribute|
        ["input", "output"].each do |in_out|
          unless in_out == "input" && theoretical_attribute.alias == "theoretical_cost"

            theoretical_est_val = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => theoretical_attribute.id, :in_out => in_out).first
            if theoretical_est_val.nil?
              theoretical_est_val = EstimationValue.create(:module_project_id => @module_project.id, :pe_attribute_id => theoretical_attribute.id, :in_out => in_out)

              case theoretical_attribute.alias
                when "theoretical_effort"
                  retained_attribute = PeAttribute.find_by_alias("effort")
                when "theoretical_cost"
                  retained_attribute = PeAttribute.find_by_alias("cost")
              end

              retained_attribute_est_val = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => retained_attribute.id, :in_out => in_out).first
              if retained_attribute_est_val
                ["low", "most_likely", "high", "probable"].each do |level|
                  theoretical_est_val[:"string_data_#{level}"] = retained_attribute_est_val[:"string_data_#{level}"]
                  theoretical_est_val[:"string_data_#{level}"][:pe_attribute_name] = theoretical_attribute.name
                end
                theoretical_est_val[:custom_attribute] = retained_attribute_est_val[:custom_attribute]
                theoretical_est_val[:description] = theoretical_attribute.description
              end

              theoretical_est_val.save
            end
          end
        end
      end

      ## Update selected attribute
      @module_project_ratio_elements.each do |mp_ratio_element|
        selected_elements = params['selected']
        if !selected_elements.nil? && selected_elements.include?(mp_ratio_element.id.to_s)
          mp_ratio_element.selected = true
        else
          if !mp_ratio_element.wbs_activity_ratio_element.nil? && mp_ratio_element.wbs_activity_ratio_element.is_optional==true ##mp_ratio_element.is_optional == true
            mp_ratio_element.selected = false
          else
            mp_ratio_element.selected = true
          end
        end
        mp_ratio_element.save
      end

    end

    #===== Fin test =====


    level_estimation_value = Hash.new
    current_pbs_estimations = current_module_project.estimation_values
    input_effort_for_global_ratio = 0.0
    effort_total_for_global_ratio = 0.0


    current_pbs_estimations.each do |est_val|

      @tmp_results = Hash.new

      if est_val.pe_attribute.alias == "ratio_name"
        ratio_name = @ratio_reference.name
        est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_name })

      #elsif est_val.pe_attribute.alias == "effort" || est_val.pe_attribute.alias == "cost"
      #elsif est_val.pe_attribute.alias == "theoretical_effort" || est_val.pe_attribute.alias == "theoretical_cost"
      elsif est_val.pe_attribute.alias.in?("theoretical_effort", "theoretical_cost", "effort", "cost")
        if (est_val.in_out == 'output') #&& (est_val.pe_attribute.alias != "effort")

          @results = Hash.new
          tmp_prbl = Array.new

          # The "Cost" attribute = "retained_cost" and the "effort" attribute is "retained_effort"
          pe_attribute_alias = est_val.pe_attribute.alias

          mp_pe_attribute_alias = pe_attribute_alias
          if pe_attribute_alias.in?("effort", "cost")
            mp_pe_attribute_alias = "retained_#{pe_attribute_alias}"
          end

          ### ======== GET the retained attribute
          retained_attribute = ""
          mp_ratio_element_attribute_alias = pe_attribute_alias
          case pe_attribute_alias
            when "theoretical_effort"
              retained_attribute = PeAttribute.find_by_alias("effort")
              mp_ratio_element_attribute_alias = "effort"
            when "theoretical_cost"
              retained_attribute = PeAttribute.find_by_alias("cost")
              mp_ratio_element_attribute_alias = "cost"
          end

          #retained_est_val = EstimationValue.where(:pe_attribute_id => retained_attribute.id, :module_project_id => @module_project.id, :in_out => "output").first_or_create

          just_changed_values = params['is_just_changed']
          # Il s'agit du bouton pour réinitialiser le calcul
          if params['initialize_calculation']
            just_changed_values = []
          end

          level_retained_effort_most_likely = params["retained_effort_most_likely"]
          level_retained_effort_most_likely.each do |key, value|
            level_retained_effort_most_likely[key] = value.to_f * effort_unit_coefficient
          end

          ["low", "most_likely", "high"].each do |level|
            if @wbs_activity.three_points_estimation?
              ###eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values][level].to_f * effort_unit_coefficient, @ratio_reference)
              retained_effort_level = params["retained_effort_#{level}"]
              retained_effort_level.each do |key, value|
                retained_effort_level[key] = value.to_f * effort_unit_coefficient
              end
              eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values][level].to_f * effort_unit_coefficient, @ratio_reference, just_changed_values, retained_effort_level)
            else
              ###eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference)
              eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference, just_changed_values, level_retained_effort_most_likely)
            end

            @tmp_results[level.to_sym] = { "#{est_val.pe_attribute.alias}_#{current_module_project.id}".to_sym => eb.send("get_#{est_val.pe_attribute.alias}") }

            level_estimation_value[@pbs_project_element.id] = @tmp_results[level.to_sym]["#{est_val.pe_attribute.alias}_#{current_module_project.id.to_s}".to_sym]
            @results["string_data_#{level}"] = level_estimation_value

            #======= Update the retained effort output if nil or for the first time  ========
            # level_retained_value = retained_est_val.send("string_data_#{level}")
            #  if level_retained_value.nil?
            #    #retained_est_val.send("string_data_#{level}=", level_estimation_value)
            #    level_retained_value = Hash.new
            #  end
            # if level_retained_value[@pbs_project_element.id].nil?
            #   level_retained_value[@pbs_project_element.id] = level_estimation_value[@pbs_project_element.id]
            #   retained_est_val.send("string_data_#{level}=", level_retained_value)
            # end


            #=========== Save results in the Module-Project Ratio Elements THEORETICAL (and RETAINED VALUE if necessary) ===============
            @module_project_ratio_elements.each do |mp_ratio_element|
              element_level_estimation_value = level_estimation_value[@pbs_project_element.id][mp_ratio_element.wbs_activity_element_id]
              if element_level_estimation_value.is_a?(Float) && element_level_estimation_value.nan?
                element_level_estimation_value = nil
              else
                element_level_estimation_value = element_level_estimation_value.to_f
              end
              mp_ratio_element.send("#{mp_pe_attribute_alias}_#{level}=", element_level_estimation_value)

              # Then update retained values if necessary
              element_retained_mp_value = mp_ratio_element.send("retained_#{mp_ratio_element_attribute_alias}_#{level}")
              if element_retained_mp_value.nil?
                mp_ratio_element.send("retained_#{mp_ratio_element_attribute_alias}_#{level}=", element_level_estimation_value)
              end

              mp_ratio_element.save
            end

          end
          #=========== END Save results in the Module-Project Ratio Elements  ===================


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

          # update probable_estimation_value[@pbs_project_element.id] for each wbs-activity-element
          wbs_activity_elements.each do |wbs_activity_elt|
            wbs_activity_elt_id = wbs_activity_elt.id
            wbs_probable_estimation_value = probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]
            if wbs_probable_estimation_value.nil?
              probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id] = Hash.new
              probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"] = Hash.new
            end
          end

          #@project.organization.organization_profiles.each do |profile|
          @wbs_activity.organization_profiles.each do |profile|
            profiles_probable_value["profile_id_#{profile.id}"] = Hash.new
            # Parent values are reset to zero
            wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt.id}"] = 0.0 }

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

                  #if est_val.pe_attribute.alias == "cost"
                  if est_val.pe_attribute.alias.in?("theoretical_cost", "cost")
                    eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference, just_changed_values, level_retained_effort_most_likely)
                    efforts_man_month = eb.get_effort  ### efforts_man_month = eb.get_theoretical_effort

                    res = Hash.new
                    efforts_man_month.each do |key, value|
                      tmp = Hash.new
                      wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: key).first
                      unless wbs_activity_ratio_element.nil?
                        wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                          tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * (efforts_man_month[key].to_f * @wbs_activity.effort_unit_coefficient.to_f) * (warp.ratio_value.to_f / 100)
                        end
                      end
                      res[key] = tmp

                      current_activity_element = WbsActivityElement.find(key)
                      if current_activity_element.root?
                        res[key] = tmp.values.sum
                      else
                        res[key] = tmp
                      end
                    end

                    estimation_value_profile = res
                    res.each do |wbs_id, res_hash_value|
                      wbs_value = probable_estimation_value[@pbs_project_element.id][wbs_id]
                      current_wbs_profile_values =  probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"]
                      if current_wbs_profile_values.nil? || current_wbs_profile_values.empty?
                        probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"] = { "profile_id_#{profile.id}" => Hash.new } #Hash.new

                      elsif current_wbs_profile_values["profile_id_#{profile.id}"].nil? || current_wbs_profile_values["profile_id_#{profile.id}"].empty?
                        current_wbs_profile_values["profile_id_#{profile.id}"] = Hash.new
                      end

                      current_wbs = WbsActivityElement.find(wbs_id)
                      if current_wbs.is_childless?
                        estimation_value_profile = res_hash_value[profile.id].to_f
                        parent_profile_est_value["#{wbs_id}"] = estimation_value_profile
                        probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"]["profile_id_#{profile.id}"]["ratio_id_#{@ratio_reference.id}"] =  { :value => estimation_value_profile }

                        # Update values for ancestors
                        # current_wbs.ancestors.each do |ancestor|
                        #   parent_profile_est_value["#{ancestor.id}"] = parent_profile_est_value["#{ancestor.id}"].to_f + estimation_value_profile
                        # end
                      end
                    end

                  #Effort attribute
                  else
                    estimation_value_profile = (hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100
                    current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => { :value => estimation_value_profile } }

                    #the update the parent's value
                    parent_profile_est_value["#{wbs_activity_element.id}"] = estimation_value_profile
                    ###parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile

                    # Update values for ancestors if the element it self is selected
                    mp_ratio_element_for_effort_profile = @module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_element).first
                    if (mp_ratio_element_for_effort_profile && mp_ratio_element_for_effort_profile.selected==true) || mp_ratio_element_for_effort_profile.nil?
                      wbs_activity_element.ancestors.each do |ancestor|
                        parent_profile_est_value["#{ancestor.id}"] = parent_profile_est_value["#{ancestor.id}"].to_f + estimation_value_profile
                      end
                    end


                    #Need to calculate the parents effort by profile : addition of its children values
                    # wbs_activity_elements.each do |wbs_activity_element_id|
                    #   begin
                    #     probable_estimation_value[@pbs_project_element.id][wbs_activity_element_id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element_id}"]} }
                    #   rescue
                    #   end
                    # end
                  end
                end
                ###current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => estimation_value_profile} }
              end
              #  end
            end

            # #Need to calculate the parents effort / cost by profile : addition of its children values
            wbs_activity_elements.each do |wbs_activity_element|
              begin
                ###probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element.id}"]} }
                if wbs_activity_element.has_children?
                  ancestor_value = 0.0
                  # Update values for ancestors
                  wbs_activity_element.children.each do |child|
                    ancestor_value = ancestor_value.to_f + parent_profile_est_value["#{child.id}"]
                  end
                  parent_profile_est_value["#{wbs_activity_element.id}"] = ancestor_value
                end

                probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"]["ratio_id_#{@ratio_reference.id}"] =  { :value => parent_profile_est_value["#{wbs_activity_element.id}"] }
              rescue
              end
            end
          end

          @results['string_data_probable'] = probable_estimation_value
          #Update current pbs estimation values
          est_val.update_attributes(@results)

          # Recupere effort global pour ratio global
          if est_val.pe_attribute.alias == "effort"
            root_element = wbs_activity_elements.first.root
            effort_total_for_global_ratio = probable_estimation_value[@pbs_project_element.id][root_element.id][:value]
          end

          #======= Update PROBABLE the retained effort/cost output if nil or for the first time  ========
          # probable_retained_value = retained_est_val.send("string_data_probable")
          # if probable_retained_value.nil?
          #   retained_est_val.send("string_data_probable=", probable_estimation_value)
          # elsif probable_retained_value[@pbs_project_element.id].nil?
          #   probable_retained_value[@pbs_project_element.id] = probable_estimation_value[@pbs_project_element.id]
          #   retained_est_val.send("string_data_probable=", probable_retained_value)
          # end
          # retained_est_val.save


          #=========== Update Module-Project Ratio-Elements Theoretical and Retained PROBABLE-values  ======
          mp_pbs_probable_value = probable_estimation_value[@pbs_project_element.id]
          @module_project_ratio_elements.each do |mp_ratio_element|
            wbs_probable_value = mp_pbs_probable_value[mp_ratio_element.wbs_activity_element_id]
            if wbs_probable_value.nil? || (wbs_probable_value.is_a?(Float) && wbs_probable_value.nan?)
              wbs_probable_value = nil
            else
              wbs_probable_value = ((wbs_probable_value[:value].is_a?(Float) && wbs_probable_value[:value].nan?) ? nil : wbs_probable_value[:value].to_f)
            end
            # save théorétical values
            mp_ratio_element.send("#{mp_pe_attribute_alias}_probable=", wbs_probable_value)

            # get the retained attribute value
            mp_retained_alias = "retained_#{mp_ratio_element_attribute_alias}_probable"
            if mp_ratio_element.send("#{mp_retained_alias}").nil?
              mp_ratio_element.send("#{mp_retained_alias}=", wbs_probable_value)
            end


            # if value is manually updated, update the flagged attribute
            unless just_changed_values.nil?
              if !just_changed_values.empty? && just_changed_values.include?("#{mp_ratio_element.id}")
                mp_ratio_element.flagged = true
              end
            end

            mp_ratio_element.save
          end

        elsif est_val.in_out == 'input' && est_val.pe_attribute.alias.in?("theoretical_effort", "effort")
          in_result = Hash.new
          tmp_prbl = Array.new
          ['low', 'most_likely', 'high'].each do |level|
            level_estimation_value = Hash.new

            if @wbs_activity.three_points_estimation?
              level_estimation_value[@pbs_project_element.id] = params[:values][level].to_f * effort_unit_coefficient
              in_result["string_data_#{level}"] = level_estimation_value
            else
              level_estimation_value[@pbs_project_element.id] = params[:values]["most_likely"].to_f * effort_unit_coefficient
              #in_result["string_data_most_likely"] = level_estimation_value
              in_result["string_data_#{level}"] = level_estimation_value
            end

            tmp_prbl << level_estimation_value[@pbs_project_element.id]
          end

          est_val.update_attributes(in_result)
          pbs_input_probable_value = ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6)
          est_val.update_attribute(:"string_data_probable", { current_component.id => pbs_input_probable_value } )

          if est_val.pe_attribute.alias == "effort"
            input_effort_for_global_ratio = pbs_input_probable_value
          end

          #=================  Save the module_project_ratio_variables values from de probable value  =================================
          # if est_val.pe_attribute.alias == "effort"
          #   #initialize calculator
          #   calculator = Dentaku::Calculator.new
          #
          #   root_probable_effort_value = pbs_input_probable_value
          #   calculator.store(root_probable_effort_value: pbs_input_probable_value)
          #
          #   #mp_ratio_variables = @ratio_reference.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio_reference.id)
          #   mp_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio_reference.id)
          #   mp_ratio_variables.each do |mp_var|
          #     wbs_ratio_variable  = mp_var.wbs_activity_ratio_variable
          #     percentage_of_input = wbs_ratio_variable.percentage_of_input
          #     if wbs_ratio_variable.is_modifiable
          #      percentage_of_input = mp_var.percentage_of_input
          #     end
          #
          #     # calculate value from percentage of input
          #     if root_probable_effort_value.nil? || percentage_of_input.blank?
          #       mp_var.update_attribute(:value_from_percentage, nil)
          #     else
          #       value_from_percentage = calculator.evaluate("#{root_probable_effort_value.to_f} * #{percentage_of_input}")
          #       mp_var.update_attribute(:value_from_percentage, value_from_percentage)
          #     end
          #   end
          # end
          #=================  END Save module_project_ratio_variables  =================================

        end
      elsif est_val.pe_attribute.alias == "ratio"
        ratio_global = @ratio_reference.wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)

        #nouvelle calcul du ratio
        rtu = @ratio_reference.module_project_ratio_variables.where(name: "RTU").first
        input_effort = input_effort_for_global_ratio
        effort_total = effort_total_for_global_ratio
        if effort_total.nil? || effort_total == 0
          new_ratio_global = nil
        else
          new_ratio_global = (input_effort.to_f / effort_total.to_f) * 100
        end

        #est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_global })
        est_val.update_attribute(:"string_data_probable", { current_component.id => new_ratio_global })
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
      cpt = vw.pbs_project_element.nil? ? current_component : vw.pbs_project_element
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project, cpt)
    end

    ####update_effort_breakdown_retained_values

    @wbs_activity_ratio = @ratio_reference
    redirect_to dashboard_path(@project, ratio: @ratio_reference.id, anchor: 'save_effort_breakdown_form')
  end



  #======================== UPDATE THE RETAINED ATTRIBUTE ESTIMATION VALUES =============================
  def update_effort_breakdown_retained_values

    authorize! :execute_estimation_plan, @project

    #we save the Retained effort/cost now in estimation values
    @module_project = @module_project || current_module_project
    @pbs_project_element = @pbs_project_element || current_component
    @wbs_activity = @wbs_activity || @module_project.wbs_activity

    new_global_ratio_value = 0

    if @wbs_activity
      effort_unit_coefficient = @wbs_activity.effort_unit_coefficient.nil? ? 1 : @wbs_activity.effort_unit_coefficient.to_f
      @ratio_reference = @ratio_reference || WbsActivityRatio.find(params[:ratio]) ###WbsActivityRatio.find(params[:dashboard_selected_ratio_id])

      @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)

      # SAUVEGARDE DES VALEURS DES RATIO-ELEMENTS DU MODULE-PROJECT
      #======================  DEBUT SAUVEGARDE ====================
      # Save Ratio-Element values
      selected_elements = params['selected']
      @module_project_ratio_elements.each_with_index do |mp_ratio_element, i|
        test = mp_ratio_element
        if !selected_elements.nil? && selected_elements.include?(mp_ratio_element.id.to_s)
          mp_ratio_element.selected = true
          new_global_ratio_value = new_global_ratio_value + mp_ratio_element.ratio_value.to_f
        else
            if mp_ratio_element.is_optional == true
              mp_ratio_element.selected = false
            else
              mp_ratio_element.selected = true
              new_global_ratio_value = new_global_ratio_value + mp_ratio_element.ratio_value.to_f
            end
        end

        if @ratio_reference.allow_modify_ratio_reference
          unless params[:ratio_values].nil?
            mp_ratio_element.ratio_value = params[:ratio_values]["#{mp_ratio_element.id}"].to_f
            if !params[:multiple_references].nil? && params[:multiple_references].join(",").include?(mp_ratio_element.id.to_s)
              mp_ratio_element.multiple_references = true
            else
              mp_ratio_element.multiple_references = false
            end
          end
        end

        #Save theoretical_effort_probable and theoretical_cost_probable
        # Theoretical values are now saved in save_effort_breakdown function
        # ["theoretical_effort", "theoretical_cost"].each do |theoretical_attribute|
        #   theoretical_pe_attribute_alias = theoretical_attribute
        #   if @wbs_activity.three_points_estimation?
        #     low_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_low")
        #     ml_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_most_likely")
        #     high_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_high")
        #     theoretical_probable_value = (low_value.to_f + 4 * ml_value.to_f +  high_value.to_f) / 6
        #   else
        #     theoretical_probable_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_most_likely")
        #   end
        #   mp_ratio_element.send("#{theoretical_pe_attribute_alias}_probable=", theoretical_probable_value)
        # end

        #Save retained_effort_probable and retained_cost_probable
        ["retained_effort", "retained_cost"].each do |retained_attribute|
          level_value = []
          theoretical_pe_attribute = ""
          if retained_attribute == "retained_cost"
            effort_unit_coefficient_per_attr = 1
            theoretical_pe_attribute = "theoretical_cost"
          else
            effort_unit_coefficient_per_attr = effort_unit_coefficient
            theoretical_pe_attribute = "theoretical_effort"
          end


          if @wbs_activity.three_points_estimation?
            ["low", "most_likely", "high"].each do |level|
              retained_value = params["#{retained_attribute}_#{level}"]["#{mp_ratio_element.id}"]
              if retained_value.nil? || retained_value.empty?
                retained_value_level = mp_ratio_element.send("#{theoretical_pe_attribute}_#{level}")
              else
                retained_value_level = retained_value.to_f * effort_unit_coefficient_per_attr.to_f
              end
              level_value << retained_value_level
              mp_ratio_element.send("#{retained_attribute}_#{level}=", retained_value_level)
            end
          else
            retained_value = params["#{retained_attribute}_most_likely"]["#{mp_ratio_element.id}"]
            if retained_value.nil? || retained_value.empty?
              retained_value_level = mp_ratio_element.send("#{theoretical_pe_attribute}_most_likely")
            else
              retained_value_level = retained_value.to_f * effort_unit_coefficient_per_attr.to_f
            end

            level_value << retained_value_level
            ["low", "most_likely", "high"].each do |level|
              mp_ratio_element.send("#{retained_attribute}_#{level}=", retained_value_level)
            end
          end

          if level_value.compact.empty?
            retained_value_probable = nil
          else
            if @wbs_activity.three_points_estimation?
              retained_value_probable = (level_value[0].to_f + 4 * level_value[1].to_f +  level_value[2].to_f) / 6
            else
              retained_value_probable = level_value[0]
            end
          end
          mp_ratio_element.send("#{retained_attribute}_probable=", retained_value_probable)
        end

        mp_ratio_element.save

      end
      #=== FIN SAUVEGARDE DES VALEURS DES RATIO-ELEMENTS  DU MODULE-PROJECT ====


      #== UPDATE THE RETAINED ATTRIBUTE ESTIMATION VALUES ===
      @module_project.pemodule.attribute_modules.each do |am|
        @estimation_values = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id, :in_out => "output").all

        pe_attribute_alias =  am.pe_attribute.alias
        output_effort_or_cost = Hash.new

        @estimation_values.each do |ev|
          tmp_prbl = Array.new
          ["low", "most_likely", "high", "probable"].each do |level|

            ###level_estimation_value = Hash.new
            level_estimation_value = ev.send("string_data_#{level}") || Hash.new
            psb_level_estimation_value = level_estimation_value[@pbs_project_element.id] || Hash.new

            #level_estimation_value[@pbs_project_element.id] = set_element_value_with_activities(level_estimation_value_without_consistency, start_module_project)
            #result_with_consistency[wbs_project_elt_id] = {:value => est_value}

            #if pe_attribute_alias.in?("retained_effort", "retained_cost")
            if pe_attribute_alias.in?("effort", "cost")
              mp_retained_attribute = "retained_#{pe_attribute_alias}_#{level}"

              @module_project_ratio_elements.reject{ |mp_elt| mp_elt.wbs_activity_element_id.nil? }.each_with_index do |mp_ratio_element, i|

                # psb_level_estimation_value[mp_ratio_element.wbs_activity_element_id] = {
                #     value: mp_ratio_element.send("#{pe_attribute_alias}_#{level}"),
                #     is_consistent: true,
                #     profiles: {}
                # }
                wbs_activity_element_id = mp_ratio_element.wbs_activity_element_id
                mp_retained_value = mp_ratio_element.send("#{mp_retained_attribute}")

                if psb_level_estimation_value[wbs_activity_element_id].nil?
                  psb_level_estimation_value[wbs_activity_element_id] = Hash.new
                end

                if level == "probable"
                  psb_level_estimation_value[wbs_activity_element_id][:value] = mp_retained_value

                  # Then update Effort or cost by phases and profiles
                  activity_element_profiles = psb_level_estimation_value[wbs_activity_element_id]["profiles"]
                  psb_level_estimation_value_avant = psb_level_estimation_value
                  ###psb_level_estimation_value = save_retained_value_by_phases_profiles(ev, wbs_activity_element_id, mp_retained_value, activity_element_profiles, level_estimation_value, psb_level_estimation_value, mp_ratio_element, pe_attribute_alias)
                  puts "Test = #{psb_level_estimation_value}"
                else
                  # level = low, most_likely, high
                  psb_level_estimation_value[wbs_activity_element_id] = mp_retained_value
                end

              end
              ev.send("string_data_#{level}")[current_component.id] = psb_level_estimation_value
              ev.save

            elsif pe_attribute_alias == "ratio"
              ev.send("string_data_#{level}")[current_component.id] = new_global_ratio_value
              ev.save
            end

          end
        end
      end
    else
      flash[:warning] = "Wbs-Activity inexistant"
    end

    ####redirect_to dashboard_path(@project)
  end




  def update_effort_breakdown_retained_values_SAVE

    authorize! :execute_estimation_plan, @project

    #we save the Retained effort/cost now in estimation values
    @module_project = current_module_project
    @pbs_project_element = current_component
    @wbs_activity = @module_project.wbs_activity

    new_global_ratio_value = 0

    if @wbs_activity
      effort_unit_coefficient = @wbs_activity.effort_unit_coefficient.nil? ? 1 : @wbs_activity.effort_unit_coefficient.to_f
      @ratio_reference = WbsActivityRatio.find(params[:ratio]) ###WbsActivityRatio.find(params[:dashboard_selected_ratio_id])

      @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)

      # SAUVEGARDE DES VALEURS DES RATIO-ELEMENTS DU MODULE-PROJECT
      #======================  DEBUT SAUVEGARDE ====================
      # Save Ratio-Element values
      selected_elements = params['selected']
      @module_project_ratio_elements.each_with_index do |mp_ratio_element, i|
        test = mp_ratio_element
        if selected_elements.include?(mp_ratio_element.id.to_s)
          mp_ratio_element.selected = true
          new_global_ratio_value = new_global_ratio_value + mp_ratio_element.ratio_value.to_f
        else
          if mp_ratio_element.is_optional == true
            mp_ratio_element.selected = false
          else
            mp_ratio_element.selected = true
            new_global_ratio_value = new_global_ratio_value + mp_ratio_element.ratio_value.to_f
          end
        end

        if @ratio_reference.allow_modify_ratio_reference
          unless params[:ratio_values].nil?
            mp_ratio_element.ratio_value = params[:ratio_values]["#{mp_ratio_element.id}"].to_f
            if !params[:multiple_references].nil? && params[:multiple_references].join(",").include?(mp_ratio_element.id.to_s)
              mp_ratio_element.multiple_references = true
            else
              mp_ratio_element.multiple_references = false
            end
          end
        end

        #Save theoretical_effort_probable and theoretical_cost_probable
        # Theoretical values are now saved in save_effort_breakdown function
        # ["theoretical_effort", "theoretical_cost"].each do |theoretical_attribute|
        #   theoretical_pe_attribute_alias = theoretical_attribute
        #   if @wbs_activity.three_points_estimation?
        #     low_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_low")
        #     ml_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_most_likely")
        #     high_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_high")
        #     theoretical_probable_value = (low_value.to_f + 4 * ml_value.to_f +  high_value.to_f) / 6
        #   else
        #     theoretical_probable_value = mp_ratio_element.send("#{theoretical_pe_attribute_alias}_most_likely")
        #   end
        #   mp_ratio_element.send("#{theoretical_pe_attribute_alias}_probable=", theoretical_probable_value)
        # end

        #Save retained_effort_probable and retained_cost_probable
        ["retained_effort", "retained_cost"].each do |retained_attribute|
          level_value = []
          theoretical_pe_attribute = ""
          if retained_attribute == "retained_cost"
            effort_unit_coefficient_per_attr = 1
            theoretical_pe_attribute = "theoretical_cost"
          else
            effort_unit_coefficient_per_attr = effort_unit_coefficient
            theoretical_pe_attribute = "theoretical_effort"
          end


          if @wbs_activity.three_points_estimation?
            ["low", "most_likely", "high"].each do |level|
              retained_value = params["#{retained_attribute}_#{level}"]["#{mp_ratio_element.id}"]
              if retained_value.nil? || retained_value.empty?
                retained_value_level = mp_ratio_element.send("#{theoretical_pe_attribute}_#{level}")
              else
                retained_value_level = retained_value.to_f * effort_unit_coefficient_per_attr.to_f
              end
              level_value << retained_value_level
              mp_ratio_element.send("#{retained_attribute}_#{level}=", retained_value_level)
            end
          else
            retained_value = params["#{retained_attribute}_most_likely"]["#{mp_ratio_element.id}"]
            if retained_value.nil? || retained_value.empty?
              retained_value_level = mp_ratio_element.send("#{theoretical_pe_attribute}_most_likely")
            else
              retained_value_level = retained_value.to_f * effort_unit_coefficient_per_attr.to_f
            end

            level_value << retained_value_level
            ["low", "most_likely", "high"].each do |level|
              mp_ratio_element.send("#{retained_attribute}_#{level}=", retained_value_level)
            end
          end

          if level_value.compact.empty?
            retained_value_probable = nil
          else
            if @wbs_activity.three_points_estimation?
              retained_value_probable = (level_value[0].to_f + 4 * level_value[1].to_f +  level_value[2].to_f) / 6
            else
              retained_value_probable = level_value[0]
            end
          end
          mp_ratio_element.send("#{retained_attribute}_probable=", retained_value_probable)
        end

        mp_ratio_element.save

      end
      #=== FIN SAUVEGARDE DES VALEURS DES RATIO-ELEMENTS  DU MODULE-PROJECT ====


      #== UPDATE THE RETAINED ATTRIBUTE ESTIMATION VALUES ===
      @module_project.pemodule.attribute_modules.each do |am|
        @estimation_values = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id, :in_out => "output").all

        pe_attribute_alias =  am.pe_attribute.alias
        output_effort_or_cost = Hash.new

        @estimation_values.each do |ev|
          tmp_prbl = Array.new
          ["low", "most_likely", "high", "probable"].each do |level|

            ###level_estimation_value = Hash.new
            level_estimation_value = ev.send("string_data_#{level}") || Hash.new
            psb_level_estimation_value = level_estimation_value[@pbs_project_element.id] || Hash.new

            #level_estimation_value[@pbs_project_element.id] = set_element_value_with_activities(level_estimation_value_without_consistency, start_module_project)
            #result_with_consistency[wbs_project_elt_id] = {:value => est_value}

            #if pe_attribute_alias.in?("retained_effort", "retained_cost")
            if pe_attribute_alias.in?("effort", "cost")
              mp_retained_attribute = "retained_#{pe_attribute_alias}_#{level}"

              @module_project_ratio_elements.reject{ |mp_elt| mp_elt.wbs_activity_element_id.nil? }.each_with_index do |mp_ratio_element, i|

                # psb_level_estimation_value[mp_ratio_element.wbs_activity_element_id] = {
                #     value: mp_ratio_element.send("#{pe_attribute_alias}_#{level}"),
                #     is_consistent: true,
                #     profiles: {}
                # }
                wbs_activity_element_id = mp_ratio_element.wbs_activity_element_id
                mp_retained_value = mp_ratio_element.send("#{mp_retained_attribute}")

                if psb_level_estimation_value[wbs_activity_element_id].nil?
                  psb_level_estimation_value[wbs_activity_element_id] = Hash.new
                end

                if level == "probable"
                  psb_level_estimation_value[wbs_activity_element_id][:value] = mp_retained_value

                  # Then update Effort or cost by phases and profiles
                  activity_element_profiles = psb_level_estimation_value[wbs_activity_element_id]["profiles"]
                  psb_level_estimation_value_avant = psb_level_estimation_value
                  ###psb_level_estimation_value = save_retained_value_by_phases_profiles(ev, wbs_activity_element_id, mp_retained_value, activity_element_profiles, level_estimation_value, psb_level_estimation_value, mp_ratio_element, pe_attribute_alias)
                  puts "Test = #{psb_level_estimation_value}"
                else
                  # level = low, most_likely, high
                  psb_level_estimation_value[wbs_activity_element_id] = mp_retained_value
                end

              end
              ev.send("string_data_#{level}")[current_component.id] = psb_level_estimation_value
              ev.save

            elsif pe_attribute_alias == "ratio"
              ev.send("string_data_#{level}")[current_component.id] = new_global_ratio_value
              ev.save
            end

          end
        end
      end
    else
      flash[:warning] = "Wbs-Activity inexistant"
    end

    redirect_to dashboard_path(@project)
  end
#============================



  # TODO : pas encore fini
  #==============
  # Save/Update the Effort by Phases and Profiles Probable value of the ratained attributes
  def save_retained_value_by_phases_profiles(est_val, wbs_activity_element_id, mp_retained_value, activity_element_profiles, probable_estimation_value, psb_level_estimation_value, mp_ratio_element, pe_attribute_alias)
    activity_element_profiles = psb_level_estimation_value[wbs_activity_element_id]["profiles"]
    wbs_activity_elt_id = wbs_activity_element_id

    original_probable_estimation_value = probable_estimation_value

    wbs_activity_elements = @wbs_activity.wbs_activity_elements
    referenced_wbs_activity_ratio_profiles = @ratio_reference.wbs_activity_ratio_profiles  # Get the referenced ratio wbs_activity_ratio_profiles 
    profiles_probable_value = {}
    parent_profile_est_value = {}

    #===================
    probable_estimation_value = probable_estimation_value  || Hash.new

    ####### Get the project referenced ratio #####
    # Get the wbs_project_element which contain the wbs_activity_ratio
    wbs_activity_root = @wbs_activity.wbs_activity_elements.first.root
    referenced_wbs_activity_ratio_profiles = @ratio_reference.wbs_activity_ratio_profiles
    profiles_probable_value = {}
    parent_profile_est_value = {}

    @wbs_activity.organization_profiles.each do |profile|
      profiles_probable_value["profile_id_#{profile.id}"] = Hash.new
      # Parent values are reset to zero
      wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt.id}"] = 0 }

      unless probable_estimation_value
        probable_estimation_value[@pbs_project_element.id].each do |wbs_activity_elt_id, hash_value|

          wbs_activity_element = WbsActivityElement.find(wbs_activity_elt_id)
          wbs_activity_elt_id = wbs_activity_element.id

          # Get the probable value profiles values
          if hash_value["profiles"].nil?
            # create a new hash for profiles estimations results
            probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"] = Hash.new
          end

          current_probable_profiles = probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"]

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
               efforts_man_month = mp_retained_value

                res = Hash.new
                #efforts_man_month.each do |key, value|
                  tmp = Hash.new
                  wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: key).first
                  unless wbs_activity_ratio_element.nil?
                    wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                      tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * (efforts_man_month.to_f * @wbs_activity.effort_unit_coefficient.to_f) * (warp.ratio_value.to_f / 100)
                    end
                  end
                  res[wbs_activity_elt_id] = tmp

                  if WbsActivityElement.find(key).root?
                    res[wbs_activity_elt_id] = tmp.values.sum
                  else
                    res[wbs_activity_elt_id] = tmp
                  end
                #end
                estimation_value_profile = res

                res.each do |wbs_id, res_hash_value|
                  current_wbs_profile_values =  probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"]
                  if current_wbs_profile_values.nil? || current_wbs_profile_values.empty?
                    probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"] = { "profile_id_#{profile.id}" => Hash.new } #Hash.new
                  end

                  current_wbs = WbsActivityElement.find(wbs_id)
                  if current_wbs.is_childless?
                    estimation_value_profile = res_hash_value[profile.id].to_f
                    parent_profile_est_value["#{wbs_id}"] = estimation_value_profile
                    probable_estimation_value[@pbs_project_element.id][wbs_id]["profiles"]["profile_id_#{profile.id}"]["ratio_id_#{@ratio_reference.id}"] =  { :value => estimation_value_profile }
                  end
                end

                #Effort attribute
              else
                #estimation_value_profile = (hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100
                estimation_value_profile = (mp_retained_value.to_f * corresponding_ratio_profile_value.to_f) / 100
                current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => { :value => estimation_value_profile } }

                #the update the parent's value
                parent_profile_est_value["#{wbs_activity_element.id}"] = estimation_value_profile
                ###parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile
                # Update values for ancestors
                wbs_activity_element.ancestors.each do |ancestor|
                  parent_profile_est_value["#{ancestor.id}"] = parent_profile_est_value["#{ancestor.id}"].to_f + estimation_value_profile
                end
              end
            end
          end
        end
      end

      # #Need to calculate the parents effort / cost by profile : addition of its children values
      wbs_activity_elements.each do |wbs_activity_element|
        begin
          ###probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element.id}"]} }
          if wbs_activity_element.has_children?
            ancestor_value = 0.0
            # Update values for ancestors
            wbs_activity_element.children.each do |child|
              ancestor_value = ancestor_value.to_f + parent_profile_est_value["#{child.id}"]
            end
            parent_profile_est_value["#{wbs_activity_element.id}"] = ancestor_value
          end

          value_per_phase_ratio = parent_profile_est_value["#{wbs_activity_element.id}"]
          probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"]["ratio_id_#{@ratio_reference.id}"] =  { :value => value_per_phase_ratio }
        rescue
        end
      end
    end

    #@results['string_data_probable'] = probable_estimation_value
    #est_val.update_attributes(@results)

    probable_estimation_value[@pbs_project_element.id]

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
