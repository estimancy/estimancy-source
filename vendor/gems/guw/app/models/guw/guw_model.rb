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

    attr_accessible :name, :description, :organization_id,
                   :three_points_estimation, :retained_size_unit, :one_level_model,
                   :copy_id, :copy_number, :coefficient_label,
                   :hour_coefficient_conversion, :default_display, :weightings_label,
                   :factors_label, :effort_unit, :cost_unit,
                   :allow_technology, :work_unit_type, :weighting_type,
                   :factor_type, :work_unit_min, :work_unit_max,
                   :factor_min, :factor_max, :weighting_min,
                   :weighting_max, :orders, :config_type,
                   :allow_ml, :allow_excel, :allow_jira,
                   :allow_redmine, :excel_ml_server, :jira_ml_server,
                   :redmine_ml_server, :allow_ml_excel, :allow_ml_jira,
                   :allow_ml_redmine, :view_data

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
    has_many :guw_scale_module_attributes, dependent: :delete_all #revoir la gestion des :delete_all qui semble ne pas fonctionner

    has_many :attribute_modules, dependent: :destroy
    has_many :guw_output_types, dependent: :delete_all #revoir la gestion des :delete_all qui semble ne pas fonctionner

    belongs_to :organization

    serialize :orders, Hash

    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}

    #Search fields
    scoped_search :on => [:name]
    scope :name_starts_with, -> (name) { where("name like ?", "#{name}%")}


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
        #"#{self.name} (#{mp.creation_order})"
        self.name
      end
    end

    #Terminate the duplication
    def terminate_guw_model_duplication(old_model, is_organization_copy=false)
      #new_organization.guw_models.each do |guw_model|
      guw_model = self
      guw_model_organization = guw_model.organization
      guw_model_organization_id = guw_model_organization.id

      # Copy PeAttributes for  the new model outputs
      pm = Pemodule.where(alias: "guw").first
      old_pe_attributes = PeAttribute.where(guw_model_id: old_model.id)

      old_pe_attributes.each do |old_pe_attribute|
        new_pe_attribute = old_pe_attribute.dup
        new_pe_attribute.guw_model_id = guw_model.id
        new_pe_attribute.save

        am = AttributeModule.where(pe_attribute_id: old_pe_attribute.id, pemodule_id: pm.id, in_out: "both", guw_model_id: guw_model.id).first
        if am.nil?
          am = AttributeModule.where(pe_attribute_id: new_pe_attribute.id, pemodule_id: pm.id, in_out: "both",
                                     guw_model_id: guw_model.id).first_or_create!
        else
          am.pe_attribute_id = new_pe_attribute.id
          am.save
        end

        if is_organization_copy == true
          guw_model.module_projects.where(organization_id: guw_model_organization.id).each do |module_project|
            module_project.estimation_values.where(organization_id: guw_model_organization.id, pe_attribute_id: old_pe_attribute.id).each do |estimation_value|

              estimation_value.pe_attribute_id = new_pe_attribute.id
              estimation_value.save
            end

            module_project.views_widgets.where(pe_attribute_id: old_pe_attribute.id).each do |view_widget|
              view_widget.pe_attribute_id = new_pe_attribute.id
              view_widget.save
            end

          end
        end
      end


      #Update GUW organization_id apres gestion Temps de Reponse
      #====== debut ======
      #puts "\nGuwType"
      guw_model.guw_types.update_all(organization_id: guw_model_organization_id)

      #puts "\nGuwOutput"
      guw_model.guw_outputs.update_all(organization_id: guw_model_organization_id)

      #puts "\nGuwCoefficient"
      guw_model.guw_coefficients.update_all(organization_id: guw_model_organization_id)

      #puts "\nGuwCoefficientElement"
      guw_model.guw_coefficients.where(organization_id: guw_model_organization_id).each do |guw_coefficient|
        guw_coefficient.guw_coefficient_elements.update_all(organization_id: guw_model_organization_id, guw_model_id: guw_model.id)
      end

      #puts "\nGuwAttribute
      guw_model.guw_attributes.update_all(organization_id: guw_model_organization_id)

      #puts "\nGuwOutputType"
      guw_model.guw_output_types.update_all(organization_id: guw_model_organization_id)

      #puts "\nGuwWorkUnit"
      guw_model.guw_work_units.update_all(organization_id: guw_model_organization_id)

      #puts "\nEstimationValue : voir dans execute_duplication"
      #puts "\nGuwCoefficientElementUnitOfWork : voir dans execute_duplication"
      #puts "\nModuleProject : voir dans execute_duplication"
      #puts "\nGuwUnitOfWorkAttribute : voir dans execute_duplication"

      #puts "\nGuwComplexityTechnology : n'est plus utilisé"
      #puts "\nGuwComplexityWorkUnit : n'est plus utilisé"
      #====== fin ========


      guw_model.guw_types.each do |guw_type|

        #puts "\nGuwTypeComplexity"
        guw_type.guw_type_complexities.update_all(organization_id: guw_model_organization_id, guw_model_id: guw_model.id)

        #puts "\nGuwAttributeType : #{Guw::GuwAttributeType.where(organization_id: nil).size} elements"
        GuwAttributeType.where(guw_type_id: guw_type.id).each do |guw_attribute_type|
          guw_attribute_type.update_attributes(organization_id: guw_model_organization.id, guw_model_id: guw_model.id)
        end

        # Copy the complexities technologies
        guw_type.guw_complexities.each do |guw_complexity|

          #puts "\nGuwComplexity"
          guw_complexity.guw_model_id = guw_model.id
          guw_complexity.organization_id = guw_model_organization_id
          guw_complexity.save

          #puts "\nGuwOutputAssociation"
          guw_complexity.guw_output_associations.each do |new_goa|

            go = GuwOutput.where(guw_model_id: guw_model.id,  copy_id: new_goa.guw_output_id).first
            goa = GuwOutput.where(guw_model_id: guw_model.id, copy_id: new_goa.guw_output_associated_id).first

            new_goa.guw_output_id = go.nil? ? nil : go.id
            new_goa.guw_output_associated_id =  goa.nil? ? nil : goa.id

            new_goa.guw_model_id = guw_model.id
            new_goa.organization_id = guw_model_organization.id
            new_goa.save(validate: false)
          end

          #puts "\nGuwOutputComplexity"
          guw_complexity.guw_output_complexities.each do |new_goc|

            go = GuwOutput.where(guw_model_id: guw_model.id, copy_id: new_goc.guw_output_id).first

            new_goc.guw_output_id = go.nil? ? nil : go.id

            new_goc.guw_model_id = guw_model.id
            new_goc.organization_id = guw_model_organization.id
            new_goc.save(validate: false)
          end

          #puts "\nGuwOutputComplexityInitialization"
          guw_complexity.guw_output_complexity_initializations.each do |new_goci|

            go = GuwOutput.where(guw_model_id: guw_model.id, copy_id: new_goci.guw_output_id).first

            new_goci.guw_output_id = go.nil? ? nil : go.id

            new_goci.organization_id = guw_model_organization.id
            new_goci.guw_model_id = guw_model.id

            new_goci.save(validate: false)
          end
        end

        guw_model_guw_types = guw_model.guw_types
        guw_model_guw_attributes = guw_model.guw_attributes

        #Guw UnitOfWorkAttributes && Guw UnitOfWorks AJUSTED_SIZE and SIZE update if is_organization_copy=true
        guw_type.guw_unit_of_works.where(organization_id: guw_model_organization.id,
                                         guw_model_id: guw_model.id).each do |guw_unit_of_work|

          guw_unit_of_work.guw_unit_of_work_attributes.where(organization_id: guw_model_organization.id,
                                                             guw_model_id: guw_model.id).each do |guw_uow_attr|

            new_guw_type = guw_model_guw_types.where(organization_id: guw_model_organization.id,
                                                     guw_model_id: guw_model.id,
                                                     copy_id: guw_uow_attr.guw_type_id).first

            new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

            new_guw_attribute = guw_model_guw_attributes.where(organization_id: guw_model_organization.id,
                                                               guw_model_id: guw_model.id,
                                                               copy_id: guw_uow_attr.guw_attribute_id).first

            new_guw_attribute_id = new_guw_attribute.nil? ? nil : new_guw_attribute.id

            guw_uow_attr.update_attributes(organization_id: guw_model_organization.id,
                                           guw_model_id: guw_model.id,
                                           guw_type_id: new_guw_type_id,
                                           guw_attribute_id: new_guw_attribute_id)
          end


          if is_organization_copy == true
            #Guw UnitOfWorks AJUSTED_SIZE and SIZE update according to the outputs keys
            if guw_unit_of_work.ajusted_size.is_a?(Hash)
              new_ajusted_size = Hash.new
              guw_unit_of_work.ajusted_size.each do |guw_output_key, value|
                new_guw_ouput = GuwOutput.where(guw_model_id: guw_model.id, copy_id: guw_output_key).first
                unless new_guw_ouput.nil?
                  new_ajusted_size["#{new_guw_ouput.id}"] = value
                end
              end
              guw_unit_of_work.ajusted_size = new_ajusted_size
            end

            # SIZE
            if guw_unit_of_work.size.is_a?(Hash)
              new_size = Hash.new
              guw_unit_of_work.size.each do |guw_output_key, value|
                new_guw_ouput = GuwOutput.where(guw_model_id: guw_model.id, copy_id: guw_output_key).first
                unless new_guw_ouput.nil?
                  new_size["#{new_guw_ouput.id}"] = value
                end
              end
              guw_unit_of_work.size = new_size
            end

            if guw_unit_of_work.changed?
              guw_unit_of_work.save
            end
          end

        end

      end

      guw_model.guw_attributes.each do |guw_attribute|
        guw_attribute.guw_attribute_complexities.each do |guw_attr_complexity|
          new_guw_type = guw_model.guw_types.where(guw_model_id: guw_model.id, copy_id: guw_attr_complexity.guw_type_id).first
          new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

          unless new_guw_type.nil?

            new_guw_type_complexity = new_guw_type.guw_type_complexities.where(guw_model_id: guw_model.id, copy_id: guw_attr_complexity.guw_type_complexity_id).first
            new_guw_type_complexity.guw_model_id = guw_model.id
            new_guw_type_complexity.save(validate: false)

            #puts "\nGuwAttributeComplexity"
            guw_attr_complexity.organization_id = guw_model_organization.id
            guw_attr_complexity.guw_model_id = guw_model.id
            guw_attr_complexity.guw_type_id = new_guw_type_id
            guw_attr_complexity.guw_type_complexity_id = new_guw_type_complexity.nil? ? nil : new_guw_type_complexity.id

            guw_attr_complexity.save(validate: false)

          end
        end
      end

      guw_model.guw_coefficients.each do |guw_coefficient|

        guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|

          guw_coefficient_element.guw_model_id = guw_model.id
          guw_coefficient_element.organization_id = guw_model_organization.id
          guw_coefficient_element.save

          #puts "\nGuwComplexityCoefficientElement"
          guw_coefficient_element.guw_complexity_coefficient_elements.each do |gcce|

            new_guw_type = guw_model.guw_types.where(guw_model_id: guw_model.id, copy_id: gcce.guw_type_id).last
            new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

            new_guw_output = guw_model.guw_outputs.where(guw_model_id: guw_model.id, copy_id: gcce.guw_output_id).last
            new_guw_output_id = new_guw_output.nil? ? nil : new_guw_output.id

            new_guw_complexity = GuwComplexity.where(guw_model_id: guw_model.id, copy_id: gcce.guw_complexity_id).last
            new_guw_complexity_id = new_guw_complexity.nil? ? nil : new_guw_complexity.id

            gcce.guw_type_id = new_guw_type_id
            gcce.guw_output_id = new_guw_output_id
            gcce.guw_complexity_id = new_guw_complexity_id

            gcce.guw_model_id = guw_model.id
            gcce.organization_id = guw_model_organization.id
            gcce.save(validate: false)
          end
        end
      end

      #update GuwOutputType
      old_model.guw_output_types.each do |output_type|
        new_output = GuwOutput.where(guw_model_id: guw_model.id, copy_id: output_type.guw_output_id).first
        new_type = GuwType.where(guw_model_id: guw_model.id, copy_id: output_type.guw_type_id).first

        unless new_output.nil? || new_type.nil?
          GuwOutputType.create(organization_id: guw_model_organization.id,
                               guw_model_id: guw_model.id,
                               guw_output_id: new_output.id,
                               guw_type_id: new_type.id,
                               display_type: output_type.display_type)
        end

      end

    end

    def self.display_value(data_probable, estimation_value, vw, user)

      module_project = estimation_value.module_project
      guw_model = module_project.guw_model
      pe_attribute = estimation_value.pe_attribute

      begin
        guw_output = guw_model.guw_outputs.where(name: pe_attribute.name).first
      rescue
        guw_output = nil
      end

      unless guw_output.nil?
        conv = guw_output.standard_coefficient
      else
        conv = 1
      end

      begin
        value = data_probable.to_f.round(2)

        if vw.use_organization_effort_unit == true
          tab = Organization.get_organization_unit(value, guw_model.organization)
          unit = tab.last
        else
          unless guw_output.nil?
            unit = guw_output.unit
          else
            unit = ''
          end
        end
      rescue
        unit = ''
      end

      begin
        if pe_attribute.alias == "effort" && guw_model.config_type == "old"
          res = "#{ActionController::Base.helpers.number_with_precision((data_probable.to_f / guw_model.hour_coefficient_conversion.to_f).to_f, delimiter: ' ', precision: user.number_precision.nil? ? 2 : user.number_precision, locale: (user.language.locale rescue "fr"))} #{guw_model.effort_unit}"
        elsif pe_attribute.alias == "cost" && guw_model.config_type == "old"
          res = "#{ActionController::Base.helpers.number_with_precision((data_probable.to_f / (conv.nil? ? 1.0 : conv.to_f)).to_f, delimiter: ' ', precision: user.number_precision.nil? ? 2 : user.number_precision, locale: (user.language.locale rescue "fr"))} #{guw_model.cost_unit}"
        elsif pe_attribute.alias == "retained_size" && guw_model.config_type == "old"
          res = "#{ActionController::Base.helpers.number_with_precision((data_probable.to_f / (conv.nil? ? 1.0 : conv.to_f)).to_f, delimiter: ' ', precision: user.number_precision.nil? ? 2 : user.number_precision, locale: (user.language.locale rescue "fr"))} #{guw_model.retained_size_unit}"
        else
          res = "#{ActionController::Base.helpers.number_with_precision((data_probable.to_f / (conv.nil? ? 1.0 : conv.to_f)).to_f, delimiter: ' ', precision: user.number_precision.nil? ? 2 : user.number_precision, locale: (user.language.locale rescue "fr"))} #{unit}"
        end
      rescue
        #??
      end

      return res

    end

  end
end
