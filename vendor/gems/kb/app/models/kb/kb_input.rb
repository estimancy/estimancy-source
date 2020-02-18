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

module Kb
  class KbInput < ActiveRecord::Base
    belongs_to :kb_model

    serialize :filters, Hash
    serialize :values, Array
    serialize :regression, Array

    #def self.display_size(p, c, level, component_id)
    #  if c.send("string_data_#{level}")[component_id].nil?
    #    begin
    #      p.send("string_data_#{level}")[component_id]
    #    rescue
    #      nil
    #    end
    #  else
    #    c.send("string_data_#{level}")[component_id]
    #  end
    #end

  end
end
