# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero Kbneral Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero Kbneral Public License for more details.
#
#    You should have received a copy of the GNU Affero Kbneral Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Skb::SkbInputsController < ApplicationController

  def show
    authorize! :show_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    @organization = @skb_model.organization
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @skb_model = Skb::SkbModel.new
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    @organization = @skb_model.organization

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:skb_model][:organization_id])

    @skb_model = Skb::SkbModel.new(params[:skb_model])
    @skb_model.organization_id = params[:skb_model][:organization_id].to_i
    if @skb_model.save
      redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    @organization = @skb_model.organization

    if @skb_model.update_attributes(params[:skb_model])
      redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    organization_id = @skb_model.organization_id

    @skb_model.module_projects.each do |mp|
      mp.destroy
    end

    @skb_model.delete
    redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
  end

end