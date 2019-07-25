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

class FieldsController < ApplicationController

  # GET /fields/new
  # GET /fields/new.json
  def new
    authorize! :manage, Field

    @field = Field.new
    set_page_title I18n.t(:fields)
    set_breadcrumbs I18n.t(:fields) => organization_setting_path(@current_organization, anchor: "tabs-fields"), I18n.t('new_field') => ""

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/1/edit
  def edit
    set_page_title I18n.t(:fields)
    authorize! :show_custom_fields, Field
    @field = Field.find(params[:id])
    set_breadcrumbs I18n.t(:fields) => organization_setting_path(@current_organization, anchor: "tabs-fields"), I18n.t('field_edition') => ""
  end

  # POST /fields
  # POST /fields.json
  def create
    authorize! :manage, Field

    @field = Field.new(params[:field])
    @organization = @field.organization

    set_page_title I18n.t(:fields)
    set_breadcrumbs I18n.t(:fields) => organization_setting_path(@organization, anchor: "tabs-fields"), I18n.t('new_field') => ""

    respond_to do |format|
      if @field.save
        format.html { redirect_to organization_setting_path(@field.organization_id, anchor: "tabs-fields"), notice: 'Field was successfully created.' }
        format.json { render json: @field, status: :created, location: @field }
      else
        format.html { render action: "new" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fields/1
  # PUT /fields/1.json
  def update
    authorize! :manage, Field

    @field = Field.find(params[:id])
    @organization = @field.organization

    set_page_title I18n.t(:fields)
    set_breadcrumbs I18n.t(:fields) => organization_setting_path(@organization, anchor: "tabs-fields"), I18n.t('field_edition') => ""

    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.html { redirect_to organization_setting_path(@organization, anchor: "tabs-fields"), notice: 'Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    authorize! :manage, Field

    @field = Field.find(params[:id])
    organization_id = @field.organization_id
    @field.destroy

    respond_to do |format|
      format.html { redirect_to organization_setting_path(organization_id, anchor: "tabs-fields") }
      format.json { head :no_content }
    end
  end
end


# o = Organization.find(69)
# o.projects.where(original_model_id: [4067, 7827, 7828]).each do |project|
#   # effort
#   pf = ProjectField.where(project_id: project.id, field_id: 96).first
#   unless pf.nil?
#     vw = ViewsWidget.where(name: "Charge Totale (jh)", module_project_id: project.module_project_ids).first
#     pf.views_widget_id = vw.id
#     pf.save
#   end
#
#   # vw_estimation_value = vw.estimation_value
#   # unless vw_estimation_value.nil?
#   #   value = vw_estimation_value.string_data_probable[project.root_component.id]
#   #   puts value
#   #   if value.nil?
#   #     pf.value = value
#   #     pf.save
#   #   end
#   # end
# end
