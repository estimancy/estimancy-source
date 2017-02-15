# #encoding: utf-8
# #############################################################################
# #
# # Estimancy, Open Source project estimation web application
# # Copyright (c) 2014 Estimancy (http://www.estimancy.com)
# #
# #    This program is free software: you can redistribute it and/or modify
# #    it under the terms of the GNU Affero General Public License as
# #    published by the Free Software Foundation, either version 3 of the
# #    License, or (at your option) any later version.
# #
# #    This program is distributed in the hope that it will be useful,
# #    but WITHOUT ANY WARRANTY; without even the implied warranty of
# #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# #    GNU Affero General Public License for more details.
# #
# #    You should have received a copy of the GNU Affero General Public License
# #    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# #
# #############################################################################
#
# class RecordStatusesController < ApplicationController
#    #Module for master data changes validation
#   load_resource
#
#
#
#   def index
#     authorize! :manage_master_data, :all
#
#     set_page_title I18n.t(:record_status)
#     set_breadcrumbs I18n.t(:record_status) => record_statuses_path, I18n.t('record_status') => ""
#
#     @record_statuses = RecordStatus.all
#
#     respond_to do |format|
#       format.html # index.html.erb
#       format.json { render json: @record_statuses }
#     end
#   end
#
#   def show
#     authorize! :manage_master_data, :all
#
#     @record_status = RecordStatus.find(params[:id])
#
#     respond_to do |format|
#       format.html # show.html.erb
#       format.json { render json: @record_status }
#     end
#   end
#
#   def new
#     authorize! :manage_master_data, :all
#
#     set_page_title I18n.t(:new_record_status)
#
#     @record_status = RecordStatus.new
#
#     respond_to do |format|
#       format.html
#       format.json { render json: @record_status }
#     end
#   end
#
#   def edit
#     authorize! :manage_master_data, :all
#
#     @record_status = RecordStatus.find(params[:id])
#     set_page_title I18n.t(:edit_record_status, value: @record_status.name)
#     unless @record_status.child_reference.nil?
#       if @record_status.child_reference.is_proposed_or_custom?
#         flash[:warning] = I18n.t(:warning_record_status_cant_be_edit)
#         redirect_to record_statuses_path
#       end
#     end
#   end
#
#   def create
#     authorize! :manage_master_data, :all
#
#     @record_status = RecordStatus.new(params[:record_status])
#
#     if @record_status.save
#       redirect_to redirect_apply(nil,new_record_status_path(),  record_statuses_path), notice: "#{I18n.t (:notice_record_status_successful_created)}"
#     else
#       render action: 'new'
#     end
#   end
#
#   def update
#     authorize! :manage_master_data, :all
#
#     @record_status = nil
#     current_record_status = RecordStatus.find(params[:id])
#     if current_record_status.is_defined?
#       @record_status = current_record_status.amoeba_dup
#       @record_status.owner_id = current_user.id
#     else
#       @record_status = current_record_status
#     end
#
#     if @record_status.update_attributes(params[:record_status])
#       redirect_to redirect_apply(edit_record_status_path(@record_status), nil, record_statuses_path ), notice: "#{I18n.t (:notice_record_status_successful_updated)}"
#     else
#       flash[:error] = "#{I18n.t (:error_record_status_failed_update)}"
#       render action: 'edit'
#     end
#
#   end
#
#   def destroy
#     authorize! :manage_master_data, :all
#
#     @record_status = RecordStatus.find(params[:id])
#     if @record_status.is_defined? || @record_status.is_custom?
#       #logical deletion: delete don't have to suppress records anymore
#       @record_status.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
#     else
#       if @record_status.name=='Defined'
#         record_status_defined=true
#       end
#
#       @record_status.destroy
#       if record_status_defined
#         @record_status = RecordStatus.find_by_name('Defined')
#         @record_status.update_attributes(:record_status_id => @record_status.id, :owner_id => current_user.id)
#       end
#     end
#
#     respond_to do |format|
#       format.html { redirect_to record_statuses_url }
#       format.json { head :no_content }
#     end
#   end
# end
