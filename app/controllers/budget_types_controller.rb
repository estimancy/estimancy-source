class BudgetTypesController < ApplicationController

  def new
    authorize! :manage, BudgetType

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
    @budget_type = BudgetType.new
    @organization = Organization.find(params[:organization_id])
    @application = Application.find(params[:application_id])

  end

  def edit
    authorize! :show_budget_types, BudgetType

    @budget_type = BudgetType.find(params[:id])
    @organization = Organization.find(params[:organization_id])
    @application = Application.find(params[:application_id])

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
  end

  def create
    authorize! :manage, BudgetType

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""

    @budget_type = BudgetType.new(params[:budget_type])
    @organization = Organization.find(params[:organization_id])
    @application = Application.find(params[:application_id])
    @budget_type.application_id = @application.id

    if @budget_type.save

      params[:estimation_statuses].each do |k, v|
        BudgetTypeStatus.where(organization_id: @organization.id,
                               budget_type_id: @budget_type.id,
                               estimation_status_id: k,
                               application_id: @application.id).first_or_create
      end

      flash[:notice] = I18n.t (:notice_budget_type_successful_created)
      redirect_to :back
    else
      render action: 'new'
    end
  end

  def update
    #authorize! :manage, BudgetType
    @organization = Organization.find(params[:organization_id])
    @budget_type = BudgetType.find(params[:id])
    @application = Application.find(params[:application_id])

    BudgetTypeStatus.where(organization_id: @organization.id,
                           budget_type_id: @budget_type.id,
                           application_id: @application.id ).delete_all

    params[:estimation_statuses].each do |k, v|
      BudgetTypeStatus.where(organization_id: @organization.id,
                             budget_type_id: @budget_type.id,
                             estimation_status_id: k,
                             application_id: @application.id).first_or_create
    end

    if @budget_type.update_attributes(params[:budget_type])
      flash[:notice] = I18n.t (:notice_budget_type_successful_updated)
      redirect_to :back
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, BudgetType

    @budget_type = BudgetType.find(params[:id])
    organization_id = @budget_type.organization_id
    @budget_type.destroy

    flash[:notice] = I18n.t (:notice_budget_type_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-budget-type')
  end
end
