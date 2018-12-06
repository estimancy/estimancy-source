class DemandTypesController < ApplicationController

  def index
    @demand_types = DemandType.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    @demand_type = DemandType.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @demand = DemandType.new(params[:demand])
    @organization = Organization.find(params[:organization_id])

    if @demand.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end
  end

  def edit
  end

  def destroy
  end

end
