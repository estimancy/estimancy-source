class DemandStatusesController < ApplicationController

  def index
    @demand_statuses = DemandStatus.where(organization_id: params[:organization_id]).all
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    set_page_title (I18n.t('edit_demand_statuses'))
    @demand_status = DemandStatus.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_demand_statuses'))
    @demand_status = DemandStatus.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    set_page_title (I18n.t('create_demand_statuses'))
    @demand_status = DemandStatus.new(params[:demand_status])
    @organization = Organization.find(params[:organization_id])

    if @demand_status.save
      flash[:notice] = "DemandStatuse créee avec succès"
      redirect_to organization_setting_demand_path(@organization, partial_name: 'tabs_demand_statuses', item_title: I18n.t('demands_statuses'), anchor: 'demands_statuses')
    else
      render action: 'new'
    end
  end

  def update
    @demand_status = DemandStatus.find(params[:id])
    @organization = Organization.find(params[:organization_id])
    @demand_status.update(params[:demand_status])
    redirect_to organization_setting_demand_path(@organization, partial_name: 'tabs_demand_statuses', item_title: I18n.t('demands_statuses'), anchor: 'demands_statuses')
  end

  def set_demand_status_workflow
    @organization = Organization.find(params[:organization_id])
    @demand_type = DemandType.find(params[:demand_type_id])

    if params[:commit] == I18n.t('cancel')
      redirect_to :back
    else
      @demand_type.demand_statuses.each do |status|
        if params[:status_workflow].nil?
          status.update_attribute('demand_to_transition_status_ids', status.id)
        else
          status.update_attribute('demand_to_transition_status_ids', params[:status_workflow][status.id.to_s])
        end
      end
      redirect_to :back
    end
  end
end
