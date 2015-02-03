#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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

#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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
########################################################################

require 'effort_breakdown/version'

module EffortBreakdown

  #Effort Breakdown class
  class EffortBreakdown
    include PemoduleEstimationMethods

    attr_accessor :pbs_project_element, :module_project, :input_effort, :project #module input/output parameters

    def initialize(c, mp, e)
      #puts "INPUT_DATA = #{module_input_data}"   for ex. : INPUT_DATA = {:effort=>"10", :pbs_project_element_id=>271, :module_project_id=>265}
      @pbs_project_element = c
      @module_project = mp
      @project = @module_project.project
      e.nil? ? @input_effort = nil : @input_effort = e
    end

    # Getters for module outputs

    # Calculate each Wbs activity effort according to Ratio and Reference_Value and PBS effort
    def get_effort
      # First build cache_depth
      WbsActivityElement.rebuild_depth_cache!

      efforts_man_month = nil
      efforts_man_month = get_effort_with_activities_elements
      efforts_man_month
    end

    # Calculate the Cost for each WBS-Project-Element/Phase
    # Cout Moyen
    def get_cost(*arg)
      cost = Hash.new
      # Project pe_wbs_activity
      wbs_activity = @module_project.wbs_activity
      # Get the wbs_activity_element which contain the wbs_activity_ratio
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root
      # Get the efforts hash for all Wbs_project_element effort
      efforts_man_month = get_effort

      efforts_man_month.each do |key, value|
        cost[key]  = value.to_f * @project.organization.cost_per_hour.to_f
      end

      cost
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

      # Use project default Ratio, unless PSB got its own Ratio,
      # If default ratio was defined in PBS, it will override the one defined in module-project
      ratio_reference = wbs_activity.wbs_activity_ratios.first

      #Get the referenced wbs_activity_elt of the ratio_reference
      referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', ratio_reference.id, true)
      # If there is no referenced elements, all elements will be consider as references
      if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
        referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', ratio_reference.id)
      end

      referenced_values_efforts = 0
      referenced_ratio_elements.each do |reference_value|
        referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
      end

      output_effort = Hash.new
      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |element|
          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless element.nil?
            # Element effort is really computed only on leaf element
            if element.is_childless? || element.has_new_complement_child?
              # Get the ratio Value of current element
              corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, element.id).first
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
