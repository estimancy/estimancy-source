#encoding: utf-8
##########################################################################
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
##########################################################################

class BudgetsController < ApplicationController

  #include OrganizationsHelper

  def new
    authorize! :manage, Budget

    set_page_title I18n.t(:budget)
    set_breadcrumbs I18n.t(:budget) => organization_setting_path(@current_organization, anchor: "tabs-budgets"), I18n.t('budget') => ""
    @budget = Budget.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_budgets, Budget

    @budget = Budget.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:budget)
    set_breadcrumbs I18n.t(:budget) => organization_setting_path(@current_organization, anchor: "tabs-budgets"), I18n.t('budget') => ""

  end

  def create
    authorize! :manage, Budget

    set_page_title I18n.t(:budget)
    set_breadcrumbs I18n.t(:budget) => organization_setting_path(@current_organization, anchor: "tabs-budgets"), I18n.t('budget') => ""

    @budget = Budget.new(params[:budget])
    @organization = Organization.find(params[:organization_id])
    #@application = Application.find(params[:application_id])
    #@budget.application_id = @application.id

    if @budget.save
      flash[:notice] = I18n.t (:notice_budget_successful_created)
      redirect_to :back
    else
      render action: 'new'
    end
  end

  def update
    @organization = Organization.find(params[:organization_id])
    @budget = Budget.find(params[:id])
    #@application = Application.find(params[:application_id])

    if @budget.update_attributes(params[:budget])
      flash[:notice] = I18n.t (:notice_budget_successful_updated)
      redirect_to organization_setting_path(@organization, :anchor => 'tabs-budgets')
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, Budget

    @budget = Budget.find(params[:id])
    organization_id = @budget.organization_id
    @budget.destroy

    flash[:notice] = I18n.t (:notice_budget_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-budgets')
  end

  def generate_budget_report
    @organization = Organization.find(params[:organization_id])
    @budget = Budget.find(params[:budget_id])
    @application = Application.find(params[:application_id])
    redirect_to organization_report_path(@organization, application_id: @application.id, budget_id: @budget.id, :anchor => 'tabs-budget-report')
  end

  def generate_report_excel
    @organization = Organization.find(params[:organization_id])

    unless params[:budget_id].nil?
      @budget = Budget.find(params[:budget_id])
    end

    unless params[:application_id].nil?
      @application = Application.find(params[:application_id])
    end

    @bt_hash = Hash.new {|h,k| h[k] = [] }

    @fields_coefficients = {}
    @pfs = {}
    @projects = @organization.projects

    fields = @organization.fields
    ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(fields.map(&:id))
          if pf.project && pf.views_widget
            if pf.project_id == pf.views_widget.module_project.project_id
              @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
            else
              pf.delete
            end
          else
            pf.delete
          end
        else
          pf.delete
        end

      rescue
        #puts "erreur"
      end
    end

    unless params[:application_id].nil? || params[:budget_id].nil?
      BudgetTypeStatus.where(application_id: @application.id,
                             organization_id: @current_organization.id).all.each do |bts|

        projects = Project.where(application_id: @application.id ,
                                 organization_id: @current_organization.id,
                                 estimation_status_id: bts.estimation_status_id,
                                 is_model: false).all
        projects_sum = 0
        projects.each do |project|
          unless @budget.field_id.nil?

            field = Field.where(organization_id: project.organization_id, name: Field.find(@budget.field_id).name).first
            column = QueryColumn.new(field.name.to_sym,
                                     sortable: "",
                                     caption: "",
                                     field_id: field.id,
                                     organization_id: @current_organization.id)
            value = OrganizationsHelper.column_content(@pfs, column, project, @fields_coefficients).gsub("<td><span class=\"pull-right\">", '').gsub("</span></td>", "").gsub(",", ".").to_f

            projects_sum += value.round(2)
            unless bts.budget_type.nil?
              @bt_hash[bts.budget_type.name] << projects_sum.round(2)
            end
          end
        end
      end

      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]
      @bt_hash.each do |k,v|
        worksheet.add_cell(k, v)
      end
      send_data(workbook.stream.string, filename: "2020-CLIC.xlsx" , type: "application/vnd.ms-excel")
    end

  end

  def save_budget
    params[:value].each do |k|
      Budget.where(application_id: params[:value])
    end
  end

end