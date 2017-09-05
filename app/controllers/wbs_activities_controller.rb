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
require 'rubyXL'

class WbsActivitiesController < ApplicationController
  # #Module for master data changes validation
  include ModuleProjectsHelper
  load_resource


  def refresh_ratio_elements

    # @wbs_activity_ratio_elements = []
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    @wbs_activity = @wbs_activity_ratio.wbs_activity
    @wbs_activity_organization = @wbs_activity.organization
    @selected_ratio = @wbs_activity_ratio

    #now only the selected profiles from the WBS'organization profiles list will be used
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity.organization_profiles.order('name')  #@wbs_activity_organization.organization_profiles

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
    elsif @wbs_activity_ratio_variables.size > 4
      diff = @wbs_activity_ratio_variables.size-4
      diff.times.each do |i|
        ratio_var = @wbs_activity_ratio_variables.where(name: "").last
        if ratio_var
          ratio_var.destroy
        end
      end
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

      elsif @wbs_activity_ratio_variables.size > 4
        diff = @wbs_activity_ratio_variables.size-4
        diff.times.each do |i|
          ratio_var = @wbs_activity_ratio_variables.where(name: "").last
          if ratio_var
            ratio_var.destroy
          end
        end
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

            #Update Wbs-activity-ratio-varibales
            old_ratio = old_wbs_activity.wbs_activity_ratios.where(id: ratio.copy_id).first
            if old_ratio
              old_ratio.wbs_activity_ratio_variables.each do |old_ratio_variable|
                new_ratio_variable = old_ratio_variable.dup
                new_ratio_variable.wbs_activity_ratio_id = ratio.id
                new_ratio_variable.save
              end
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
              if ratio.save
                wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements
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
    @module_project = current_module_project
    @wbs_activity = @module_project.wbs_activity
    module_project_attributes = @module_project.pemodule.pe_attributes

    # Get selected Ratio
    @ratio_reference = WbsActivityRatio.find(params[:ratio])

    if @ratio_reference.nil?
      flash[:warning] = "Erreur : vous devez sélectionner un Ratio pour continuer"
      redirect_to dashboard_path(@project, ratio: nil, anchor: 'save_effort_breakdown_form') and return
    else
      wai = @module_project.wbs_activity_inputs.where(wbs_activity_id: @wbs_activity.id, wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)
                                               .first_or_create(module_project_id: @module_project.id, pbs_project_element_id: @pbs_project_element.id,
                                                                wbs_activity_id: @wbs_activity.id, wbs_activity_ratio_id: @ratio_reference.id)
      wai.comment = params[:comment][wai.id.to_s]
      wai.save
    end
    @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @ratio_reference.id, pbs_project_element_id: @pbs_project_element.id)

    effort_unit_coefficient = @wbs_activity.effort_unit_coefficient.nil? ? 1.0 : @wbs_activity.effort_unit_coefficient.to_f

    level_estimation_value = Hash.new
    current_pbs_estimations = current_module_project.estimation_values
    input_effort_for_global_ratio = 0.0
    effort_total_for_global_ratio = 0.0
    initialize_calculation = false

    just_changed_values = params['is_just_changed'] || []
    # Il s'agit du bouton pour réinitialiser le calcul
    if params['initialize_calculation']
      just_changed_values = []
      initialize_calculation = true
    end


    #======= Voir si les attributs theoretical_effort et theoretical_cost existe sinon les créer ============
    # Update the Activity module-project attributes if they don't exist (theoretical_effort, theoretical_cost)
    unless @module_project.wbs_activity.nil?

      # Sauvegarder le ratio utilisé lors du calcul
      @module_project.wbs_activity_ratio_id = @ratio_reference.id
      @module_project.save

      theoretical_effort = module_project_attributes.where(alias: "theoretical_effort").first #PeAttribute.find_by_alias("theoretical_effort")
      theoretical_cost = module_project_attributes.where(alias: "theoretical_cost").first #PeAttribute.find_by_alias("theoretical_cost")

      [theoretical_effort, theoretical_cost].compact.each do |theoretical_attribute|
        ["input", "output"].each do |in_out|
          unless in_out == "input" && theoretical_attribute.alias == "theoretical_cost"

            theoretical_est_val = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => theoretical_attribute.id, :in_out => in_out).first
            if theoretical_est_val.nil?
              theoretical_est_val = EstimationValue.create(:module_project_id => @module_project.id, :pe_attribute_id => theoretical_attribute.id, :in_out => in_out)

              case theoretical_attribute.alias
                when "theoretical_effort"
                  retained_attribute = module_project_attributes.where(alias: "effort").first #PeAttribute.find_by_alias("effort")
                when "theoretical_cost"
                  retained_attribute = module_project_attributes.where(alias: "cost").first #PeAttribute.find_by_alias("cost")
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

              if theoretical_est_val.changed?
                theoretical_est_val.save
              end
            end
          end
        end
      end


      retained_effort_level = Hash.new
      retained_cost_level = Hash.new
      input_effort_values = Hash.new

      ["low", "most_likely", "high"].each do |level|
        # Input Effort
        #input_effort_values["#{level}"] = params[:values]["#{level}"].to_f * effort_unit_coefficient
        input_effort_values["#{level}"] = Hash.new
        if @wbs_activity.three_points_estimation?
          current_entry_value = params[:values][level]
        else
          current_entry_value = params[:values]["most_likely"]
        end

        unless current_entry_value.nil?
          current_entry_value.each do |key, value|
            input_effort_values["#{level}"]["#{key}"] = value.to_f * effort_unit_coefficient
          end
        end

        # Retained Effort
        level_retained_effort_with_wbs_activity_elt_id = Hash.new

        each_level_retained_effort = params["retained_effort_#{level}"]
        if each_level_retained_effort.nil?
          each_level_retained_effort = []
        end

        # Retained Cost
        level_retained_cost_with_wbs_activity_elt_id = Hash.new
        each_level_retained_cost = params["retained_cost_#{level}"]
        if each_level_retained_cost.nil?
          each_level_retained_cost = []
        end

        each_level_retained_effort.each do |key, value|
          mp_ratio_element = ModuleProjectRatioElement.find(key)
          level_retained_effort_with_wbs_activity_elt_id[mp_ratio_element.wbs_activity_element_id] = value.empty? ? nil : (value.to_f * effort_unit_coefficient)
          level_retained_cost_with_wbs_activity_elt_id[mp_ratio_element.wbs_activity_element_id] = each_level_retained_cost["#{mp_ratio_element.id}"].empty? ? nil : each_level_retained_cost["#{mp_ratio_element.id}"].to_f
        end

        retained_effort_level["#{level}"] = level_retained_effort_with_wbs_activity_elt_id
        retained_cost_level["#{level}"] = level_retained_cost_with_wbs_activity_elt_id
      end

      # Get the input effort values
      probable_input_effort_values = input_effort_values["most_likely"] ###params[:values]["most_likely"].to_f * effort_unit_coefficient
      if @wbs_activity.three_points_estimation?
        ###probable_input_effort_values = (input_effort_values["low"].to_f + (4 * input_effort_values["most_likely"].to_f) + input_effort_values["high"].to_f)/6
        probable_input_effort_values = Hash.new
        input_effort_values["most_likely"].each do |key, value|
          probable_input_effort_values[key] = (input_effort_values["low"][key].to_f + (4 * input_effort_values["most_likely"][key].to_f) + input_effort_values["high"][key].to_f)/6
        end
      end

      #### Save the module_project_ratio_variables values from de probable value
      calculator = Dentaku::Calculator.new

      #store entries value
      effort_ids = module_project_attributes.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten  #PeAttribute.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten
      current_inputs_evs = @module_project.estimation_values.where(pe_attribute_id: effort_ids, in_out: "input")
      current_inputs_evs.each do |ev|
        effort_value = params['values']['most_likely']["#{ev.id}"].to_f * effort_unit_coefficient
        calculator.store(:"#{ev.pe_attribute.alias.downcase}" => effort_value)
      end


      # Calculate the module_project_ratio_variable value_percentage
      #mp_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio_reference.id)
      mp_ratio_variables = @module_project.get_module_project_ratio_variables(@ratio_reference, @pbs_project_element)
      mp_ratio_variables.each do |mp_var|
        wbs_ratio_variable  = mp_var.wbs_activity_ratio_variable
        percentage_of_input = wbs_ratio_variable.percentage_of_input
        if wbs_ratio_variable.is_modifiable
          percentage_of_input = params['mp_ratio_variable']["#{mp_var.id}"] ###mp_var.percentage_of_input
        end
        mp_var.percentage_of_input = percentage_of_input

        # calculate value from percentage of input
        if percentage_of_input.blank?
          value_from_percentage = nil
        else
          ###value_from_percentage = calculator.evaluate("#{probable_input_effort_values.to_f} * #{percentage_of_input}")
          formula_expression = "#{percentage_of_input.downcase}"
          begin
            normalized_formula_expression = formula_expression.gsub('%', ' * 0.01 ')
          rescue
            normalized_formula_expression = nil
          end

          value_from_percentage = calculator.evaluate("#{normalized_formula_expression}")
        end

        mp_var.value_from_percentage = value_from_percentage.to_f

        if mp_var.save
          if mp_var.wbs_activity_ratio_variable.is_used_in_ratio_calculation == true
            input_effort_for_global_ratio += value_from_percentage.to_f
          end
        end
      end


      ## Update module_project_ratio_element selected attribute
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

        if mp_ratio_element.changed?
          mp_ratio_element.save
        end
      end

    end


    #===== Appel Effort breakdown avec calcul de toutes des valeurs des attributs (theoretical_effot, retained_effort, theoretical_cost, retained_cost) =====
    effort_breakdown = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, input_effort_values["most_likely"],
                                                            @ratio_reference, just_changed_values, retained_effort_level["most_likely"],
                                                            retained_cost_level["most_likely"], initialize_calculation)

    theoretical_efforts, theoretical_cost, retained_efforts, retained_costs = effort_breakdown.calculate_estimations


    current_pbs_estimations.each do |est_val|

      @tmp_results = Hash.new

      unless est_val.pe_attribute.nil?
        if est_val.pe_attribute.alias == "ratio_name"
          ratio_name = @ratio_reference.name
          est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_name })

        #elsif est_val.pe_attribute.alias.in?("theoretical_effort", "theoretical_cost", "effort", "cost")
        elsif est_val.pe_attribute.alias.in?("theoretical_effort", "theoretical_cost", "effort", "cost", "E1", "E2", "E3", "E4")
          if (est_val.in_out == 'output') && (est_val.pe_attribute.alias.in?("theoretical_effort", "theoretical_cost", "effort", "cost"))

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
                retained_attribute = module_project_attributes.where(alias: "effort").first  #PeAttribute.find_by_alias("effort")
                mp_ratio_element_attribute_alias = "effort"
              when "theoretical_cost"
                retained_attribute = module_project_attributes.where(alias: "cost").first  #PeAttribute.find_by_alias("cost")
                mp_ratio_element_attribute_alias = "cost"
            end

            #retained_est_val = EstimationValue.where(:pe_attribute_id => retained_attribute.id, :module_project_id => @module_project.id, :in_out => "output").first_or_create

            ["low", "most_likely", "high"].each do |level|
              if @wbs_activity.three_points_estimation?
                ###eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values][level].to_f * effort_unit_coefficient, @ratio_reference)
                effort_breakdown = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, input_effort_values[level],
                                                                        @ratio_reference, just_changed_values, retained_effort_level[level],
                                                                        retained_cost_level[level], initialize_calculation)
                theoretical_efforts, theoretical_cost, retained_efforts, retained_costs = effort_breakdown.calculate_estimations
              else
                #eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference)
                ###effort_breakdown = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference, just_changed_values, retained_effort_level["most_likely"], retained_cost_level["most_likely"], initialize_calculation)
              end

              ###@tmp_results[level.to_sym] = { "#{est_val.pe_attribute.alias}_#{current_module_project.id}".to_sym => effort_breakdown.send("get_#{est_val.pe_attribute.alias}") }
              @tmp_results[level.to_sym] = { "#{est_val.pe_attribute.alias}_#{current_module_project.id}".to_sym => effort_breakdown.send("#{mp_pe_attribute_alias}") }

              level_estimation_value[@pbs_project_element.id] = @tmp_results[level.to_sym]["#{est_val.pe_attribute.alias}_#{current_module_project.id.to_s}".to_sym]
              @results["string_data_#{level}"] = level_estimation_value


              #=========== Save results in the Module-Project Ratio Elements THEORETICAL (and RETAINED VALUE if necessary) ===============
              @module_project_ratio_elements.each do |mp_ratio_element|
                element_level_estimation_value = level_estimation_value[@pbs_project_element.id][mp_ratio_element.wbs_activity_element_id]
                if element_level_estimation_value.is_a?(Float) && element_level_estimation_value.nan?
                  element_level_estimation_value = nil
                else
                  element_level_estimation_value = element_level_estimation_value
                end
                mp_ratio_element.send("#{mp_pe_attribute_alias}_#{level}=", element_level_estimation_value)

                # Then update retained values if necessary
                #element_retained_mp_value = mp_ratio_element.send("retained_#{mp_ratio_element_attribute_alias}_#{level}")
                #if element_retained_mp_value.nil?
                #  mp_ratio_element.send("retained_#{mp_ratio_element_attribute_alias}_#{level}=", element_level_estimation_value)
                #end

                if mp_ratio_element.changed?
                  mp_ratio_element.save
                end
              end
            end
            #=========== END Save results in the Module-Project Ratio Elements  ===================

            WbsActivityElement.rebuild_depth_cache!
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
            wbs_activity_elements = @wbs_activity.wbs_activity_elements

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
              #wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt.id}"] = 0.0 }
              wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt.id}"] = nil }

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

                    #if est_val.pe_attribute.alias == "cost" or "theoretical_cost"
                    if est_val.pe_attribute.alias.in?("theoretical_cost", "cost")
                      ####eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values]["most_likely"].to_f * effort_unit_coefficient, @ratio_reference, just_changed_values, retained_effort_level["most_likely"], retained_cost_level["most_likely"], initialize_calculation)
                      ####efforts_man_month = eb.get_effort  ### efforts_man_month = eb.get_theoretical_effort

                      effort_man_month_attribute = "retained_effort"
                      if est_val.pe_attribute.alias == "theoretical_cost"
                        effort_man_month_attribute = "theoretical_effort"
                      end
                      efforts_man_month = effort_breakdown.send("#{effort_man_month_attribute}")

                      res = Hash.new
                      ####res = eb.get_cost
                      efforts_man_month.each do |key, value|
                        tmp = Hash.new
                        wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: key).first
                        unless wbs_activity_ratio_element.nil?
                          wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                            if efforts_man_month[key].nil?
                              tmp[warp.organization_profile.id] = nil
                            else
                              tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * (efforts_man_month[key].to_f * @wbs_activity.effort_unit_coefficient.to_f) * (warp.ratio_value.to_f / 100)
                            end
                          end
                        end
                        res[key] = tmp

                        current_activity_element = WbsActivityElement.find(key)
                        if current_activity_element.root?
                          res[key] = tmp.values.compact.sum
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
                          estimation_value_profile = res_hash_value[profile.id]
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
                      if wbs_activity_element.is_childless?
                        estimation_value_profile = hash_value[:value].nil? ? nil : ((hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100)

                        current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => { :value => estimation_value_profile } }

                        #the update the parent's value
                        parent_profile_est_value["#{wbs_activity_element.id}"] = estimation_value_profile
                        ###parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile

                        # Update values for ancestors if the element it self is selected
                        # mp_ratio_element_for_effort_profile = @module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_element).first
                        # if (mp_ratio_element_for_effort_profile && mp_ratio_element_for_effort_profile.selected==true) #|| mp_ratio_element_for_effort_profile.nil?
                        #   # wbs_activity_element.ancestors.each do |ancestor|
                        #   #   parent_profile_est_value["#{ancestor.id}"] = parent_profile_est_value["#{ancestor.id}"].to_f + estimation_value_profile
                        #   # end
                        #   parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile
                        # end

                          #Need to calculate the parents effort by profile : addition of its children values
                          # wbs_activity_elements.each do |wbs_activity_element_id|
                          #   begin
                          #     probable_estimation_value[@pbs_project_element.id][wbs_activity_element_id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element_id}"]} }
                          #   rescue
                          #   end
                          # end
                      end
                    end
                  end
                  ###current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => estimation_value_profile} }
                end
                #  end
              end

              # #Need to calculate the parents effort / cost by profile : addition of its children values
              wbs_activity_root.children.each do |node|
                # Sort node subtree by ancestry_depth
                sorted_node_elements = node.subtree.order('ancestry_depth desc')
                sorted_node_elements.each do |wbs_activity_element|
                #wbs_activity_elements.each do |wbs_activity_element|
                  begin
                    ###probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{@ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element.id}"]} }
                    if wbs_activity_element.has_children?
                      ancestor_value = nil
                      # Update values for ancestors
                      wbs_activity_element.children.each do |child|
                        mp_ratio_element_for_effort_profile = @module_project_ratio_elements.where(wbs_activity_element_id: child.id).first
                        if mp_ratio_element_for_effort_profile && mp_ratio_element_for_effort_profile.selected==true
                          unless parent_profile_est_value["#{child.id}"].nil?
                            if ancestor_value.nil?
                              ancestor_value = parent_profile_est_value["#{child.id}"].to_f
                            else
                              ancestor_value = ancestor_value + parent_profile_est_value["#{child.id}"].to_f
                            end
                          end
                        end
                      end
                      parent_profile_est_value["#{wbs_activity_element.id}"] = ancestor_value
                    end

                    if probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"].nil?
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"] = Hash.new
                    end

                    if probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"].empty?
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"] = { "profile_id_#{profile.id}" => { "ratio_id_#{@ratio_reference.id}" => { :value => parent_profile_est_value["#{wbs_activity_element.id}"] } } }

                    elsif probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"].nil?
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] = Hash.new
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] =  { "ratio_id_#{@ratio_reference.id}" => { :value => parent_profile_est_value["#{wbs_activity_element.id}"] } }

                    elsif probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"].empty?
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"] =  { "ratio_id_#{@ratio_reference.id}" => { :value => parent_profile_est_value["#{wbs_activity_element.id}"] } }

                    else
                      probable_estimation_value[@pbs_project_element.id][wbs_activity_element.id]["profiles"]["profile_id_#{profile.id}"]["ratio_id_#{@ratio_reference.id}"] =  { :value => parent_profile_est_value["#{wbs_activity_element.id}"] }
                    end

                  rescue
                  end
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

            #=========== Update Module-Project-Ratio-Elements Theoretical and Retained PROBABLE-values  ======
            mp_pbs_probable_value = probable_estimation_value[@pbs_project_element.id]
            @module_project_ratio_elements.each do |mp_ratio_element|
              wbs_probable_value = mp_pbs_probable_value[mp_ratio_element.wbs_activity_element_id]
              if wbs_probable_value.nil? || (wbs_probable_value.is_a?(Float) && wbs_probable_value.nan?)
                wbs_probable_value = nil
              else
                if wbs_probable_value[:value].is_a?(Float) && wbs_probable_value[:value].nan?
                wbs_probable_value = nil
                else
                wbs_probable_value =  wbs_probable_value[:value].nil? ? nil : wbs_probable_value[:value].to_f
                end
              end
              # save theoretical values
              mp_ratio_element.send("#{mp_pe_attribute_alias}_probable=", wbs_probable_value)

              # get the retained attribute value
              #mp_retained_alias = "retained_#{mp_ratio_element_attribute_alias}_probable"
              #if mp_ratio_element.send("#{mp_retained_alias}").nil?
              #  mp_ratio_element.send("#{mp_retained_alias}=", wbs_probable_value)
              #end

              # if value is manually updated, update the flagged attribute
              unless just_changed_values.nil?
                if !just_changed_values.empty? && just_changed_values.include?("#{mp_ratio_element.id}")
                  mp_ratio_element.flagged = true
                end
              end

              if mp_ratio_element.changed?
                mp_ratio_element.save
              end
            end

            # Update flagged Effort or Cost values
            @module_project_ratio_elements.each do |mp_ratio_element|
              wbs_activity_ratio_elt = mp_ratio_element.wbs_activity_ratio_element
              if wbs_activity_ratio_elt.effort_is_modifiable == true || wbs_activity_ratio_elt.cost_is_modifiable == true
                theoretical_effort = mp_ratio_element.send("theoretical_effort_most_likely")
                retained_effort = mp_ratio_element.send("retained_effort_most_likely")

                theoretical_cost = mp_ratio_element.send("theoretical_cost_most_likely")
                retained_cost = mp_ratio_element.send("retained_cost_most_likely")

                if (theoretical_effort.to_f != retained_effort.to_f) || (theoretical_cost.to_f != retained_cost.to_f)
                  mp_ratio_element.flagged = true
                else
                  mp_ratio_element.flagged = false
                end
              else
                mp_ratio_element.flagged = false
              end

              if mp_ratio_element.changed?
                mp_ratio_element.save
              end
            end

          ###elsif est_val.in_out == 'input' && est_val.pe_attribute.alias.in?("theoretical_effort", "effort")
          #elsif est_val.in_out == 'input' && est_val.pe_attribute.alias.in?("theoretical_effort", "effort", "E1", "E2", "E3", "E4")
          elsif est_val.in_out == 'input' && est_val.pe_attribute.alias.in?("E1", "E2", "E3", "E4")
            in_result = Hash.new
            tmp_prbl = Array.new
            ['low', 'most_likely', 'high'].each do |level|
              level_estimation_value = Hash.new

              entry_level_value = nil
              if @wbs_activity.three_points_estimation?
                if est_val.pe_attribute.alias.in?("theoretical_effort", "effort")
                  entry_level_value = params[:values][level].first.last
                else
                  entry_level_value = params[:values][level]["#{est_val.id}"]
                end
                ###level_estimation_value[@pbs_project_element.id] = params[:values][level].to_f * effort_unit_coefficient
                if entry_level_value.nil? || entry_level_value.empty?
                  level_estimation_value[@pbs_project_element.id] = nil
                else
                  level_estimation_value[@pbs_project_element.id] = entry_level_value.to_f * effort_unit_coefficient
                end
                in_result["string_data_#{level}"] = level_estimation_value

              else
                if est_val.pe_attribute.alias.in?("theoretical_effort", "effort")
                  entry_level_value = params[:values]["most_likely"].first.last
                else
                  entry_level_value = params[:values]["most_likely"]["#{est_val.id}"]
                end
                ###level_estimation_value[@pbs_project_element.id] = params[:values]["most_likely"].to_f * effort_unit_coefficient
                if entry_level_value.nil? || entry_level_value.empty?
                  level_estimation_value[@pbs_project_element.id] = nil
                else
                  level_estimation_value[@pbs_project_element.id] = entry_level_value.to_f * effort_unit_coefficient
                end

                in_result["string_data_#{level}"] = level_estimation_value
              end

              tmp_prbl << level_estimation_value[@pbs_project_element.id]
            end

            est_val.update_attributes(in_result)
            pbs_input_probable_value = ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6)
            est_val.update_attribute(:"string_data_probable", { current_component.id => pbs_input_probable_value } )

            #if est_val.pe_attribute.alias == "effort"
            #  input_effort_for_global_ratio = pbs_input_probable_value
            #end
          end
        elsif est_val.pe_attribute.alias == "ratio"
          ratio_global = @ratio_reference.wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)

          #nouvelle calcul du ratio
          input_effort = input_effort_for_global_ratio
          effort_total = effort_total_for_global_ratio
          if input_effort.nil? || input_effort == 0
            new_ratio_global = nil
          else
            new_ratio_global = (effort_total.to_f / input_effort.to_f) * 100.0
          end

          #est_val.update_attribute(:"string_data_probable", { current_component.id => ratio_global })
          est_val.update_attribute(:"string_data_probable", { current_component.id => new_ratio_global })
        end
      end
    end


    # if Initialize calculation, update the flagged attribute to false
    if initialize_calculation == true
      ## Update selected attribute
      @module_project_ratio_elements.each do |mp_ratio_element|
        mp_ratio_element.flagged = false
        mp_ratio_element.save
      end
    end


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


    @wbs_activity_ratio = @ratio_reference
    redirect_to dashboard_path(@project, ratio: @ratio_reference.id, anchor: 'save_effort_breakdown_form')
  end



  def the_most_largest(my_string)
    ind = 0
    len = 0
    len2 = 0
    if my_string.nil?
      return 1
    end
    while my_string[ind]
      if my_string[ind] == "\n" || my_string[ind + 1] == nil
        if len2 < len
          len2 = len
        end
        len = 0
      else
        len += 1
      end
      ind += 1
    end
    len2
  end


  #Export the WBS
  def export_xlsx
    authorize! :show_modules_instances, ModuleProject

    ActiveRecord::Base.transaction do

      @wbs_activity = WbsActivity.find(params[:wbs_activity_id])

      if @wbs_activity

        wbs_activity_elements_list = @wbs_activity.wbs_activity_elements.arrange(order: 'position')
        @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity_elements_list)

        @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
        wbs_organization_profiles = @wbs_activity.organization_profiles.order('name')

        workbook = RubyXL::Workbook.new
        workbook.add_worksheet(I18n.t(:wbs_elements))  #workbook.add_worksheet("WBS-Activity-Elements")
        workbook.add_worksheet("Ratios")
        #workbook.add_worksheet("Ratio Elements")

        ind = 0
        ind1 = 0
        ind2 = 1
        ind3 = 5
        used_column = []

        # add worksheet to workbook
        model_worksheet = workbook[0]
        elements_worksheet = workbook[1]
        ratios_worksheet = workbook[2]
        #ratio_elements_worksheet = workbook[3]
        new_workbook_number = 3

        model_worksheet.sheet_name = "Model"

        first_page = [[I18n.t(:model_name),  @wbs_activity.name],
                      [I18n.t(:model_description), @wbs_activity.description ],
                      [I18n.t(:three_points_estimation), @wbs_activity.three_points_estimation ? 1 : 0],
                      [I18n.t(:modification_entry_valur), @wbs_activity.enabled_input ? 1 : 0 ],
                      [I18n.t(:hide_wbs_header), @wbs_activity.hide_wbs_header ? 1 : 0 ],
                      [I18n.t(:Wording_of_the_module_unit_effort), @wbs_activity.effort_unit],
                      [I18n.t(:Conversion_factor_standard_effort), @wbs_activity.effort_unit_coefficient],
                      ["#{I18n.t(:profiles_list)} : ", ""]]
                      #[I18n.t(:advice_ge), ""]]

        wbs_organization_profiles.each_with_index do |profile, index|
          first_page << ["Profil #{index+1}", profile.name]
        end
        first_page << [I18n.t(:advice_ge), ""]

        first_page.each_with_index do |row, index|
          model_worksheet.add_cell(index, 0, row[0])
          model_worksheet.add_cell(index, 1, row[1]).change_horizontal_alignment('center')
          ["bottom", "right"].each do |symbole|
            model_worksheet[index][0].change_border(symbole.to_sym, 'thin')
            model_worksheet[index][1].change_border(symbole.to_sym, 'thin')
          end
        end
        model_worksheet.change_column_bold(0,true)
        model_worksheet.change_column_width(0, 60)
        model_worksheet.change_column_width(1, 100)
        model_worksheet.sheet_data[1][1].change_horizontal_alignment('left')


        # WBS ACTIVITY ELEMENTS  : activity_elements_worksheet
        # activity_elements_worksheet
        counter_line = 1
        elements_worksheet.add_cell(0, 0, I18n.t('position'))
        elements_worksheet.add_cell(0, 1, I18n.t(:phase_short_name))
        elements_worksheet.add_cell(0, 2, I18n.t(:name))
        elements_worksheet.add_cell(0, 3, I18n.t(:description))
        elements_worksheet.add_cell(0, 4, "Root")
        elements_worksheet.add_cell(0, 5, I18n.t('parent'))

        elements_worksheet.change_row_bold(0,true)

        elements_worksheet.change_row_horizontal_alignment(0, 'center')
        @wbs_activity_elements.each_with_index do |activity_element, index|

          elements_worksheet.add_cell(index + 1, 0, activity_element.position)
          elements_worksheet.add_cell(index + 1, 1, activity_element.phase_short_name)
          elements_worksheet.add_cell(index + 1, 2, activity_element.name)
          elements_worksheet.add_cell(index + 1, 3, activity_element.description)
          elements_worksheet.add_cell(index + 1, 4, activity_element.is_root ? 1 : 0)
          elements_worksheet.add_cell(index + 1, 5, (activity_element.parent.nil? ? nil : activity_element.parent.name))


          if ind < activity_element.name.size
            elements_worksheet.change_column_width(0, I18n.t('position').size)
            elements_worksheet.change_column_width(1, I18n.t(:phase_short_name).size)
            elements_worksheet.change_column_width(2, activity_element.name.size)
            elements_worksheet.change_column_width(3, I18n.t(:description).size)
            elements_worksheet.change_column_width(4, 10)
            ind = activity_element.name.size

            ind2 = elements_worksheet.get_column_width(3)
          end
          if ind2 < the_most_largest(activity_element.description)
            elements_worksheet.change_column_width(3, the_most_largest(activity_element.description))
            ind2 = the_most_largest(activity_element.description)
          end
          counter_line += 1
        end

        counter_line.times.each do |line|
          ["bottom", "right"].each do |symbole|
            elements_worksheet[line][0].change_border(symbole.to_sym, 'thin')
            elements_worksheet[line][1].change_border(symbole.to_sym, 'thin')
            elements_worksheet[line][2].change_border(symbole.to_sym, 'thin')
            elements_worksheet[line][3].change_border(symbole.to_sym, 'thin')
            elements_worksheet[line][4].change_border(symbole.to_sym, 'thin')
          end
        end


        #WBS ACTIVITY RATIO - ratios_worksheet
        ind = 0
        ind2 = 1
        counter_line = 1
        ratios_worksheet.add_cell(0, 0, I18n.t(:name))
        ratios_worksheet.add_cell(0, 1, I18n.t(:description))
        ratios_worksheet.add_cell(0, 2, I18n.t(:do_not_show_cost))
        ratios_worksheet.add_cell(0, 3, I18n.t(:do_not_show_phases_with_zero_value))
        ratios_worksheet.change_row_bold(0,true)

        ratios_worksheet.change_row_horizontal_alignment(0, 'center')
        @wbs_activity_ratios.each_with_index do |ratio, index|
          ratios_worksheet.add_cell(index + 1, 0, ratio.name)
          ratios_worksheet.add_cell(index + 1, 1, ratio.description)
          ratios_worksheet.add_cell(index + 1, 2, ratio.do_not_show_cost ? 1 : 0)
          ratios_worksheet.add_cell(index + 1, 3, ratio.do_not_show_phases_with_zero_value ? 1 : 0)

          if ind < ratio.name.size
            ratios_worksheet.change_column_width(0, ratio.name.size)
            ind = ratio.name.size
          end
          if ind2 < the_most_largest(ratio.description)
            ratios_worksheet.change_column_width(1, the_most_largest(ratio.description))
            ind2 = the_most_largest(ratio.description)
          end

          ratios_worksheet.change_column_width(2, I18n.t(:do_not_show_cost).size)
          ratios_worksheet.change_column_width(3, I18n.t(:do_not_show_phases_with_zero_value).size)

          counter_line += 1

        end

        counter_line.times.each do |line|
          ["bottom", "right"].each do |symbole|
            ratios_worksheet[line][0].change_border(symbole.to_sym, 'thin')
            ratios_worksheet[line][1].change_border(symbole.to_sym, 'thin')
          end
        end

        # WSB ACTIVITY RATIO ELEMENTS - ratio_elements_worksheet
        # Les attributs de ratio-element
        ratio_attributes = ["name"] #["name", "do_not_show_cost", "do_not_show_phases_with_zero_value"]
        counter_line = 1
        # On cree une feuille par element de ratio
        @wbs_activity_ratios.each_with_index do |ratio, index|
          # on cree une feuille pour tous les elments de ce ratio
          workbook.add_worksheet("#{ratio.name}")
          ratio_elements_worksheet = workbook["#{ratio.name}"]
          new_workbook_number += 1

          ratio_elements_worksheet.add_cell(0, 0, I18n.t(:name))
          #ratio_elements_worksheet.add_cell(1, 0, I18n.t(:do_not_show_cost))
          #ratio_elements_worksheet.add_cell(2, 0, I18n.t(:do_not_show_phases_with_zero_value))

          ratio_elements_worksheet.add_cell(0, 1, ratio.name)
          #ratio_elements_worksheet.add_cell(1, 1, ratio.do_not_show_cost ? 1 : 0)
          #ratio_elements_worksheet.add_cell(2, 1, ratio.do_not_show_phases_with_zero_value ? 1 : 0)

          ratio_elements_worksheet.change_column_bold(0,true)
          ratio_elements_worksheet.change_column_width(0, I18n.t(:do_not_show_phases_with_zero_value).size)
          counter_line = 2 #4


          # WBS-ACTIVITY-RATIO-VARIABLES
          ratio_elements_worksheet.add_cell(counter_line, 0, "Ratio Variables")
          #ratio_elements_worksheet.change_row_bold(counter_line,true)

          ratio_variable_attributes = ["name", "percentage_of_input", "is_modifiable", "is_used_in_ratio_calculation", "description"]

          ratio_variable_attributes.each_with_index do |variable_attr, index|
            column_number = index + 1
            ratio_elements_worksheet.add_cell(counter_line, column_number, I18n.t("#{variable_attr}")).change_horizontal_alignment('center')
            ratio_elements_worksheet.change_column_width(column_number, I18n.t("#{variable_attr}").size)

            ["bottom", "right"].each do |symbole|
              begin
                ratio_elements_worksheet[counter_line][column_number].change_border(symbole.to_sym, 'thin')
              rescue
              end
            end

            line_number = counter_line + 1
            ratio.wbs_activity_ratio_variables.each do |ratio_variable|
              value = ratio_variable.send(variable_attr)

              if variable_attr.in?("is_modifiable", "is_used_in_ratio_calculation")
                val = ratio_variable.send(variable_attr)
                if val == true
                  value = 1
                else
                  value = 0
                end
              end

              ratio_elements_worksheet.add_cell(line_number, column_number, value)
              line_number += 1
            end
          end

          counter_line += 6


          # WBS-ACTIVITY-RATIO-ELEMENTS
          ratio_elements = ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
          wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

          ratio_elements_worksheet.add_cell(counter_line, 0, "Formule de calcul de chaque phase de la WBS")
          ratio_elements_attributes = ["position", "phase_short_name", "name", "description", "is_optional", "effort_is_modifiable", "cost_is_modifiable", "formula"]

          ratio_elements_attributes.each_with_index do |attr, index|
            column_number = index + 1

            ratio_elements_worksheet.add_cell(counter_line, column_number, I18n.t("#{attr}")).change_horizontal_alignment('center')
            ratio_elements_worksheet.change_column_width(column_number, I18n.t("#{attr}").size)

            line_number = counter_line + 1

            wbs_activity_ratio_elements.each do |ratio_element|
              if attr.in?("position", "phase_short_name", "name", "description")
                activity_element = ratio_element.wbs_activity_element
                if activity_element
                  value = activity_element.send(attr)
                else
                  value = nil
                end

              elsif attr.in?("is_optional", "effort_is_modifiable", "cost_is_modifiable")
                val = ratio_element.send(attr)
                if val == true
                  value = 1
                else
                  value = 0
                end

              else
                value = ratio_element.send(attr)
              end

              ratio_elements_worksheet.add_cell(line_number, column_number, value)
              column_width = ratio_elements_worksheet.get_column_width(column_number)
              if !value.nil? && value.to_s.size > column_width
                ratio_elements_worksheet.change_column_width(column_number, value.to_s.size)
              end

              ["bottom", "right"].each do |symbole|
                begin
                  ratio_elements_worksheet[line_number][column_number].change_border(symbole.to_sym, 'thin')
                rescue
                end
              end

              line_number += 1
            end
          end

          counter_line += @wbs_activity_elements.length
          counter_line += 2


          # WBS-ACTIVITY-RATIO-PROFILES
          wbs_activity_profiles = wbs_organization_profiles

          ratio_elements_worksheet.add_cell(counter_line, 0, "Valeurs des ratios par profils")
          ratio_elements_worksheet.add_cell(counter_line, 1, I18n.t(:position)).change_horizontal_alignment('center')
          ratio_elements_worksheet.add_cell(counter_line, 2, "Phases").change_horizontal_alignment('center')

          column_number = 2

          ratio_profile_attributes = ["position", "name"]
          wbs_activity_profiles.each do |profile|
            ratio_profile_attributes << profile.name

            column_number += 1
            ratio_elements_worksheet.add_cell(counter_line, column_number, profile.name).change_horizontal_alignment('center')

            column_width = ratio_elements_worksheet.get_column_width(column_number)
            if profile.name.to_s.size > column_width
              ratio_elements_worksheet.change_column_width(column_number, profile.name.to_s.size)
            end
          end

          line_number = counter_line + 1
          wbs_activity_ratio_elements.each do |ratio_element|

            ratio_elements_worksheet.add_cell(line_number, 1, ratio_element.wbs_activity_element.position)
            ratio_elements_worksheet.add_cell(line_number, 2, ratio_element.wbs_activity_element.name)

            column_width = ratio_elements_worksheet.get_column_width(2)
            if ratio_element.wbs_activity_element.name.to_s.size > column_width
              ratio_elements_worksheet.change_column_width(2, ratio_element.wbs_activity_element.name.to_s.size)
            end

            wbs_activity_profiles.each_with_index do |profile, index|
              activity_profile = WbsActivityRatioProfile.where(wbs_activity_ratio_element_id: ratio_element.id, organization_profile_id: profile.id).first
              current_percentage =  activity_profile.nil? ? nil : activity_profile.ratio_value
              ratio_elements_worksheet.add_cell(line_number, index + 3, "#{current_percentage}")
            end

            line_number += 1
          end

          counter_line += @wbs_activity_elements.length
          counter_line += 2


          all_columns_number = ratio_elements_attributes.length
          if ratio_profile_attributes.length > all_columns_number
            all_columns_number = ratio_profile_attributes.length
          end
          counter_line.times.each do |line|
            all_columns_number.times do |column|
              ["bottom", "right"].each do |symbole|
                begin
                  ratio_elements_worksheet[line][column].change_border(symbole.to_sym, 'thin')
                rescue
                end
              end
            end
          end
        end

        # Send the file
        send_data(workbook.stream.string, filename: "#{@wbs_activity.organization.name[0..4]}-#{@wbs_activity.name.gsub(" ", "_")}_wbs_data-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")

      else
        flash[:error] = "WBS-Activity introuvable"
      end
    end

  end


  #Import a new WBS-Activities from a CVS file
  def import_wbs_from_xl

    authorize! :manage_modules_instances, ModuleProject


    @organization = Organization.find(params[:organization_id])
    organization_profiles = @organization.organization_profiles

    tab_error = []
    # Debut transaction
    ActiveRecord::Base.transaction do
      if params[:file]
        if !params[:file].nil? && (File.extname(params[:file].original_filename).to_s.downcase == ".xlsx")

          #get the file data
          workbook = RubyXL::Parser.parse(params[:file].path)

          #if a model exists, only factors data will be imported
          if !params[:wbs_activity_id].nil? && !params[:wbs_activity_id].empty?

            @wbs_activity = WbsActivity.find(params[:wbs_activity_id])

          else
            #there is no model, we will create new model from the model attributes data of the file to import
            model_sheet_order_attributes = ["name", "description", "three_points_estimation", "enabled_input", "hide_wbs_header", "effort_unit", "effort_unit_coefficient",
                                            "wbs_organization_profiles"]

            model_sheet_order = Hash.new
            model_sheet_order_attributes.each_with_index do |attr_name, index|
              model_sheet_order["#{index}".to_sym] = attr_name
            end

            model_worksheet = workbook['Model']

            if !model_worksheet.nil?
              @wbs_activity = WbsActivity.new
              @wbs_activity.organization = @organization

              model_worksheet.each_with_index do | row, index |
                row && row.cells.each do |cell|
                  if !cell.nil?
                    if cell.column == 1
                      val = cell && cell.value

                      if index <= 7  ### Ligne des profiles
                        attr_name = model_sheet_order["#{index}".to_sym]
                        #begin
                          if attr_name != "wbs_organization_profiles"
                            @wbs_activity["#{attr_name}"] = val unless attr_name.nil?
                          end
                        # rescue
                        # end
                      else
                        # Gestion dse profils
                        if row.cells[0].value.include?("Profil")
                          organization_profile = organization_profiles.where(name: val).first
                          if organization_profile.nil?
                            organization_profile = OrganizationProfile.create(organization_id: @organization.id, name: val, description: val, cost_per_hour: 0)
                            @organization.organization_profiles << organization_profile
                            @organization.save(validate: false)
                            organization_profiles = @organization.organization_profiles
                          end

                          @wbs_activity.organization_profiles << organization_profile
                        end
                      end
                    end
                  end
                end
              end


              if @wbs_activity && @wbs_activity.save
                ######## WBS-Activity_elements worksheet  ######
                activity_elements_sheet_order_attributes = [ "position", "phase_short_name", "name", "description", "is_root", "parent"]
                elements_parents = Hash.new
                # activity_elements_sheet_order = Hash.new
                # activity_elements_sheet_order_attributes.each_with_index do |attr_name, index|
                #   activity_elements_sheet_order["#{index}".to_sym] = attr_name
                # end

                elements_worksheet = workbook[I18n.t(:wbs_elements)]

                begin
                  elements_worksheet_tab = elements_worksheet.extract_data
                rescue
                  flash[:error] = "La feuille des éléments de la WBS n'existe pas"
                  redirect_to request.referer + "#tabs-1" and return
                end

                elements_worksheet_tab.each_with_index do | row, index |
                  if index != 0 && !row.nil?
                    activity_element = WbsActivityElement.create(wbs_activity_id: @wbs_activity.id, position: row[0].to_f, phase_short_name: row[1],
                                                                 name: row[2], description: row[3], is_root: row[4])
                    elements_parents["#{activity_element.id}"] = row[5]
                  end
                end

                # Update wbs-activity-element parent (ancestry)
                elements_parents.each do |key, parent_name|
                  #begin
                    activity_element = WbsActivityElement.find(key)
                    parent = WbsActivityElement.where(name: parent_name, wbs_activity_id: @wbs_activity.id).first
                    if !parent.nil?
                      activity_element.parent = parent
                    end
                    activity_element.save
                  # rescue
                  # end
                end

                # Update WBS Phase phases_short_name_number
                wbs_elements_short_names = @wbs_activity.wbs_activity_elements.map(&:phase_short_name)
                phases_short_name_number = Array.new
                wbs_elements_short_names.each_with_index do |shortname, index|
                  begin
                    phases_short_name_number[index] = shortname.scan(/\d+/).first.to_i
                  rescue
                    phases_short_name_number[index] = index+1
                  end
                end

                @wbs_activity.phases_short_name_number = phases_short_name_number.max
                @wbs_activity.save

                ######## Ratios worksheet  ######
                ratios_worksheet = workbook["Ratios"]
                begin
                  ratios_worksheet_tab = ratios_worksheet.extract_data
                rescue
                  flash[:error] = "La feuille contenant la liste des Ratios n'existe pas"
                  redirect_to request.referer + "#tabs-1" and return
                end

                ratios_worksheet_tab.each_with_index do | row, index |
                  if index > 0 && !row.nil?
                    #begin
                      WbsActivityRatio.create(wbs_activity_id: @wbs_activity.id, name: row[0], description: row[1], do_not_show_cost: row[2], do_not_show_phases_with_zero_value: row[3])
                    # rescue
                    # end
                  end
                end

                ######## Ratios Elements worksheet  ######
                @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
                @wbs_activity_elements = @wbs_activity.wbs_activity_elements
                @wbs_activity_profiles = @wbs_activity.organization_profiles
                ratio_name_line = 0
                ratio_variables_line = ratio_name_line + 2
                formulas_line = ratio_variables_line + 6
                ratio_profiles_line = formulas_line + @wbs_activity_elements.size + 2
                profile_col_number = Hash.new

                @wbs_activity_ratios.each do |ratio|

                  ratio_elements_worksheet = workbook["#{ratio.name}"]
                  begin
                    ratio_elements_worksheet_tab = ratio_elements_worksheet.extract_data
                  rescue
                    flash[:error] = "La feuille des éléments du ratio '#{ratio.name}' n'existe pas"
                    redirect_to request.referer + "#tabs-1" and return
                  end

                  ratio_elements_worksheet_tab.each_with_index do | row, index |
                    unless row.nil?
                      if index > 0
                        case index
                          # Wbs-activity_ratio-variables
                          when ratio_variables_line+1..ratio_variables_line+4

                            WbsActivityRatioVariable.create(wbs_activity_ratio_id: ratio.id, name: row[1], percentage_of_input: row[2],
                                               is_modifiable: row[3], is_used_in_ratio_calculation: row[4], description: row[5])

                          # Elements formulas
                          when formulas_line+1..formulas_line+@wbs_activity_elements.size

                            wbs_activity_element = @wbs_activity_elements.where(name: row[3]).first
                            WbsActivityRatioElement.create(wbs_activity_ratio_id: ratio.id, wbs_activity_element_id: wbs_activity_element.id,
                                                            is_optional: row[5], effort_is_modifiable: row[6], cost_is_modifiable: row[7], formula: row[8])

                          # Ratio-elements par profile
                          when ratio_profiles_line..ratio_profiles_line+@wbs_activity_elements.size

                            if index == ratio_profiles_line
                              (3..(3+@wbs_activity_profiles.size-1)).to_a.each do |j|
                                val = row[j]
                                if !val.blank?
                                  profile = @wbs_activity_profiles.where(name: val).first
                                  unless profile.nil?
                                    profile_col_number["#{profile.name}"] = j
                                  end
                                end
                              end

                            else
                              wbs_activity_element = @wbs_activity_elements.where(name: row[2]).first
                              ratio_element = ratio.wbs_activity_ratio_elements.where(wbs_activity_element_id: wbs_activity_element.id).first

                              @wbs_activity_profiles.each do |profile|
                                k = profile_col_number["#{profile.name}"]
                                unless k.nil?
                                  if row[k].blank?
                                    ratio_value = nil
                                  else
                                    ratio_value = row[k].to_f
                                  end

                                  WbsActivityRatioProfile.create(wbs_activity_ratio_element_id: ratio_element.id, organization_profile_id: profile.id, ratio_value: ratio_value)
                                end
                              end
                            end
                        end
                      end
                    end
                  end
                end

                flash[:notice] = "Modèle créé avec succès"
              else
                existing_ge_model_name = WbsActivity.where(name: @wbs_activity.name).first
                if existing_ge_model_name
                  tab_error << "Erreur : une instance avec le nom '#{@wbs_activity.name}' existe déjà"
                  flash[:error] = "Erreur : une instance avec le nom '#{@wbs_activity.name}' existe déjà"
                else
                  tab_error << "Une erreur est survenue lors de la création du modèle"
                  flash[:error] = "Une erreur est survenue lors de la création du modèle"
                end
              end
            else
              tab_error << "Les attributs du modèle ne sont pas définis dans le fichier importé"
              flash[:error] = "Les attributs du modèle ne sont pas définis dans le fichier importé"
            end
          end
        else
          flash[:error] =  I18n.t(:route_flag_error_4)
        end
      else
        flash[:error] =  I18n.t(:route_flag_error_17)
      end

      if @wbs_activity && @wbs_activity.save
        redirect_to edit_wbs_activity_path(@wbs_activity, anchor: "tabs-1")
      else
        redirect_to request.referer + "#tabs-1" #redirect_to :back
      end
    end
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

end
