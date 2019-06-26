# # -*- coding: utf-8 -*-
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
# require 'time_diff'
#
# namespace :projestimate do
#   desc "Task that purges the Audit data from server side"
#
#   task :purge_audit_history_data => :environment do
#     begin
#       @defined_record_status = RecordStatus.find_by_name('Defined')
#       # get the admin parameter
#       audit_history_setting = AdminSetting.find_by_key_and_record_status_id('audit_history_lifetime', @defined_record_status.id)
#       if audit_history_setting && audit_history_setting != 0
#         audit_history_setting_value = audit_history_setting.value.to_s.split(' ')
#         # Get the audit_history_lifetime unit : day(s), week(s) or month(s)
#         lifetime_value = audit_history_setting_value.first.to_i
#         lifetime_unit = audit_history_setting_value.last.to_s.singularize
#         histories_to_delete = Array.new
#         # get all audit history data that feet the conditions: to be deleted
#         audit_histories_to_delete = Audit.all.reject { |history| Time.diff(Time.parse("#{history.created_at}"), Time.now)[:"#{lifetime_unit}"] < lifetime_value }
#         ids_to_delete = audit_histories_to_delete.collect(&:id)
#         # then delete all the histories data that have more than "audit_history_lifetime" value
#         Audit.where(:id => ids_to_delete).destroy_all
#       end
#     rescue Exception => e
#       puts "Error : #{e.message}"
#       puts e.message
#     end
#   end
# end
#
# CLEAN DATABASE
# ProjectField.where(value: nil).delete_all
# Guw::GuwAttributeComplexity.where(value: nil, value_b: nil).delete_all
# Guw::GuwOutputComplexity.where(value: nil).delete_all
# Guw::GuwUnitOfWorkAttribute.where(low: nil, most_likely: nil, high: nil).delete_all
# Guw::GuwComplexity.all.each do |cplx|
#   unless cplx.guw_type.nil?
#     cplx.guw_model_id = cplx.guw_type.guw_model_id
#     cplx.save
#   end
# end