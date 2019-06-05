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

    if params[:add_budget_type].present?
      selected_budget_type_id = params[:selected_budget_type_id]
      unless selected_budget_type_id.nil? || selected_budget_type_id.empty?
        add_budget_type(@organization.id, @budget.id, selected_budget_type_id)
      end

    else
      if @budget.update_attributes(params[:budget])
        app_montants = params[:budget_app_montant]
        selected_apps = params[:budget_app_check]

        unless app_montants.empty?
          app_montants.each do |app_id, montant|
              app_budget = ApplicationBudget.where(organization_id: @organization.id,
                                       application_id: app_id,
                                       budget_id: @budget.id).first_or_create
              app_budget.montant = montant.empty? ? nil : montant.to_f

              if app_id.in?(selected_apps)
                app_budget.is_used = true
              end
              app_budget.save
          end
        end

        budget_type = params[:budget_budget_type_id]
        unless budget_type.nil?
          budget_budget_type = BudgetBudgetType.where(organization_id: @organization.id,
                                 budget_id: @budget.id,
                                 budget_type_id: budget_type).first_or_create
          budget_budget_type.save
        end

        flash[:notice] = I18n.t (:notice_budget_successful_updated)
        #redirect_to organization_setting_path(@organization, :anchor => 'tabs-budgets')
        redirect_to edit_organization_budget_path(@organization, @budget)
      else
        render action: 'edit'
      end
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

  def destroy_budget_budget_type
    @organization = Organization.find(params[:organization_id])
    @budget = Budget.find(params[:budget_id])
    BudgetBudgetType.find(params[:bbt_id]).delete

    redirect_to edit_organization_budget_path(@organization, @budget)
  end

  def add_budget_type(organization_id, budget_id, budget_type_id)
    @organization = Organization.find(organization_id)
    @budget = Budget.find(budget_id)

    unless budget_type_id.nil?
      @budget_type = BudgetType.where(id: budget_type_id).first

      @budget_budget_type = BudgetBudgetType.where(organization_id: organization_id,
                                   budget_id: budget_id,
                                   budget_type_id: budget_type_id).first_or_create
      if @budget_budget_type
        @budget.applications.each do |application|
          @budget_type.budget_type_statuses.each do |budget_type_status|

            ApplicationBudgetType.where(organization_id: organization.id,
                                 budget_id: @budget.id,
                                 application_id: application.id,
                                 budget_type_id: budget_type_status.budget_type_id,
                                 estimation_status_id: budget_type_status.estimation_status_id
                               ).first_or_create
          end
        end
      end

    end

    redirect_to edit_organization_budget_path(@organization, @budget)
  end

  def generate_budget_report
    @organization = Organization.find(params[:organization_id])
    @budget = Budget.find(params[:budget_id])
    @application = Application.find(params[:application_id])

    redirect_to organization_report_path(@organization, application_id: @application.id, budget_id: @budget.id, :anchor => 'tabs-budget-report')
  end

  def generate_report_excel
    organization = Organization.find(params[:organization_id])
    budget = Budget.find(params[:budget_id])
    application = Application.find(params[:application_id])

    data = Budget::fetch_project_field_data(organization, budget , application)

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]

    i = 0
    data.each do |k,v|
      worksheet.add_cell(i, 0, k)
      worksheet.add_cell(i, 1, v)
      i = i + 1
    end

    send_data(workbook.stream.string, filename: "#{@budget.name}-#{@application.name}.xlsx" , type: "application/vnd.ms-excel")
  end

  def save_budget
    params[:value].each do |k|
      Budget.where(application_id: params[:value])
    end
  end

end