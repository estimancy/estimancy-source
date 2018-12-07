class DemandStatusesController < ApplicationController

  def index
    @demand_statuses = DemandStatus.where(organization_id: params[:organization_id]).all
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    @demand_status = DemandStatus.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def new
    @demand_status = DemandStatus.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @demand_status = DemandStatus.new(params[:demand_status])
    @organization = Organization.find(params[:organization_id])

    if @demand_status.save
      flash[:notice] = "DemandStatuse créee avec succès"
      redirect_to organization_demand_statuses_path(@organization)
    else
      render action: 'new'
    end
  end
end
