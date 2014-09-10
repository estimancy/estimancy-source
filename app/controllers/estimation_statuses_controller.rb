class EstimationStatusesController < ApplicationController

  # Set the estimation status workflow
  def set_estimation_status_workflow
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization_id])

    if params[:commit] == I18n.t('cancel')
      redirect_to edit_organization_path(:anchor => "tabs-estimations-statuses"), :notice => "#{I18n.t (:notice_estimation_status_successful_cancelled)}"
    else
      @organization.estimation_statuses.each do |status|
        if params[:status_workflow].nil?
          status.update_attribute('to_transition_status_ids', nil)
        else
          status.update_attribute('to_transition_status_ids', params[:status_workflow][status.id.to_s])
        end
      end
      redirect_to edit_organization_path(@organization, :anchor => "tabs-estimations-statuses"), :notice => "#{I18n.t (:notice_estimation_status_successful_updated)}"
    end
  end


  # Set the estimations permission for groups according to the estimate status
  def set_estimation_status_group_roles
    authorize! :edit_organizations, Organization
    @organization = Organization.find(params[:organization_id])

    @organization.estimation_statuses.all.each do |status|
      params[:status_group_role][status.id.to_s] ||= {}
      Group.all.each do |group|
        params[:status_group_role][status.id.to_s][group.id.to_s] ||= []

        est_status_groups = status.estimation_status_group_roles.where(group_id: group.id)
        est_status_groups.delete_all

        params[:status_group_role][status.id.to_s][group.id.to_s].each do |permission|
          status.estimation_status_group_roles.build(organization_id: @organization.id, group_id: group.id, permission_id: permission)
          status.save
        end
      end
    end

    ##status.estimation_status_group_roles(force_reload = true)
    redirect_to edit_organization_path(@organization, :anchor => "tabs-estimations-statuses"), :notice => "#{I18n.t (:notice_estimation_status_successful_updated)}"
  end


  # GET /estimation_statuses
  # GET /estimation_statuses.json
  def index
    @estimation_statuses = EstimationStatus.all
  end

  # GET /estimation_statuses/1
  # GET /estimation_statuses/1.json
  def show
    @estimation_status = EstimationStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @estimation_status }
    end
  end

  # GET /estimation_statuses/new
  # GET /estimation_statuses/new.json
  def new
    @estimation_status = EstimationStatus.new
    @organization = Organization.find_by_id(params[:organization_id])



  end

  # GET /estimation_statuses/1/edit
  def edit
    @estimation_status = EstimationStatus.find(params[:id])
    @organization = @estimation_status.organization
  end

  # POST /estimation_statuses
  # POST /estimation_statuses.json
  def create
    @estimation_status = EstimationStatus.new(params[:estimation_status])
    @organization = Organization.find_by_id(params['estimation_status']['organization_id'])

    if @estimation_status.save
      flash[:notice] = I18n.t (:notice_estimation_status_successful_created)
      redirect_to redirect_apply(nil, new_estimation_status_path(params[:estimation_status]), edit_organization_path(@organization, :anchor => 'tabs-estimations-statuses'))
    else
      render action: 'new', :organization_id => @organization.id
    end

  end

  # PUT /estimation_statuses/1
  # PUT /estimation_statuses/1.json
  def update
    @estimation_status = EstimationStatus.find(params[:id])
    @organization = @estimation_status.organization

    if @estimation_status.update_attributes(params[:estimation_status])
      flash[:notice] = I18n.t (:notice_estimation_status_successful_updated)
      redirect_to redirect_apply(edit_estimation_status_path(params[:estimation_status]), nil, edit_organization_path(@organization, :anchor => 'tabs-estimations-statuses'))
    else
      render action: 'edit', :organization_id => @organization.id
    end
  end

  # DELETE /estimation_statuses/1
  # DELETE /estimation_statuses/1.json
  def destroy
    @estimation_status = EstimationStatus.find(params[:id])

    organization_id = @estimation_status.organization_id
    @estimation_status.destroy
    respond_to do |format|
      format.html { redirect_to redirect(edit_organization_path(organization_id, :anchor => 'tabs-estimations-statuses')), notice: "#{I18n.t (:notice_estimation_status_successful_deleted)}" }
    end
  end
end
