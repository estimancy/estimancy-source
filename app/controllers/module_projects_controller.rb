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

class ModuleProjectsController < ApplicationController

  load_resource

  # Associate current module_project inputs with the preceding module_project ouputs
  def associate_module_projects_inputs_outputs

    @module_project = ModuleProject.find(params[:mp])

    #Estimation-Values association
    if params[:preceding].present?
      params[:preceding].each do |k, v|
        curr_ev = EstimationValue.where(id: k.to_i).first
        pre_ev = EstimationValue.where(id: v.to_i).first
        curr_ev.estimation_value_id = pre_ev.nil? ? nil : pre_ev.id
        curr_ev.save
      end
    end

    redirect_to :back
  end

  #Update the module_project corresponding data of view
  def update_associated_estimation_values_data
    module_project_id = params['current_module_project_id']

    if !module_project_id.nil? && module_project_id != 'undefined'
      @current_module_project = ModuleProject.find(module_project_id)
      @current_estimation_value = EstimationValue.find(params['current_estimation_value_id']) if params['current_estimation_value_id']

      begin
        if params['preceding_module_project_id'].nil? || params['preceding_module_project_id'].empty? || params['preceding_module_project_id'] == "undefined"
          @preceding_estimations_values = []
        else
          @preceding_selected_module_project = ModuleProject.find(params['preceding_module_project_id'])
          @preceding_estimations_values = @preceding_selected_module_project.get_module_project_estimation_values.where(in_out: "output")
        end
      rescue
        @preceding_estimations_values = []
      end
    end

  end



  # Reassing the current mp instance module
  def module_projects_reassign
    #Reassing
    @module_project = ModuleProject.find(params[:current_mp])

      if params[:guw_model_id].present?

        @module_project.guw_model_id = params[:guw_model_id]

      elsif params[:ge_model_id].present?

        @module_project.ge_model_id = params[:ge_model_id]

      elsif params[:staffing_model_id].present?

        @module_project.staffing_model_id = params[:staffing_model_id]

      elsif params[:wbs_activity_id].present?

        @module_project.wbs_activity_id = params[:wbs_activity_id]

      elsif params[:operation_model_id].present?

        @module_project.operation_model_id = params[:operation_model_id]

      elsif params[:expert_judgement_id].present?

        @module_project.expert_judgement_id = params[:expert_judgement_id]

      elsif params[:kb_model_id].present?

        @module_project.kb_model_id = params[:kb_model_id]

      end
    @module_project.save(validate: false)


    redirect_to :back
  end


  def edit
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project
    @organization = @module_project.organization

    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @module_projects.find_by_pemodule_id(@initialization_module.id)

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    set_page_title I18n.t(:editing, parameter: @module_project.pemodule.title)
  end


  def update
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project
    @organization = @module_project.organization

    authorize! :alter_estimation_plan, @project

    @module_project.estimation_values.each_with_index do |est_val, j|
      corresponding_am = AttributeModule.where('pemodule_id =? and pe_attribute_id = ?', @module_project.pemodule.id, est_val.pe_attribute.id).first
      if !corresponding_am.nil?
        unless corresponding_am.is_mandatory
          est_val.update_attribute('is_mandatory', params["is_mandatory_#{est_val.id}_#{est_val.in_out}"])
        end
      end
      est_val.update_attribute('description', params["description_#{est_val.id}_#{est_val.in_out}"])
    end

    # Get the project's max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    redirect_to redirect(dashboard_path(@project)), notice: "#{I18n.t (:notice_module_project_successful_updated)}"
  end


  def module_projects_matrix
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
  end

  def associate_modules_projects
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
    @module_projects.each do |mp|
      mp.update_attribute('associated_module_project_ids', params[:module_projects][mp.id.to_s])
    end
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end

  #Update the module_project dynamic connexion (add or delete)
  def update_module_project_dynamic_connections
    if params['connect_or_detach_connection']
      source_id = params['source_id'].to_i
      target_id = params['target_id'].to_i

      module_project = ModuleProject.find(source_id)
      # les successeurs du module_project
      module_project_successors_ids = module_project.inverse_associated_module_project_ids  #module_project.associated_module_project_ids

      case params['connect_or_detach_connection']
        when "connect"
          module_project_successors_ids << target_id
        when "detach"
          module_project_successors_ids.delete(target_id)
        else
          # ignored
          # type code here
      end

      #update associations
      module_project.update_attribute('inverse_associated_module_project_ids', module_project_successors_ids.uniq)
    end
  end


  #update the module_project top and left position after drag (from estimation_plan)
  def update_module_project_left_and_top_positions
    module_projects = params[:module_projects_params]
    module_projects.each do |mp_params|
      mp_node = mp_params[1]
      unless mp_node[:module_project_id].nil?
        module_project = ModuleProject.find(mp_node[:module_project_id])
        if module_project
          # Update the Module-Project positions (left = position_x, top = position_y)
          module_project.update_attributes(left_position: mp_node[:left_position].to_f, top_position: mp_node[:top_position].to_f)
        end
      end
    end

    respond_to do |format|
      format.js {}
    end
  end


  def destroy
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project
    @organization = @module_project.organization

    authorize! :alter_estimation_plan, @project

    #re-set positions
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
    position_x = @module_project.position_x

    #...finally, destroy object module_project and its associations
    associated_module_projects =  @module_project.associated_module_projects
    inverse_associated_module_projects =  @module_project.inverse_associated_module_projects
    @module_project.destroy
    associated_module_projects.delete_all
    inverse_associated_module_projects.delete_all

    #Update column module_projects link with initialization module
    unless @initialization_module_project.nil?
      mp = @project.module_projects.where('position_x = ?', position_x).order('position_y ASC').first
      mp.update_attribute('associated_module_project_ids', @initialization_module_project.id) unless mp.nil?
    end

    expire_fragment "guw"

    session[:module_project_id] = nil
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end

  def associate_module_project_to_ratios
    @module_project = ModuleProject.find(params[:module_project_id])
    @project = Project.find(params[:project_id])
    @organization = @project.organization

    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects

    @module_projects.each do |mp|
      mp.update_attribute(:reference_value_id, params["module_projects_#{mp.id.to_s}"])
    end

    if params[:commit] == I18n.t('apply')
      flash[:notice] = I18n.t (:notice_module_project_successful_updated)
      redirect_to redirect(edit_module_project_path(@module_project.id, :anchor => 'tabs-3'))
    else
      redirect_to redirect(edit_project_path(@project.id, :anchor => 'tabs-4')), notice: "#{I18n.t (:notice_module_project_successful_updated)}"
    end
  end

  # Set the current balancing attribute for the Balancing-Module
  def selected_balancing_attribute
    session[:balancing_attribute_id] = params[:attribute_id]

    @project = Project.find(params[:project_id])
    @module_projects = @project.module_projects
    @pbs_project_element = current_component

    authorize! :alter_estimation_plan, @project

    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @results = nil
  end

  # Show or not the module_project results view in dashboard
  def show_module_project_results_view
    if params[:module_project_id]
      @module_project = ModuleProject.find(params[:module_project_id])
      @project = @module_project.project
      @project_organization = @project.organization
      @module_projects = @project.module_projects
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

      # when get click on the show_module_project_results_view button
      # if show_module_project_results_view is true, value will be changed to false and vice-versa
      case @module_project.show_results_view
        when true
          @module_project.update_attribute(:show_results_view, false)
        when false
          @module_project.update_attribute(:show_results_view, true)
        else
          @module_project.update_attribute(:show_results_view, true)
      end
    end
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    respond_to do |format|
      format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
    end
  end

  #The module_project configuration view on dashboard
  def edit_module_project_view_config
    @module_project = ModuleProject.find(params[:module_project_id])
    @corresponding_views = @current_organization.views.where(pemodule_id: @module_project.pemodule_id, is_reference_view: true)
  end

  #Update module_project view configuration from dashboard
  def update_module_project_view_config
    @module_project = ModuleProject.find(params[:module_project_id])
    @project = @module_project.project
    organization_id = @project.organization_id

    authorize! :alter_estimation_plan, @project

    @corresponding_views = @current_organization.views.where(pemodule_id: @module_project.pemodule_id, is_reference_view: true)

    #Update the current module_project view by copying the selected view and all its widgets
    if params['module_project']
      #selected_view = @module_project.view  #View.find(params['module_project']['view_id']) unless params['module_project']['view_id'].nil?

      respond_to do |format|

        # for the save button
        if params['save'] && !params['save'].nil?

          selected_view = View.find(params['module_project']['view_id']) unless params['module_project']['view_id'].nil?
          module_project_name = @module_project.to_s

          #If the module_project view has changed, update with the new selected view
          if selected_view.nil?
            @module_project.update_attribute(:color, params['module_project']['color'])
          else
            #using the same view
            if selected_view.id == @module_project.view_id
              @module_project.update_attributes(view_id: selected_view.id, color: params['module_project']['color'])
            else
              #want to use another view, so need to copy the view with all its widgets
              new_copied_view = View.new(name: "#{@project} - #{@module_project} view", description: "", pemodule_id: @module_project.pemodule_id, organization_id: organization_id, initial_view_id: selected_view.id)
              if new_copied_view.save
                #Then copy the widgets
                selected_view.views_widgets.each do |view_widget|
                  widget_est_val = view_widget.estimation_value
                  in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
                  estimation_value = @module_project.estimation_values.where(organization_id: organization_id, pe_attribute_id: view_widget.estimation_value.pe_attribute_id, in_out: in_out).last
                  estimation_value_id = estimation_value.nil? ? nil : estimation_value.id
                  widget_copy = ViewsWidget.new(view_id: new_copied_view.id, module_project_id: @module_project.id, estimation_value_id: estimation_value_id,
                                                name: view_widget.name, show_name: view_widget.show_name,
                                                show_tjm: view_widget.show_tjm,
                                                equation: view_widget.equation,
                                                comment: view_widget.comment,
                                                is_kpi_widget: view_widget.is_kpi_widget,
                                                kpi_unit: view_widget.kpi_unit,
                                                icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max,
                                                width: view_widget.width, height: view_widget.height, widget_type: view_widget.widget_type, position: view_widget.position,
                                                position_x: view_widget.position_x,
                                                position_y: view_widget.position_y,
                                                min_value: view_widget.min_value,
                                                max_value: view_widget.max_value,
                                                validation_text: view_widget.validation_text)
                  #Save and copy project_fields
                  if widget_copy.save
                    unless view_widget.project_fields.empty?
                      project_field = view_widget.project_fields.last

                      #Get project_field value
                      @value = 0
                      if widget_copy.estimation_value.module_project.pemodule.alias == "effort_breakdown"
                        begin
                          @value = widget_copy.estimation_value.string_data_probable[current_component.id][widget_copy.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                        rescue
                          begin
                            @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                          rescue
                            @value = 0
                          end
                        end
                      else
                        @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                      end

                      #create the new project_field
                      ProjectField.create(project_id: @project.id, field_id: project_field.field_id, views_widget_id: widget_copy.id, value: @value)
                    end
                  end
                end
              end

              #get the module_project current view before updating
              mp_current_view = @module_project.view

              #update module_project view
              @module_project.update_attributes(view_id: new_copied_view.id, color: params['module_project']['color'])

              #Then delete the view used by the module_project
              unless mp_current_view.nil?
                mp_current_view.destroy
              end
            end
          end
          flash[:notice] = I18n.t(:view_successfully_updated)
        end

        #for the save_as button
        if params['save_as'] && !params['save_as'].nil?
          selected_view = @module_project.view

          view_name = params['view_name'].nil? ? "#{@module_project} view" : params['view_name']
          view_description = params['view_description']

          #Copy the selected view as new name, and all its widgets
          new_view_saved_as = View.new(is_reference_view: true, name: view_name, description: view_description, pemodule_id: @module_project.pemodule_id, organization_id: @project.organization_id)
          #================
          if new_view_saved_as.save
            unless selected_view.nil?
              #Then copy the widgets
              selected_view.views_widgets.each do |view_widget|
                widget_est_val = view_widget.estimation_value
                in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
                #estimation_value = @module_project.estimation_values.where(organization_id: organization_id, pe_attribute_id: view_widget.estimation_value.pe_attribute_id, in_out: in_out).last
                widget_copy = ViewsWidget.new(view_id: new_view_saved_as.id, module_project_id: @module_project.id, estimation_value_id: view_widget.estimation_value_id,
                                              name: view_widget.name, show_name: view_widget.show_name,
                                              show_tjm: view_widget.show_tjm,
                                              equation: view_widget.equation,
                                              comment: view_widget.comment,
                                              is_kpi_widget: view_widget.is_kpi_widget,
                                              kpi_unit: view_widget.kpi_unit,
                                              icon_class: view_widget.icon_class, color: view_widget.color,
                                              show_min_max: view_widget.show_min_max,
                                              width: view_widget.width, height: view_widget.height,
                                              widget_type: view_widget.widget_type, position: view_widget.position,
                                              position_x: view_widget.position_x, position_y: view_widget.position_y)
                #Save and copy project_fields
                if widget_copy.save
                  unless view_widget.project_fields.empty?
                    project_field = view_widget.project_fields.last

                    #Get project_field value
                    @value = 0
                    if widget_copy.estimation_value.module_project.pemodule.alias == "effort_breakdown"
                      begin
                        @value = widget_copy.estimation_value.string_data_probable[current_component.id][widget_copy.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                      rescue
                        begin
                          @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                        rescue
                          @value = 0
                        end
                      end
                    else
                      @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                    end

                    #create the new project_field
                    ProjectField.create(project_id: @project.id, field_id: project_field.field_id, views_widget_id: widget_copy.id, value: @value)
                  end
                end
              end
            end

            flash[:notice] = I18n.t(:view_successfully_created)
          else

            if !new_view_saved_as.errors.messages[:name].empty? && !new_view_saved_as.errors.messages[:name].nil?
              flash.now[:error] = "#{I18n.t(:new_view)} : #{I18n.t(:name)} #{ new_view_saved_as.errors.messages[:name].first}"
            else
              flash.now[:error] = "#{I18n.t(:errors.messages.not_saved)}"
            end

            format.js {
              render :edit_module_project_view_config do |page|
                #page.replace "error_explanation", :partial => 'layouts/notifications'
              end
            }
          end
          #================
        end

        format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}

      end   #end respond_to
    end
  end

end
