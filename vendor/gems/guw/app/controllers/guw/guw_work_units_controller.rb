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


class Guw::GuwWorkUnitsController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title I18n.t(:Work_Unit)
  end

  def new
    @guw_work_unit = Guw::GuwWorkUnit.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization)
    set_page_title I18n.t(:Create_a_new_Work_Unit)
  end

  def edit
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])

    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization),
                    @guw_model => guw.edit_guw_model_path(@guw_work_unit.guw_model, organization_id: @current_organization.id)

    set_page_title I18n.t(:Edit_a_new_Work_Unit)
  end

  def create
    @guw_work_unit = Guw::GuwWorkUnit.new(params[:guw_work_unit])
    @guw_work_unit.save
    redirect_to guw.edit_guw_model_path(@guw_work_unit.guw_model, organization_id: @current_organization.id, anchor: "tabs-factors")
  end

  def update
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])
    @guw_work_unit.update_attributes(params[:guw_work_unit])
    set_page_title I18n.t(:Edit_Units_Of_Work)
    redirect_to guw.edit_guw_model_path(@guw_work_unit.guw_model, organization_id: @current_organization.id, anchor: "tabs-factors")
  end

  def destroy
    @guw_work_unit = Guw::GuwWorkUnit.find(params[:id])
    @guw_model = @guw_work_unit.guw_model
    @guw_work_unit.delete
    if @guw_model.default_display == "list"
      redirect_to guw.guw_model_all_guw_types_path(@guw_model)
    else
      redirect_to guw.guw_model_path(@guw_model)
    end
  end
end
