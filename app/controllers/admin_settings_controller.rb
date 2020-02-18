#encoding: utf-8
#########################################################################
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
########################################################################

class AdminSettingsController < ApplicationController

  load_resource

  helper_method :admin_setting_selected_status

  def maintenances
    set_page_title I18n.t(:admin_settings)
    set_breadcrumbs I18n.t(:admin_settings) => admin_settings_path, I18n.t('maintenance_message') => ""

    @admin_setting = AdminSetting.where(key: "allow_authentication").first
  end

  def mass_mailing
    @users = User.all
    @message = params[:message]
    @objet = params[:objet]
    UserMailer.maintenance(@users, @message, @objet).deliver
    redirect_to "/organizationals_params"
  end

  def index
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:Parameters)
    set_breadcrumbs I18n.t(:Parameters) => admin_settings_path, I18n.t('admin_settings') => ""
    @admin_settings = AdminSetting.all
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:Parameters)
    set_breadcrumbs I18n.t(:Parameters) => admin_settings_path, I18n.t('new_admin_settings') => ""
    @admin_setting = AdminSetting.new
  end

  def edit
    authorize! :manage_master_data, :all
    set_page_title I18n.t(:Parameters)
    @admin_setting = AdminSetting.find(params[:id])

    set_breadcrumbs I18n.t(:Parameters) => admin_settings_path, I18n.t('edit_admin_setting') => ""
  end

  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:Parameters)
    set_breadcrumbs I18n.t(:Parameters) => admin_settings_path, I18n.t('new_admin_settings') => ""

    @admin_setting = AdminSetting.new(params[:admin_setting])

    if @admin_setting.save
      flash[:notice] = I18n.t (:notice_administration_setting_successful_created)
      redirect_to redirect_apply(nil,new_admin_setting_path(),admin_settings_path)
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    @admin_setting = AdminSetting.find(params[:id])

    set_page_title I18n.t(:Parameters)
    set_breadcrumbs I18n.t(:Parameters) => admin_settings_path, I18n.t('edit_admin_setting') => ""

    if @admin_setting.update_attributes(params[:admin_setting])
      flash[:notice] = I18n.t (:notice_administration_setting_successful_updated)
      redirect_to redirect_apply(edit_admin_setting_path(@admin_setting),nil,admin_settings_path)
    else
      flash[:error] = I18n.t (:error_administration_setting_failed_update)
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all

    @admin_setting = AdminSetting.find(params[:id])
    @admin_setting.destroy

    redirect_to admin_settings_path
  end

end
