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

class Guw::GuwComplexitiesController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_complexities = @guw_type.guw_complexities
  end

  def new
    set_page_title I18n.t(:new_complexity)
    @guw_complexity = Guw::GuwComplexity.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
  end

  def edit
    set_page_title I18n.t(:edit_complexity)
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
  end

  def create
    @guw_complexity = Guw::GuwComplexity.new(params[:guw_complexity])

    @guw_type = Guw::GuwType.find(params[:guw_complexity][:guw_type_id])

    @guw_complexity.bottom_range = params[:guw_complexity][:bottom_range].to_i
    @guw_complexity.top_range = params[:guw_complexity][:top_range].to_i

    @guw_complexity.organization_id = @current_organization.id
    @guw_complexity.guw_model_id = @guw_type.guw_model_id

    @guw_complexity.save

    @guw_model = @guw_type.guw_model
    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_complexity.guw_type.name.gsub(" ", "-")}")
    end
  end

  def update
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_type = Guw::GuwType.find(params[:guw_complexity][:guw_type_id])
    @guw_complexity.update_attributes(params[:guw_complexity])

    @guw_model = @guw_type.guw_model
    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end

  def destroy
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_type = @guw_complexity.guw_type
    @guw_model = @guw_type.guw_model
    @guw_complexity.delete

    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end
end
