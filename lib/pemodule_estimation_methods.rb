# encoding: UTF-8
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

# Module that contains all generic methods for Estimancy modules estimations calculation
module PemoduleEstimationMethods

  # method that compute not leaf node estimation value by aggregation
  def compact_array_and_compute_node_value(node, effort_array)
    tab = []
    node.children.map do |child|
      value = effort_array[child.id]
      if value.is_a?(Integer) || value.is_a?(Float)
        tab << value
      end
    end

    estimation_value = nil
    unless tab.empty?
      estimation_value = tab.compact.sum
    end

    estimation_value
  end
end