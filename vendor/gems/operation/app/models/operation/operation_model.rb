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

module Operation
  class OperationModel < ActiveRecord::Base

    DEFAULT_INPUT_ATTRIBUTES_ALIAS = ["ent1_operation", "ent2_operation", "ent3_operation", "ent4_operation"]
    OUTPUT_ATTRIBUTES_ALIAS = ["sortie_operation"]

    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}
    #validates :standard_unit_coefficient, :output_unit, :presence => true
    validates :operation_type, :presence => true

    attr_accessible :organization_id, :name, :three_points_estimation, :operation_type

    belongs_to :organization
    has_many :module_projects, :dependent => :destroy
    has_many :operation_inputs, dependent: :destroy
    has_many :pe_attributes, through: :operation_inputs

    amoeba do
      enable
      exclude_association [:module_projects, :pe_attributes]

      customize(lambda { |original_ge_model, new_ge_model|
        new_ge_model.copy_id = original_ge_model.id
      })
    end


    def terminate_operation_model_duplication(new_organisation_id = nil)
      new_operation_model = self
      pm = Pemodule.where(alias: "operation").first

      old_operation_model = OperationModel.find(new_operation_model.copy_id)
      old_operation_model_attributes = old_operation_model.pe_attributes

      new_operation_model.operation_inputs.each do |operation_input|
        attr = PeAttribute.where(name: operation_input.name,
                                 alias: operation_input.name.underscore.gsub(" ", "_"),
                                 description: operation_input.description,
                                 operation_input_id: operation_input.id,
                                 operation_model_id: operation_input.operation_model_id).first_or_create!

        am = AttributeModule.where(pe_attribute_id: attr.id,
                                   pemodule_id: pm.id,
                                   in_out: operation_input.in_out,
                                   operation_model_id: operation_input.operation_model_id).first_or_create!

        # Update estimation_values pe_attributes when copying organization
        unless new_organisation_id.nil?
          # Update estimation_values pe_attribute
          new_operation_model.module_projects.each do |mp|
            ev_with_current_attribute = mp.estimation_values.includes(:pe_attribute).where(pe_attribute: { alias: attr.alias })
            ev_with_current_attribute.each do |est_val|
              est_val.pe_attribute_id = attr.id
              est_val.save
            end
          end
        end
      end

      old_operation_model_attributes
    end


    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end

    def self.display_value(data_probable, estimation_value, view_widget, user)

      module_project = estimation_value.module_project
      operation_model = module_project.operation_model
      value = data_probable.to_f.round(2)

      if view_widget.use_organization_effort_unit == true
        tab = Organization.get_organization_unit(value, operation_model.organization)
        unit_coefficient = tab.first
        unit = tab.last
      else
        begin
          operation_input = estimation_value.pe_attribute.operation_input
        rescue
          operation_input = nil
        end

        unless operation_input.nil?
          unit_coefficient = operation_input.send("standard_unit_coefficient")
          unit_coefficient = unit_coefficient.nil? ? 1 : unit_coefficient.to_f

          unit = operation_input.send("standard_unit")
        else
          unit_coefficient = 1
          unit = ''
        end
      end

      begin
        if data_probable.nil?
          result_value = nil
        else
          result_value = (data_probable.to_f / unit_coefficient)
        end
      rescue
        result_value = nil
      end

      return "#{ActionController::Base.helpers.number_with_precision(result_value, precision: user.number_precision.nil? ? 2 : user.number_precision, delimiter: ' ', locale: (user.language.locale rescue "fr"))} #{unit}"
    end


    def self.display_size(p, c, level, component_id, operation_model)
      standard_coefficient = 1
      begin
        if c.send("string_data_#{level}")[component_id].nil?
          begin
            p.send("string_data_#{level}")[component_id]
          rescue
            nil
          end
        else
          c.send("string_data_#{level}")[component_id]
        end
      rescue
        nil
      end
    end

  end
end
