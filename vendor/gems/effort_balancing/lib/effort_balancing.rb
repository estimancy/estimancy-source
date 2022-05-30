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
require 'effort_balancing/version'

module EffortBalancing
  class EffortBalancing
    include PemoduleEstimationMethods
    attr_accessor :effort, :note, :wbs_project_element_root

    def initialize(elem)
      @effort = elem[:effort]
      @note = elem[:note]
      set_wbs_project_element_root(elem)
    end

    #Get the project WBS root
    def set_wbs_project_element_root(elem)
      @pbs_project_element = PbsProjectElement.find(elem[:pbs_project_element_id])
      current_project = @pbs_project_element.pe_wbs_project.project
      pe_wbs_project_activity = current_project.pe_wbs_projects.activities_wbs.first
      @wbs_project_element_root = pe_wbs_project_activity.wbs_project_elements.where('is_root = ?', true).first
    end

    def get_effort(*args)
      new_effort = Hash.new
      root_element_effort = 0.0
      @wbs_project_element_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |wbs_project_element|
          if wbs_project_element.is_childless?
            new_effort[wbs_project_element.id] = (@effort[wbs_project_element.id.to_s].blank? ? nil : @effort[wbs_project_element.id.to_s].to_f)
          else
            node_effort = 0.0
            wbs_project_element.children.each do |child|
              node_effort = node_effort + new_effort[child.id].to_f
            end
            new_effort[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, new_effort)
          end
        end
      end
      new_effort[@wbs_project_element_root.id] = compact_array_and_compute_node_value(@wbs_project_element_root, new_effort)
      new_effort
    end

    def get_note(*args)
      new_note = Hash.new
      sorted_node_elements = @wbs_project_element_root.subtree.order('ancestry_depth desc')
      sorted_node_elements.each do |wbs_project_element|
        new_note[wbs_project_element.id] = @note[wbs_project_element.id.to_s]
      end
      new_note
    end
  end
end
