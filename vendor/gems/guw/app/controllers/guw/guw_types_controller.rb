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


class Guw::GuwTypesController < ApplicationController

  def show
    @guw_type = Guw::GuwType.find(params[:id])
    @guw_model = @guw_type.guw_model
    @organization = @guw_model.organization

    set_page_title "#{@guw_type}"
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def new
    @guw_type = Guw::GuwType.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @organization = @guw_model.organization

    set_page_title I18n.t(:add_unit_of_work)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def edit

    @guw_type = Guw::GuwType.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @organization = @guw_type.guw_model.organization

    set_page_title I18n.t(:edit_project_element_name, parameter: @guw_type.name)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def create
    @guw_type = Guw::GuwType.new(params[:guw_type])
    @guw_type.guw_model_id = params[:guw_type][:guw_model_id]
    @guw_type.save
    @guw_model = @guw_type.guw_model
    @organization = @guw_model.organization

    set_page_title I18n.t(:new_complexity)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end

  def update
    @guw_type = Guw::GuwType.find(params[:id])
    @guw_type.update_attributes(params[:guw_type])
    @guw_model = @guw_type.guw_model
    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end

  def destroy
    @guw_type = Guw::GuwType.find(params[:id])
    guw_model_id = @guw_type.guw_model.id
    @guw_model = @guw_type.guw_model
    @guw_type.delete
    if @guw_model.default_display == "list"
      redirect_to guw.guw_type_path(@guw_type)
    else
      redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end
end
