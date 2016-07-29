class ModuleProjectRatioElementsController < ApplicationController

  def new
    @module_project_ratio_element = ModuleProjectRatioElement.new
    if params[:module_project_id]
      @module_project = ModuleProject.find(params[:module_project_id])
      @pbs_project_element = PbsProjectElement.find(params[:pbs_project_element_id])
      @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

      @potential_parents = @module_project.get_module_project_ratio_elements(@wbs_activity_ratio, @pbs_project_element, false)
    end
    @selected_parent ||= @potential_parents.find(params[:selected_parent_id])
  end

  def edit
    @module_project_ratio_element = ModuleProjectRatioElement.find(params[:id])

    @module_project = @module_project_ratio_element.module_project
    @pbs_project_element = @module_project_ratio_element.pbs_project_element
    @wbs_activity_ratio = @module_project_ratio_element.wbs_activity_ratio

    if @module_project_ratio_element.ancestry.nil?
      @potential_parents = []
    else
      @potential_parents = @module_project.get_module_project_ratio_elements(@wbs_activity_ratio, @pbs_project_element)
    end

    @selected_parent = @module_project_ratio_element.parent
  end


  def create
    @module_project_ratio_element = ModuleProjectRatioElement.new(params[:module_project_ratio_element])
    @module_project_ratio_element.module_project_id = params[:module_project_id]
    @module_project_ratio_element.wbs_activity_ratio_id = params[:wbs_activity_ratio_id]
    @module_project_ratio_element.pbs_project_element_id = params[:pbs_project_element_id]

    if @module_project_ratio_element.save
      redirect_to dashboard_path(@project)
    else
      render(:new)
    end
  end


  def update
    @module_project_ratio_element = ModuleProjectRatioElement.find(params[:id])
    if @module_project_ratio_element.update_attributes(params[:module_project_ratio_element])
      redirect_to dashboard_path(@project)
    else
      render(:edit)
    end
  end


  def destroy
    @module_project_ratio_element = ModuleProjectRatioElement.find(params[:id])
    @module_project_ratio_element.delete

    # Then update root element Effort and Cost value
    # TODO
    redirect_to main_app.dashboard_path(@project)
  end

  def load_comments
    @module_project_ratio_element = ModuleProjectRatioElement.find(params[:'module_project_ratio_element_id'])
  end

  def save_comments
    @module_project_ratio_element = ModuleProjectRatioElement.find(params[:comments].keys.first)
    @module_project_ratio_element.name = params[:name].values.first
    @module_project_ratio_element.comments = params[:comments].values.first
    @module_project_ratio_element.save
    redirect_to main_app.dashboard_path(@project)
  end


  def refresh_dashboard_module_project_ratio_elements

    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

    @selected_ratio = @wbs_activity_ratio
    @pbs_project_element = current_component
    @module_project = current_module_project

    if @wbs_activity_ratio

      @wbs_activity = @wbs_activity_ratio.wbs_activity
      @wbs_activity_input = WbsActivityInput.where(module_project_id: @module_project.id, wbs_activity_id: @module_project.wbs_activity_id, pbs_project_element_id: @pbs_project_element.id).first
      @organization = @wbs_activity.organization
      @effort_coefficient = @wbs_activity.effort_unit_coefficient.nil? ? 1 : @wbs_activity.effort_unit_coefficient

      # # Module_project Ratio elements
      @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@wbs_activity_ratio, @pbs_project_element)
    end

    #@total = @module_project_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
  end


  def  refresh_dashboard_retained_effort_and_cost
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

    @selected_ratio = @wbs_activity_ratio
    @pbs_project_element = current_component
    @module_project = current_module_project
    @mp_ratio_element = ModuleProjectRatioElement.find(params["mp_ratio_element_id"])
    @element_parents_ids = Array.new
    @element_parents_ids_effort_cost_values = Hash.new

    if @wbs_activity_ratio && @mp_ratio_element

      @wbs_activity_elt_root = @wbs_activity_ratio.wbs_activity.wbs_activity_elements.first.root

      @wbs_activity_element = @mp_ratio_element.wbs_activity_element
      wbs_activity = @wbs_activity_ratio.wbs_activity
      effort_unit_coefficient = wbs_activity.effort_unit_coefficient

      wbs_activity_ratio_element_id = @mp_ratio_element.wbs_activity_ratio_element_id
      @level = params['level']
      ratio_value = params['ratio_value']
      effort_value = params['effort_value']
      previous_effort_value = params['previous_effort_value']
      previous_cost_value = params['previous_cost_value']
      mp_ratio_element_parents_efforts = params['element_parents_efforts'] || []

      if @wbs_activity_element
        @retained_effort_id = "retained_cost_#{@level}_#{params["mp_ratio_element_id"]}"
        @cost_value = calculate_cost_from_effort(effort_value, @mp_ratio_element, effort_unit_coefficient)

      else
        # Il s'agit d'une phase ajouté au niveau du dashboard
        @cost_value = previous_cost_value.to_f
      end

      # Mettre à jour les valeurs de l'effort et de côut des elements parents
      mp_ratio_element_parents_efforts.each do |key, current_parent_values|
        parent_mp_ratio_element = ModuleProjectRatioElement.find(key)
        if parent_mp_ratio_element
          parent_new_effort_value = (current_parent_values[:effort].to_f - previous_effort_value.to_f) + effort_value.to_f
          parent_new_cost_value = (current_parent_values[:cost].to_f - previous_cost_value.to_f) + @cost_value.to_f
          @element_parents_ids_effort_cost_values[key] = { effort: parent_new_effort_value, cost: parent_new_cost_value }
        end
      end
    end
  end


  def refresh_dashboard_added_phase_parents_cost_value
    @level = params['level']
    cost_value = params['cost_value']
    previous_cost_value = params['previous_cost_value']
    mp_ratio_element_parents_costs = params['element_parents_costs'] || []
    @element_parents_ids_cost_values = Hash.new

    @mp_ratio_element = ModuleProjectRatioElement.find(params["mp_ratio_element_id"])
    if @mp_ratio_element
      # Mettre à jour les valeurs de l'effort et de côut des elements parents
      mp_ratio_element_parents_costs.each do |key, current_parent_values|
        parent_mp_ratio_element = ModuleProjectRatioElement.find(key)
        if parent_mp_ratio_element
          parent_new_cost_value = (current_parent_values[:cost].to_f - previous_cost_value.to_f) + cost_value.to_f
          @element_parents_ids_cost_values[key] = { cost: parent_new_cost_value }
        end
      end
    end

  end


  def calculate_cost_from_effort(effort_value, mp_ratio_element, effort_unit_coeff)

    cost_value = 0.0

    wbs_activity_element = mp_ratio_element.wbs_activity_element
    wbs_activity = wbs_activity_element.wbs_activity
    wbs_activity_root = wbs_activity.wbs_activity_elements.first.root
    wbs_activity_ratio_element = mp_ratio_element.wbs_activity_ratio_element

    unless wbs_activity_ratio_element.nil?
      tmp_cost = Hash.new
      wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
        tmp_cost[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * effort_value.to_f * warp.ratio_value.to_f / 100
      end
    end

    cost_value = tmp_cost.values.sum

    cost_value * effort_unit_coeff.to_f
  end


end
