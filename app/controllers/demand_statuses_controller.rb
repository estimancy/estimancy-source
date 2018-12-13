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
      redirect_to organization_setting_demand_path(@organization)
    else
      render action: 'new'
    end
  end

  def set_demand_status_workflow
    @organization = Organization.find(params[:organization_id])

    if params[:commit] == I18n.t('cancel')
      redirect_to :back
    else
      @organization.demand_statuses.each do |status|
        if params[:status_workflow].nil?
          status.update_attribute('demand_to_transition_status_ids', status.id)
        else
          status.update_attribute('demand_to_transition_status_ids', params[:status_workflow][status.id.to_s])
        end
      end
      redirect_to organization_setting_demand_path(@organization, anchor: 'tabs-demand-statuses'), :notice => "OK"
    end
  end
end
