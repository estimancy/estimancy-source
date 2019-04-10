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


class Guw::GuwCoefficientsController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_coefficients = @guw_model.guw_coefficients
  end

  def new
    @guw_coefficient = Guw::GuwCoefficient.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_coefficient_element = Guw::GuwCoefficientElement.new

    set_page_title "New"

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization)
  end

  def edit
    @guw_coefficient = Guw::GuwCoefficient.find(params[:id])
    @guw_coefficient_element = Guw::GuwCoefficientElement.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title "Edit"
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization),
                    @guw_coefficient => guw.edit_guw_model_path(@guw_coefficient.guw_model, organization_id: @current_organization.id)
  end

  def create
    @guw_coefficient = Guw::GuwCoefficient.new(params[:guw_coefficient])
    @guw_coefficient_element = Guw::GuwCoefficientElement.new
    @guw_coefficient.save
    redirect_to guw.edit_guw_model_path(@guw_coefficient.guw_model, organization_id: @current_organization.id, anchor: "tabs-coefficients")
  end

  def update
    @guw_coefficient = Guw::GuwCoefficient.find(params[:id])
    @guw_coefficient.update_attributes(params[:guw_coefficient])
    set_page_title I18n.t(:Edit_Units_Of_Work)
    redirect_to guw.edit_guw_model_path(@guw_coefficient.guw_model, organization_id: @current_organization.id, anchor: "tabs-coefficients")
  end

  def destroy
    @guw_coefficient = Guw::GuwCoefficient.find(params[:id])
    @guw_model = @guw_coefficient.guw_model
    @guw_coefficient.delete
    redirect_to guw.edit_guw_model_path(@guw_coefficient.guw_model, organization_id: @current_organization.id, anchor: "tabs-coefficients")
  end
end
