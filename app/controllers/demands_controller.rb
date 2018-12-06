class DemandsController < ApplicationController

  def index
    @demands = Demand.where(organization_id: params[:organization_id]).all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    @demand = Demand.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @demand = Demand.new(params[:demand])
    @organization = Organization.find(params[:organization_id])

    if @demand.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end
  end
end
