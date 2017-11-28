# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero Kbneral Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero Kbneral Public License for more details.
#
#    You should have received a copy of the GNU Affero Kbneral Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Kb::KbInputsController < ApplicationController

  def show
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:uo_model) => main_app.edit_organization_path(@kb_model.organization), @kb_model.organization => ""
  end

  def new
    authorize! :manakb_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @kb_model = Kb::KbModel.new
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    @organization = @kb_model.organization

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:uo_model) => main_app.edit_organization_path(@kb_model.organization), @kb_model.organization => ""
  end

  def import
    @kb_model = Kb::KbModel.find(params[:kb_model_id])

    unless params[:file].nil?
      file = Roo::Spreadsheet.open(params[:file].path, extension: :xls)

      Kb::KbData.delete_all("kb_model_id = #{@kb_model.id}")

      ((file.first_row + 1)..file.last_row).each do |line|
        attr_one   = file.cell(line, 'A')
        attr_two   = file.cell(line, 'B')

        h = Hash.new
        ('C'..'ZZ').each_with_index do |letter, i|
          if i < file.last_column
            begin
              h[file.cell(1, letter.to_s).to_sym] = file.cell(line, letter.to_s)
            rescue
              # ignored
            end
          end
        end

        Kb::KbData.create(size: attr_one,
                          effort: attr_two,
                          unit: "UF",
                          custom_attributes: h,
                          kb_model_id: @kb_model.id)
      end
    end

    redirect_to kb.edit_kb_model_path(@kb_model)
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:kb_model][:organization_id])

    @kb_model = Kb::KbModel.new(params[:kb_model])
    @kb_model.organization_id = params[:kb_model][:organization_id].to_i
    if @kb_model.save
      redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    @organization = @kb_model.organization

    if @kb_model.update_attributes(params[:kb_model])
      redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    organization_id = @kb_model.organization_id

    @kb_model.module_projects.each do |mp|
      mp.destroy
    end

    @kb_model.delete
    redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
  end

end
