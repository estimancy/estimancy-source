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

class PeAttributesController < ApplicationController
  load_resource :except => [:find_use_attribute, :check_attribute]

  def index
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:pe_attributes)
    set_breadcrumbs I18n.t(:pe_attributes) => pe_attributes_path, I18n.t('attributes_list') => ""

    @attributes = PeAttribute.all
  end

  def new
    authorize! :manage_master_data, :all
    set_breadcrumbs I18n.t(:pe_attributes) => pe_attributes_path, I18n.t('new_pe_attribute') => ""

    set_page_title I18n.t(:pe_attributes)
    @attribute = PeAttribute.new
  end

  def edit
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:pe_attributes)
    set_breadcrumbs I18n.t(:pe_attributes) => pe_attributes_path, I18n.t('pe_attribute_edition') => ""

    @attribute = PeAttribute.find(params[:id])

    env["HTTP_REFERER"] += '#tabs-attribute'
  end

  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:pe_attributes)
    set_breadcrumbs I18n.t(:pe_attributes) => pe_attributes_path, I18n.t('new_pe_attribute') => ""

    @attribute = PeAttribute.new(params[:pe_attribute])
    @attribute.options = params[:options]
    @attribute.attr_type = params[:options][0]

    if @attribute.save
      flash[:notice] = I18n.t (:notice_pe_attribute_successful_created)
      redirect_to redirect_apply(nil, new_pe_attribute_path,  pe_attributes_path)
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:pe_attributes)
    set_breadcrumbs I18n.t(:pe_attributes) => pe_attributes_path, I18n.t('pe_attribute_edition') => ""

    @attribute = nil
    @attribute = PeAttribute.find(params[:id])

    if @attribute.update_attributes(params[:pe_attribute]) and @attribute.update_attribute('options', params[:options])
      @attribute.attr_type = params[:options][0]
      if @attribute.save
        flash[:notice] = I18n.t (:notice_pe_attribute_successful_updated)
        redirect_to redirect_apply(edit_pe_attribute_path(@attribute), nil, pe_attributes_path)
      else
        render action: 'edit'
      end
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all

    @attribute = PeAttribute.find(params[:id])
    @attribute.destroy
    redirect_to pe_attributes_path
  end

  #TODO opi : add a comment to explain when/how is used check_attribute
  def check_attribute
    if params[:est_val_id]
      @ev = EstimationValue.find(params[:est_val_id])
      @is_valid = @ev.is_validate(params[:value])
      test = params[:value]
      @level = params[:level]
      @est_val_id = params[:est_val_id]
      params[:wbs_project_elt_id].eql?('undefined') ? @wbs_project_elt_id = nil : @wbs_project_elt_id = params[:wbs_project_elt_id]
    end
  end

  #Find where attribute is using
  def find_use_attribute
    authorize! :manage_master_data, :all

    @pe_attribute = PeAttribute.find(params[:pe_attribute_id])
    @attribute_modules = AttributeModule.find_all_by_pe_attribute_id(@pe_attribute.id)
    @attribute_organizations = AttributeOrganization.find_all_by_pe_attribute_id(@pe_attribute.id)
  end

end
