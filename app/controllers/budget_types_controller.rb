class BudgetTypesController < ApplicationController

  def new
    authorize! :manage, BudgetType

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
    @budget_type = BudgetType.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_budget_types, BudgetType

    @budget_type = BudgetType.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""
  end

  def create
    authorize! :manage, BudgetType

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@current_organization, anchor: "tabs-budget-type"), I18n.t('budget_type') => ""

    @budget_type = BudgetType.new(params[:budget_type])
    @organization = Organization.find(params[:organization_id])

    if @budget_type.save
      flash[:notice] = I18n.t (:notice_budget_type_successful_created)
      redirect_to redirect_apply(nil, new_organization_budget_type_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-budget-type') )
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, BudgetType
    @organization = Organization.find(params[:organization_id])
    @budget_type = BudgetType.find(params[:id])

    set_page_title I18n.t(:budget_type)
    set_breadcrumbs I18n.t(:budget_type) => organization_setting_path(@organization, anchor: "tabs-budget-type"), I18n.t(:edit_project_area) => ""

    if @budget_type.update_attributes(params[:budget_type])
      flash[:notice] = I18n.t (:notice_budget_type_successful_updated)
      redirect_to redirect_apply(edit_organization_budget_type_path(@organization, @budget_type), nil, organization_setting_path(@organization, :anchor => 'tabs-budget-type') )
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
