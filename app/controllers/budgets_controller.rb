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
      redirect_to organization_setting_path(@organization)
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

  def save_budget
    params[:value].each do |k|
      Budget.where(application_id: params[:value])
    end
  end



end