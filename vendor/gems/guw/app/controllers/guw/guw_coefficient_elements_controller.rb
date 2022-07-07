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


class Guw::GuwCoefficientElementsController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_coefficient_elements = @guw_model.guw_coefficient_elements
  end

  def new
    @guw_coefficient_element = Guw::GuwCoefficientElement.new
    @guw_coefficient = Guw::GuwCoefficient.find(params[:guw_coefficient_id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title "Nouveau coefficient"
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    I18n.t(:uo_model) => guw.edit_guw_model_path(@guw_model, organization_id: @current_organization.id, anchor: "tabs-coefficients"),
                    @guw_model.organization => ""
  end

  def edit
    @guw_coefficient_element = Guw::GuwCoefficientElement.find(params[:id])
    @guw_coefficient = Guw::GuwCoefficient.find(params[:guw_coefficient_id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title "Editer le coefficient"
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}",
                    I18n.t(:uo_model) => guw.edit_guw_model_path(@guw_model, organization_id: @current_organization.id, anchor: "tabs-coefficients"),
                    @guw_model.organization => ""

  end

  def create
    @guw_coefficient_element = Guw::GuwCoefficientElement.new(params[:guw_coefficient_element])
    @guw_coefficient_element.save
    redirect_to guw.edit_guw_model_path(@guw_coefficient_element.guw_model, organization_id: @current_organization.id)
  end

  def update
    @guw_coefficient_element = Guw::GuwCoefficientElement.find(params[:id])
    @guw_coefficient_element.update_attributes(params[:guw_coefficient_element])
    set_page_title I18n.t(:Edit_Units_Of_Work)
    redirect_to guw.edit_guw_model_path(@guw_coefficient_element.guw_model, organization_id: @current_organization.id)
  end

  def destroy
    @guw_coefficient_element = Guw::GuwCoefficientElement.find(params[:id])
    @guw_model = @guw_coefficient_element.guw_model
    
    @guw_coefficient_element.delete
    redirect_to guw.edit_guw_model_path(@guw_coefficient_element.guw_model, organization_id: @current_organization.id)
  end
end
