class ApplicationsController < ApplicationController
  before_filter :set_application, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @applications = Application.all
    respond_with(@applications)
  end

  def show
    respond_with(@application)
  end

  def new
    @application = Application.new
    @organization = Organization.find(params[:organization_id])
    respond_with(@application)
  end

  def edit
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @application = Application.new(params[:application])
    @organization = Organization.find(params[:organization_id])

    if @application.save
      redirect_to redirect_apply(nil, new_organization_application_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-applications') )
    else
      render action: 'new'
    end
  end

  def update
    @organization = Organization.find(params[:organization_id])
    @application = Application.find(params[:id])
    if @application.update_attributes(params[:application])
      redirect_to redirect_apply(edit_organization_application_path(@organization, @application), nil, organization_setting_path(@organization, :anchor => 'tabs-applications') )
    else
      render action: 'edit'
    end  end

  def destroy
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
