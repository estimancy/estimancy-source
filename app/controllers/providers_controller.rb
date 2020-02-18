class ProvidersController < ApplicationController

  load_resource

  def new
    authorize! :manage, Provider

    set_page_title I18n.t(:providers)
    set_breadcrumbs I18n.t(:providers) => organization_setting_path(@current_organization, anchor: "tabs-providers"), I18n.t('new_provider') => ""
    @provider = Provider.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    authorize! :show_providers, Provider

    @provider = Provider.find(params[:id])
    @organization = Organization.find(params[:organization_id])

    set_page_title I18n.t(:providers)
    set_breadcrumbs I18n.t(:providers) => organization_setting_path(@organization, anchor: "tabs-providers"), I18n.t(:provider_edition) => ""
  end

  def create
    authorize! :manage, Provider

    set_page_title I18n.t(:providers)
    set_breadcrumbs I18n.t(:providers) => organization_setting_path(@current_organization, anchor: "tabs-providers"), I18n.t('new_provider') => ""

    @provider = Provider.new(params[:provider])
    @organization = Organization.find(params[:organization_id])

    if @provider.save
      flash[:notice] = I18n.t (:notice_provider_successful_created)
      redirect_to redirect_apply(nil, new_organization_provider_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-providers') )
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, Provider
    @organization = Organization.find(params[:organization_id])
    @provider = Provider.find(params[:id])

    set_page_title I18n.t(:providers)
    set_breadcrumbs I18n.t(:providers) => organization_setting_path(@organization, anchor: "tabs-providers"), I18n.t(:provider_edition) => ""

    if @provider.update_attributes(params[:provider])
      flash[:notice] = I18n.t (:notice_provider_successful_updated)
      redirect_to redirect_apply(edit_organization_provider_path(@organization, @provider), nil, organization_setting_path(@organization, :anchor => 'tabs-providers') )
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage, Provider

    @provider = Provider.find(params[:id])
    organization_id = @provider.organization_id
    @provider.destroy

    flash[:notice] = I18n.t (:notice_provider_successful_deleted)
    redirect_to organization_setting_path(organization_id, :anchor => 'tabs-providers')
  end

end
