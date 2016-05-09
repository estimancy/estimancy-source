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

class CurrenciesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource
  #load_and_authorize_resource

  before_filter :get_record_statuses

  def index
    authorize! :manage_master_data, :all
    @currencies = Currency.all
    set_page_title I18n.t(:currencies)
    set_breadcrumbs I18n.t(:currencies) => currencies_path
  end

  # GET /currencies/new
  # GET /currencies/new.json
  def new
    authorize! :manage_master_data, :all
    @currency = Currency.new
    set_page_title I18n.t(:new_currency)
    set_breadcrumbs I18n.t(:currencies) => profiles_path, I18n.t('new_currency') => ""
  end

  # GET /currencies/1/edit
  def edit
    authorize! :manage_master_data, :all
    set_page_title I18n.t(:edit_currency)
    set_breadcrumbs I18n.t(:currencies) => profiles_path, I18n.t('edit_currency') => ""

    @currency = Currency.find(params[:id])

    unless @currency.child_reference.nil?
      if @currency.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_currency_cant_be_edit)
        redirect_to currencies_path
      end
    end
  end

  # POST /currencies
  # POST /currencies.json
  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:new_currency)
    set_breadcrumbs I18n.t(:currencies) => profiles_path, I18n.t('new_currency') => ""

    @currency = Currency.new(params[:currency])
    @currency.save
    redirect_to redirect(currencies_url)
  end

  # PUT /currencies/1
  # PUT /currencies/1.json
  def update
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:edit_currency)
    set_breadcrumbs I18n.t(:currencies) => profiles_path, I18n.t('edit_currency') => ""

    @currency = nil
    current_currency = Currency.find(params[:id])
    if current_currency.is_defined?
      @currency = current_currency.amoeba_dup
      @currency.owner_id = current_user.id
    else
      @currency = current_currency
    end

    if @currency.update_attributes(params[:currency])
      redirect_to redirect(currencies_url), notice: "#{I18n.t (:notice_currency_successful_updated)}"
    else
      render action: 'edit'
    end
  end

  # DELETE /currencies/1
  # DELETE /currencies/1.json
  def destroy
    authorize! :manage_master_data, :all

    @currency = Currency.find(params[:id])
    if @currency.is_defined? || @currency.is_custom?
      #logical deletion: delete don't have to suppress records anymore on defined record
      @currency.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @currency.destroy
    end

    flash[:notice] = I18n.t (:notice_currency_successful_deleted)
    redirect_to currencies_url
  end
end
