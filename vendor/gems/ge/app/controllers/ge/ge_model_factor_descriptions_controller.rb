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

module Ge
  class GeModelFactorDescriptionsController < ApplicationController

    def new
      @ge_model_factor_description = GeModelFactorDescription.new
      @ge_model = GeModel.find(params[:ge_model_id])
      @ge_factor = @ge_model.ge_factors.where(id: params[:ge_factor_id]).first
      @project = Project.find(params[:project_id])
    end


    def edit
      @ge_model_factor_description = GeModelFactorDescription.find(params[:id])

      @ge_model = @ge_model_factor_description.ge_model
      @ge_factor = @ge_model_factor_description.ge_factor
      @organization = @ge_model.organization
      @project = Project.find(params[:project_id])
      @module_project = params[:module_project_id]
    end

    def create
    end


    def update
      #authorize! :manage_modules_instances, ModuleProject

      @ge_model_factor_description = GeModelFactorDescription.find(params[:id])

      @ge_model = @ge_model_factor_description.ge_model
      @ge_factor = @ge_model_factor_description.ge_factor
      @organization = @ge_model.organization
      @project = @ge_model_factor_description.project
      @module_project = @ge_model_factor_description.module_project

      selected_factor_id = params[:factor_selected_value].to_i
      selected_factor = GeFactorValue.find(selected_factor_id)
      if selected_factor
        selected_factor_value = selected_factor.value_number

        # Update selected value from slider
        @ge_input = GeInput.where(module_project_id: @module_project.id, organization_id: @organization.id, ge_model_id: @ge_model.id).first
        @ge_input_values = @ge_input.values

        unless @ge_input_values.nil? && @ge_input_values.empty?
          #@ge_input_values["#{@ge_factor.alias}"][:ge_factor_value_id] = selected_factor_id
          #@ge_input_values["#{@ge_factor.alias}"][:value] = selected_factor_value
          @ge_input_values["#{@ge_factor.alias}"] = { ge_factor_value_id: selected_factor_id, scale_prod: selected_factor.factor_scale_prod,
                                                      factor_name: selected_factor.factor_name, value: selected_factor_value }

          @ge_input.values = @ge_input_values
          @ge_input.save
        end
      end

      respond_to do |format|
        @ge_model_factor_description.description = params[:ge_model_factor_description][:description]
        if @ge_model_factor_description.save #update_attributes(params[:ge_model_factor_description])
          format.html { redirect_to main_app.dashboard_path(@project) }
          format.js { render :js => "window.location.replace('#{main_app.dashboard_path(@project)}');"}
        else
          format.html { render action: :edit }
          format.js   { render action: :edit }
        end
      end
    end

  end
end