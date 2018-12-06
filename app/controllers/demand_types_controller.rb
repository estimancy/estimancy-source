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
    @demand_type = DemandType.new(params[:demand_type])
    @organization = Organization.find(params[:organization_id])

    if @demand_type.save
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
