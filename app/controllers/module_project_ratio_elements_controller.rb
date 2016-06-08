class ModuleProjectRatioElementsController < ApplicationController

  def new
    @module_project_ratio_element = ModuleProjectRatioElement.new
  end

  def edit

  end

  def create
    @module_project_ratio_element = ModuleProjectRatioElement.new(params[:module_project_ratio_element])
    @module_project_ratio_element.module_project_id = params[:module_project_id]
    @module_project_ratio_element.wbs_activity_ratio_id = params[:wbs_activity_ratio_id]
    @module_project_ratio_element.pbs_project_element_id = params[:pbs_project_element_id]

    if @module_project_ratio_element.save
      redirect_to dashboard_path(@project)
    else
      render(:edit)
    end
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

      # Module_project Ratio elements
      @module_project_ratio_elements = @module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: @wbs_activity_ratio.id, pbs_project_element_id: @pbs_project_element.id)

      if @module_project_ratio_elements.nil? || @module_project_ratio_elements.empty?
        #create module_project ratio elements
        @wbs_activity_ratio.wbs_activity_ratio_elements.each do |ratio_element|

          #mp_ratio_element = ModuleProjectRatioElement.new(pbs_project_element_id: @pbs_project_element.id, module_project_id: my_module_project.id, wbs_activity_ratio_id: ratio.id, wbs_activity_ratio_element_id: ratio_element.id,
          #                                                 multiple_references: ratio_element.multiple_references, name: ratio_element.wbs_activity_element.name, description: ratio_element.wbs_activity_element.description,
          #                                                 ratio_value: ratio_element.ratio_value, wbs_activity_element_id: ratio_element.wbs_activity_element_id, position: ratio_element.wbs_activity_element.position)

          mp_ratio_element = ModuleProjectRatioElement.where(pbs_project_element_id: @pbs_project_element.id, module_project_id: @module_project.id,
                                                             wbs_activity_ratio_id: @wbs_activity_ratio.id, wbs_activity_ratio_element_id: ratio_element.id)
                                                      .first_or_create(pbs_project_element_id: @pbs_project_element.id, module_project_id: @module_project.id,
                                                          wbs_activity_ratio_id: @wbs_activity_ratio.id, wbs_activity_ratio_element_id: ratio_element.id,
                                                          multiple_references: ratio_element.multiple_references, wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                                          name: ratio_element.wbs_activity_element.name, description: ratio_element.wbs_activity_element.description,
                                                          ratio_value: ratio_element.ratio_value,  position: ratio_element.wbs_activity_element.position)
        end
      end
    end

    #@total = @module_project_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
  end


  def  refresh_dashboard_retained_cost
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

    @selected_ratio = @wbs_activity_ratio
    @pbs_project_element = current_component
    @module_project = current_module_project
    @mp_ratio_element = ModuleProjectRatioElement.find(params["mp_ratio_element_id"])

    if @wbs_activity_ratio && @mp_ratio_element
      @wbs_activity_element = @mp_ratio_element.wbs_activity_element
      wbs_activity_ratio_element_id = @mp_ratio_element.wbs_activity_ratio_element_id

      if @wbs_activity_element
        wbs_activity = @wbs_activity_element.wbs_activity

        #get element parent
        parent_wbs_activity_element_id = @wbs_activity_element.parent_id
        @mp_ratio_element_parent_id = ModuleProjectRatioElement.where(pbs_project_element_id: @pbs_project_element.id, module_project_id: @module_project.id,
                                                                     wbs_activity_ratio_id: @wbs_activity_ratio.id, wbs_activity_ratio_element_id: wbs_activity_ratio_element_id).first

        level = params['level']
        ratio_value = params['ratio_value']
        effort_value = params['effort_value']
        @retained_effort_id = "retained_cost_#{level}_#{params["mp_ratio_element_id"]}"

        @cost_value = calculate_cost_from_effort(effort_value, @mp_ratio_element, wbs_activity.effort_unit_coefficient)

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
