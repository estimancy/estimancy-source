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

require 'initialization/version'
require 'date'

module Initialization

  class Initialization
    attr_accessor :project_id, :pbs_project_element_id, :pe_attribute_alias, :module_input_data, :output_result

    def initialize(module_input_data)
      @module_input_data = module_input_data
      puts "module_input_data = #{@module_input_data}"
      @pe_attribute_alias = module_input_data[:pe_attribute_alias]
      module_input_data[@pe_attribute_alias].blank? ? @output_result = nil : @output_result = module_input_data[@pe_attribute_alias]

      unless @output_result.nil?
        if @output_result.valid_integer?
          @output_result = @output_result.to_i
        elsif @output_result.valid_float?
          @output_result = @output_result.to_f
        else
          @output_result = @output_result.to_s
        end
      end

      (class << self; self; end).class_eval do
        define_method("get_#{module_input_data[:pe_attribute_alias]}".to_sym) do |*args|
          @output_result
        end
      end
    end

  end
end
