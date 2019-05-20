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

    attr_accessible :name, :description, :ge_model_instance_mode, :coeff_a, :coeff_b, :copy_number, :copy_id, :modify_theorical_effort,
                    :ent1_unit, :ent2_unit, :ent3_unit, :ent4_unit, :sort1_unit, :sort2_unit, :sort3_unit, :sort4_unit,
                    :ent1_unit_coefficient, :ent2_unit_coefficient, :ent3_unit_coefficient, :ent4_unit_coefficient,
                    :sort1_unit_coefficient, :sort2_unit_coefficient, :sort3_unit_coefficient, :sort4_unit_coefficient,
                    :ent1_is_modifiable, :ent2_is_modifiable, :ent3_is_modifiable, :ent4_is_modifiable,
                    :sort1_is_modifiable, :sort2_is_modifiable, :sort3_is_modifiable, :sort4_is_modifiable,
                    :ge_model_instance_mode, :input_pe_attribute_id, :output_pe_attribute_id,
                    :c_calculation_method, :s_calculation_method, :p_calculation_method,
                    :enabled_input, :input_effort_standard_unit_coefficient, :output_effort_standard_unit_coefficient, :three_points_estimation,
                    :output_effort_unit, :input_effort_unit, :output_size_unit, :input_size_unit, :organization_id


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

    #validates_presence_of :organization_id
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}
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


    def self.display_value(data_probable, estimation_value, view_widget, user)

      module_project = estimation_value.module_project
      ge_model = module_project.ge_model
      value = data_probable.to_f
      unit_coefficient = 1

      if estimation_value.pe_attribute.alias == "remaining_defects" || estimation_value.pe_attribute.alias == "introduced_defects"
        unless value.class == Hash
          "#{convert_with_precision(value, 2, true)}"
        end
      else
        if view_widget.use_organization_effort_unit == true
          tab = Organization.get_organization_unit(value, ge_model.organization)
          unit_coefficient = tab.first
          unit = tab.last
        else
          begin
            in_out_ev_attr_alias = estimation_value.pe_attribute.alias
            unit_coefficient = ge_model.send("#{in_out_ev_attr_alias}_unit_coefficient")
            unit = ge_model.send("#{in_out_ev_attr_alias}_unit")
          rescue
            unit_coefficient = 1
            unit = ""
          end
        end
      end


      begin
        if value.nil?
          result_value = nil
        else
          result_value = (value / unit_coefficient.to_f)
        end
      rescue
        result_value = nil
      end

      return "#{ActionController::Base.helpers.number_with_precision(result_value, precision: user.number_precision.nil? ? 2 : user.number_precision, delimiter: ' ', locale: (user.language.locale rescue "fr"))} #{unit}"
    end


  end
end
