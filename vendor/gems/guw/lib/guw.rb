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

require 'guw/version'
require 'guw/engine'
module Guw
  class Guw
    attr_accessor :retained_size, :project, :delay, :defects, :cost

    #def initialize(theorical_size, retained_size, cplx, project)
    def initialize(*args)
      #@theorical_size = theorical_size
      #@retained_size = retained_size
      #@cplx = cplx
      @project = args[0]
      @mp = args[1]
    end

    def get_defects(*args)
      # size = args[0]
      # @defects = size*0.08*100
    end

    def get_delay(*args)
      # size = args[0]
      # @delay = (2.5 * (size**0.32 )).to_f * @project.organization.number_hours_per_month.to_f
    end

    def get_cost(*args)
      # size = args[0]
      # @cost = size * @project.organization.number_hours_per_month.to_f * @project.organization.cost_per_hour.to_f
    end

    def get_retained_size(*args)
      #attr = PeAttribute.where(alias: "retained_size").first
      #EstimationValue.where(module_project_id: @mp.id,
      #                      pe_attribute_id: attr.id).first.string_data_probable[current_component.id]
    end

    def get_effort(*args)
      #attr = PeAttribute.where(alias: "effort").first
      #EstimationValue.where(module_project_id: @mp.id,
      #                     pe_attribute_id: attr.id).first.string_data_probable[current_component.id]
    end
  end
end
