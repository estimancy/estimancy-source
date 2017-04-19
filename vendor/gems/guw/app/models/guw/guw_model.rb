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

module Guw
  class GuwModel < ActiveRecord::Base

    # include ActionView::Helpers

    has_many :guw_types, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy
    has_many :guw_attributes, dependent: :destroy
    has_many :guw_work_units, dependent: :destroy
    has_many :module_projects, dependent: :destroy
    has_many :guw_weightings, dependent: :destroy
    has_many :guw_factors, dependent: :destroy
    has_many :guw_outputs, dependent: :destroy
    has_many :guw_coefficients, dependent: :destroy
    has_many :guw_coefficient_elements, dependent: :destroy
    has_many :guw_scale_module_attributes, dependent: :destroy

    has_many :attribute_modules, dependent: :destroy

    belongs_to :organization

    serialize :orders, Hash

    #Search fields
    scoped_search :on => [:name]

    amoeba do
      enable
      include_association [:guw_types, :guw_attributes, :guw_work_units, :guw_weightings, :guw_factors, :guw_scale_module_attributes, :guw_outputs, :guw_coefficients, :attribute_modules]

      customize(lambda { |original_guw_model, new_guw_model|
        new_guw_model.copy_id = original_guw_model.id
      })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end

    #Terminate the duplication
    def terminate_guw_model_duplication(old_model)
      #new_organization.guw_models.each do |guw_model|
      guw_model = self
      guw_model_organization = guw_model.organization

      guw_model.guw_types.each do |guw_type|

        # Copy the complexities technologies
        guw_type.guw_complexities.each do |guw_complexity|
          # Copy the complexities technologie
          guw_complexity.guw_complexity_technologies.each do |guw_complexity_technology|
            new_organization_technology = guw_model_organization.organization_technologies.where(copy_id: guw_complexity_technology.organization_technology_id).first
            unless new_organization_technology.nil?
              guw_complexity_technology.update_attribute(:organization_technology_id, new_organization_technology.id)
            end
            guw_complexity_technology.update_attribute(:guw_type_id, guw_type.id)
          end

          # Copy the complexities units of works
          guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
            new_guw_work_unit = guw_model.guw_work_units.where(copy_id: guw_complexity_work_unit.guw_work_unit_id).first
            unless new_guw_work_unit.nil?
              guw_complexity_work_unit.update_attribute(:guw_work_unit_id, new_guw_work_unit.id)
            end
          end

          # Copy the complexities units of works
          guw_complexity.guw_complexity_weightings.each do |guw_complexity_weighting|
            new_guw_weighting = guw_model.guw_weightings.where(copy_id: guw_complexity_weighting.guw_weighting_id).first
            unless new_guw_weighting.nil?
              guw_complexity_weighting.update_attribute(:guw_weighting_id, new_guw_weighting.id)
            end
          end

          # Copy the complexities units of works
          guw_complexity.guw_complexity_factors.each do |guw_complexity_factor|
            new_guw_factor = guw_model.guw_factors.where(copy_id: guw_complexity_factor.guw_factor_id).first
            unless new_guw_factor.nil?
              guw_complexity_factor.update_attribute(:guw_factor_id, new_guw_factor.id)
            end
          end

          guw_complexity.guw_output_associations.each do |new_goa|

            go = GuwOutput.where(guw_model_id: guw_model.id,
                                 copy_id: new_goa.guw_output_id).first

            goa = GuwOutput.where(guw_model_id: guw_model.id,
                                  copy_id: new_goa.guw_output_associated_id).first

            new_goa.guw_output_id = go.nil? ? nil : go.id
            new_goa.guw_output_associated_id =  goa.nil? ? nil : goa.id

            new_goa.save(validate: false)
          end

          guw_complexity.guw_output_complexities.each do |new_goc|

            go = GuwOutput.where(guw_model_id: guw_model.id,
                                 copy_id: new_goc.guw_output_id).first

            new_goc.guw_output_id = go.nil? ? nil : go.id

            new_goc.save(validate: false)
          end

          guw_complexity.guw_output_complexity_initializations.each do |new_goci|

            go = GuwOutput.where(guw_model_id: guw_model.id,
                                 copy_id: new_goci.guw_output_id).first

            new_goci.guw_output_id = go.nil? ? nil : go.id

            new_goci.save(validate: false)
          end
        end

        #Guw UnitOfWorkAttributes
        guw_type.guw_unit_of_works.each do |guw_unit_of_work|
          guw_unit_of_work.guw_unit_of_work_attributes.each do |guw_uow_attr|
            new_guw_type = guw_model.guw_types.where(copy_id: guw_uow_attr.guw_type_id).first
            new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

            new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_uow_attr.guw_attribute_id).first
            new_guw_attribute_id = new_guw_attribute.nil? ? nil : new_guw_attribute.id

            guw_uow_attr.update_attributes(guw_type_id: new_guw_type_id, guw_attribute_id: new_guw_attribute_id)

          end
        end

      end

      guw_model.guw_attributes.each do |guw_attribute|
        guw_attribute.guw_attribute_complexities.each do |guw_attr_complexity|
          new_guw_type = guw_model.guw_types.where(copy_id: guw_attr_complexity.guw_type_id).first
          new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

          unless new_guw_type.nil?
            new_guw_type_complexity = new_guw_type.guw_type_complexities.where(copy_id: guw_attr_complexity.guw_type_complexity_id).first
            new_guw_type_complexity_id = new_guw_type_complexity.nil? ? nil : new_guw_type_complexity.id

            guw_attr_complexity.update_attributes(guw_type_id: new_guw_type_id, guw_type_complexity_id: new_guw_type_complexity_id )

          end
        end
      end

      guw_model.guw_coefficients.each do |guw_coefficient|
        guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
          guw_coefficient_element.guw_complexity_coefficient_elements.each do |gcce|

            new_guw_type = guw_model.guw_types.where(copy_id: gcce.guw_type_id).last
            new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

            new_guw_output = guw_model.guw_outputs.where(copy_id: gcce.guw_output_id).last
            new_guw_output_id = new_guw_output.nil? ? nil : new_guw_output.id

            new_guw_complexity = GuwComplexity.where(copy_id: gcce.guw_complexity_id).last
            new_guw_complexity_id = new_guw_complexity.nil? ? nil : new_guw_complexity.id

            gcce.guw_type_id = new_guw_type_id
            gcce.guw_output_id = new_guw_output_id
            gcce.guw_complexity_id = new_guw_complexity_id

            gcce.save(validate: false)

          end
        end
      end
    end

    def self.display_value(data_probable, estimation_value, vw)

      module_project = estimation_value.module_project
      guw_model = module_project.guw_model
      pe_attribute = estimation_value.pe_attribute

      guw_output = guw_model.guw_outputs.where(name: pe_attribute.name).first

      unless guw_output.nil?
        conv = guw_output.standard_coefficient
      else
        conv = 1
      end

      value = data_probable.to_f.round(2)

      if vw.use_organization_effort_unit == true
        tab = get_organization_unit(value, guw_model.organization)
        unit = tab.last
      else
        unless guw_output.nil?
          unit = guw_output.unit
        else
          unit = ''
        end
      end

      return "#{data_probable.to_f.round(2) / (conv.nil? ? 1 : conv.to_f)} #{unit}"

    end

    private
    def self.get_organization_unit(v, organization)
      unless v.class == Hash
        value = v.to_f
        if value < organization.limit1.to_i
          [organization.limit1_coef.to_f, organization.limit1_unit]
        elsif value < organization.limit2.to_i
          [organization.limit2_coef.to_f, organization.limit2_unit]
        elsif value < organization.limit3.to_i
          [organization.limit3_coef.to_f, organization.limit3_unit]
        elsif value < organization.limit4.to_i
          [organization.limit4_coef.to_f, organization.limit4_unit]
        else
          [organization.limit4_coef.to_f, organization.limit4_unit]
        end
      else
        []
      end
    end

  end
end
