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

    has_many :guw_types, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy
    has_many :guw_attributes, dependent: :destroy
    has_many :guw_work_units, dependent: :destroy
    has_many :module_projects, dependent: :destroy
    has_many :guw_weightings, dependent: :destroy
    has_many :guw_factors, dependent: :destroy
    has_many :guw_outputs, dependent: :destroy
    has_many :guw_coefficients, dependent: :destroy
    has_many :guw_scale_module_attributes, dependent: :destroy

    belongs_to :organization

    serialize :orders, Hash

    #validates_presence_of :name####, :organization_id
    validates :name, :presence => true #, :uniqueness => {:scope => :organization_id, :case_sensitive => false}
    # validates :coefficient_label, :presence => true

    #Search fields
    scoped_search :on => [:name]

    amoeba do
      enable
      include_association [:guw_types, :guw_attributes, :guw_work_units, :guw_weightings, :guw_factors, :guw_scale_module_attributes]

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
    def terminate_guw_model_duplication
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

        # Copy the GUW-attribute-complexity
        #guw_type.guw_type_complexities.each do |guw_type_complexity|
        #  guw_type_complexity.guw_attribute_complexities.each do |guw_attr_complexity|
        #
        #    new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_attr_complexity.guw_attribute_id).first
        #    new_guw_attribute_id = new_guw_attribute.nil? ? nil : new_guw_attribute.id
        #
        #    new_guw_type = guw_model.guw_types.where(copy_id: guw_type_complexity.guw_type_id).first
        #    new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id
        #
        #    guw_attr_complexity.update_attributes(guw_type_id: new_guw_type_id, guw_attribute_id: new_guw_attribute_id)
        #  end
        #end
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
      #end

    end

  end
end
