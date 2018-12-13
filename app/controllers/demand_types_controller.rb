class DemandTypesController < ApplicationController

  def index
    @demand_types = DemandType.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_demand_statuses'))
    @demand_type = DemandType.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    set_page_title (I18n.t('create_demand_statuses'))
    @demand_type = DemandType.new(params[:demand_type])
    @organization = Organization.find(params[:organization_id])

    if @demand_type.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end
  end

  def update
    @demand_type = DemandType.find(params[:id])
    @demand_type.update(params[:demand_type])

    redirect_to :back
  end

  def edit
    set_page_title (I18n.t('edit_demand_types'))
    @demand_type = DemandType.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def destroy
  end

end
