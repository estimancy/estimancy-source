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
    end


    def edit
      @ge_model_factor_description = GeModelFactorDescription.find(params[:id])

      @ge_model = @ge_model_factor_description.ge_model
      @ge_factor = @ge_model_factor_description.ge_factor
      @organization = @ge_model.organization
      @project = Project.find(params[:project_id])
    end

    def create
    end

    def update
      #authorize! :manage_modules_instances, ModuleProject

      @ge_model_factor_description = GeModelFactorDescription.find(params[:id])

      @ge_model = @ge_model_factor_description.ge_model
      @ge_factor = @ge_model_factor_description.ge_factor
      @organization = @ge_model.organization
      @project = Project.find(params[:project_id])

      respond_to do |format|
        if @ge_model_factor_description.update_attributes(params[:ge_model_factor_description])
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