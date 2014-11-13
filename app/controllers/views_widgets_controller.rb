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
  before_filter :load_current_project_data, only: [:create, :update, :destroy]

  def load_current_project_data
    @project = current_project
    if @project
      @project_organization = @project.organization
      @module_projects ||= @project.module_projects
      #Get the initialization module_project
      @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    end
  end

  def new
    @views_widget = ViewsWidget.new(params[:views_widget])
  end

  def edit
    @views_widget = ViewsWidget.find(params[:id])
  end

  def create
    @views_widget = ViewsWidget.new(params[:views_widget])
    if @views_widget.save
      flash[:notice] = "Widget ajouté avec succès"
    else
      flash[:error] = "Erreur d'ajout de Widget"
    end
    #render :partial => "views_widgets/refresh_views_widgets_results"
    redirect_to '/dashboard'
  end

  def update
    @views_widget = ViewsWidget.find(params[:id])
    if @views_widget.update_attributes(params[:views_widget])
      flash[:notice] = "Widget mis à jour avec succès"
    else
      flash[:error] = "Erreur lors de la mise à jour du Widget dans la vue"
    end
    #render :partial => "views_widgets/refresh_views_widgets_results"
    redirect_to '/dashboard'
  end

  def destroy
    @views_widget = ViewsWidget.find(params[:id])
    @views_widget.destroy
    #render :partial => "views_widgets/refresh_views_widgets_results"
    redirect_to '/dashboard'
  end

  def update_view_widget_positions_and_sizes
    view_id = params[:view_id]
    widgets_orders = params[:widgets_orders]
    if view_id != "" && view_id != "undefined"
      widgets_orders.each_with_index do |dashboard_widget_id, index|
        if dashboard_widget_id != ""
          view_widget_id = dashboard_widget_id.split("dashboard_widget_").last.to_i
          view_widget = ViewsWidget.find(view_widget_id)
          if view_widget
            view_widget.update_attribute('position', index+1)
          end
        end
      end
    end

  end

  def update_view_widget_positions_and_sizes_SAVE
    if params["view_widget_id"] != "" && params["view_widget_id"] != "undefined"
      view_widget = ViewsWidget.find(params[:view_widget_id].to_i)
      pos_x = "#{params[:position_x]}px"
      pos_y = "#{params[:position_y]}px"

      # Update the View Widget positions (left = position_x, top = position_y)
      view_widget.update_attributes(position_x: pos_x, position_y: pos_y)
    end
  end
end
