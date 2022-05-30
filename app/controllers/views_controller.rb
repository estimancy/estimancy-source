# encoding: UTF-8
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

class ViewsController < ApplicationController
  # GET /views
  # GET /views.json
  def index
    @views = View.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @views }
    end
  end

  # GET /views/1
  # GET /views/1.json
  def show
    @view = View.find(params[:id])

    respond_to do |format|
      format.html # show.js.erb
      format.json { render json: @view }
    end
  end

  # GET /views/new
  # GET /views/new.json
  def new
    @view = View.new
    @organization = Organization.find_by_id(params[:organization_id])

    set_page_title I18n.t(:views)
    set_breadcrumbs I18n.t(:views) => organization_setting_path(@current_organization, anchor: "tabs-views", partial_name: 'tabs_views'), I18n.t('new_view') => ""

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @view }
    end
  end

  # GET /views/1/edit
  def edit
    @view = View.find(params[:id])
    @organization = @view.organization
    set_page_title I18n.t(:edit_view_2)
    set_breadcrumbs I18n.t(:views) => organization_setting_path(@organization, anchor: "tabs-views", partial_name: 'tabs_views'), I18n.t('edit_view_2') => ""
  end

  # POST /views
  # POST /views.json
  def create
    @view = View.new(params[:view])
    @organization = Organization.find_by_id(params['view']['organization_id'])
    last_default_view = @organization.views.where('pemodule_id = ? AND is_default_view = ?', @view.pemodule_id, true).first

    if @view.save

      if @view.is_default_view && last_default_view
        last_default_view.update_attribute(:is_default_view, false)
      end

      flash[:notice] = I18n.t(:view_successfully_created)
      redirect_to redirect_apply(nil, new_view_path(params[:view]), organization_setting_path(@organization, :anchor => 'tabs-views', partial_name: 'tabs_views'))
    else
      render action: "new", :organization_id => @organization.id
    end
  end

  # PUT /views/1
  # PUT /views/1.json
  def update
    @view = View.find(params[:id])
    @organization = @view.organization
    last_default_view = @organization.views.where('pemodule_id = ? AND is_default_view = ?', @view.pemodule_id, true).first

    if @view.update_attributes(params[:view])

      if @view.is_default_view && last_default_view
        last_default_view.update_attribute(:is_default_view, false)
      end

      flash[:notice] = I18n.t(:view_successfully_updated)
      redirect_to redirect_apply(edit_organization_view_path(params[:view]), nil, organization_setting_path(@organization, :anchor => 'tabs-views', partial_name: 'tabs_views'))
    else
      render action: "edit", :organization_id => @organization.id
    end

  end

  # DELETE /views/1
  # DELETE /views/1.json
  def destroy
    @view = View.find(params[:id])
    @organization = @view.organization

    @view.destroy

    redirect_to organization_setting_path(@organization, :anchor => 'tabs-views', partial_name: 'tabs_views')
  end
end
