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

class PermissionsController < ApplicationController

  load_resource

  def index
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:permissions)
    set_breadcrumbs I18n.t(:permissions) => permissions_path, I18n.t('permissions_list') => ""

    @permissions = Permission.all

    respond_to do |format|
      format.html
    end
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:permissions)
    set_breadcrumbs I18n.t(:permissions) => permissions_path, I18n.t('new_permission') => ""

    @permission = Permission.new
  end

  def edit
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:permissions)
    set_breadcrumbs I18n.t(:permissions) => permissions_path, I18n.t('permission_edition') => ""

    @permission = Permission.find(params[:id])
  end

  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:permissions)
    set_breadcrumbs I18n.t(:permissions) => permissions_path, I18n.t('new_permission') => ""

    @permission = Permission.new(params[:permission])

    @groups = Group.all

    @permission.alias = params[:permission][:alias].underscore.gsub(' ', '_')

    if @permission.save
      redirect_to redirect_apply(nil, new_permission_path(), session[:previous] + "#authorizations"), notice: "#{I18n.t (:notice_permission_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:permissions)
    set_breadcrumbs I18n.t(:permissions) => permissions_path, I18n.t('permission_edition') => ""

    @permission = Permission.find(params[:id])

    if @permission.update_attributes(params[:permission])
      @permission.alias = @permission.alias.underscore.gsub(' ', '_')
      @permission.save
      redirect_to session[:previous] + "#authorizations"
    else
      render action: 'edit'
    end
  end

  def destroy
    authorize! :manage_master_data, :all
    @permission = Permission.find(params[:id])
    @permission.destroy
    redirect_to permissions_path, notice: "#{I18n.t (:notice_permission_successful_deleted)}"
  end

  #Set all global rights : organization and modules permissions
  def set_rights
    authorize! :manage_organization_permissions, Permission

    if params[:organization_permissions] == I18n.t('cancel') || params[:modules_permissions] == I18n.t('cancel')
      flash[:notice] = I18n.t(:notice_permission_successful_cancelled)
    else
      @groups = @current_organization.groups
      @permissions = Permission.all

      @groups.each do |group|
        group.update_attribute('permission_ids', params[:permissions][group.id.to_s])
      end
    end

    redirect_tab = "tabs-global-permissions"
    if !params[:modules_permissions].nil?
      redirect_tab = "tabs-modules-permissions"
    elsif !params[:organization_permissions].nil?
      redirect_tab = "tabs-organization-permissions"
    end
    redirect_to organization_authorization_path(@current_organization, anchor: redirect_tab)
  end

  #Set rights on estimations permissions
  def set_rights_project_security
    authorize! :manage_estimations_permissions, Permission

    @organization = Organization.find(params[:organization_id])
    #For the cancel button
    if params[:commit] == I18n.t('cancel')
      redirect_to organization_authorization_path(@organization, :anchor => "tabs-estimations-permissions"), :notice => "#{I18n.t (:notice_permission_successful_cancelled)}"
    else
      @project_security_levels = @organization.project_security_levels
      @permissions = Permission.all

      @project_security_levels.each do |psl|
        if params[:permissions].nil?
          psl.update_attribute('permission_ids', nil)
        else
          psl.update_attribute('permission_ids', params[:permissions][psl.id.to_s])
        end
      end

      redirect_to organization_authorization_path(@organization, anchor: "tabs-estimations-permissions")
    end
  end

  def export_permissions
    authorize! :manage_master_data, Permission

    permissions = Permission.all

    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    worksheet.add_cell(0, 2, I18n.t(:alias))
    worksheet.add_cell(0, 3, I18n.t(:object_type))
    worksheet.add_cell(0, 4, I18n.t(:category))
    worksheet.add_cell(0, 5, I18n.t(:project_permissions))
    worksheet.add_cell(0, 6, I18n.t(:global_permissions))
    worksheet.add_cell(0, 7, I18n.t(:associated_object))

    permissions.each_with_index do |permission, index|
      ["name", "description", "alias", "object_type", "category", "is_master_permission", "is_permission_project", "object_associated"].each_with_index do |attribut, i|
        worksheet.add_cell(index + 1, i, permission.send("#{attribut}"))
      end
    end

    send_data(workbook.stream.string, filename: "Permissions-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def import_permissions
    tab_error = []
    del_array = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0].extract_data

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].nil?
          permission = Permission.where(description: row[1],
                                        alias: row[2],
                                        object_type: row[3],
                                        category: row[4],
                                        object_associated: row[7]).first

          if permission.nil?
            permission = Permission.create(name: row[0],
                                          description: row[1],
                                          alias: row[2],
                                          object_type: row[3],
                                          category: row[4],
                                          object_associated: row[7])
          else
            del_array << permission
          end
        end
      end

    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end

    doublons = Permission.all.group_by{|perm| [perm.name, perm.alias]}
    doublons.values.each do |duplicates|
      first_one = duplicates.shift
      duplicates.each{|doub| doub.destroy }
    end

    redirect_to :back
  end
end
