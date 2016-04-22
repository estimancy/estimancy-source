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
##############################################################################

require 'effort_breakdown/version'

module EffortBreakdown

  #Effort Breakdown class
  class EffortBreakdown
    include PemoduleEstimationMethods

    attr_accessor :pbs_project_element, :module_project, :input_effort, :project, :ratio #module input/output parameters

    #def initialize(c, mp, e, r)
    def initialize(*args)
      #puts "INPUT_DATA = #{module_input_data}"   for ex. : INPUT_DATA = {:effort=>"10", :pbs_project_element_id=>271, :module_project_id=>265}
      @pbs_project_element = args[0]
      @module_project = args[1]
      @project = @module_project.project
      @ratio = args[3]
      args[2].nil? ? @input_effort = nil : @input_effort = args[2]
    end

    # Getters for module outputs

    # Calculate each Wbs activity effort according to Ratio and Reference_Value and PBS effort
    def get_effort(*args)
      # First build cache_depth
      WbsActivityElement.rebuild_depth_cache!

      efforts_man_month = nil
      efforts_man_month = get_effort_with_activities_elements
      efforts_man_month
    end

    # Calculate the Cost for each WBS-Project-Element/Phase
    # Cout Moyen
    def get_cost(*args)
      cost = Hash.new {|h,k| h[k]=[]}
      res = Hash.new

      wbs_activity = @module_project.wbs_activity

      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      efforts_man_month = get_effort
      efforts_man_month.each do |key, value|
        tmp = Hash.new
        wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: key).first
        unless wbs_activity_ratio_element.nil?
          wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
            tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * efforts_man_month[key].to_f * warp.ratio_value / 100
          end
        end

        tmp.each do |k, v|
          cost[key] << tmp[k]
        end

        cost.each do |k, v|
          if WbsActivityElement.find(key).root?
            res[key] = cost.values.sum.sum
          else
            res[key] = cost[k].sum
          end
        end
      end

      res
    end

    # Calculate the WBS-Activity effort according to the selected value as ratio
    # Ratio references will be based on the selected reference,
    # If there is no selected reference, all Ratio elements will be consider as being a reference
    def get_effort_with_activities_elements
      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      wbs_activity = @module_project.wbs_activity

      # Get the wbs_activity_element which contain the wbs_activity_ratio
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      #Get the referenced wbs_activity_elt of the @ratio
      referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', @ratio.id, true)
      # If there is no referenced elements, all elements will be consider as references
      if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
        referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', @ratio.id)
      end

      output_effort = Hash.new

      # If using base-100 percentages
      if @ratio.use_real_base_percentage == true

        #The real ratio elements percentages will be use
        referenced_values_efforts = 0.0
        referenced_ratio_activity_element_ids = []
        referenced_ratio_elements.each do |reference_value|
          wbs_activity_element_id = reference_value.wbs_activity_element_id
          referenced_ratio_activity_element_ids << wbs_activity_element_id

          current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * reference_value.ratio_value.to_f / 100)
          output_effort[wbs_activity_element_id] = current_output_effort.to_f
          referenced_values_efforts = referenced_values_efforts + current_output_effort.to_f
        end

        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil? || element.id.in?(referenced_ratio_activity_element_ids)
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = (referenced_values_efforts.to_f  * corresponding_ratio_value.to_f / 100)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      else
        # Utilise les valeurs des pourcentage en base 100
        referenced_values_efforts = 0.0
        referenced_ratio_elements.each do |reference_value|
          referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
        end

        #output_effort = Hash.new
        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil?
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * corresponding_ratio_value.to_f / referenced_values_efforts)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)

      # Global output efforts
      output_effort
    end

    # redefinition of the methods
    # method that compute not leaf node estimation value by aggregation
    def compact_array_and_compute_node_value(node, effort_array)
      tab = []
      node.children.map do |child|
        unless child.nil? || child.wbs_activity.nil?
          value = effort_array[child.id]
          if value.is_a?(Integer) || value.is_a?(Float)
            tab << value
          end
        end
      end

      estimation_value = nil
      unless tab.empty?
        estimation_value = tab.compact.sum
      end

      estimation_value
    end

  end
end
