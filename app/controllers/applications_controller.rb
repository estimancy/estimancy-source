class ApplicationsController < ApplicationController
  before_filter :set_application, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def new
    authorize! :manage, Application
    set_page_title I18n.t(:new_application)
    @application = Application.new
    @organization = Organization.find(params[:organization_id])
    respond_with(@application)
  end

  def edit
    authorize! :show_project_areas, Application
    set_page_title I18n.t(:edit_application)
    @organization = Organization.find(params[:organization_id])
  end

  def create
    authorize! :manage, Application

    @application = Application.new(params[:application])
    @organization = Organization.find(params[:organization_id])

    if @application.save
      redirect_to redirect_apply(nil, new_organization_application_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-applications'))
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, Application

    @organization = Organization.find(params[:organization_id])
    @application = Application.find(params[:id])
    if @application.update_attributes(params[:application])
      redirect_to redirect_apply(edit_organization_application_path(@organization, @application), nil, organization_setting_path(@organization, :anchor => 'tabs-applications') )
    else
      render action: 'edit'
    end  end

  def destroy
    authorize! :manage, Application

    application_id = @application.id
    @organization = Organization.find(params[:organization_id])
    @application.destroy
    redirect_to redirect_apply(edit_organization_application_path(@organization, application_id), nil, organization_setting_path(@organization, :anchor => 'tabs-applications') )
  end

  private
    def set_application
      @application = Application.find(params[:id])
    end
end
