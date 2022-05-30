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

require 'skb/version'
require 'skb/engine'
module Skb
  class Skb
    def initialize(*args)
      @project = args[0]
      @mp = args[1]
    end

    def set_effort(*args)
      #attr = PeAttribute.where(alias: "effort").first
      #
      #ev = EstimationValue.where(module_project_id: @mp.id,
      #                           pe_attribute_id: attr.id).first
      #
      #unless ev.nil?
      #  ev.update_attribute(:"string_data_low", { @mp.id => 69 } )
      #  ev.update_attribute(:"string_data_most_likely", { @mp.id => 690 } )
      #  ev.update_attribute(:"string_data_high", { @mp.id => 6900 } )
      #  ev.update_attribute(:"string_data_probable", { @mp.id => 100 } )
      #end
    end

    def set_retained_size(*args)
      #attr = PeAttribute.where(alias: "retained_size").first
      #
      #ev = EstimationValue.where(module_project_id: @mp.id,
      #                           pe_attribute_id: attr.id).first
      #
      #unless ev.nil?
      #  ev.update_attribute(:"string_data_low", { @mp.id => 69 } )
      #  ev.update_attribute(:"string_data_most_likely", { @mp.id => 690 } )
      #  ev.update_attribute(:"string_data_high", { @mp.id => 6900 } )
      #  ev.update_attribute(:"string_data_probable", { @mp.id => 100 } )
      #end
    end

    def get_effort(*args)
      #24
    end

    def get_retained_size(*args)
      #12
    end

  end
end
