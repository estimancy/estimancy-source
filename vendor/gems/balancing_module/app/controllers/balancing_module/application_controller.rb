# encoding: UTF-8
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

module BalancingModule
  class ApplicationController < ActionController::Base
    def selected_balancing_attribute

      #No authorize required since everyone can select a PBS
      session[:pbs_project_element_id] = params[:pbs_id]

      @user = current_user
      @project = Project.find(params[:project_id])
      @is_project_view = params[:is_project_show_view]

      if @project.nil?
        @project = current_project
      end

      @module_projects = @project.module_projects
      @pbs_project_element = current_component

      # Get the initialization module_project
      @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

      # Get the max X and Y positions of modules
      @module_positions = ModuleProject.where(:project_id => @project.id).sort_by{|i| i.position_y}.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

      @results = nil
      render :partial => "refresh_attribute_balancing_input"
    end

  end

end
