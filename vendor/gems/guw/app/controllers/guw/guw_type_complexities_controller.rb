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


class Guw::GuwTypeComplexitiesController < ApplicationController
  def index
    @guw_attribute_complexities = Guw::GuwTypeComplexity.all
  end

  def new
    @guw_type_complexity = Guw::GuwTypeComplexity.new
  end

  def edit
    @guw_type_complexity = Guw::GuwTypeComplexity.find(params[:id])
    set_page_title I18n.t(:edit_complexity)
  end

  def create
    @guw_type_complexity = Guw::GuwTypeComplexity.new(params[:guw_type_complexity])
    @guw_type_complexity.save
    redirect_to guw.guw_model_path(@guw_type_complexity.guw_type.guw_model, anchor: "tabs-#{@guw_type_complexity.guw_type.name.gsub(" ", "-")}")
  end

  def update
    @guw_type_complexity = Guw::GuwTypeComplexity.find(params[:id])
    @guw_type_complexity.update_attributes(params[:guw_type_complexity])
    redirect_to guw.guw_model_path(@guw_type_complexity.guw_type.guw_model, anchor: "tabs-#{@guw_type_complexity.guw_type.name.gsub(" ", "-")}")
  end

  def destroy
    @guw_type_complexity = Guw::GuwTypeComplexity.find(params[:id])
    @guw_type_complexity.guw_attribute_complexities.delete_all
    guw_model_id = @guw_type_complexity.guw_type.guw_model.id
    @guw_type_complexity.delete
    redirect_to guw.guw_model_path(guw_model_id, anchor: "tabs-#{@guw_type_complexity.guw_type.name.gsub(" ", "-")}")
  end

end
