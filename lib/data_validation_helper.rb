# # encoding: UTF-8
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
# #Module for master data method
# module DataValidationHelper
#
#   #Validate changes on record
#   def validate_change
#     authorize! :manage_master_data, :all
#
#     #get the record controller name
#     controller = params[:controller]    #controller.controller_name
#     record_class_name = controller.classify  #controller.singularize.capitalize
#
#     begin
#       #Get the record to validate from its ID
#       @record = record_class_name.constantize.find(params[:id])
#       trans_successful = false
#       #Temporally save uuid
#       temp_current_uuid = @record.uuid
#       parent_record = @record.parent_reference
#
#       ##get all has many relations et for each...
#       @record.transaction do
#         @record.class.reflect_on_all_associations(:has_many).map{|i| i.name }.each do |associated_class_name|
#           unless associated_class_name == EstimationValue
#             unless @record.parent_reference.nil?
#               @record.parent_reference.send(associated_class_name).each do |obj|
#                 obj.send("#{@record.class.to_s.underscore}_id=", @record.id)
#                 obj.save
#               end
#             end
#           end
#         end
#       end
#
#       #If record parent is nil (for new created record)...only status is going to change
#       if parent_record.nil?
#         @record.record_status = @defined_status
#         if @record.save
#           flash[:notice] = I18n.t(:notice_master_data_successful_validated)
#         else
#           flash[:error] = I18n.t(:error_master_data_failed_validate, :value => @record.errors.full_messages.to_sentence)
#         end
#       else
#         temp_parent_uuid = parent_record.uuid
#         #Create transaction to avoid uuid duplication error in DB
#         parent_record.transaction do
#           @record.uuid = UUIDTools::UUID.random_create.to_s
#           parent_record.record_status = @retired_status
#           parent_record.uuid = temp_current_uuid
#           parent_record.reference_uuid = @record.reference_uuid
#           @record.save!
#           parent_record.save!
#           trans_successful = true
#         end
#
#         if trans_successful
#           @record.reference_uuid = nil
#           @record.uuid = temp_parent_uuid
#           @record.record_status = @defined_status
#
#           if @record.save
#             flash[:notice] = I18n.t(:notice_master_data_successful_validated)
#           else
#            flash[:error] = I18n.t(:error_master_data_failed_validate, :value => @record.errors.full_messages.to_sentence)
#           end
#         end
#       end
#
#       #redirect_to :back and return
#       redirect_to :back and return
#
#     rescue ActiveRecord::StatementInvalid => error
#       put "#{error.message}"
#       flash[:error] = "#{error.message}"
#       redirect_to :back and return
#     rescue ActiveRecord::RecordInvalid => err
#       flash[:error] = "#{err.message}"
#       redirect_to :back
#     end
#   end
#
#
#   #Restoring change on record
#   def restore_change
#     authorize! :manage_master_data, :all
#
#     #get the record controller name
#     controller = params[:controller]    #controller.controller_name
#     record_class_name = controller.classify  #controller.singularize.capitalize
#     begin
#       #Get the record to validate from its ID
#       @record = record_class_name.constantize.find(params[:id])
#       trans_successful = false
#       @record.transaction do
#         @record.class.reflect_on_all_associations(:has_many).map{|i| i.name }.each do |associated_class_name|
#           unless associated_class_name == EstimationValue
#             if @record.parent_reference.nil?
#                record= @record.child_reference
#             else @record.child_reference
#               record= @record.parent_reference
#             end
#             unless record.nil?
#               record.send(associated_class_name).each do |obj|
#                 obj.send("#{@record.class.to_s.underscore}_id=", @record.id)
#                 obj.save
#             end
#             end
#           end
#         end
#       end
#       if @record.is_retired?
#         #Temporally save uuid
#         temp_current_uuid = @record.uuid
#         child_record =  record_class_name.constantize.find_by_uuid(@record.reference_uuid) #@record.child
#
#         if child_record.nil?
#           @record.record_status = @defined_status
#           if @record.save
#             flash[:notice] = I18n.t(:notice_master_data_successful_validated)
#           else
#             flash[:error] =  I18n.t(:error_master_data_failed_restore)
#           end
#
#         else
#           temp_child_uuid = child_record.uuid
#
#           #Create transaction to avoid uuid duplication error in DB
#           child_record.transaction do
#             @record.uuid = UUIDTools::UUID.random_create.to_s
#             child_record.record_status = @retired_status
#             child_record.uuid = temp_current_uuid
#             child_record.reference_uuid = @record.reference_uuid
#             @record.save!(:validate => false)
#             child_record.save!(:validate => false)
#             trans_successful = true
#           end
#
#           if trans_successful
#             @record.reference_uuid = nil
#             @record.uuid = temp_child_uuid
#             @record.record_status = @defined_status
#
#             if @record.save
#               flash[:notice] = I18n.t(:notice_master_data_successful_restored)
#             else
#               flash[:error] = I18n.t(:error_master_data_failed_restore)
#             end
#           end
#         end
#       else
#         flash[:error] = I18n.t(:warning_master_data_unauthorized_action)
#       end
#
#       redirect_to :back and return
#
#     rescue ActiveRecord::StatementInvalid => error
#       put "#{error.message}"
#       flash[:error] = "#{error.message}"
#       redirect_to :back and return
#     rescue ActiveRecord::RecordInvalid => err
#       flash[:error] = "#{err.message}"
#       redirect_to :back
#     end
#   end
#
# end