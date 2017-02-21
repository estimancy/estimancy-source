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

#require_dependency "staffing/application_controller"

#module Staffing
  class Staffing::StaffingModelsController < ApplicationController

    StaffingModel = Staffing::StaffingModel

    # GET /staffing_models
    # GET /staffing_models.json
    def index
      @staffing_models = StaffingModel.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @staffing_models }
      end
    end
  
    # GET /staffing_models/1
    # GET /staffing_models/1.json
    def show
      authorize! :show_modules_instances, ModuleProject

      @staffing_model = StaffingModel.find(params[:id])
      @organization = @staffing_model.organization

      set_page_title @staffing_model.name
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:team_modules) => main_app.organization_module_estimation_path(@organization, anchor: "team"), @staffing_model.name => ""
    end

    # GET /staffing_models/new
    # GET /staffing_models/new.json
    def new
      authorize! :manage_modules_instances, ModuleProject

      @organization = Organization.find(params[:organization_id])
      @staffing_model = StaffingModel.new

      set_page_title I18n.t(:New_Team_module_instance)
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:team_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "team"), I18n.t(:new) => ""
    end
  
    # GET /staffing_models/1/edit
    def edit
      authorize! :show_modules_instances, ModuleProject

      @staffing_model = StaffingModel.find(params[:id])
      @organization = @staffing_model.organization

      set_page_title I18n.t(:Edit_Staffing)
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:team_modules) => main_app.organization_module_estimation_path(@organization, anchor: "team"), @staffing_model.name => ""
    end
  
    # POST /staffing_models
    # POST /staffing_models.json
    def create
      authorize! :manage_modules_instances, ModuleProject

      @organization = Organization.find(params[:staffing_model][:organization_id])
      @staffing_model = StaffingModel.new(params[:staffing_model])
      x0 = params[:staffing_model]['x0'] || 0
      y0 = params[:staffing_model]['y0'] || 20
      x1 = params[:staffing_model]['x1'] || 20
      x2 = params[:staffing_model]['x2'] || 80
      x3 = params[:staffing_model]['x3'] || 100
      y3 = params[:staffing_model]['y3'] || 20

      @staffing_model.trapeze_default_values = { :x0 => x0, :y0 => y0, :x1 => x1, :x2 => x2, :x3 => x3, :y3 => y3 }

      if @staffing_model.save
        redirect_to main_app.organization_module_estimation_path(@staffing_model.organization_id, anchor: "team", notice: 'Staffing model was successfully created.')
      else
        render action: "new"
      end

    end
  
    # PUT /staffing_models/1
    # PUT /staffing_models/1.json
    def update
      authorize! :manage_modules_instances, ModuleProject

      @staffing_model = StaffingModel.find(params[:id])
      @organization = @staffing_model.organization

      x0 = params[:staffing_model]['x0'] || 0
      y0 = params[:staffing_model]['y0'] || 20
      x1 = params[:staffing_model]['x1'] || 20
      x2 = params[:staffing_model]['x2'] || 80
      x3 = params[:staffing_model]['x3'] || 100
      y3 = params[:staffing_model]['y3'] || 20

      trapeze_default_values = { :x0 => x0, :y0 => y0, :x1 => x1, :x2 => x2, :x3 => x3, :y3 => y3 }

      params[:staffing_model][:trapeze_default_values] = trapeze_default_values

      respond_to do |format|
        if @staffing_model.update_attributes(params[:staffing_model])
          #format.html { redirect_to main_app.organization_module_estimation_path(@staffing_model.organization_id, anchor: 'team', notice: 'Staffing model was successfully updated.') }
          format.html { redirect_to staffing.edit_staffing_model_path(@staffing_model) }

          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @staffing_model.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /staffing_models/1
    # DELETE /staffing_models/1.json
    def destroy
      authorize! :manage_modules_instances, ModuleProject

      @staffing_model = StaffingModel.find(params[:id])
      organization_id = @staffing_model.organization_id

      @staffing_model.module_projects.each do |mp|
        mp.destroy
      end

      @staffing_model.destroy

      redirect_to main_app.organization_module_estimation_path(organization_id)
    end


    #Duplicate the staffing model
    def duplicate
      @staffing = Staffing::StaffingModel.find(params[:staffing_model_id])

      new_copy_number = @staffing.copy_number.to_i + 1

      new_staffing = @staffing.dup
      new_staffing.name = "#{@staffing.name}(#{new_copy_number})"
      new_staffing.copy_number = 0

      @staffing.copy_number = new_copy_number

      @staffing.save
      new_staffing.save

      redirect_to main_app.organization_module_estimation_path(@staffing.organization_id, anchor: "team", notice: 'Staffing model was successfully created.' )
    end


    def export_staffing
      staffing_data = Staffing::StaffingCustomDatum.find(params[:staffing_model_id])
      workbook = RubyXL::Workbook.new
      number_of_people =  staffing_data.chart_actual_coordinates
      theoretical_trapeze_values = staffing_data.trapeze_chart_theoretical_coordinates

      worksheet = workbook[0]

      worksheet.add_cell(0,0, I18n.t(:period))
      worksheet.sheet_data[0][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[0][0].change_border(:right, 'thin')
      worksheet.add_cell(1,0, I18n.t(:theoretical_trapeze))
      worksheet.sheet_data[1][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[1][0].change_border(:right, 'thin')
      worksheet.add_cell(2,0, I18n.t(:person_number))
      worksheet.sheet_data[2][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[2][0].change_border(:right, 'thin')

      theoretical_trapeze_values.each_with_index do |trap_val, index|
        worksheet.add_cell(0,index + 1, "P#{trap_val[0]}").change_horizontal_alignment('center')
        worksheet.sheet_data[0][index + 1].change_border(:bottom, 'thin')
        worksheet.sheet_data[0][index + 1].change_border(:right, 'thin')

        worksheet.add_cell(1,index + 1, trap_val[1].round(1)).change_horizontal_alignment('center')
        worksheet.sheet_data[1][index + 1].change_border(:bottom, 'thin')
        worksheet.sheet_data[1][index + 1].change_border(:right, 'thin')

      end

      number_of_people.each_with_index do |num_peop, index|
        worksheet.add_cell(2,index + 1, num_peop[1].round(1)).change_horizontal_alignment('center')
        worksheet.sheet_data[2][index + 1].change_border(:bottom, 'thin')
        worksheet.sheet_data[2][index + 1].change_border(:right, 'thin')

      end

      worksheet.add_cell(4,0, I18n.t(:effort_week))
      worksheet.add_cell(4,1, staffing_data.global_effort_value.round(2)).change_horizontal_alignment('center')
      worksheet.sheet_data[4][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[4][0].change_border(:right, 'thin')
      worksheet.sheet_data[4][0].change_border(:top, 'thin')
      worksheet.sheet_data[4][1].change_border(:top, 'thin')
      worksheet.sheet_data[4][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[4][1].change_border(:right, 'thin')

      worksheet.add_cell(5,0, I18n.t(:duration_in_week))
      worksheet.add_cell(5,1, staffing_data.duration.round(2)).change_horizontal_alignment('center')
      worksheet.sheet_data[5][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[5][0].change_border(:right, 'thin')
      worksheet.sheet_data[5][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[5][1].change_border(:right, 'thin')

      worksheet.add_cell(6,0, I18n.t(:max_staff_trap))
      worksheet.add_cell(6,1, staffing_data.max_staffing.round(2)).change_horizontal_alignment('center')
      worksheet.sheet_data[6][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[6][0].change_border(:right, 'thin')
      worksheet.sheet_data[6][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[6][1].change_border(:right, 'thin')

      worksheet.add_cell(7,0, I18n.t(:max_staff_rayl))
      worksheet.add_cell(7,1, staffing_data.max_staffing_rayleigh.round(2)).change_horizontal_alignment('center')
      worksheet.sheet_data[7][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[7][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[7][0].change_border(:right, 'thin')
      worksheet.sheet_data[7][1].change_border(:right, 'thin')

      send_data(workbook.stream.string, filename: "#{staffing_data.staffing_model.name}-(#{current_module_project.position_x},#{current_module_project.position_y})-Export-Staffing-#{Time.now.strftime('%Y-%m-%d_%H-%M')}.xlsx", type: "application/vnd.ms-excel")
    end

  end
#end
