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
# require "rubygems"
# require "uuidtools"
#
# module MasterDataHelper
#
#   def self.included(base)
#
#     base.class_eval do
#
#       #self relation on master data : Parent<->Child
#       has_one    :child_reference,  :class_name => "#{base}", :inverse_of => :parent_reference, :foreign_key => "reference_id"
#       belongs_to :parent_reference, :class_name => "#{base}", :inverse_of => :child_reference,  :foreign_key => "reference_id"
#
#       #UUID generation on create
#       #TODO: validate uuid format and length in model
#       before_validation(:on => :create) do
#         self.uuid = UUIDTools::UUID.random_create.to_s   #generate uuid like: 4f844456-42bb-11e2-bebb-d4bed96c8c48"
#       end
#
#       #scope for find methods
#       scope :by_uuid, lambda {|uuid| where("uuid = ?", uuid) }
#       scope :by_record_status_id, lambda {|record_status_id| where("record_status_id <> ?", record_status_id) }
#       scope :custom_value, lambda {|custom_value| where("custom_value <> ?", custom_value) }
#
#       scope :corresponding_local_record, lambda { |guid, loc| where("uuid = ? AND record_status_id <> ? AND (custom_value IS NULL OR custom_value <> ?)", guid, loc, "Locally edited") }
#
#       scope :defined, -> { where(record_status_id: RecordStatus.find_by_name("Defined")) }
#       scope :local, -> { where(record_status_id: RecordStatus.find_by_name("Local")) }
#       scope :defined_or_local, -> { defined + local }
#
#       ##Enable the amoeba gem for deep copy/clone (dup with associations)
#       amoeba do
#         enable
#         customize(lambda { |original_record, new_record|
#           new_record.reference_uuid = original_record.uuid
#           new_record.reference_id = original_record.id
#           new_record.record_status = RecordStatus.find_by_name("Proposed") #RecordStatus.first
#         })
#       end
#
#       #Local method for local instance record
#       define_method(:is_local_record?) do
#         begin
#           (self.record_status.name == "Local") ? true : false
#         rescue
#           false
#         end
#       end
#
#       #Define method for record status
#       define_method(:is_proposed?) do
#         begin
#           (self.record_status.name == "Proposed") ? true : false
#         rescue
#           false
#         end
#       end
#
#       #Define method for record Defined status
#       define_method(:is_defined?) do
#         begin
#           (self.record_status.name == "Defined") ? true : false
#         rescue
#           false
#         end
#       end
#
#       #Retired method for record Retired status
#       define_method(:is_retired?) do
#         begin
#           (self.record_status.name == "Retired") ? true : false
#         rescue
#           false
#         end
#       end
#
#       # If record status id defined or nil
#       define_method(:is_defined_or_nil?) do
#         begin
#           ((self.record_status.name == "Defined") || (self.record_status.nil?)) ? true : false
#         rescue
#           false
#         end
#       end
#
#       # If record status id local or nil
#       define_method(:is_local_or_nil?) do
#         begin
#           ((self.record_status.name == "Local") || (self.record_status.nil?)) ? true : false
#         rescue
#           false
#         end
#       end
#
#       # If record status id defined or custom
#       define_method(:is_proposed_or_custom?) do
#         begin
#           ( (self.record_status.name == "Proposed") || (self.record_status.name == "Custom") ) ? true : false
#         rescue
#           false
#         end
#       end
#
#       #Custom record status
#       define_method(:is_custom?) do
#         begin
#           (self.record_status.name == "Custom") ? true : false
#         rescue
#           false
#         end
#       end
#
#       #Draft record status
#       define_method(:is_draft?) do
#         begin
#           (self.record_status.name == "Draft") ? true : false
#         rescue
#           false
#         end
#       end
#
#       #InReview record status
#       define_method(:is_inReview?) do
#         begin
#           (self.record_status.name == "InReview") ? true : false
#         rescue
#           false
#         end
#       end
#
#       ##To know if record is fine/OK for validation
#       #define_method(:is_ok_for_validation?) do
#       #  begin
#       #    (self.record_status.name != "Defined" && self.record_status.name != "Retired" && self.record_status.name != "Local") ? true : false
#       #  rescue
#       #    false
#       #  end
#       #end
#
#
#       #isLocal record status
#       define_method(:is_local?) do
#         begin
#           (self.record_status.name == "local") ? true : false
#         rescue
#           false
#         end
#       end
#
#
#       #Allow to show or not the record custom value (only if record_status = Custom) on List
#       def show_custom_value
#         #if self.is_custom? || self.is_local_record?
#         unless self.is_local_record?
#           self.custom_value.blank? ? "" : " (#{self.custom_value}) "
#         end
#       end
#
#     end
#
#     #Show record status collection list according to current_user permission
#     def record_status_collection
#       @record_statuses = RecordStatus
#       begin
#         if self.new_record?
#           if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
#             @record_statuses = RecordStatus.where("name = ?", "Proposed")
#           else
#             @record_statuses = RecordStatus.where("name = ?", "Local")
#           end
#         else
#           @record_statuses = RecordStatus.where("name <> ?", "Defined")
#         end
#         #Return only the "Defined" records
#         @record_statuses = @record_statuses.defined
#       rescue
#         []
#       end
#     end
#
#   end #END self.included
#
# end