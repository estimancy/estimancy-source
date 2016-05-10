#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class EstimationStatusesController < ApplicationController

  # Set the estimation status workflow
  def set_estimation_status_workflow
    authorize! :manage, EstimationStatus

    @organization = Organization.find(params[:organization_id])

    if params[:commit] == I18n.t('cancel')
      redirect_to :back
    else
      @organization.estimation_statuses.each do |status|
        if params[:status_workflow].nil?
          status.update_attribute('to_transition_status_ids', status.id)    #status.update_attribute('to_transition_status_ids', nil)
        else
          status.update_attribute('to_transition_status_ids', params[:status_workflow][status.id.to_s])
        end
      end
      redirect_to organization_setting_path(@organization, anchor: 'tabs-estimations-statuses'), :notice => "#{I18n.t (:notice_estimation_status_successful_updated)}"
    end
  end


  # Set the estimations permission for groups according to the estimate status
  def set_estimation_status_group_roles
    authorize! :manage, EstimationStatus

    @organization = Organization.find(params[:organization_id])

    @organization.estimation_statuses.all.each do |status|
      params[:status_group_role][status.id.to_s] ||= {}
      @organization.groups.each do |group|
        params[:status_group_role][status.id.to_s][group.id.to_s] ||= []

        est_status_groups = status.estimation_status_group_roles.where(group_id: group.id)
        est_status_groups.delete_all

        unless params[:status_group_role][status.id.to_s][group.id.to_s].blank?
          status.estimation_status_group_roles.build(organization_id: @organization.id,
                                                     group_id: group.id,
                                                     project_security_level_id: params[:status_group_role][status.id.to_s][group.id.to_s].to_i)
        end
        status.save
      end
    end

    redirect_to organization_setting_path(@organization, anchor: 'tabs-estimations-statuses'), :notice => "#{I18n.t (:notice_estimation_status_successful_updated)}"
  end

  def new
    authorize! :manage, EstimationStatus
    @estimation_status = EstimationStatus.new
    @organization = Organization.find_by_id(params[:organization_id])
    set_page_title I18n.t(:new_estimation_status)
    set_breadcrumbs I18n.t(:estimations_statuses) => organization_setting_path(@organization, anchor: "tabs-estimations-statuses"), I18n.t('new_estimation_status') => ""
  end

  def edit

    authorize! :show_estimation_statuses, EstimationStatus

    @estimation_status = EstimationStatus.find(params[:id])
    @organization = @estimation_status.organization
    set_page_title I18n.t(:edit_estimation_status, value: @estimation_status.name)
    set_breadcrumbs I18n.t(:estimations_statuses) => organization_setting_path(@organization, anchor: "tabs-estimations-statuses"), I18n.t('estimation_status_edition') => ""
  end

  def create
    authorize! :manage, EstimationStatus

    @estimation_status = EstimationStatus.new(params[:estimation_status])
    @organization = Organization.find_by_id(params['estimation_status']['organization_id'])

    set_page_title I18n.t(:new_estimation_status)
    set_breadcrumbs I18n.t(:estimations_statuses) => organization_setting_path(@organization, anchor: "tabs-estimations-statuses"), I18n.t('new_estimation_status') => ""

    if @estimation_status.save
      # Create the status self transition
      StatusTransition.create(from_transition_status_id: @estimation_status.id, to_transition_status_id: @estimation_status.id)
      flash[:notice] = I18n.t (:notice_estimation_status_successful_created)
      redirect_to redirect_apply(nil, new_estimation_status_path(params[:estimation_status]), organization_setting_path(@organization, :anchor => 'tabs-estimations-statuses'))
    else
      render action: 'new', :organization_id => @organization.id
    end

  end

  def update
    authorize! :manage, EstimationStatus

    @estimation_status = EstimationStatus.find(params[:id])
    @organization = @estimation_status.organization

    set_page_title I18n.t(:edit_estimation_status, value: @estimation_status.name)
    set_breadcrumbs I18n.t(:estimations_statuses) => organization_setting_path(@organization, anchor: "tabs-estimations-statuses"), I18n.t('estimation_status_edition') => ""

    if @estimation_status.update_attributes(params[:estimation_status])
      flash[:notice] = I18n.t (:notice_estimation_status_successful_updated)
      redirect_to redirect_apply(edit_estimation_status_path(params[:estimation_status]), nil, organization_setting_path(@organization, :anchor => 'tabs-estimations-statuses'))
    else
      render action: 'edit', :organization_id => @organization.id
    end
  end

  def destroy
    authorize! :manage, EstimationStatus

    @estimation_status = EstimationStatus.find(params[:id])
    organization_id = @estimation_status.organization_id

    # Before destroying, we should check if the status is used by one or more projects before to be able to delete it.
    if @estimation_status.projects.empty? || @estimation_status.projects.nil?
      @estimation_status.destroy
      flash[:notice] = I18n.t(:notice_estimation_status_successful_deleted)
    else
      flash[:warning] = I18n.t(:warning_estimation_status_cannot_be_deleted, value: @estimation_status.name)
    end

    respond_to do |format|
      format.html { redirect_to organization_setting_path(organization_id, :anchor => 'tabs-estimations-statuses') }
    end
  end
end
