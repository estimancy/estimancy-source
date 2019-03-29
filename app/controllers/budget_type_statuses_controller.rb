class BudgetTypeStatusesController < ApplicationController
  def new
    #authorize! :manage, BudgetTypeStatus

    set_page_title I18n.t(:budget_type_status)
    set_breadcrumbs I18n.t(:budget_type_status) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
    @budget_type_status = BudgetTypeStatus.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    #authorize! :show_budget_type_status, BudgetTypeStatus

    @budget_type_status = BudgetTypeStatus.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:budget_type_status)
    set_breadcrumbs I18n.t(:budget_type_status) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
  end

  def create
    authorize! :manage, BudgetTypeStatus

    set_page_title I18n.t(:budget_type_status)
    set_breadcrumbs I18n.t(:budget_type_status) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""

    @budget_type_status = BudgetTypeStatus.new(params[:budget_type_status])
    @organization = Organization.find(params[:organization_id])

    if @budget_type_status.save
      flash[:notice] = I18n.t (:notice_budget_type_successful_created)
      redirect_to redirect_apply(nil, new_organization_budget_type_status_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-budget-type') )
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, BudgetTypeStatus
    @organization = Organization.find(params[:organization_id])
    @budget_type_status = BudgetTypeStatus.find(params[:id])

    set_page_title I18n.t(:budget_type_status)
    set_breadcrumbs I18n.t(:budget_type_status) => organization_setting_path(@organization, anchor: "tabs-budget-type"), I18n.t(:edit_project_area) => ""

    if @budget_type_status.update_attributes(params[:budget_type_status])
      flash[:notice] = I18n.t (:notice_budget_type_successful_updated)
      redirect_to redirect_apply(edit_organization_budget_type_status_path(@organization, @budget_type_status), nil, organization_setting_path(@organization, :anchor => 'tabs-budget-type') )
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, BudgetTypeStatus

    @budget_type_status = BudgetTypeStatus.find(params[:id])
    organization_id = @budget_type_status.organization_id
    @budget_type_status.destroy

    flash[:notice] = I18n.t (:notice_budget_type_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-budget-type')
  end
end
