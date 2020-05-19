class KpisController < ApplicationController
  def new
    set_page_title I18n.t(:new_kpi)
    @kpi = Kpi.new
    @organization = Organization.find_by_id(params[:organization_id])

    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
    set_breadcrumbs I18n.t(:kpis) => organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators'), I18n.t('new_kpi') => ""


  end

  def edit
    @kpi = Kpi.find(params[:id])
    @organization = @kpi.organization

    set_page_title I18n.t(:edit_kpi, value: @kpi.name)
    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
  end



  def create

    params[:kpi].permit!
    @kpi = Kpi.new(params[:kpi])
    @organization = Organization.find_by_id(params['kpi']['organization_id'])

    set_page_title I18n.t(:new_kpi)
    #set_breadcrumbs I18n.t(:kpis) => organization_setting_path(@organization, anchor: "tabs-kpi"), I18n.t('new_kpi') => ""

    if @kpi.save
      #redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_productivity")
      redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
    else
      render action: 'new'
    end
  end


  def update
    params[:kpi].permit!
    @kpi = Kpi.find(params[:id])
    @organization = @kpi.organization

    #set_page_title I18n.t(:edit_kpi, value: @kpi.name)
    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", "#{@organization.to_s} / #{I18n.t(:kpis)} / #{@kpi.to_s}" => edit_organization_path(@organization)

    if @kpi.update_attributes(params[:kpi])
      flash[:notice] =  "#{I18n.t (:notice_kpi_successful_updated)}"
      #redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_productivity")
      redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
    else
      render action: 'edit'
    end
  end


  def destroy
    @organization = Organization.find(params[:organization_id])
    @kpi = Kpi.find(params[:id])

    @kpi.destroy

    flash[:notice] = I18n.t(:notice_kpi_successful_deleted)
    #redirect_to organization_authorization_path(@organization, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), anchor: "tabs-group")
    redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
  end

  #Update the module_project corresponding data of view
  def update_productivity_kpi_field
    estimation_model_id = params['estimation_model_id']

    if !estimation_model_id.nil? && estimation_model_id != 'undefined'

      @estimation_model = Project.find(estimation_model_id)

      @estimation_model_project_fields = @estimation_model.project_fields
      @estimation_model_fields = []

      @estimation_model_project_fields.each do |pf|
        @estimation_model_fields << pf.field
      end
    end
  end

end
