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

module Ge
  class GeModel < ActiveRecord::Base
    #validates_presence_of :name####, :organization_id
    validates :name, :presence => true
    validates :input_effort_standard_unit_coefficient, :output_effort_standard_unit_coefficient, :presence => true
    validates :input_effort_unit, :output_effort_unit, :presence => true
    validates :input_effort_standard_unit_coefficient, :output_effort_standard_unit_coefficient, :presence => true
    validates :coeff_a, :coeff_b, :numericality => {:allow_nil => true}

    belongs_to :organization
    belongs_to :input_pe_attribute, class_name: PeAttribute, foreign_key: :input_pe_attribute_id
    belongs_to :output_pe_attribute, class_name: PeAttribute, foreign_key: :output_pe_attribute_id

    has_many :module_projects, :dependent => :destroy

    has_many :ge_factors, :dependent => :destroy
    has_many :ge_factor_values, :through => :ge_factors, :dependent => :destroy
    has_many :ge_inputs, :dependent => :destroy

    amoeba do
      enable
      exclude_association [:module_projects]

      customize(lambda { |original_ge_model, new_ge_model|
        new_ge_model.copy_id = original_ge_model.id
      })
    end


    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end

    # display input size or effort according to pe_attribute
    # For input attribute: so we are going to use the : input_effort_standard_unit_coefficient
    def self.display_size(p, c, level, component_id, ge_model)
      begin
        if c.send("string_data_#{level}")[component_id].nil?
          begin
            #p.send("string_data_#{level}")[component_id]
            case p.pe_attribute.alias
              when "effort"
                p.send("string_data_#{level}")[component_id].to_f / ge_model.input_effort_standard_unit_coefficient.to_f
              when "retained_size"
                p.send("string_data_#{level}")[component_id]
            end
          rescue
            nil
          end
        else
          #c.send("string_data_#{level}")[component_id]
          case c.pe_attribute.alias
            when "effort"
              c.send("string_data_#{level}")[component_id].to_f / ge_model.input_effort_standard_unit_coefficient.to_f
            when "retained_size"
              c.send("string_data_#{level}")[component_id]
          end
        end
      rescue
        nil
      end

    end
  end
end
