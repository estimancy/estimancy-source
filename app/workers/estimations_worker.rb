# ##########################################################################
# #
# # ProjEstimate, Open Source project estimation web application
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
# ########################################################################
#
# # After each update of estimation value, this worker will be call to recompute estimation value for its parent component
# class EstimationsWorker
#   # include Sidekiq::Worker
#   ###sidekiq_options :queue => :often, :retry => true, :backtrace => true
#
#   def perform(pbs_project_elt_id, estimation_value_id)
#     #No authorize required since this method is private and won't be call from any route
#
#     pbs_project_elt = PbsProjectElement.find(pbs_project_elt_id)
#     estimation_value = EstimationValue.find(estimation_value_id)
#     updated_estimation_value = Hash.new
#     pe_attribute = estimation_value.pe_attribute
#     module_project = estimation_value.module_project
#     pemodule = module_project.pemodule
#     wbs_project_elt_root = nil
#
#     # Get the project wbs_project_element root if module with activities
#     if pemodule.yes_for_output_with_ratio? || pemodule.yes_for_output_without_ratio? || pemodule.yes_for_input_output_with_ratio? || pemodule.yes_for_input_output_without_ratio?
#       wbs_project_elt_root = module_project.project.wbs_project_elements.elements_root.first
#     end
#
#     # Rebuild the tree to have an updated deph for each component
#     WbsProjectElement.rebuild_depth_cache!
#     unless pbs_project_elt.is_root?
#       pbs_ancestors = pbs_project_elt.ancestors.reverse
#       unless pbs_ancestors.empty?
#         pbs_ancestors.each do |component|
#           ['low', 'most_likely', 'high', 'probable'].each do |level|
#             level_estimation_values = Hash.new
#             level_estimation_values = estimation_value.send("string_data_#{level}")
#
#             component_estimation_value = compute_component_estimation_value(component, pe_attribute.id, level_estimation_values, wbs_project_elt_root)
#
#             if wbs_project_elt_root.nil?
#               # get estimation value without activities
#               level_estimation_values[component.id] = component_estimation_value
#             else
#               # get estimation value from WBS-Project_element (with activities)
#               level_estimation_values[component.id][wbs_project_elt_id] = { :value => component_estimation_value }
#             end
#
#             updated_estimation_value["string_data_#{level}"] = level_estimation_values
#           end
#         end
#       end
#
#       # Update the estimation value for all levels
#       estimation_value.update_attributes(updated_estimation_value)
#     end
#
#   rescue ActiveRecord::RecordNotFound
#   end
#
#
#   def compute_component_estimation_value(component, pe_attribute_id, level_estimation_value, wbs_project_elt_root=nil)
#     #No authorize required since this method is private and won't be call from any route
#     component_children_results_array = Array.new
#     new_effort_person_hour = Hash.new
#     pe_attribute = PeAttribute.find(pe_attribute_id)
#     node_children_results_array = Array.new
#
#     #component.children.each do |node|
#     if component.folder?
#       component.descendants.each do |child|
#         if wbs_project_elt_root.nil?
#           node_children_results_array << level_estimation_value[child.id]
#         else
#           # get value with activities
#           wbs_est_val = level_estimation_value[child.id][wbs_project_elt_root.id]
#           node_children_results_array << wbs_est_val.nil? ? nil : wbs_est_val[:value]
#         end
#       end
#     else
#       if wbs_project_elt_root.nil?
#         node_children_results_array << level_estimation_value[component.id]
#       else
#         wbs_est_val = level_estimation_value[component.id][wbs_project_elt_root.id]
#         node_children_results_array << wbs_est_val.nil? ? nil : wbs_est_val[:value]
#       end
#     end
#
#     # get the result value according to the pe_attribute type
#     component_estimation_value = nil
#     attribute_type = pe_attribute.attr_type
#     case attribute_type
#       when 'integer', 'float'
#         ###component_estimation_value = node_children_results_array.compact.sum
#         node_children_results_array = node_children_results_array.compact.collect!{ |i| i.to_f }
#         component_estimation_value = node_children_results_array.inject{ |sum, el| sum + el }
#       when 'date'
#         component_estimation_value = node_children_results_array.compact.max
#       else
#         # see if the pe_attribute type is list or text
#         component_estimation_value = node_children_results_array.last
#     end
#
#     component_estimation_value
#   end
#
#   # Get the component estimation_value according to the in_out type (input or output)
#   def compute_estimation_values_with_activities(in_out, module_project_id, wbs_project_elt_root_id, component_id)
#     module_project = ModuleProject.find(module_project_id)
#
#     # The in_out attribute tells if it is an input or output
#     case in_out
#       when 'input'
#         if module_project.pemodule.yes_for_input? || module_project.pemodule.yes_for_input_output_with_ratio? || module_project.pemodule.yes_for_input_output_without_ratio?
#         else
#
#         end
#           when 'output'
#         if module_project.pemodule.yes_for_output_with_ratio? || module_project.pemodule.yes_for_output_without_ratio? || module_project.pemodule.yes_for_input_output_with_ratio? || module_project.pemodule.yes_for_input_output_without_ratio?
#         else
#
#         end
#
#       else
#         # Nothing (data are even input or output)
#     end
#   end
#
# end