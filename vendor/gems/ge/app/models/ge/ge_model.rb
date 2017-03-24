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

    INPUT_EFFORTS_ALIAS = ["ent1", "ent2", "ent3", "ent4"]
    OUTPUT_ATTRIBUTES_ALIAS = ["sort1", "sort2", "sort3", "sort4"]
    TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS = ["sort1", "sort2", "sort3", "sort4"]

    GE_ATTRIBUTES_ALIAS = ["ent1", "ent2", "ent3", "ent4", "sort1", "sort2", "sort3", "sort4"]

    DEFECTS_INPUT_EFFORTS_ALIAS = ["ent1"]
    DEFECTS_OUTPUT_ATTRIBUTES_ALIAS = ["sort1", "sort2"]
    DEFECTS_TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS = ["sort1", "sort2"]

    INPUT_ATTRIBUTES_ALIAS_FOR_SELECT = ["retained_size", "effort"]
    OUTPUT_ATTRIBUTES_ALIAS_FOR_SELECT = ["retained_size", "effort", "introduced_defects"]

    CORRESPONDING_INPUTS_WITH_OUTPUTS = {"sort1" => "ent1", "sort2" => "ent2", "sort3" => "ent3", "sort4" => "ent4"}

    #validates_presence_of :name####, :organization_id
    validates :name, :presence => true, uniqueness: { :scope => :organization_id, :case_sensitive => false }
    validates :ge_model_instance_mode, :presence => true
    validates :coeff_a, :coeff_b, :numericality => {:allow_nil => true}

    # Unite des entrée /sorties
    validates :ent1_unit, :ent2_unit, :ent3_unit, :ent4_unit, :sort1_unit, :sort2_unit, :sort3_unit, :sort4_unit, :presence => true

    # coeff de conversion de l'effort (standard)
    validates :ent1_unit_coefficient, :ent2_unit_coefficient, :ent3_unit_coefficient, :ent4_unit_coefficient, :presence => true
    validates :sort1_unit_coefficient, :sort2_unit_coefficient, :sort3_unit_coefficient, :sort4_unit_coefficient, :presence => true


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
        "#{self.name} (#{mp.creation_order})"
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
              when "retained_size", "introduced_defects"
                p.send("string_data_#{level}")[component_id]
              else

                in_out = p.in_out
                in_out_attribute = self.send("#{in_out}_pe_attribute")
                if in_out_attribute.alias == "effort"
                  in_out_ev_attr_alias = ev.pe_attribute.alias
                  in_out_effort_standard_unit_coefficient = self.send("#{in_out_ev_attr_alias}_unit_coefficient")
                else
                  in_out_effort_standard_unit_coefficient = 1
                end
                p.send("string_data_#{level}")[component_id].to_f / in_out_effort_standard_unit_coefficient.to_f
            end
          rescue
            nil
          end
        else
          #c.send("string_data_#{level}")[component_id]
          case c.pe_attribute.alias
            when "effort"
              c.send("string_data_#{level}")[component_id].to_f / ge_model.input_effort_standard_unit_coefficient.to_f
            when "retained_size", "introduced_defects"
              c.send("string_data_#{level}")[component_id]

            else
              in_out = c.in_out
              in_out_attribute = self.send("#{in_out}_pe_attribute")
              if in_out_attribute.alias == "effort"
                in_out_ev_attr_alias = ev.pe_attribute.alias
                in_out_effort_standard_unit_coefficient = self.send("#{in_out_ev_attr_alias}_unit_coefficient")
              else
                in_out_effort_standard_unit_coefficient = 1
              end
              c.send("string_data_#{level}")[component_id].to_f / in_out_effort_standard_unit_coefficient.to_f
          end
        end
      rescue
        nil
      end
    end

  end
end
