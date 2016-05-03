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
#############################################################################

class ViewsWidgetsController < ApplicationController

  require 'rubyXL'
  include ViewsWidgetsHelper
  include ProjectsHelper
  before_filter :load_current_project_data, only: [:create, :update, :destroy]

  def load_current_project_data
    #@project = Project.find(params[:project_id])
    #if @project
    @project_organization = @project.organization
    @module_projects ||= @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    #end
  end

  def new
    authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.new(params[:views_widget])
    @view_id = params[:view_id]
    @position_x = 1; @position_y = 1
    @module_project = ModuleProject.find(params[:module_project_id])
    @module_project_box = @module_project
    @pbs_project_element_id = current_component.id
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
    else
      @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
    end
  end

  def edit
    authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.find(params[:id])
    @view_id = @views_widget.view_id
    @position_x = (@views_widget.position_x.nil? || @views_widget.position_x.downcase.eql?("nan")) ? 1 : @views_widget.position_x
    @position_y = (@views_widget.position_y.nil? || @views_widget.position_y.downcase.eql?("nan")) ? 1 : @views_widget.position_y

    @module_project = @views_widget.module_project_id.nil? ? ModuleProject.find(params[:module_project_id]) : @views_widget.module_project
    @module_project_box = ModuleProject.find(params[:module_project_id])

    ###@pbs_project_element_id = @views_widget.pbs_project_element_id.nil? ? current_component.id : @views_widget.pbs_project_element_id
    @pbs_project_element_id = current_component.id
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
    else
      @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
    end
  end

  def create
    authorize! :manage_estimation_widgets, @project

    @module_project = ModuleProject.find(params[:current_module_project_id]) ###ModuleProject.find(params[:views_widget][:module_project_id])
    @module_project_box = @module_project
    @pemodule = @module_project.pemodule

    if @module_project.view.nil?
      current_view = View.create(organization_id: @project.organization_id,
                                 pemodule_id: @pemodule.id,
                                 name: "#{@project.title} - #{@module_project} view")
      @view_id = current_view.id
      @module_project.update_attribute(:view_id, @view_id)
    else
      @view_id = params[:views_widget][:view_id]
      #get the current view
      current_view = View.find(params[:views_widget][:view_id])
    end

    # Add the position_x and position_y to params
    position_x = 1
    position_y = 1

    # Get the max (width, height) of the view's widgets : then add the widget in last positions
    unless current_view.nil? || current_view.views_widgets.empty?
      current_view_widgets = current_view.views_widgets
      y_positions = current_view.views_widgets.map(&:position_y).map(&:to_i)
      y_max = y_positions.max
      widgets_on_ymax = current_view_widgets.where(position_y: y_max)
      x_positions = widgets_on_ymax.map(&:position_x).map(&:to_i)
      x_max = x_positions.max
      view_widget_max_position = widgets_on_ymax.where(position_x: x_max).first

      position_x = view_widget_max_position.position_x.to_i+view_widget_max_position.width.to_i+1
      position_y = y_max ###view_widget_max_position.position_y.to_i+view_widget_max_position.height.to_i+1
    end

    #new widget with the default positions
    @views_widget = ViewsWidget.new(params[:views_widget].merge(:view_id => current_view.id,
                                                                :position_x => position_x,
                                                                :position_y => position_y,
                                                                :width => 3,
                                                                :height => 3))

    if params[:views_widget][:is_kpi_widget].present?
      equation = Hash.new
      equation["formula"] = params[:formula].upcase
      ["A", "B", "C", "D", "E"].each do |letter|
        unless params[letter.to_sym].nil?
          equation[letter] = [params[letter.to_sym].upcase, params["module_project"][letter]]
        end
        equation[letter] = params[letter.to_sym].to_s.upcase
      end
      @views_widget.equation = equation
      @views_widget.kpi_unit = params[:views_widget][:kpi_unit]
      @views_widget.is_kpi_widget = true
      @views_widget.module_project_id = @module_project.id
    end

    respond_to do |format|
      if @views_widget.save
        unless params["field"].blank?
          ProjectField.create( project_id: @project.id, field_id: params["field"], views_widget_id: @views_widget.id,
                               value: get_view_widget_data(@views_widget.module_project, @views_widget.id)[:value_to_show])
        end
        format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
      else
        flash[:error] = "Erreur d'ajout de Vignette"
        @position_x = 1; @position_y = 1
        @pbs_project_element_id = params[:views_widget][:pbs_project_element_id].nil? ? current_component.id : params[:views_widget][:pbs_project_element_id]
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end

        format.html { render action: :new }
        format.js   { render action: :new }
      end
    end
  end

  def update
    authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.find(params[:id])
    @view_id = @views_widget.view_id
    if @views_widget.is_label_widget? || @views_widget.is_kpi_widget?
      project = @project
    else
      project = @views_widget.estimation_value.module_project.project
    end

    if params[:views_widget][:is_kpi_widget].present?
      @views_widget.is_kpi_widget = true
      equation = Hash.new
      equation["formula"] = params[:formula].upcase
      ["A", "B", "C", "D", "E"].each do |letter|
        equation[letter] = params[letter.to_sym].upcase
      end
      @views_widget.equation = equation
    end

    if params["field"].blank?
      pfs = @views_widget.project_fields
      pfs.destroy_all
    else
      pf = ProjectField.where(views_widget_id: @views_widget.id).last

      if @views_widget.estimation_value.module_project.pemodule.alias == "effort_breakdown"
        begin
          @value = @views_widget.estimation_value.string_data_probable[current_component.id][@views_widget.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
        rescue
          begin
            @value = @views_widget.estimation_value.string_data_probable[current_component.id]
          rescue
            @value = 0
          end
        end
      else
        @value = @views_widget.estimation_value.string_data_probable[current_component.id]
      end

      if pf.nil?
          ProjectField.create(project_id: project.id, field_id: params["field"].to_i, views_widget_id: @views_widget.id, value: @value)
      else
        pf.value = @value
        pf.views_widget_id = @views_widget.id
        pf.field_id = params["field"].to_i
        pf.project_id = project.id
        pf.save
      end
    end

    respond_to do |format|

      if @views_widget.update_attributes(params[:views_widget])

        #Update the widget's pe_attribute
        #widget_attribute_id = @views_widget.estimation_value.pe_attribute_id
        #if  widget_attribute_id != @views_widget.pe_attribute_id
        #  @views_widget.update_attribute(:pe_attribute_id, widget_attribute_id)
        #end

        format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
      else
        flash[:error] = "Erreur lors de la mise à jour du Widget dans la vue"
        @position_x = (@views_widget.position_x.nil? || @views_widget.position_x.downcase.eql?("nan")) ? 1 : @views_widget.position_x
        @position_y = (@views_widget.position_y.nil? || @views_widget.position_y.downcase.eql?("nan")) ? 1 : @views_widget.position_y

        @module_project = ModuleProject.find(params[:views_widget][:module_project_id])
        @module_project_box = @module_project

        @pbs_project_element_id = current_component.id
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end
        format.js { render action: :edit }
      end
    end

    #redirect_to dashboard_path(@project)
  end

  def destroy
    @views_widget = ViewsWidget.find(params[:id])
    @module_project = @views_widget.module_project

    if can?(:alter_estimation_plan, @project) || ( can?(:manage_estimation_widgets, @project) && @views_widget.project_fields.empty? )
      @views_widget.destroy
    else
      flash[:warning] = I18n.t(:notice_cannot_delete_widgets)
    end

    redirect_to dashboard_path(@project)
  end


  #update the view_widget position (x,y)
  def update_view_widget_positions
    views_widgets = params[:views_widgets]
    unless views_widgets.empty?
      views_widgets.each_with_index do |element, index|
        view_widget_hash = element.last
        view_widget_id = view_widget_hash[:view_widget_id].to_i
        if view_widget_id != 0
          view_widget = ViewsWidget.find(view_widget_id)
          if view_widget
            # Update the View Widget positions (left = position_x, top = position_y)
            view_widget.update_attributes(position_x: view_widget_hash[:col], position_y: view_widget_hash[:row], position: index+1)
          end
        end
      end
    end
  end

  def update_view_widget_sizes
    view_widget_id = params[:view_widget_id]
    if view_widget_id != "" && view_widget_id!= "indefined"
      view_widget = ViewsWidget.find(view_widget_id)
      if view_widget
        view_widget.update_attributes(width: params[:sizex], height: params[:sizey])
      end
    end
  end

  #Update the module_project corresponding data of view
  def update_widget_module_project_data
    module_project_id = params['module_project_id']
    if !module_project_id.nil? && module_project_id != 'undefined'
      @module_project = ModuleProject.find(module_project_id)
      @letter = params[:letter]
      if !@letter.nil?
        @module_project_attributes_input = @module_project.estimation_values.where(in_out: 'input').map{|i| [i, i.id]}
        @module_project_attributes_output = @module_project.estimation_values.where(in_out: 'output').map{|i| [i, i.id]}
      else
        @module_project_attributes_input = @module_project.estimation_values.where(in_out: 'input').map{|i| [i, i.id]}
        @module_project_attributes_output = @module_project.estimation_values.where(in_out: 'output').map{|i| [i, i.id]}
        #the widget type
        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end
      end
    end
  end

  def export_vignette
    workbook = RubyXL::Workbook.new
    widget = ViewsWidget.find(params[:view_widget_id])
    ind_x = 4
    ind_y = 1
    my_len = I18n.t(:profile).length
    my_len_2 = I18n.t(:phases).length
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:Project_name))
    worksheet.add_cell(0, 1, I18n.t(:version))
    worksheet.add_cell(0, 2, I18n.t(:start_date))
    worksheet.add_cell(0, 3, I18n.t(:Product_Name))
    worksheet.change_column_width(0, @project.title.to_s.length < I18n.t(:Project_name).length ? I18n.t(:Project_name).length : @project.title.to_s.length)
    worksheet.change_column_width(1, @project.version.to_s.length < I18n.t(:version).length ? I18n.t(:version).length : @project.version.to_s.length)
    worksheet.change_column_width(2, I18n.t(:start_date).length)
    worksheet.change_column_width(3, current_component.to_s.length < I18n.t(:Product_Name).length ? I18n.t(:Product_Name).length : current_component.to_s.length)
    worksheet.add_cell(0, 4, I18n.t(:phases))

    if widget.widget_type == "table_effort_per_phase"
      unless widget.estimation_value.string_data_probable.empty?
        worksheet.add_cell(0, 5, I18n.t(:effort_import))
        worksheet.add_cell(0, 6, I18n.t(:unit_value))
        widget.module_project.wbs_activity.wbs_activity_elements.each  do |element|
          worksheet.add_cell(ind_y, 0, @project.title)
          worksheet.add_cell(ind_y, 1, @project.version)
          #worksheet.add_cell(ind_y, 2, I18n.l(@project.start_date))
          tab_date = @project.start_date.to_s.split("-")
          worksheet.add_cell(ind_y, 2, '', "DATE(#{tab_date[0]},#{tab_date[1]},#{tab_date[2]})").set_number_format 'dd/mm/yy'
          worksheet.add_cell(ind_y, 3, current_component)
          worksheet.add_cell(ind_y, 4, element.name)
          my_len_2 = element.name.length < my_len_2 ? my_len_2 : element.name.length
          worksheet.change_column_width(4, my_len_2)

          begin
            worksheet.add_cell(ind_y, 5, widget.estimation_value.string_data_probable[current_component.id][element.id][:value].to_f).set_number_format('.##')
          rescue
            worksheet.add_cell(ind_y, 5, '').set_number_format('.##')
          end

          worksheet.add_cell(ind_y, 6, convert_label(widget.estimation_value.string_data_probable[current_component.id][element.id][:value], @project.organization))
          ind_y += 1
        end
      end
    elsif widget.widget_type == "effort_per_phases_profiles_table"
      unless widget.estimation_value.string_data_probable.empty?
        worksheet.add_cell(0, 5, I18n.t(:profile))
        worksheet.add_cell(0, 6, I18n.t(:effort_import))
        worksheet.add_cell(0, 7, I18n.t(:unit_value))
        attribute = widget.pe_attribute
        activity = widget.module_project.wbs_activity
        ratio = WbsActivityInput.where(wbs_activity_id: activity.id,
                                       module_project_id: widget.module_project.id).first.wbs_activity_ratio
        unless ratio.nil?
          activity.wbs_activity_elements.each do |element|
            my_len_2 = element.name.length < my_len_2 ? my_len_2 : element.name.length
            worksheet.change_column_width(4, my_len_2)
            element.wbs_activity_ratio_elements.where(wbs_activity_ratio_id: ratio.id).each do |ware|
              ware.organization_profiles.each do |profil|
                worksheet.add_cell(ind_y, 0, @project.title)
                worksheet.add_cell(ind_y, 1, @project.version)
                #worksheet.add_cell(ind_y, 2, I18n.l(@project.start_date))
                tab_date = @project.start_date.to_s.split("-")
                worksheet.add_cell(ind_y, 2, '', "DATE(#{tab_date[0]},#{tab_date[1]},#{tab_date[2]})").set_number_format 'dd/mm/yy'
                worksheet.add_cell(ind_y, 3, current_component)
                worksheet.add_cell(ind_y, 4, element.name)
                worksheet.add_cell(ind_y, 5, profil.name)
                my_len = profil.name.length < my_len ? my_len : profil.name.length
                worksheet.change_column_width(5, my_len)

                begin
                  worksheet.add_cell(ind_y, 6, widget.estimation_value.string_data_probable[current_component.id][element.id]["profiles"]["profile_id_#{profil.id}"]["ratio_id_#{ratio.id}"][:value]).set_number_format('.##')
                  worksheet.add_cell(ind_y, 7, convert_label(widget.estimation_value.string_data_probable[current_component.id][element.id][:value], @project.organization))
                rescue
                  worksheet.add_cell(ind_y, 6, "".set_number_format('.##'))
                  worksheet.add_cell(ind_y, 7, "")
                end
                ind_y += 1
             end
            end
          end
        end
      end
    end

    send_data(workbook.stream.string, filename: "#{@project.organization.name[0..4]}-#{@project.title}-#{@project.version}(#{("A".."B").to_a[widget.module_project.position_x - 1]},#{widget.module_project.position_y})-Effort-Phases-Profils-#{widget.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")

  end

  # Get the module_project attributes grouped by Input and Ouput
  def get_module_project_attributes_input_output(module_project)
    estimation_values = module_project.estimation_values.group_by{ |attr| attr.in_out }.sort()
  end

end




