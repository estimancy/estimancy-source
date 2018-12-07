#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014-2015 Estimancy (http://www.estimancy.com)
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

class OrganizationsController < ApplicationController

  # load_resource

  require 'will_paginate/array'
  require 'securerandom'
  require 'rubyXL'
  include ProjectsHelper
  include OrganizationsHelper
  include ActionView::Helpers::NumberHelper

  #Pour gestion des rapports personnalisés
  def report_management
  end

  # Export PDF de la liste des changements
  def export_to_pdf_security_audit_utilities
    @organization = @current_organization  #Organization.find(params[:organization_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date] || DateTime.now

    redirect_to organizationals_params_path if @organization.nil? and return

    @versions = AutorizationLogEvent.where(organization_id: @organization.id).order(:created_at)
    unless @start_date.blank?
      #@versions = AutorizationLogEvent.where(organization_id: @organization.id, created_at: start_date .. end_date)
      #@versions = AutorizationLogEvent.where("created_at >= ? AND created_at <= ?", Time.parse(start_date), Time.parse(end_date))
      @versions = AutorizationLogEvent.where(organization_id: @organization.id, created_at: Time.parse(@start_date)..Time.parse(@end_date))
    end

    @versions = AutorizationLogEvent.where(event_organization_id: @organization.id).order(:created_at)
    #@versions.where(item_type: ["User","OrganizationsUsers"])
    #@user_versions = @versions.where(item_type: ["User", "UserOrganizations", "UserGroups"])
    @user_organizations_versions = @versions.where(item_type: ["OrganizationUser"])
    @user_groups_versions = @versions.where(item_type: ["GroupUser"])
    @user_estimation_status_versions = @versions.where(item_type: ["EstimationStatusGroupRole"])
    @group_permissions_versions = @versions.where(item_type: ["GroupPermission"])
    @security_level_versions = @versions.where(item_type: ["PermissionProjectSecurityLevel"])
    @simple_events_versions = @versions.where(item_type: ["Group", "User", "ProjectSecurityLevel"])

    # #Pour les estimations et les models
    @project_securities = @versions.where(item_type: ["ProjectSecurity"])
    # @estimation_model_versions = @project_securities.where(is_model_permission: true)
    # @estimation_versions = @project_securities.where(is_model_permission: [false, nil])
    @estimation_model_versions = @project_securities.where(is_model: true)
    @estimation_versions = @project_securities.where(is_model: false)

    @estimation_model_groups_versions = @project_securities.where(is_model_permission: true)
    @estimation_model_users_versions = @project_securities.where(is_model_permission: true)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "export_to_pdf_security_audit_utilities.pdf",
               template: 'organizations/export_to_pdf_security_audit_utilities.pdf.erb',
               encoding: "UTF-8",
               page_size: 'A4',
               orientation: :landscape,
               footer: { right: '[page] sur [topage]' }
               #:header => { :content => "pdf_header", :spacing => 10 }
               #:header => {:content => render( :template => 'layouts/pdf_header.pdf.erb'), :spacing => 0}
      end
    end
  end

  # Page d'accueil de le fonction d'audit de sécurité
  def security_audit_utilities_view
    @organization = @current_organization
    authorize! :manage_security_audit, @organization

  end

  # Fonction d'audit de sécurité
  def security_audit_utilities
    @organization = @current_organization

    authorize! :manage_security_audit, @organization

    @versions = AutorizationLogEvent.where(event_organization_id: @organization.id).order(:created_at) #@current_organization.versions

    #@versions.where(item_type: ["User","OrganizationsUsers"])
    #@user_versions = @versions.where(item_type: ["User", "UserOrganizations", "UserGroups"])
    @user_organizations_versions = @versions.where(item_type: ["OrganizationUser"])
    @user_groups_versions = @versions.where(item_type: ["GroupUser"])
    @user_estimation_status_versions = @versions.where(item_type: ["EstimationStatusGroupRole"])
    @group_permissions_versions = @versions.where(item_type: ["GroupPermission"])
    @security_level_versions = @versions.where(item_type: ["PermissionProjectSecurityLevel"])
    @simple_events_versions = @versions.where(item_type: ["Group", "User", "ProjectSecurityLevel"])

    # #Pour les estimations et les models
    @project_securities = @versions.where(item_type: ["ProjectSecurity"])
    # @estimation_model_versions = @project_securities.where(is_model_permission: true)
    # @estimation_versions = @project_securities.where(is_model_permission: [false, nil])
    @estimation_model_versions = @project_securities.where(is_model: true)
    @estimation_versions = @project_securities.where(is_model: false)

    @estimation_model_groups_versions = @project_securities.where(is_model_permission: true)
    @estimation_model_users_versions = @project_securities.where(is_model_permission: true)

  end


  def destroy_all_security_audit_utilities
    @versions = AutorizationLogEvent.where(event_organization_id: @current_organization.id)
    @versions.delete_all
    redirect_to :back
  end


  def audit_integrity_common_data_params

  end

  def update_organizations_for_audit_common_data
    referenced_organization_id = params[:referenced_organization_id]

    unless referenced_organization_id.blank?
      @referenced_organization = Organization.find(referenced_organization_id)
      @other_organizations = Organization.where("id <> ?", referenced_organization_id)
    end
  end

  # Fonction d'audit de l'intégrité du Corps commun
  def audit_integrity_common_data
    referenced_organization_id = params[:referenced_organization_id]

    if referenced_organization_id.blank?
      flash[:warning] = "Vous devez choisir un CDS de référence"
      redirect_to :back and return
    end

    @reference_organization = Organization.where(id: referenced_organization_id).first
    @reference_organization_applications = @reference_organization.applications
    @reference_organization_profiles = @reference_organization.organization_profiles
    @reference_organization_users = @reference_organization.users

    ###@reference_guw_model = @reference_organization.guw_models.where("name like ?", "%abaque%").first
    @reference_guw_model = @reference_organization.guw_models.where("name like ?", "Dénombrement Evolution & Dire d'expert").first

    if @reference_guw_model.nil?
      flash[:warning] = "Il n'existe pas de module de Taille de référence"
      redirect_to :back and return
    end

    # Les CDS/ organisations selectionnées pour lancer l'audit
    organizations_list_ids = params[:organizations_list_ids]
    @organizations_to_audit = Organization.where(id: organizations_list_ids).all

    @all_differences = {}
    @applications_differences = {}
    @profiles_differences = {}
    @default_data_differences = {}
    @attributes_differences = {}
    @outputs_differences = {}
    @coefficients_differences = {}
    @coefficient_elements_differences = {}
    @guw_types_differences = {}
    @guw_types_complexities_differences = {}
    @attributes_type_complexities_differences = {}
    @guw_types_complexities_coefficients_outputs_matrix_differences = {}
    @attributes_type_complexities_matrix_differences = {}

    @organizations_to_audit.each do |organization|
      @all_differences[organization.id] = []
      @applications_differences[organization.id] = []
      @profiles_differences[organization.id] = []
      @default_data_differences[organization.id] = []
      @attributes_differences[organization.id] = []
      @outputs_differences[organization.id] = []
      @coefficients_differences[organization.id] = []
      @coefficient_elements_differences[organization.id] = []
      @guw_types_differences[organization.id] = []
      @guw_types_complexities_differences[organization.id] = []
      @attributes_type_complexities_differences[organization.id] = []
      @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] = []
      @attributes_type_complexities_matrix_differences[organization.id] = []
    end

    guw_model_columns = Guw::GuwModel.column_names.reject { |column| column.in? ["id", "name", "organization_id", "created_at", "updated_at", "copy_id", "copy_number"]}
    @reference_default_data = HashWithIndifferentAccess.new

    #On recupere les valeurs de reference
    guw_model_columns.each do |column_name|
      @reference_default_data[column_name] = @reference_guw_model.send(column_name)
    end

    @reference_guw_model_attributes = @reference_guw_model.guw_attributes  #attributs de references
    @reference_guw_model_outputs = @reference_guw_model.guw_outputs  #outputs de references
    @reference_guw_model_attributes = @reference_guw_model.guw_attributes
    @reference_guw_model_coefficients = @reference_guw_model.guw_coefficients  #coefficients de references
    @reference_guw_model_types = @reference_guw_model.guw_types  #Type d'UO de references


    #guw_models_with_abaque = Guw::GuwModel.where("name like ? AND id != ?", "%abaque%", @reference_guw_model.id).reject

    #On parcourt toutes les organisations de la liste
    @organizations_to_audit.each do |organization|

      ###=================================== Comparaison des APPLICATIONS ===================================###
      organization_applications = organization.applications
      organization_applications.each do |application|
        reference_application = @reference_organization_applications.where(name: application.name).first
        if reference_application.nil?
          #l'application n'existe pas dans la référence
          @applications_differences[organization.id] << { organization_id: organization.id,
                                                          application_id: application.id,
                                                          reference_id: nil,
                                                          element_id: application.id,
                                                          column_name: "Application",
                                                          column_value: application.name,
                                                          nature: "Application en trop par rapport à la référence"
          }
        end
      end
      # Pour voir si s'il ya des applications manquantes dans l'organisation concerné
      diff_applications_name = @reference_organization_applications.all.map(&:name) - organization_applications.all.map(&:name)
      unless diff_applications_name.empty?
        diff_applications = @reference_organization_applications.where(name: diff_applications_name)
        diff_applications.each do |application|
          @applications_differences[organization.id] << { organization_id: organization.id,
                                                          application_id: application.id,
                                                          reference_id: application.id,
                                                          element_id: nil,
                                                          column_name: "Application",
                                                          column_value: application.name,
                                                          nature: "Application manquante dans l'organisation'"
          }
        end
      end


      ###=================================== Comparaison des PROFILS ===================================###
      organization_profiles = organization.organization_profiles
      organization_profiles.each do |profile|
        reference_profile = @reference_organization_profiles.where(name: profile.name).first
        if reference_profile.nil?
          #le profil n'existe pas dans la référence
          @profiles_differences[organization.id] << { organization_id: organization.id,
                                                      profile_id: profile.id,
                                                      reference_id: nil,
                                                      element_id: profile.id,
                                                      column_name: "Profils",
                                                      column_value: profile.name,
                                                      nature: "Profil en trop par rapport à la référence"
          }
        end
      end
      # Pour voir si s'il ya des applications manquantes dans l'organisation concerné
      diff_profiles_name = @reference_organization_profiles.all.map(&:name) - organization_profiles.all.map(&:name)
      unless diff_profiles_name.empty?
        diff_profiles = @reference_organization_profiles.where(name: diff_profiles_name)
        diff_profiles.each do |profile|
          @profiles_differences[organization.id] << { organization_id: organization.id,
                                                      profile_id: profile.id,
                                                      reference_id: profile.id,
                                                      element_id: nil,
                                                      column_name: "Profil",
                                                      column_value: profile.name,
                                                      nature: "Profil manquant dans l'organisation'"
          }
        end
      end





      ###=================================== MODULE DE TAILLES ===================================###


      #guw_models_with_abaque = Guw::GuwModel.where("name like ? AND organization_id = ?", "%abaque%", organization.id)
      guw_models_with_abaque = Guw::GuwModel.where("name like ? AND organization_id = ?", "%Dénombrement%", organization.id)

      #Pour chaque modele, il faut vérifier pour chaque type d'UO que les éléments sont identique par rapport à l'organization de référence
      guw_models_with_abaque.each do |guw_model|

        guw_model_organization_id = organization.id #guw_model.organization_id

        guw_model_outputs = Guw::GuwOutput.where(guw_model_id: guw_model.id).order("display_order ASC")
        guw_model_attributes = guw_model.guw_attributes

        #=========================== Donnees et informations generales  ==========================#
        # @reference_default_data.each do |column_name, column_value|
        #   different = false
        #
        #   if column_name == "orders"
        #     guw_model_orders = Hash[guw_model.send(column_name).map{|k, v| [k.to_s, v.to_s]}]
        #     column_value = Hash[column_value.map{|k, v| [k.to_s, v.to_s]}]
        #
        #     #if (guw_model.send(column_name).to_a <=> column_value.to_a) != 0
        #     if (guw_model_orders.to_a <=> column_value.to_a) != 0
        #       different = true
        #       differences = guw_model.send(column_name).diff(column_value)
        #       @default_data_differences[organization.id] << { organization_id: guw_model_organization_id, guw_model_id: guw_model.id,
        #                             column_name: column_name, reference_column_value: column_value, column_value: guw_model_orders, nature: ""
        #       }
        #     end
        #
        #     #on parcourt les valeurs une à une
        #     guw_model_orders = guw_model.send(column_name)
        #     column_value.each do |key, value|
        #         #if guw_model_orders[key]
        #     end
        #
        #   else
        #     guw_model_column_value = guw_model.send(column_name)
        #     if column_value.in?([true, false]) || guw_model_column_value.in?([true, false])
        #       if !column_value != !guw_model_column_value
        #         different = true
        #         @default_data_differences[organization.id] << { organization_id: guw_model_organization_id, guw_model_id: guw_model.id,
        #                                        column_name: column_name, reference_column_value: column_value, column_value: guw_model_column_value, nature: ""
        #         }
        #       end
        #     else
        #       if guw_model_column_value != column_value
        #         different = true
        #         @default_data_differences[organization.id] << { organization_id: guw_model_organization_id, guw_model_id: guw_model.id,
        #                                        column_name: column_name, reference_column_value: column_value, column_value: guw_model_column_value, nature: ""
        #         }
        #       end
        #     end
        #   end
        # end


        #=============================== Les attributs  ===============================#
        # guw_model.guw_attributes.each do |attribute|
        #   reference_attribute = @reference_guw_model_attributes.where(name: attribute.name).first
        #   if reference_attribute
        #     ###identique_attribute = @reference_guw_model_attributes.where(name: attribute.name, description: attribute.description).first
        #
        #     if reference_attribute.name.to_s != attribute.name.to_s || reference_attribute.description.to_s != attribute.description.to_s
        #       # Description differente
        #       @attributes_differences[organization.id] << { organization_id: guw_model_organization_id, guw_model_id: guw_model.id, reference_id: reference_attribute.id,
        #                             element_id: attribute.id, column_name: "Attribut", column_value: attribute.name, nature: "Description différente"
        #       }
        #     end
        #   else
        #     #l'attribut n'existe pas dans la référence
        #     @attributes_differences[organization.id] << { organization_id: guw_model_organization_id, guw_model_id: guw_model.id, reference_id: nil,
        #                           element_id: attribute.id, column_name: "Attribut", column_value: attribute.name, nature: "Attribut en trop par rapport à la référence"
        #     }
        #   end
        # end
        # # Pour voir si s'il ya des attributs manquants dans le module de taille concerné
        # diff_attributes_name = @reference_guw_model_attributes.map(&:name) - guw_model.guw_attributes.map(&:name)
        # unless diff_attributes_name.empty?
        #   diff_attributes = @reference_guw_model_attributes.where(name: diff_attributes_name)
        #   diff_attributes.each do |attribute|
        #     @attributes_differences[organization.id] << { organization_id: guw_model_organization_id,
        #                                  guw_model_id: guw_model.id,
        #                                  reference_id: attribute.id,
        #                                  element_id: nil,
        #                                  column_name: "Attribut", column_value: attribute.name, nature: "Attribut manquant dans le module de Taille"
        #     }
        #   end
        # end


        #=============================== Les Sorties  ===============================#
        #guw_model.guw_outputs.each do |output|
        guw_model_outputs.each do |output|
          reference_output = @reference_guw_model_outputs.where(name: output.name).first
          if reference_output
            # identique_output = @reference_guw_model_outputs.where(name: output.name, output_type: output.output_type,
            #                                                       allow_intermediate_value: output.allow_intermediate_value,
            #                                                       allow_subtotal: output.allow_subtotal, standard_coefficient: output.standard_coefficient,
            #                                                       unit: output.unit, display_order: output.display_order,
            #                                                       color_code: output.color_code, color_priority: output.color_priority).first
            if  reference_output.name.to_s != output.name ||
                reference_output.output_type.to_s !=  output.output_type.to_s ||
                reference_output.allow_intermediate_value != output.allow_intermediate_value ||
                !reference_output.allow_subtotal != !output.allow_subtotal ||
                reference_output.standard_coefficient != output.standard_coefficient ||
                reference_output.unit != output.unit ||
                reference_output.display_order != output.display_order ||
                reference_output.color_code != output.color_code ||
                #((reference_output.color_code != output.color_code) && !(reference_output.color_code.to_s.in?(["", "FFFFFF"]) && output.color_code.to_s.in?(["", "FFFFFF"]))) ||
                reference_output.color_priority != output.color_priority

              # Valeurs differentes
              @outputs_differences[organization.id] << { organization_id: guw_model_organization_id,
                                        guw_model_id: guw_model.id,
                                        reference_id: reference_output.id,
                                        element_id: output.id,
                                        column_name: "Sortie",
                                        column_value: output.name, nature: "Configuration différente"
              }
            end
          else
            #l'attribut n'existe pas dans la référence
            @outputs_differences[organization.id] << { organization_id: guw_model_organization_id,
                                      guw_model_id: guw_model.id,
                                      reference_id: nil,
                                      element_id: output.id,
                                      column_name: "Sortie",
                                      column_value: output.name,
                                      nature: "Sortie en trop par rapport à la référence"
            }
          end
        end
        # Pour voir si s'il ya des attributs manquants dans le module de taille concerné
        diff_outputs_name = @reference_guw_model_outputs.all.map(&:name) - guw_model.guw_outputs.all.map(&:name)
        unless diff_outputs_name.empty?
          diff_outputs = @reference_guw_model_outputs.where(name: diff_outputs_name)
          diff_outputs.each do |output|
            @outputs_differences[organization.id] << { organization_id: guw_model_organization_id,
                                      guw_model_id: guw_model.id,
                                      reference_id: output.id,
                                      element_id: nil,
                                      column_name: "Sortie",
                                      column_value: output.name,
                                      nature: "Sortie manquante dans le module de Taille"
            }
          end
        end


        #=============================== Les COEFFICIENTS et COEFFICIENT-ELEMENTS  ===============================#

        # guw_model.guw_coefficients.each do |coefficient|
        #   reference_coefficient = @reference_guw_model_coefficients.where(name: coefficient.name).first
        #   if reference_coefficient
        #     # identique_coefficient = @reference_guw_model_coefficients.where(name: coefficient.name, coefficient_type: coefficient.coefficient_type,
        #     #                                                                  coefficient_calc: coefficient.coefficient_calc,
        #     #                                                                  allow_intermediate_value: coefficient.allow_intermediate_value,
        #     #                                                                  deported: coefficient.deported, description: coefficient.description,
        #     #                                                                  allow_comments: coefficient.allow_comments).first
        #     if reference_coefficient.name.to_s != coefficient.name.to_s ||
        #         reference_coefficient.coefficient_type.to_s != coefficient.coefficient_type.to_s ||
        #         reference_coefficient.coefficient_calc.to_s != coefficient.coefficient_calc.to_s ||
        #         !reference_coefficient.allow_intermediate_value !=  !coefficient.allow_intermediate_value ||
        #         !reference_coefficient.deported != !coefficient.deported ||
        #         reference_coefficient.description.to_s !=  coefficient.description.to_s ||
        #         !reference_coefficient.allow_comments !=  !coefficient.allow_comments
        #
        #       # Coefficient avec le même nom, mais Valeurs differentes
        #       @coefficients_differences << { organization_id: guw_model_organization_id,
        #                                      guw_model_id: guw_model.id,
        #                                      reference_id: reference_coefficient.id,
        #                                      element_id: coefficient.id, column_name: "Coefficient", model_name: "Guw::GuwCoefficient",
        #                                      column_value: coefficient.name, nature: "Configuration différente"
        #       }
        #     end
        #
        #     #=====================  COEFFICIENT-ELEMENTS  ===================================
        #     coefficient_elements = coefficient.guw_coefficient_elements
        #     reference_coefficient_elements = reference_coefficient.guw_coefficient_elements
        #     # Si le coefficient existe dans ce module de Taille, On verifie les elements de coefficients
        #     reference_coefficient.guw_coefficient_elements.each do |reference_coefficient_element|
        #       # On verifie si le coefficient-element existe avec le même nom / puis avec la même configuration
        #       coefficient_element = coefficient_elements.where(name: reference_coefficient_element.name).first
        #
        #       if coefficient_element  # L'élement de coefficient existe
        #         # identique_coefficient_element = coefficient_elements.where(name: reference_coefficient_element.name,
        #         #                                                            value: reference_coefficient_element.value,
        #         #                                                            display_order: reference_coefficient_element.display_order,
        #         #                                                            min_value: reference_coefficient_element.min_value,
        #         #                                                            max_value: reference_coefficient_element.max_value,
        #         #                                                            default_value: reference_coefficient_element.default_value,
        #         #                                                            description: reference_coefficient_element.description,
        #         #                                                            default: reference_coefficient_element.default,
        #         #                                                            color_code: reference_coefficient_element.color_code,
        #         #                                                            color_priority: reference_coefficient_element.color_priority).first
        #         #if identique_coefficient_element.nil?
        #         if (coefficient_element.name.to_s != reference_coefficient_element.name.to_s ||
        #            coefficient_element.value.to_f != reference_coefficient_element.value.to_f ||
        #            coefficient_element.display_order.to_i != reference_coefficient_element.display_order.to_i ||
        #            coefficient_element.min_value.to_f != reference_coefficient_element.min_value.to_f ||
        #            coefficient_element.max_value.to_f != reference_coefficient_element.max_value.to_f ||
        #            coefficient_element.default_value.to_f != reference_coefficient_element.default_value.to_f ||
        #            coefficient_element.description.to_s != reference_coefficient_element.description.to_s ||
        #            !coefficient_element.default != !reference_coefficient_element.default ||
        #            coefficient_element.color_code.to_s != reference_coefficient_element.color_code.to_s ||
        #            coefficient_element.color_priority.to_i != reference_coefficient_element.color_priority.to_i)
        #
        #
        #           # Coefficient-Element avec le même nom, mais Configuration differente
        #           @coefficient_elements_differences << { organization_id: guw_model_organization_id,
        #                                                  guw_model_id: guw_model.id,
        #                                                  reference_id: reference_coefficient_element.id,
        #                                                  element_id: coefficient_element.id,
        #                                                  column_name: "Element de Coefficient",
        #                                                  column_value: coefficient_element.name,
        #                                                  model_name: "Guw::GuwCoefficientElement",
        #                                                  nature: "Configuration différente"
        #           }
        #         end
        #       else
        #         # L'element de coefficient n'existe pas dans le module de Taille
        #         @coefficient_elements_differences << { organization_id: guw_model_organization_id,
        #                                                guw_model_id: guw_model.id,
        #                                                reference_id: reference_coefficient_element.id,
        #                                                element_id: nil,
        #                                                column_name: "Element de Coefficient",
        #                                                column_value: nil,
        #                                                model_name: "Guw::GuwCoefficientElement",
        #                                                nature: "L'élément de coefficient n'existe pas dans ce module"
        #                                              }
        #       end
        #
        #       # Puis on vérifie les élements de coefficient qui sont en trop dans ce module de Taille
        #       diff_coefficient_elements_name =  coefficient_elements.map(&:name) - reference_coefficient_elements.map(&:name)
        #       unless diff_coefficient_elements_name.empty?
        #         diff_coefficient_elements = coefficient_elements.where(name: diff_coefficient_elements_name)
        #         diff_coefficient_elements.each do |diff_coefficient_elt|
        #           @coefficient_elements_differences << {  organization_id: guw_model_organization_id,
        #                                                   guw_model_id: guw_model.id,
        #                                                   reference_id: nil,
        #                                                   element_id: diff_coefficient_elt.id,
        #                                                   column_name: "Element de Coefficient",
        #                                                   column_value: diff_coefficient_elt.name,
        #                                                   model_name: "Guw::GuwCoefficientElement",
        #                                                   nature: "L'élément de coefficient n'existe pas dans la référence"
        #                                               }
        #         end
        #       end
        #     end
        #
        #   else #le Coefficient n'existe pas dans la référence
        #     @coefficients_differences << { organization_id: guw_model_organization_id,
        #                                    guw_model_id: guw_model.id,
        #                                    reference_id: nil,
        #                                    element_id: coefficient.id,
        #                                    column_name: "Coefficient",
        #                                    column_value: coefficient.name,
        #                                    model_name: "Guw::GuwCoefficient",
        #                                    nature: "Coefficient en trop par rapport à la référence"
        #     }
        #   end
        # end
        # # Pour voir si s'il ya des coefficients manquants dans le module de taille concerné
        # diff_coefficients_name = @reference_guw_model_coefficients.map(&:name) - guw_model.guw_coefficients.map(&:name)
        # unless diff_coefficients_name.empty?
        #   diff_coefficients = @reference_guw_model_coefficients.where(name: diff_coefficients_name)
        #   diff_coefficients.each do |coefficient|
        #     @coefficients_differences << { organization_id: guw_model_organization_id,
        #                                    guw_model_id: guw_model.id,
        #                                    reference_id: coefficient.id,
        #                                    element_id: nil,
        #                                    column_name: "Coefficient",
        #                                    column_value: coefficient.name,
        #                                    nature: "Coefficient manquant dans le module de Taille"
        #     }
        #   end
        # end


        #=============================== Les GUW-TYPES  ===============================#

        # Pour voir si s'il ya des Guw-types manquants dans le module de taille concerné
        diff_guw_types_name = @reference_guw_model_types.all.map(&:name) - guw_model.guw_types.all.map(&:name)
        unless diff_guw_types_name.empty?
          diff_guw_types = @reference_guw_model_types.where(name: diff_guw_types_name)
          diff_guw_types.each do |guw_type|
            @guw_types_differences[organization.id] << { organization_id: guw_model_organization_id,
                                        guw_model_id: guw_model.id,
                                        reference_id: guw_type.id,
                                        element_id: nil,
                                        column_name: "Type d'UO",
                                        column_value: guw_type.name,
                                        nature: "Type d'UO manquant dans le module de Taille"
            }
          end
        end

        # voir les differences
         guw_model.guw_types.each do |guw_type|
          reference_guw_type = @reference_guw_model_types.where(name: guw_type.name).first

          guw_type_guw_complexities = guw_type.guw_complexities
          guw_type_guw_type_complexities = guw_type.guw_type_complexities.order("display_order asc")

          if reference_guw_type.nil?
            #l'attribut n'existe pas dans la référence
            @guw_types_differences[organization.id] << { organization_id: guw_model_organization_id,
                                        guw_model_id: guw_model.id,
                                        reference_id: nil,
                                        element_id: guw_type.id,
                                        column_name: "Type d'UO",
                                        column_value: guw_type.name,
                                        nature: "Type d'UO en trop par rapport à la référence"
            }
           # la reference existe
          else
            # identique_guw_type = @reference_guw_model_types.where(name: guw_type.name,
            #                                                       attribute_type: guw_type.attribute_type,
            #                                                       description: guw_type.description,
            #                                                       allow_quantity: guw_type.allow_quantity,
            #                                                       allow_retained: guw_type.allow_retained,
            #                                                       allow_complexity: guw_type.allow_complexity,
            #                                                       allow_criteria: guw_type.allow_criteria,
            #                                                       display_threshold: guw_type.display_threshold,
            #                                                       is_default: guw_type.is_default,
            #                                                       color_code: guw_type.color_code,
            #                                                       color_priority: guw_type.color_priority,
            #                                                       allow_line_color: guw_type.allow_line_color).first
            if reference_guw_type.name != guw_type.name ||
                reference_guw_type.attribute_type != guw_type.attribute_type ||
                reference_guw_type.description.to_s != guw_type.description.to_s ||
                !reference_guw_type.allow_quantity != !guw_type.allow_quantity ||
                !reference_guw_type.allow_retained != !guw_type.allow_retained ||
                !reference_guw_type.allow_complexity != !guw_type.allow_complexity ||
                !reference_guw_type.allow_criteria != !guw_type.allow_criteria ||
                !reference_guw_type.display_threshold != !guw_type.display_threshold ||
                !reference_guw_type.is_default != !guw_type.is_default ||
                reference_guw_type.color_code != guw_type.color_code ||
                reference_guw_type.color_priority != guw_type.color_priority ||
                !reference_guw_type.allow_line_color != !guw_type.allow_line_color

              # Valeurs differentes
              @guw_types_differences[organization.id] << { organization_id: guw_model_organization_id,
                                          guw_model_id: guw_model.id,
                                          reference_id: reference_guw_type.id,
                                          element_id: guw_type.id,
                                          column_name: "Type d'UO",
                                          column_value: guw_type.name,
                                          nature: "Configuration différente"
              }
            end



            #=============================== La MATRICE par GUW-TYPE : que si la référence existe ===============================#
            reference_guw_type_complexities = reference_guw_type.guw_complexities

            # simple / moyen / complexe
            # guw_type.guw_complexities.order("display_order asc").each do |guw_cplx|
            #   guw_complexity = guw_cplx
            #
            #   reference_guw_cplx = reference_guw_type_complexities.where(name: guw_cplx).first
            #
            #   #== Pour voir s'il ya des Guw-types-complexities manquants dans le module de taille concerné
            #   diff_guw_type_complexities_name = reference_guw_type_complexities.all.map(&:name) - guw_type.guw_complexities.all.map(&:name)
            #   unless diff_guw_type_complexities_name.empty?
            #     diff_guw_type_complexities = reference_guw_type_complexities.where(name: diff_guw_type_complexities_name)
            #     diff_guw_type_complexities.each do |diff_guw_type_cplx|
            #       @guw_types_complexities_differences[organization.id] << {organization_id: guw_model_organization_id,
            #                                               guw_model_id: guw_model.id,
            #                                               guw_type_id: guw_type.id,
            #                                               reference_id: diff_guw_type_cplx.id,
            #                                               element_id: nil,
            #                                               column_name: "Seuil de complexité",
            #                                               column_value: diff_guw_type_cplx.name,
            #                                               nature: "Seuil de complexité manquant dans le module de Taille"
            #       }
            #     end
            #   end
            #
            #   #=== On verifie s'il existe dans la reference
            #   if reference_guw_cplx.nil?
            #     #la complexite n'existe pas dans la référence
            #     @guw_types_complexities_differences[organization.id] << {  organization_id: guw_model_organization_id,
            #                                               guw_model_id: guw_model.id,
            #                                               guw_type_id: guw_type.id,
            #                                               reference_id: nil,
            #                                               element_id: guw_cplx.id,
            #                                               column_name: "Seuil de complexité",
            #                                               column_value: guw_cplx.name,
            #                                               nature: "Seuil de complexité en trop par rapport à la référence"
            #     }
            #   else  # la reference existe
            #     # identique_guw_type_cplx = reference_guw_type_complexities.where(name: guw_cplx.name,
            #     #                                                                 alias: guw_cplx.alias,
            #     #                                                                 weight: guw_cplx.weight,
            #     #                                                                 bottom_range: guw_cplx.bottom_range,
            #     #                                                                 top_range: guw_cplx.top_range,
            #     #                                                                 enable_value: guw_cplx.enable_value,
            #     #                                                                 display_order: guw_cplx.display_order,
            #     #                                                                 default_value: guw_cplx.default_value,
            #     #                                                                 weight_b: guw_cplx.weight_b).first
            #     if reference_guw_cplx.name != guw_cplx.name ||
            #         reference_guw_cplx.alias != guw_cplx.alias ||
            #         reference_guw_cplx.weight != guw_cplx.weight ||
            #         reference_guw_cplx.bottom_range.to_i != guw_cplx.bottom_range.to_i ||
            #         reference_guw_cplx.top_range.to_i != guw_cplx.top_range.to_i ||
            #         reference_guw_cplx.enable_value != guw_cplx.enable_value ||
            #         reference_guw_cplx.display_order != guw_cplx.display_order ||
            #         reference_guw_cplx.default_value.to_i != guw_cplx.default_value.to_i ||
            #         reference_guw_cplx.weight_b != guw_cplx.weight_b
            #
            #       # Valeurs differentes
            #       @guw_types_complexities_differences[organization.id] << {organization_id: guw_model_organization_id,
            #                                               guw_model_id: guw_model.id,
            #                                               reference_id: reference_guw_cplx.id,
            #                                               element_id: guw_cplx.id,
            #                                               column_name: "Seuil de complexité",
            #                                               column_value: guw_cplx.name,
            #                                               nature: "Configuration différente"}
            #     end
            #
            #     # ====   On compare les valeurs de la matrice  ====
            #
            #     guw_model_outputs.each do |guw_output|
            #
            #       reference_guw_output = @reference_guw_model_outputs.where(name: guw_output.name).first
            #
            #       if reference_guw_output
            #
            #         ##=== Ligne 1 : guw_output_complexity_initializations
            #         oci = Guw::GuwOutputComplexityInitialization.where(guw_complexity_id: guw_cplx.id,
            #                                                            guw_output_id: guw_output.id).first
            #
            #         reference_oci = Guw::GuwOutputComplexityInitialization.where(guw_complexity_id: reference_guw_cplx.id,
            #                                                                      guw_output_id: reference_guw_output.id).first
            #         if !oci.nil? && !reference_oci.nil?
            #           if oci.init_value.to_f != reference_oci.init_value.to_f
            #             # Differences
            #             @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                             guw_model_id: guw_model.id,
            #                                                             guw_type_id: guw_type.id,
            #                                                             reference_guw_type_id: reference_guw_type.id,
            #
            #                                                             reference_guw_output_id: reference_guw_output.id,
            #                                                             guw_output_id: guw_output.id,
            #                                                             class_name: "Guw::GuwOutputComplexityInitialization",
            #                                                             coefficient_name: "Valeur initiale (Σ)",
            #                                                             element_id: oci.id,
            #                                                             reference_id: reference_oci.id,
            #                                                             guw_complexity_id: guw_cplx.id,
            #                                                             reference_guw_complexity_id: reference_guw_cplx.id,
            #                                                             column_name: "Un (1)",
            #                                                             column_value: oci.init_value,
            #                                                             reference_column_value: reference_oci.init_value,
            #                                                             nature: "Valeur d'initialisation différente" }
            #           end
            #         end
            #
            #
            #         ##===== Ligne 2
            #         oc = Guw::GuwOutputComplexity.where(guw_complexity_id: guw_cplx.id, guw_output_id: guw_output.id).first
            #
            #         reference_oc = Guw::GuwOutputComplexity.where(guw_complexity_id: reference_guw_cplx.id,
            #                                                       guw_output_id: reference_guw_output.id).first
            #         if !oc.nil? && !reference_oc.nil?
            #           if oc.value.to_f != reference_oc.value.to_f
            #             # Differences
            #             @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                             guw_model_id: guw_model.id,
            #                                                             guw_type_id: guw_type.id,
            #                                                             reference_guw_type_id: reference_guw_type.id,
            #                                                             reference_guw_output_id: reference_guw_output.id,
            #                                                             guw_output_id: guw_output.id,
            #                                                             class_name: "Guw::GuwOutputComplexity",
            #                                                             coefficient_name: "Valeur initiale (Σ)",
            #                                                             element_id: oc.id,
            #                                                             reference_id: reference_oc.id,
            #                                                             guw_complexity_id: guw_cplx.id,
            #                                                             reference_guw_complexity_id: reference_guw_cplx.id,
            #                                                             column_name: "UO CPLX",
            #                                                             column_value: oc.value,
            #                                                             reference_column_value: reference_oc.value,
            #                                                             nature: "Valeur différente" }
            #           end
            #         end
            #
            #
            #         ##===== Ligne Sorties / Sorties
            #         reference_got = Guw::GuwOutputType.where(guw_model_id: @reference_guw_model.id,
            #                                                  guw_output_id: reference_guw_output.id,
            #                                                  guw_type_id: reference_guw_type.id).first
            #
            #         got = Guw::GuwOutputType.where(guw_model_id: guw_model.id,
            #                                        guw_output_id: guw_output.id,
            #                                        guw_type_id: guw_type.id).first
            #
            #         if !got.nil? && !reference_got.nil?
            #           if got.display_type != reference_got.display_type
            #             # Differences sur le mode d'affichage des resultats
            #             @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                             guw_model_id: guw_model.id,
            #                                                             guw_type_id: guw_type.id,
            #                                                             reference_guw_type_id: reference_guw_type.id,
            #                                                             reference_guw_output_id: reference_guw_output.id,
            #                                                             guw_output_id: guw_output.id,
            #                                                             class_name: "Guw::GuwOutputComplexity",
            #                                                             coefficient_name: "Valeur initiale (Σ)",
            #                                                             element_id: got.id,
            #                                                             reference_id: reference_got.id,
            #                                                             guw_complexity_id: guw_cplx.id,
            #                                                             reference_guw_complexity_id: reference_guw_cplx.id,
            #                                                             column_name: guw_output.name,
            #                                                             column_value: got.display_type,
            #                                                             reference_column_value: reference_got.display_type,
            #                                                             nature: "Mode d'affichage différente" }
            #           end
            #
            #           guw_model_outputs.each do |aguw_output|
            #
            #             reference_aguw_output =  @reference_guw_model_outputs.where(name: aguw_output.name).first
            #
            #             oa = Guw::GuwOutputAssociation.where( guw_complexity_id: guw_complexity.id,
            #                                                   guw_output_associated_id: aguw_output.id,
            #                                                   guw_output_id: guw_output.id).first
            #
            #             reference_oa = Guw::GuwOutputAssociation.where( guw_complexity_id: reference_guw_cplx.id,
            #                                                             guw_output_associated_id: reference_aguw_output.id,
            #                                                             guw_output_id: reference_guw_output.id).first
            #
            #             if oa && reference_oa
            #               if oa.value != reference_oa.value
            #                 # Differences sur le mode d'affichage des resultats
            #                 @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                                 guw_model_id: guw_model.id,
            #                                                                 guw_type_id: guw_type.id,
            #                                                                 reference_guw_type_id: reference_guw_type.id,
            #                                                                 reference_guw_output_id: reference_guw_output.id,
            #                                                                 guw_output_id: guw_output.id,
            #                                                                 class_name: "Guw::GuwOutputAssociation",
            #                                                                 coefficient_name: "Valeur initiale (Σ)",
            #                                                                 element_id: oa.id,
            #                                                                 reference_id: reference_oa.id,
            #                                                                 guw_complexity_id: guw_cplx.id,
            #                                                                 reference_guw_complexity_id: reference_guw_cplx.id,
            #                                                                 column_name: aguw_output.name,
            #                                                                 column_value: oa.value,
            #                                                                 reference_column_value: reference_oa.value,
            #                                                                 nature: "Mode de calcul des sorties différente" }
            #               end
            #             end
            #
            #           end
            #         end
            #
            #         ##===== Ligne Coefficient (avec Elements de coefficient) / Sorties
            #         guw_model.guw_coefficients.each do |guw_coefficient|
            #           reference_guw_coefficient = @reference_guw_model_coefficients.where(name: guw_coefficient.name).first
            #
            #           guw_coefficient_elements = guw_coefficient.guw_coefficient_elements
            #           reference_guw_coefficient_elements = reference_guw_coefficient.guw_coefficient_elements
            #
            #           # guw_complexity_coefficient_elements = {}
            #           # guw_type.guw_complexity_coefficient_elements.each do |gcce|
            #           # end
            #
            #           guw_coefficient_elements.each do |guw_coefficient_element|
            #
            #             reference_guw_coefficient_element = reference_guw_coefficient_elements.where(name: guw_coefficient_element.name).first
            #             ref_guw_complexity = reference_guw_type_complexities.where(name: guw_coefficient_element.guw_complexity.name).first
            #
            #             reference_guw_coefficient_element = reference_guw_coefficient_elements.where(guw_complexity_id: (ref_guw_complexity.id rescue nil),
            #                                                                                          guw_coefficient_element_id: reference_guw_coefficient_element.id,
            #                                                                                          guw_output_id: reference_guw_output.id).first
            #
            #             if reference_guw_coefficient_element
            #               if guw_coefficient_element.value != reference_guw_coefficient_element.value
            #                 # Differences entre coefficient element / Sorties
            #                 @guw_types_complexities_coefficients_outputs_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                                 guw_model_id: guw_model.id,
            #                                                                 guw_type_id: guw_type.id,
            #                                                                 reference_guw_type_id: reference_guw_type.id,
            #                                                                 reference_guw_output_id: reference_guw_output.id,
            #                                                                 guw_output_id: guw_output.id,
            #                                                                 class_name: "Guw::GuwComplexityCoefficientElement",
            #                                                                 coefficient_name: guw_coefficient.name,
            #                                                                 element_id: guw_coefficient_element.id,
            #                                                                 reference_id: reference_guw_coefficient_element.id,
            #                                                                 guw_complexity_id: guw_cplx.id,
            #                                                                 reference_guw_complexity_id: reference_guw_cplx.id,
            #                                                                 column_name: guw_coefficient_element.name,
            #                                                                 column_value: guw_coefficient_element.value,
            #                                                                 reference_column_value: reference_guw_coefficient_element.value,
            #                                                                 nature: "Valeur différente entre #{guw_coefficient_element.name} / #{guw_output.name}" }
            #               end
            #             end
            #           end
            #         end
            #       end
            #     end
            #   end
            # end


            #=== Fin Gestion Matrice des Attributs : Seuil de complexité des Attributs
            reference_guw_type_guw_type_complexities = reference_guw_type.guw_type_complexities.order("display_order asc")

            # if guw_type.allow_criteria == true
            #
            #   # Les valeur de seuil de complexité des attributs manquantes dans le type d'UO
            #   # Pour voir si s'il ya des complexités des attributs manquants dans le module de taille concerné
            #   diff_type_complexities_name = reference_guw_type_guw_type_complexities.all.map(&:name) - guw_type_guw_type_complexities.all.map(&:name)
            #
            #   unless diff_type_complexities_name.empty?
            #     diff_type_complexities = reference_guw_type_guw_type_complexities.where(name: diff_type_complexities_name)
            #     diff_type_complexities.each do |type_complexity|
            #       @attributes_type_complexities_differences[organization.id] << {organization_id: guw_model_organization_id,
            #                                                     guw_model_id: guw_model.id,
            #                                                     guw_type_id: guw_type.id,
            #                                                     reference_guw_type_id: reference_guw_type.id,
            #                                                     reference_id: type_complexity.id,
            #                                                     element_id: type_complexity.id,
            #                                                     column_name: "Seuil de complexité des attributs",
            #                                                     column_value: type_complexity.value,
            #                                                     nature: "Seuil d'attribut manquant dans le module de Taille"}
            #     end
            #   end
            #
            #   # Comparaison avec la référence
            #   guw_type_guw_type_complexities.each do |type_complexity|
            #
            #     reference_type_complexity = reference_guw_type_guw_type_complexities.where(name: type_complexity.name).first
            #
            #     if reference_type_complexity.nil?
            #       #Seuil de complexité des attributs n'existe pas dans la référence
            #       @attributes_type_complexities_differences[organization.id] << {organization_id: guw_model_organization_id,
            #                                                     guw_model_id: guw_model.id,
            #                                                     reference_id: nil,
            #                                                     element_id: type_complexity.id,
            #                                                     column_name: "Seuil de complexité des attributs",
            #                                                     column_value: type_complexity.value,
            #                                                     nature: "Seuil n'existe pas dans  la référence"}
            #     else
            #         # identique_reference_type_complexity = reference_guw_type_guw_type_complexities.where(name: type_complexity.name,
            #         #                                                                                      description: type_complexity.description,
            #         #                                                                                      value: type_complexity.value,
            #         #                                                                                      display_order: type_complexity.display_order).first
            #       if reference_type_complexity.name != type_complexity.name ||
            #           reference_type_complexity.description.to_s != type_complexity.description.to_s ||
            #           reference_type_complexity.value != type_complexity.value ||
            #           reference_type_complexity.display_order != type_complexity.display_order
            #
            #         # Valeurs differentes
            #         @attributes_type_complexities_differences[organization.id] << {organization_id: guw_model_organization_id,
            #                                                       guw_type_id: guw_type.id,
            #                                                       reference_guw_type_id: reference_guw_type.id,
            #                                                       guw_model_id: guw_model.id,
            #                                                       reference_id: reference_type_complexity.id,
            #                                                       element_id: type_complexity.id,
            #                                                       column_name: "Seuil de complexité des attributs",
            #                                                       column_value: type_complexity.value,
            #                                                       nature: "Configuration différente" }
            #       end
            #
            #
            #       # === On compare les valeurs de la matrice de seuils de complexité des attributs
            #       guw_model_attributes.order("name ASC").each do |guw_attribute|
            #         reference_guw_attribute = @reference_guw_model_attributes.where(name: guw_attribute.name).first
            #
            #         if reference_guw_attribute
            #           gat = Guw::GuwAttributeType.where(guw_type_id: guw_type.id, guw_attribute_id: guw_attribute.id).first
            #           reference_gat = Guw::GuwAttributeType.where(guw_type_id: reference_guw_type.id, guw_attribute_id: reference_guw_attribute.id).first
            #
            #           ac = Guw::GuwAttributeComplexity.where(guw_attribute_id: guw_attribute.id,
            #                                                  guw_type_id: guw_type,
            #                                                  guw_type_complexity_id: type_complexity.id).first
            #
            #           reference_ac = Guw::GuwAttributeComplexity.where(guw_attribute_id: reference_guw_attribute.id,
            #                                                            guw_type_id: reference_guw_type.id,
            #                                                            guw_type_complexity_id: reference_type_complexity.id).first
            #
            #           if ac && reference_ac
            #             if (ac.bottom_range != reference_ac.bottom_range) || (ac.top_range != reference_ac.top_range) ||
            #                (ac.value != reference_ac.value) ||  (ac.value_b != reference_ac.value_b) || (ac.enable_value != reference_ac.enable_value)
            #               # au moins une des valeur est différente
            #               @attributes_type_complexities_matrix_differences[organization.id] << { organization_id: guw_model_organization_id,
            #                                                               guw_model_id: guw_model.id,
            #                                                               guw_type_id: guw_type.id,
            #                                                               guw_attribute_id: guw_attribute.id,
            #                                                               type_complexity_id: type_complexity.id,
            #                                                               reference_guw_type_id: reference_guw_type.id,
            #                                                               reference_guw_output_id: nil,
            #                                                               guw_output_id: nil,
            #                                                               class_name: "Guw::GuwAttributeComplexity",
            #                                                               coefficient_name: nil,
            #                                                               element_id: type_complexity.id,
            #                                                               reference_id: reference_type_complexity.id,
            #                                                               guw_type_complexity_id: type_complexity.id,
            #                                                               reference_guw_type_complexity_id: reference_type_complexity.id,
            #                                                               column_name: "Seuil de complexité des attributs",
            #                                                               column_value: nil,
            #                                                               reference_column_value: nil,
            #                                                               nature: "Valeur différente entre #{guw_attribute.name} / #{type_complexity.name}" }
            #
            #             end
            #           end
            #
            #
            #         end
            #       end
            #     end
            #   end
            # end


          end  #=========== FIN AFFICHAGE DIFFERENCES par GUW-TYPE PAR RAPPORT A LA REFERENCE ==============================#
        end  # end guw_type
      end  # end each guw_model
    end

  end


  def import_project_areas
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      # Remove exract data
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_app = ProjectArea.new(name: row[0].value, description: row[1].value,organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_areas")
  end

  def import_project_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_app = ProjectCategory.new(name: row[0].value, description: row[1].value,organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_categories")
  end

  def import_platform_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_app = PlatformCategory.new(name: row[0].value, description: row[1].value,organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-platform_categories")
  end

  def import_acquisition_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_app = AcquisitionCategory.new(name: row[0].value, description: row[1].value, organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-acquisition_categories")
  end

  def import_project_profile
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    tab_warning_messages = ""
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?

          new_profile = OrganizationProfile.where(name: row[0].value, organization_id: @organization.id).first
          if new_profile
            tab_warning_messages << " \n\n #{new_profile.name} : #{I18n.t(:warning_already_exist)}"
          else
            new_profile = OrganizationProfile.new(name: row[0].value, description: row[1].value, cost_per_hour: row[2].value, organization_id: @organization.id)
            unless new_profile.save
              tab_error << index + 1
            end
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    flash[:warning] = tab_warning_messages
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_profile")
  end


  # Import Organization's Providers
  def import_providers
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_provider = Provider.new(name: row[0].value, organization_id: @organization.id)
          unless new_provider.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-providers")
  end

  def export_project_areas
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_project_area = @organization.project_areas
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    organization_project_area.each_with_index do |project_area, index|
      worksheet.add_cell(index + 1, 0, project_area.name)
      worksheet.add_cell(index + 1, 1, project_area.description)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Project_Area-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def export_acquisition_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_acquisition_categories = @organization.acquisition_categories
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    organization_acquisition_categories.each_with_index do |ac, index|
      worksheet.add_cell(index + 1, 0, ac.name)
      worksheet.add_cell(index + 1, 1, ac.description)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Acquisition-Category-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def export_platform_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_platform_categories = @organization.platform_categories
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    organization_platform_categories.each_with_index do |ac, index|
      worksheet.add_cell(index + 1, 0, ac.name)
      worksheet.add_cell(index + 1, 1, ac.description)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Platform-Category-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def export_project_categories
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_project_categories = @organization.project_categories
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    organization_project_categories.each_with_index do |ac, index|
      worksheet.add_cell(index + 1, 0, ac.name)
      worksheet.add_cell(index + 1, 1, ac.description)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Project-Category-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def export_providers
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_providers = @organization.providers
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    organization_providers.each_with_index do |provider, index|
      worksheet.add_cell(index + 1, 0, provider.name)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Provider-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def polyval_export
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    case params[:MYonglet]
      when "ProjectCategory"
        polyval_var = ProjectCategory.where(organization_id: @organization.id)
      when "WorkElementType"
        polyval_var = WorkElementType.where(organization_id: @organization.id)
      when "OrganizationTechnology"
        polyval_var = OrganizationTechnology.where(organization_id: @organization.id)
      when "OrganizationProfile"
        polyval_var = OrganizationProfile.where(organization_id: @organization.id)
      else
        polyval_var = PlatformCategory.where(organization_id: @organization.id)
    end
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, params[:MYonglet] == "WorkElementType" || params[:MYonglet] == "OrganizationTechnology" ? I18n.t(:alias) : I18n.t(:description))
    params[:MYonglet] == "OrganizationProfile" ? worksheet.add_cell(0, 2, I18n.t(:cost_per_hour)) : toto = 42
    params[:MYonglet] == "WorkElementType" || params[:MYonglet] == "OrganizationTechnology" ? worksheet.add_cell(0, 2,I18n.t(:description)) : toto = 42
    params[:MYonglet] == "OrganizationTechnology" ? worksheet.add_cell(0, 3, I18n.t(:productivity_ratio)) : toto = 42
    polyval_var.each_with_index do |var, index|
      worksheet.add_cell(index + 1, 0,var.name)
      worksheet.add_cell(index + 1, 1, params[:MYonglet] == "WorkElementType" || params[:MYonglet] == "OrganizationTechnology" ? var.alias : var.description)
      params[:MYonglet] == "OrganizationProfile" ? worksheet.add_cell(index + 1, 2, var.cost_per_hour) : toto = 42
      params[:MYonglet] == "WorkElementType" || params[:MYonglet] == "OrganizationTechnology" ? worksheet.add_cell(index + 1, 2, var.description) : toto = 42
      params[:MYonglet] == "OrganizationTechnology" ? worksheet.add_cell(index + 1, 3, var.productivity_ratio) : toto = 42
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}_#{params[:MYonglet]}-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def import_appli
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []

    if params[:file].nil?
      flash[:error] = I18n.t(:route_flag_error_17)
    elsif !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0
          new_app = Application.new(name: (row.nil? ? flash[:error] = I18n.t(:route_flag_error_3) : row[0].value), organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end

    if tab_error.empty?
      flash[:notice] = I18n.t(:notice_wbs_activity_element_import_successful)
    else
      flash[:error] = I18n.t(:error_impor_groups, parameter: tab_error.join(", "))
    end
    redirect_to :back
  end


  def export_appli
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_appli = @organization.applications
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    organization_appli.each_with_index do |appli, index|
      worksheet.add_cell(index + 1, 0, appli.name)
    end
    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Applications-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def import_groups
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0]

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].value.nil?
          new_group = Group.new(name: row[0].value, description: row[1].value, organization_id: @organization.id)
          unless new_group.save
            tab_error << index + 1
          end
        elsif row[0].value.nil?
          tab_error << index + 1
        end
      end
      unless tab_error.empty?
        flash[:error] = I18n.t(:error_impor_groups, parameter: tab_error.join(", "))
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    flash[:notice] = I18n.t(:notice_wbs_activity_element_import_successful)
    redirect_to :back
  end

  def export_groups
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    organization_groups = @organization.groups
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    organization_groups.each_with_index do |group, index|
      worksheet.add_cell(index + 1, 0, group.name)
      worksheet.add_cell(index + 1, 1, group.description)
    end

    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Groups-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def my_preparse(my_hash)
    my_swap = my_hash[:mon]
    my_hash[:mon] = my_hash[:mday]
    my_hash[:mday] = my_swap
    return "#{my_hash[:mday]}/#{my_hash[:mon]}/#{my_hash[:year]}"
  end

  def generate_report_excel_estimations
    if params[:detail] == "checked"
      conditions = Hash.new

      @guw_model = Guw::GuwModel.find(params[:guw_model_id])
      @guw_model_guw_attributes = @guw_model.guw_attributes

      hash = @guw_model.orders
      hash.delete("Critères")
      hash.delete("Coeff. de Complexité")

      params[:report].each do |i|
        unless i.last.blank? or i.last.nil?
          conditions[i.first] = i.last
        end
      end

      if I18n.locale == :en
        start_date_hash = Date._parse(params[:report_date][:start_date])
        end_date_hash = Date._parse(params[:report_date][:end_date])

        start_date = my_preparse(start_date_hash)
        end_date = my_preparse(end_date_hash)
      else
        start_date = params[:report_date][:start_date]
        end_date = params[:report_date][:end_date]
      end

      @organization = @current_organization
      check_if_organization_is_image(@organization)

      current_organization_projects = @organization.projects

      tmp1 = current_organization_projects.where(creator_id: current_user.id,
                                                 is_model: false,
                                                 private: true).all

      if params[:report_date][:start_date].blank? || params[:report_date][:end_date].blank?
        tmp2 = current_organization_projects.where(is_model: false, private: false).where(conditions).where("title like ?", "%#{params[:title]}%").all
      else
        tmp2 = current_organization_projects.where(is_model: false, private: false).where(conditions).where(start_date: (Time.parse(start_date)..Time.parse(end_date))).where("title like ?", "%#{params[:title]}%").all
      end

      @projects = (tmp1 + tmp2).uniq
      gap = 0

      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]

      header = [
          "-",
          "Nom du CDS",
          "Nom du fournisseur",
          "Nom de l'application",
          "Statut du devis",
          "Numéro de demande",
          "Service",
          "Prestation",
          "Localisation",
          I18n.t(:estimation),
          I18n.t(:version_number),
          I18n.t(:group),
          I18n.t(:selected),
          I18n.t(:name),
          "Type d'UO",
          I18n.t(:description),
          I18n.t(:quantity),
          I18n.t(:tracability),
          I18n.t(:cotation),
          "Coeff. de complexité"] + hash.sort_by { |k, v| v.to_f }.map{ |i| i.first }

      header.each_with_index do |val, index|
        worksheet.add_cell(0, index, val)
      end

      ind = 0
      @projects.each do |project|

        project.module_projects.each do |mp|

          @guw_unit_of_works = mp.guw_unit_of_works.where(guw_model_id: @guw_model.id).all

          @wbs_activity_module_project = mp.nexts.first
          unless @wbs_activity_module_project.nil?
            @wbs_activity = @wbs_activity_module_project.wbs_activity
          end

          # [@wbs_activity_wbs_activity_elements.select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten + ["TJM Moyen"]].each_with_index do |val, i|
          #   worksheet.add_cell(0, (20 + hash.size + @guw_model_guw_attributes.size + i), val)
          # end
          worksheet.change_row_bold(0,true)

          jj = 18 + @guw_model.guw_outputs.size + @guw_model.guw_coefficients.size


          @guw_unit_of_works.each_with_index do |guow, i|

            ind = i + 1

            if guow.off_line
              cplx = "HSAT"
            elsif guow.off_line_uo
              cplx = "HSUO"
            elsif guow.guw_complexity.nil?
              cplx = ""
            else
              cplx = guow.guw_complexity.name
            end

            worksheet.add_cell(ind, 1, project.organization)
            worksheet.add_cell(ind, 2, project.provider)
            worksheet.add_cell(ind, 3, project.application)
            worksheet.add_cell(ind, 4, project.estimation_status)
            worksheet.add_cell(ind, 5, project.request_number)
            worksheet.add_cell(ind, 6, project.project_area)
            worksheet.add_cell(ind, 7, project.acquisition_category)
            worksheet.add_cell(ind, 8, project.platform_category)
            worksheet.add_cell(ind, 9, project.title)
            worksheet.add_cell(ind, 10, project.version_number)
            worksheet.add_cell(ind, 11, guow.guw_unit_of_work_group.name)
            worksheet.add_cell(ind, 12, guow.selected ? 1 : 0)
            worksheet.add_cell(ind, 13, guow.name)
            worksheet.add_cell(ind, 14, (guow.guw_type.nil? ? '-' : guow.guw_type.name))
            worksheet.add_cell(ind, 15, guow.comments.to_s.gsub!(/[^a-zA-ZàâäôéèëêïîçùûüÿæœÀÂÄÔÉÈËÊÏÎŸÇÙÛÜÆŒ ]/, ''))
            worksheet.add_cell(ind, 16, guow.quantity)
            worksheet.add_cell(ind, 17, guow.tracking)
            worksheet.add_cell(ind, 18, cplx)
            worksheet.add_cell(ind, 19, guow.intermediate_weight)

            hash.sort_by { |k, v| v.to_f }.each_with_index do |i, j|
              if Guw::GuwCoefficient.where(name: i[0]).first.class == Guw::GuwCoefficient
                guw_coefficient = Guw::GuwCoefficient.where(name: i[0], guw_model_id: @guw_model.id).first
                unless guw_coefficient.nil?
                  unless guw_coefficient.guw_coefficient_elements.empty?
                    ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guow.id,
                                                                      guw_coefficient_id: guw_coefficient.id,
                                                                      module_project_id: mp.id).first

                    if guw_coefficient.coefficient_type == "Pourcentage"
                      worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                    elsif guw_coefficient.coefficient_type == "Coefficient"
                      worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                    else
                      worksheet.add_cell(ind, 20+j, ceuw.nil? ? '' : ceuw.guw_coefficient_element.nil? ? ceuw.percent : ceuw.guw_coefficient_element.name)
                    end
                  end
                end
              elsif Guw::GuwOutput.where(name: i[0]).first.class == Guw::GuwOutput
                guw_output = Guw::GuwOutput.where(name: i[0],
                                                  guw_model_id: @guw_model.id).first
                unless guow.guw_type.nil?
                  unless guw_output.nil?
                    v = (guow.size.nil? ? '' : (guow.size.is_a?(Numeric) ? guow.size : guow.size["#{guw_output.id}"].to_f.round(2)))
                    worksheet.add_cell(ind, 20 + j, v.to_s)
                  end
                end
              end
            end

            ii = 0
            @guw_model.guw_attributes.order("name ASC").each_with_index do |guw_attribute, i|
              guw_type = guow.guw_type
              guowa = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: guow.id,
                                                        guw_attribute_id: guw_attribute.id,
                                                        guw_type_id: guw_type.nil? ? nil : guw_type.id).first

              unless guowa.nil?
                gat = Guw::GuwAttributeType.where(guw_type_id: guw_type.id,
                                                  guw_attribute_id: guowa.guw_attribute_id).first
                worksheet.add_cell(ind, jj + ii, guowa.most_likely.nil? ? (gat.nil? ? "N/A" : gat.default_value.to_s) : guowa.most_likely)
                worksheet.add_cell(ind, jj + ii + 1, guowa.nil? ? '' : guowa.comments)
              else
                p "GUOWA is nil"
              end
              ii = ii + 2
            end

            ii = 0
            @guw_model.guw_attributes.each do |guw_attribute|
              worksheet.add_cell(0, jj + ii, guw_attribute.name)
              worksheet.add_cell(0, jj + ii + 1, "Commentaires")
              ii = ii + 2
            end

            unless @wbs_activity.nil?
              kk = header.size - @wbs_activity.wbs_activity_elements.select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten.size - 1 #-1 for TJM moyen

              @wbs_activity_ratio = @wbs_activity.wbs_activity_ratios.first
              @module_project_ratio_elements = @wbs_activity_module_project.get_module_project_ratio_elements(@wbs_activity_ratio, mp)
              @root_module_project_ratio_element = @module_project_ratio_elements.select{|i| i.root? }.first

              tjm_array = []

              calculator = Dentaku::Calculator.new

              @wbs_activity.wbs_activity_elements.select{|i| !i.root? }.each_with_index do |wbs_activity_element|

                guw_output_effort = Guw::GuwOutput.where(name: "Charge RTU (jh)", guw_model_id: @guw_model.id).first

                if guw_output_effort.nil?
                  guw_output_effort = Guw::GuwOutput.where(name: "Charge RIS (jh)", guw_model_id: @guw_model.id).first
                end
                guw_output_test = Guw::GuwOutput.where(name: "Assiette Test (jh)", guw_model_id: @guw_model.id).first

                mp_ratio_element = @module_project_ratio_elements.select { |mp_ratio_elt| mp_ratio_elt.wbs_activity_element_id == wbs_activity_element.id }.first

                begin

                  guw_output_effort_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"].to_f.round(2)))
                  guw_output_test_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_test.id}"].to_f.round(2)))

                  corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @wbs_activity_ratio.id, wbs_activity_element.id).first

                  final_formula = corresponding_ratio_elt.formula
                                      .gsub("RTU", guw_output_effort_value.to_s)
                                      .gsub("TEST", guw_output_test_value.to_s)
                                      .gsub('%', ' * 0.01 ')

                  value = calculator.evaluate(final_formula).to_f.round(3)
                rescue
                  value = 0
                end

                value_cost = value * mp_ratio_element.tjm.to_f

                tjm_array << mp_ratio_element.tjm.to_f

                worksheet.add_cell(ind, kk + ii, value.round(3))
                worksheet.add_cell(ind, kk + ii + 1, value_cost.round(3))
                ii = ii + 2
              end

              unless tjm_array.empty?
                worksheet.add_cell(ind, kk + ii, (tjm_array.inject(&:+) / tjm_array.size).round(3))
              end

            end

          end
        end
      end
    else

      conditions = Hash.new

      params[:report].each do |i|
        unless i.last.blank? or i.last.nil?
          conditions[i.first] = i.last
        end
      end

      if I18n.locale == :en
        start_date_hash = Date._parse(params[:report_date][:start_date])
        end_date_hash = Date._parse(params[:report_date][:end_date])

        start_date = my_preparse(start_date_hash)
        end_date = my_preparse(end_date_hash)
      else
        start_date = params[:report_date][:start_date]
        end_date = params[:report_date][:end_date]
      end

      @organization = @current_organization
      check_if_organization_is_image(@organization)

      @projects = @organization.projects.where(is_model: false)

      @fields_coefficients = {}
      @pfs = {}

      fields = @organization.fields
      ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
        begin
          if pf.field_id.in?(fields.map(&:id))
            if pf.project && pf.views_widget
              if pf.project_id == pf.views_widget.module_project.project_id
                @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
              else
                pf.delete
              end
            else
              pf.delete
            end
          else
            pf.delete
          end

        rescue
          #puts "erreur"
        end
      end

      fields.each do |f|
        @fields_coefficients[f.id] = f.coefficient
      end

      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]

      selected_inline_columns = update_selected_inline_columns(Project)

      @projects.each_with_index do |project, i|
        selected_inline_columns.each_with_index do |column, j|
          worksheet.add_cell(i, j, column_content_without_content_tag(@pfs, column, project, @fields_coefficients))
        end
      end

    end

    send_data(workbook.stream.string, filename: "export_estimations.xlsx", type: "application/vnd.ms-excel")

  end

  def generate_report_excel_detail

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    ind = 0

    @current_organization.projects.each do |project|

      module_project = project.module_projects.select{|i| i.pemodule.alias == "guw" }.first

      unless module_project.nil?
        @guw_model = module_project.guw_model
        @wbs_activity_module_project = module_project.nexts.first
        unless @wbs_activity_module_project.nil?
          @wbs_activity = @wbs_activity_module_project.wbs_activity
        end

        unless @wbs_activity.nil?
          @component = current_component
          @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: module_project,
                                                        guw_model_id: @guw_model)

          hash = @guw_model.orders
          hash.delete("Critères")
          hash.delete("Coeff. de Complexité")

          # @guw_unit_of_works.each do |i|
          #   if i.nil?
          #     i.destroy
          #   end
          # end

          header = [
              "",
              "Nom du CDS",
              "Nom du fournisseur",
              "Nom de l'application",
              "Statut du devis",
              "Numéro de demande",
              "Service",
              "Prestation",
              "Localisation",
              I18n.t(:estimation),
              I18n.t(:version_number),
              I18n.t(:group),
              I18n.t(:selected),
              I18n.t(:name),
              "Type d'UO",
              I18n.t(:description),
              I18n.t(:quantity),
              I18n.t(:tracability),
              I18n.t(:cotation),
              "Coeff. de complexité"] + hash.sort_by { |k, v| v.to_f }.map{|i| i.first } +
                @guw_model.guw_attributes.order("name ASC").map{|i| [i.name, "Commentaires"] }.flatten +
                (@wbs_activity.nil? ? [] : @wbs_activity.wbs_activity_elements.select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten) +
                ["TJM Moyen"]

          header.each_with_index do |val, index|
            worksheet.add_cell(0, index, val)
          end

          worksheet.change_row_bold(0,true)

          jj = 18 + @guw_model.guw_outputs.size + @guw_model.guw_coefficients.size

          @guw_unit_of_works.each_with_index do |guow, i|

            ind = ind + 1

            if guow.off_line
              cplx = "HSAT"
            elsif guow.off_line_uo
              cplx = "HSUO"
            elsif guow.guw_complexity.nil?
              cplx = ""
            else
              cplx = guow.guw_complexity.name
            end

            worksheet.add_cell(ind, 1, project.organization.nil? ? '' : project.organization.name)
            worksheet.add_cell(ind, 2, project.provider.nil? ? '' : project.provider.name)
            worksheet.add_cell(ind, 3, project.application.nil? ? '' : project.application.name)
            worksheet.add_cell(ind, 4, project.estimation_status.nil? ? '' : project.estimation_status.name)
            worksheet.add_cell(ind, 5, project.request_number)
            worksheet.add_cell(ind, 6, project.project_area)
            worksheet.add_cell(ind, 7, project.acquisition_category)
            worksheet.add_cell(ind, 8, project.platform_category)
            worksheet.add_cell(ind, 9, project.title)
            worksheet.add_cell(ind, 10, project.version_number)
            worksheet.add_cell(ind, 11, guow.guw_unit_of_work_group.nil? ? '-' : guow.guw_unit_of_work_group.name)
            worksheet.add_cell(ind, 12, guow.selected ? 1 : 0)
            worksheet.add_cell(ind, 13, guow.name)
            worksheet.add_cell(ind, 14, (guow.guw_type.nil? ? '-' : guow.guw_type.name))
            worksheet.add_cell(ind, 15, guow.comments.to_s.gsub!(/[^a-zA-ZàâäôéèëêïîçùûüÿæœÀÂÄÔÉÈËÊÏÎŸÇÙÛÜÆŒ ]/, ''))
            worksheet.add_cell(ind, 16, guow.quantity)
            worksheet.add_cell(ind, 17, guow.tracking)
            worksheet.add_cell(ind, 18, cplx)
            worksheet.add_cell(ind, 19, guow.intermediate_weight)

            hash.sort_by { |k, v| v.to_f }.each_with_index do |i, j|
              if Guw::GuwCoefficient.where(name: i[0]).first.class == Guw::GuwCoefficient
                guw_coefficient = Guw::GuwCoefficient.where(name: i[0], guw_model_id: @guw_model.id).first
                unless guw_coefficient.nil?
                  unless guw_coefficient.guw_coefficient_elements.empty?
                    unless module_project.nil?
                      ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guow.id,
                                                                        guw_coefficient_id: guw_coefficient.id,
                                                                        module_project_id: module_project.id).first

                      if guw_coefficient.coefficient_type == "Pourcentage"
                        worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                      elsif guw_coefficient.coefficient_type == "Coefficient"
                        worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                      else
                        worksheet.add_cell(ind, 20+j, ceuw.nil? ? '' : ceuw.guw_coefficient_element.nil? ? ceuw.percent : ceuw.guw_coefficient_element.name)
                      end
                    end
                  end
                end
              elsif Guw::GuwOutput.where(name: i[0]).first.class == Guw::GuwOutput
                guw_output = Guw::GuwOutput.where(name: i[0],
                                                  guw_model_id: @guw_model.id).first
                unless guow.guw_type.nil?
                  unless guw_output.nil?
                    v = (guow.size.nil? ? '' : (guow.size.is_a?(Numeric) ? guow.size : guow.size["#{guw_output.id}"].to_f.round(2)))
                    worksheet.add_cell(ind, 20 + j, v.to_s)
                  end
                end
              end
            end

            ii = 0
            @guw_model.guw_attributes.order("name ASC").each_with_index do |guw_attribute, i|
              guw_type = guow.guw_type
              guowa = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: guow.id,
                                                        guw_attribute_id: guw_attribute.id,
                                                        guw_type_id: guw_type.nil? ? nil : guw_type.id).first

              unless guowa.nil?
                gat = Guw::GuwAttributeType.where(guw_type_id: guw_type.id,
                                                  guw_attribute_id: guowa.guw_attribute_id).first
                worksheet.add_cell(ind, jj + ii, guowa.most_likely.nil? ? (gat.nil? ? "N/A" : gat.default_value.to_s) : guowa.most_likely)
                worksheet.add_cell(ind, jj + ii + 1, guowa.nil? ? '' : guowa.comments)
              else
                p "GUOWA is nil"
              end
              ii = ii + 2
            end

            ii = 0
            @guw_model.guw_attributes.each do |guw_attribute|
              worksheet.add_cell(0, jj + ii, guw_attribute.name)
              worksheet.add_cell(0, jj + ii + 1, "Commentaires")
              ii = ii + 2
            end

            kk = header.size - (@guw_model.guw_attributes.order("name ASC").map{|i| [i.name, "Commentaires"] }.flatten).size - (@wbs_activity.nil? ? 0 : @wbs_activity.wbs_activity_elements.select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten.size) - 1 #-1 for TJM moyen
            @wbs_activity_ratio = @wbs_activity.nil? ? nil : @wbs_activity.wbs_activity_ratios.first
            unless @wbs_activity_module_project.nil?
              @module_project_ratio_elements = @wbs_activity_module_project.get_module_project_ratio_elements(@wbs_activity_ratio, current_component)
              @root_module_project_ratio_element = @module_project_ratio_elements.select{|i| i.root? }.first

              tjm_array = []

              calculator = Dentaku::Calculator.new

              @wbs_activity.wbs_activity_elements.select{|i| !i.root? }.each_with_index do |wbs_activity_element|

                guw_output_effort = Guw::GuwOutput.where(name: "Charge RTU (jh)", guw_model_id: @guw_model.id).first

                if guw_output_effort.nil?
                  guw_output_effort = Guw::GuwOutput.where(name: "Charge RIS (jh)", guw_model_id: @guw_model.id).first
                end
                guw_output_test = Guw::GuwOutput.where(name: "Assiette Test (jh)", guw_model_id: @guw_model.id).first

                mp_ratio_element = @module_project_ratio_elements.select { |mp_ratio_elt| mp_ratio_elt.wbs_activity_element_id == wbs_activity_element.id }.first

                begin
                  guw_output_effort_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"].to_f.round(2)))
                  guw_output_test_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_test.id}"].to_f.round(2)))

                  corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @wbs_activity_ratio.id, wbs_activity_element.id).first

                  final_formula = corresponding_ratio_elt.formula
                                      .gsub("RTU", guw_output_effort_value.to_s)
                                      .gsub("TEST", guw_output_test_value.to_s)
                                      .gsub('%', ' * 0.01 ')

                  value = calculator.evaluate(final_formula).to_f.round(3)
                rescue
                  value = 0
                end

                value_cost = value * mp_ratio_element.tjm.to_f

                tjm_array << mp_ratio_element.tjm.to_f

                worksheet.add_cell(ind, kk + ii, value.round(3))
                worksheet.add_cell(ind, kk + ii + 1, value_cost.round(3))
                ii = ii + 2
              end

              unless tjm_array.empty?
                worksheet.add_cell(ind, kk + ii, (tjm_array.inject(&:+) / tjm_array.size).round(3))
              end
            end
          end
        end
      end
    end

    send_data(workbook.stream.string, filename: "#{@current_organization.name}-#{@guw_model.name}-#{Time.now.strftime('%Y-%m-%d-%H-%M')}.xlsx", type: "application/vnd.ms-excel")
  end

  def report
    @organization = Organization.find(params[:organization_id])
    set_page_title I18n.t(:report, parameter: @organization)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), I18n.t(:report) => ""
    check_if_organization_is_image(@organization)
  end

  def authorization
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:authorisation, parameter: @organization)

    @groups = @organization.groups

    @organization_permissions = Permission.order('name').select{ |i| i.object_type == "organization_super_admin_objects" }
    @global_permissions = Permission.order('name').select{ |i| i.object_type == "general_objects" }
    @permission_projects = Permission.order('name').select{ |i| i.object_type == "project_dependencies_objects" }
    @modules_permissions = Permission.order('name').select{ |i| i.object_type == "module_objects" }
    @master_permissions = Permission.order('name').select{ |i| i.is_master_permission }

    @permissions_classes_organization = @organization_permissions.map(&:category).uniq.sort
    @permissions_classes_globals = @global_permissions.map(&:category).uniq.sort
    @permissions_classes_projects = @permission_projects.map(&:category).uniq.sort
    @permissions_classes_masters = @master_permissions.map(&:category).uniq.sort
    @permissions_classes_modules = @modules_permissions.map(&:category).uniq.sort

    @project_security_levels = @organization.project_security_levels
  end

  def setting
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:Parameter, parameter: @organization)

    @technologies = @organization.organization_technologies
    @fields = @organization.fields
    @work_element_types = @organization.work_element_types

    @organization_profiles = @organization.organization_profiles

    @organization_group = @organization.groups
    @estimation_models = Project.where(organization_id: @organization.id, :is_model => true) #@organization.projects.where(:is_model => true)

    ProjectField.where(project_id: @estimation_models.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(@fields.map(&:id))
          if pf.project && pf.views_widget
            if pf.project_id != pf.views_widget.module_project.project_id
              pf.delete
            end
          else
            pf.delete
          end
        else
          pf.delete
        end
      rescue
        #puts "erreur"
      end
    end

  end

  def setting_demand
    @organization = Organization.find(params[:organization_id])
    @demands = Demand.where(organization_id: @organization.id).all
    @demands_statuses = DemandStatus.where(organization_id: @organization.id).all
    @demands_type = DemandType.where(organization_id: @organization.id).all
    @livrables = Livrable.where(organization_id: @organization.id).all
    @livrable = Livrable.where(organization_id: @organization.id)
  end

  def module_estimation
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), I18n.t(:label_estimation_modules) => ""
    set_page_title I18n.t(:module ,parameter: @organization)

    @guw_models = @organization.guw_models.order("name asc")
    @skb_models = @organization.skb_models.order("name asc")
    @wbs_activities = @organization.wbs_activities.order("name asc")
    @technologies = @organization.organization_technologies.order("name asc")
  end

  def users
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:spec_users, parameter: @organization)
  end

  def estimations
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:spec_estimations, parameter: @organization.to_s)

    if params[:filter_version].present?
      @filter_version = params[:filter_version]
    else
      @filter_version = '4'
    end

    @object_per_page = (current_user.object_per_page || 10)

    if params[:min].present? && params[:max].present?
      @min = params[:min].to_i
      @max = params[:max].to_i
    else
      @min = 0
      @max = @object_per_page
    end

    if session[:sort_action].blank?
      session[:sort_action] = "true"
    end

    if session[:sort_column].blank?
      session[:sort_column] = "start_date"
    end

    if session[:sort_order].blank?
      session[:sort_order] ="desc"
    end

    @sort_action = params[:sort_action].blank? ? session[:sort_action] : params[:sort_action]
    @sort_column = params[:sort_column].blank? ? session[:sort_column] : params[:sort_column]
    @sort_order = params[:sort_order].blank? ? session[:sort_order] : params[:sort_order]

    @search_column = session[:search_column]
    @search_value = session[:search_value]
    #@search_hash =  {} #session[:search_hash] || {}
    @search_hash = (params['search'].blank? ? session[:search_hash] : params['search'])
    @search_hash ||=  {}
    @search_string = ""
    final_results = []

    # Pour garder le tri même lors du raffraichissement de la page
    projects = @organization.projects.where(:is_model => [nil, false])
    organization_projects = get_sorted_estimations(@organization.id, projects, @sort_column, @sort_order, @search_hash)

    res = []
    organization_projects.each do |p|
      if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
        res << p
      end

    end

    @projects = res[@min..@max].nil? ? [] : res[@min..@max-1]

    last_page = res.paginate(:page => 1, :per_page => @object_per_page).total_pages
    @last_page_min = (last_page.to_i-1) * @object_per_page
    @last_page_max = @last_page_min + @object_per_page

    if params[:is_last_page] == "true" || (@min == @last_page_min)
      @is_last_page = "true"
    else
      @is_last_page = "false"
    end

    session[:sort_column] = @sort_column
    session[:sort_order] = @sort_order
    session[:sort_action] = @sort_action
    session[:is_last_page] = @is_last_page
    session[:search_column] = @search_column
    session[:search_value] = @search_value
    session[:search_hash] = @search_hash

    # @projects = check_for_projects(@min, @max)
    # @projects = check_for_projects(@min, @object_per_page)

    @fields_coefficients = {}
    @pfs = {}

    fields = @organization.fields
    ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(fields.map(&:id))
          if pf.project && pf.views_widget
            if pf.project_id == pf.views_widget.module_project.project_id
              @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
            else
              pf.delete
            end
          else
            pf.delete
          end
        else
          pf.delete
        end

      rescue
        #puts "erreur"
      end
    end

    fields.each do |f|
      @fields_coefficients[f.id] = f.coefficient
    end
  end

  private def check_for_projects(start_number, desired_size)

    organization_estimations = @organization.organization_estimations

    if start_number == 0
      projects = organization_estimations.limit(desired_size)
    else
      project = organization_estimations.all[start_number-1] #|| organization_estimations.last
      begin
        projects = project.next_ones_by_date(desired_size)
      rescue
        projects = []
      end
    end

    # Ability.new(user, organization, project, nb_project = 1, estimation_view = false, first_iteration=false)
    @current_ability = Ability.new(current_user, @current_organization, projects, desired_size, true)

    last_project = projects.last
    result = []
    i = 0
    # nb_total = 0

    estimations_abilities = lambda do |projects|
      i = 0
      while result.size < desired_size && !projects.empty? do
        organization_project = projects[i]
        # nb_total += 1

        if organization_project.nil?
          break
        else
          project = organization_project.project
          if can?(:see_project, project, estimation_status_id: organization_project.estimation_status_id)
            result << project
            last_project = organization_project
          end
          i += 1
        end
      end

      # if nb_total >= 12100
      #   puts "Test"
      #   puts "nb_total = #{nb_total}"
      # end

      if (result.size == desired_size) || (projects.size < desired_size) || last_project.nil?
        return result
      else
        next_projects = last_project.next_ones_by_date(desired_size)
        unless next_projects.all.empty?
          @current_ability = Ability.new(current_user, @current_organization, next_projects, desired_size, true)
          i = 0
          estimations_abilities.call(next_projects)
        end
      end
    end

    estimations_abilities.call(projects)

    result
  end


  # New organization from image
  def new_organization_from_image
  end

  # Method that execute the duplication: duplicate estimation model for organization
  def execute_duplication(project_id, new_organization_id)
    user = current_user

    #begin
    old_prj = Project.find(project_id)
    new_organization = Organization.find(new_organization_id)

    new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
    new_prj.organization_id = new_organization_id
    new_prj.title = old_prj.title
    new_prj.description = old_prj.description
    new_estimation_status = new_organization.estimation_statuses.where(copy_id: new_prj.estimation_status_id).first
    new_estimation_status_id = new_estimation_status.nil? ? nil : new_estimation_status.id
    new_prj.estimation_status_id = new_estimation_status_id

    if old_prj.is_model
      new_prj.is_model = true
    else
      new_prj.is_model = false
    end

    if new_prj.save
      old_prj.save #Original project copy number will be incremented to 1

      old_prj.applications.each do |application|
        app = Application.where(name: application.name, organization_id: new_organization.id).first
        ap = ApplicationsProjects.create(application_id: app.id,
                                         project_id: new_prj.id)
        # new_prj.application_id = app.id
        # new_prj.save(validate: false)
        ap.save
      end


      #Managing the component tree : PBS
      pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

      # For PBS
      new_prj_components = pe_wbs_product.pbs_project_elements
      new_prj_components.each do |new_c|
        new_ancestor_ids_list = []
        new_c.ancestor_ids.each do |ancestor_id|
          ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
          new_ancestor_ids_list.push(ancestor_id)
        end
        new_c.ancestry = new_ancestor_ids_list.join('/')
        new_c.save
      end

      #Update the project securities for the current user who create the estimation from model
      #if params[:action_name] == "create_project_from_template"
      if old_prj.is_model
        unless old_prj.creator.nil?
          creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
          unless creator_securities.nil?
            creator_securities.update_attribute(:user_id, user.id)
          end
        end
      end
      #Other project securities for groups
      new_prj.project_securities.where('group_id IS NOT NULL').each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        new_group = new_organization.groups.where(copy_id: project_security.group_id).first
        if new_security_level.nil? || new_group.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id, group_id: new_group.id)
        end
      end

      #Other project securities for users
      new_prj.project_securities.where('user_id IS NOT NULL').each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        if new_security_level.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id)
        end
      end

      # For ModuleProject associations
      old_prj.module_projects.group(:id).each do |old_mp|
        new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

        # ModuleProject Associations for the new project
        old_mp.associated_module_projects.each do |associated_mp|
          new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
          new_mp.associated_module_projects << new_associated_mp
        end

        ##========================== NEW =======
        # Wbs activity create module_project ratio elements
        old_mp.module_project_ratio_elements.each do |old_mp_ratio_elt|
          mp_ratio_element = old_mp_ratio_elt.dup
          mp_ratio_element.module_project_id = new_mp.id
          mp_ratio_element.copy_id = old_mp_ratio_elt.id

          # pbs
          pbs = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first
          pbs_id = pbs.nil? ? nil : pbs.id
          mp_ratio_element.pbs_project_element_id = pbs_id

          #wbs_activity
          old_wbs_activity_id = old_mp_ratio_elt.wbs_activity_ratio.wbs_activity_id
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: old_wbs_activity_id).first

          if new_wbs_activity.nil?
            mp_ratio_element.wbs_activity_element_id = nil
            mp_ratio_element.wbs_activity_ratio_id = nil
            mp_ratio_element.wbs_activity_ratio_element_id = nil
          else
            # wbs_activity_element
            new_wbs_activity_element = new_wbs_activity.wbs_activity_elements.where(copy_id: old_mp_ratio_elt.wbs_activity_element_id).first
            new_wbs_activity_element_id = new_wbs_activity_element.nil? ? nil : new_wbs_activity_element.id
            mp_ratio_element.wbs_activity_element_id = new_wbs_activity_element_id

            # wbs_activity_ratio
            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: old_mp_ratio_elt.wbs_activity_ratio_id).first

            if new_wbs_activity_ratio.nil?
              mp_ratio_element.wbs_activity_ratio_id = nil
              mp_ratio_element.wbs_activity_ratio_element_id = nil
            else
              mp_ratio_element.wbs_activity_ratio_id = new_wbs_activity_ratio.id

              # wbs_activity_ratio_element
              new_wbs_activity_ratio_element = new_wbs_activity_ratio.wbs_activity_ratio_elements.where(copy_id: old_mp_ratio_elt.wbs_activity_ratio_element_id).first
              wbs_activity_ratio_element_id = new_wbs_activity_ratio_element.nil? ? nil : new_wbs_activity_ratio_element.id

              mp_ratio_element.wbs_activity_ratio_element_id = wbs_activity_ratio_element_id
            end
          end

          mp_ratio_element.save
        end

        new_mp_ratio_elements = new_mp.module_project_ratio_elements
        new_mp_ratio_elements.each do |mp_ratio_element|
          #mp_ratio_element.pbs_project_element_id = new_prj_components.where(copy_id: mp_ratio_element.pbs_project_element_id).first.id

          #unless mp_ratio_element.is_root?
          new_ancestor_ids_list = []
          mp_ratio_element.ancestor_ids.each do |ancestor_id|
            ancestor = new_mp_ratio_elements.where(copy_id: ancestor_id).first
            if ancestor
              ancestor_id = ancestor.id
              new_ancestor_ids_list.push(ancestor_id)
            end
          end
          mp_ratio_element.ancestry = new_ancestor_ids_list.join('/')
          #end
          mp_ratio_element.save
        end
        ### End wbs_activity


        # For SKB-Input
        old_mp.skb_inputs.each do |skbi|
          new_skb_model = new_organization.skb_models.where(copy_id: skbi.skb_model_id).first
          if new_skb_model
            Skb::SkbInput.create(skb_model_id: new_skb_model.id, data: skbi.data, processing: skbi.processing, retained_size: skbi.retained_size,
                                 organization_id: new_organization_id, module_project_id: new_mp.id)
          end
        end

        # For KB-Inputs
        old_mp.kb_inputs.each do |kbi|
          new_kb_model = new_organization.kb_models.where(copy_id: kbi.kb_model_id).first
          if new_kb_model
            kb_input = Kb::KbInput.where(kb_model_id: new_kb_model.id, module_project_id: new_mp.copy_id).first
            if kb_input.nil?
              kb_input = kbi.dup
              kb_input.save
            end

            kb_input.update_attributes(kb_model_id: new_kb_model.id, organization_id: new_organization_id, module_project_id: new_mp.id)
          end
        end

        # For Expert-Judgment Input Estimates
        old_mp.ej_instance_estimates.each do |ie|
          new_expert_judgment_model = new_organization.expert_judgement_instances.where(copy_id: ie.expert_judgement_instance_id).first

          if new_expert_judgment_model
            # Update the module_project expert_judgement_instance_id
            new_mp.expert_judgement_instance_id = new_expert_judgment_model.id

            new_ej_instance_estimate = ie.dup  ##ExpertJudgement::InstanceEstimate.create
            new_ej_instance_estimate.expert_judgement_instance_id = new_expert_judgment_model.id
            new_ej_instance_estimate.module_project_id = new_mp.id
            new_pbs = new_prj_components.where(copy_id: ie.pbs_project_element_id).first
            begin
              new_ej_instance_estimate.pbs_project_element_id = new_pbs.id
            rescue
              new_ej_instance_estimate.pbs_project_element_id = nil
            end
            new_ej_instance_estimate.save
            new_mp.save
          end
        end

        old_mp.staffing_custom_data.each do |staffing_custom_data|
          new_staffing_model = new_organization.staffing_models.where(copy_id: staffing_custom_data.staffing_model_id).first
          if new_staffing_model
            new_staffing_custom_data = staffing_custom_data.dup
            new_staffing_custom_data.staffing_model_id = new_staffing_model.id
            new_staffing_custom_data.module_project_id = new_mp.id

            new_pbs = new_prj_components.where(copy_id: staffing_custom_data.pbs_project_element_id).first
            begin
              new_staffing_custom_data.pbs_project_element_id = new_pbs.id
            rescue
              new_staffing_custom_data.pbs_project_element_id = nil
            end
            new_staffing_custom_data.save

          end
        end

        # GeFactorDescription
        old_mp.ge_model_factor_descriptions.each do |factor_description|
          new_ge_model = new_organization.ge_models.where(copy_id: factor_description.ge_model_id).first
          if new_ge_model
            new_ge_factor = new_ge_model.ge_factors.where(copy_id: factor_description.ge_factor_id).first
            if new_ge_factor
              Ge::GeModelFactorDescription.create(ge_model_id: new_ge_model.id, ge_factor_id: new_ge_factor.id,
                                                  factor_alias: new_ge_factor.alias, description: factor_description.description,
                                                  module_project_id: new_mp.id, project_id: new_prj.id, organization_id: new_organization_id)
            end
          end
        end

        new_view = View.create(organization_id: new_organization_id, pemodule_id: new_mp.pemodule_id, name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "")
        # We have to copy all the selected view's widgets in a new view for the current module_project
        if old_mp.view
          old_mp_view_widgets = old_mp.view.views_widgets.all
          old_mp_view_widgets.each do |view_widget|
            new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
            new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
            widget_est_val = view_widget.estimation_value
            unless widget_est_val.nil?
              in_out = widget_est_val.in_out
              widget_pe_attribute_id = widget_est_val.pe_attribute_id
              unless new_view_widget_mp.nil?
                new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
                estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
                widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id,
                                                 name: view_widget.name, show_name: view_widget.show_name,
                                                 show_tjm: view_widget.show_tjm,
                                                 equation: view_widget.equation,
                                                 comment: view_widget.comment,
                                                 is_kpi_widget: view_widget.is_kpi_widget,
                                                 kpi_unit: view_widget.kpi_unit,
                                                 icon_class: view_widget.icon_class, color: view_widget.color,
                                                 show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                 width: view_widget.width, height: view_widget.height, position: view_widget.position,
                                                 position_x: view_widget.position_x, position_y: view_widget.position_y)
                #===

                # #Update KPI Widget aquation
                unless view_widget.equation.empty?
                  ["A", "B", "C", "D", "E"].each do |letter|
                    unless view_widget.equation[letter].nil?

                      new_array = []
                      est_val_id = view_widget.equation[letter].first
                      mp_id = view_widget.equation[letter].last

                      begin
                        new_mpr = new_prj.module_projects.where(copy_id: mp_id).first
                        new_mpr_id = new_mpr.id
                        begin
                          new_est_val_id = new_mpr.estimation_values.where(copy_id: est_val_id).first.id
                        rescue
                          new_est_val_id = nil
                        end
                      rescue
                        new_mpr_id = nil
                      end

                      new_array << new_est_val_id
                      new_array << new_mpr_id

                      widget_copy.equation[letter] = new_array
                    end
                  end
                  widget_copy.save
                end

                #===

                pf = ProjectField.where(project_id: new_prj.id, views_widget_id: view_widget.id).first
                unless pf.nil?
                  new_field = new_organization.fields.where(copy_id: pf.field_id).first
                  pf.views_widget_id = widget_copy.id
                  pf.field_id = new_field.nil? ? nil : new_field.id
                  pf.save
                end
              end
            end
          end
        end
        #update the new module_project view
        new_mp.update_attribute(:view_id, new_view.id)
        ###end

        #Update the Unit of works's groups
        new_mp.guw_unit_of_work_groups.each do |guw_group|
          new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
          new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id

          #technology
          new_technology = new_organization.organization_technologies.where(copy_id: guw_group.organization_technology_id).first
          new_technology_id = new_technology.nil? ? nil : new_technology.id

          guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id, organization_technology_id: new_technology_id,
                                      project_id: new_prj.id, organization_id: new_organization_id)

          # Update the group unit of works and attributes
          guw_group.guw_unit_of_works.each do |guw_uow|
            new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
            new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

            #PBS
            new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
            new_pbs_id = new_pbs.nil? ? nil : new_pbs.id

            # GuwModel
            new_guw_model = new_organization.guw_models.where(copy_id: guw_uow.guw_model_id).first
            new_guw_model_id = new_guw_model.nil? ? nil : new_guw_model.id

            # guw_work_unit
            if !new_guw_model.nil?
              new_guw_work_unit = new_guw_model.guw_work_units.where(copy_id: guw_uow.guw_work_unit_id).first
              new_guw_work_unit_id = new_guw_work_unit.nil? ? nil : new_guw_work_unit.id

              #Type
              new_guw_type = new_guw_model.guw_types.where(copy_id: guw_uow.guw_type_id).first
              new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

              #Complexity
              if !guw_uow.guw_complexity_id.nil? && !new_guw_type.nil?
                new_complexity = new_guw_type.guw_complexities.where(copy_id: guw_uow.guw_complexity_id).first
                new_complexity_id = new_complexity.nil? ? nil : new_complexity.id
              else
                new_complexity_id = nil
              end

            else
              new_guw_work_unit_id = nil
              new_guw_type_id = nil
              new_complexity_id = nil
            end

            #Technology
            uow_new_technology = new_organization.organization_technologies.where(copy_id: guw_uow.organization_technology_id).first
            uow_new_technology_id = uow_new_technology.nil? ? nil : uow_new_technology.id

            guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id, guw_model_id: new_guw_model_id,
                                      guw_type_id: new_guw_type_id, guw_work_unit_id: new_guw_work_unit_id, guw_complexity_id: new_complexity_id,
                                      organization_technology_id: uow_new_technology_id,
                                      project_id: new_prj.id, organization_id: new_organization_id)
          end
        end

        # UOW-INPUTS
        # new_mp.uow_inputs.each do |uo|
        #   new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
        #   new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
        #   uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
        # end

        new_mp_pemodule_attributes = new_mp.pemodule.pe_attributes
        if new_mp.pemodule.alias == "guw"
          new_mp_pemodule_attributes = new_mp_pemodule_attributes.where(guw_model_id: new_mp.guw_model_id)
        elsif new_mp.pemodule.alias == "operation" #Operation
          new_mp_pemodule_attributes = new_mp_pemodule_attributes.where(operation_model_id: new_mp.operation_model_id)

        elsif new_mp && new_mp.pemodule.alias == "effort_breakdown"

          # Update module_project wbs_activity_id and wbs_activity_ratio_id and WBS-ACTIVITY-INPUTS
          old_wbs_activity_id = new_mp.wbs_activity_id
          old_wbs_activity_ratio_id = new_mp.wbs_activity_ratio_id
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: old_wbs_activity_id).first

          unless new_wbs_activity.nil?
            new_mp.wbs_activity_id = new_wbs_activity.id

            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: old_wbs_activity_ratio_id).first

            if new_wbs_activity_ratio.nil?
              new_mp.wbs_activity_ratio_id =  nil
            else
              new_mp.wbs_activity_ratio_id = new_wbs_activity_ratio.id
            end
            new_mp.save(valide: false)

            new_mp.wbs_activity_inputs.where(wbs_activity_id: old_wbs_activity_id).each do |activity_input|
              activity_input.wbs_activity_id = new_wbs_activity.id

              wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: activity_input.wbs_activity_ratio_id).first
              if wbs_activity_ratio.nil?
                activity_input.wbs_activity_ratio_id = nil
              else
                activity_input.wbs_activity_ratio_id = wbs_activity_ratio.id
              end

              activity_input.save(validate: false)
            end
          end
        end

        ["input", "output"].each do |io|
          #puts io
          new_mp_pemodule_attributes.each do |attr|
            old_prj.pbs_project_elements.each do |old_component|
              new_prj_components.each do |new_component|
                ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                unless ev.nil?

                  ["low", "most_likely", "high", "probable"].each do |level|

                    old_level_value = ev.send("string_data_#{level}")
                    new_level_value = ev.send("string_data_#{level}")

                    if new_level_value.nil?
                      ev.send("string_data_#{level}=", new_level_value)
                    else
                      # old_pbs_level_value = old_level_value.delete(old_component.id.to_i)
                      # new_level_value[new_component.id.to_i] = old_pbs_level_value

                      if level == "probable" && new_mp.pemodule.alias == "effort_breakdown"

                        old_pbs_level_value = old_level_value[old_component.id.to_i]
                        new_level_value[new_component.id.to_i] = old_pbs_level_value
                        new_level_value.delete(old_component.id)

                        new_pbs_level_value = new_level_value[new_component.id]

                        if new_pbs_level_value.nil?
                          ev.send("string_data_#{level}=", new_level_value)
                        else
                          if new_pbs_level_value.is_a?(Float)
                            ev.send("string_data_#{level}=", new_level_value)
                          elsif new_pbs_level_value.is_a?(Hash)

                            temp_values = Hash.new
                            temp_values[new_component.id] = Hash.new

                            new_pbs_level_value.each do |element_id, values_hash|
                              #puts values_hash
                              new_mp_ratio = new_mp.wbs_activity_ratio
                              if new_mp_ratio.nil?
                                #puts "Ratio nul"
                              else
                                wbs_activity = new_mp_ratio.wbs_activity
                                new_element = new_mp.wbs_activity_elements.where(copy_id: element_id).first

                                if new_element
                                  temp_values[new_component.id][new_element.id] = values_hash
                                  profiles_hash = values_hash['profiles']
                                  temp_values[new_component.id][new_element.id]['profiles'] = Hash.new

                                  unless profiles_hash.blank? #profiles_hash.nil? && profiles_hash.empty?

                                    profiles_hash.each do |key, profile_values|
                                      old_profile_id = key.gsub('profile_id_', '')
                                      new_wbs_profiles = wbs_activity.organization_profiles

                                      unless new_wbs_profiles.nil?
                                        new_profile = new_wbs_profiles.where(copy_id: old_profile_id).first
                                        if new_profile
                                          temp_values[new_component.id][new_element.id]['profiles']["profile_id_#{new_profile.id}"] = Hash.new

                                          #wbs_activity.wbs_activity_ratios.each do |new_ratio|
                                            old_ratio_id = new_mp_ratio.copy_id #new_ratio.copy_id
                                            begin
                                              ratio_value = profile_values["ratio_id_#{old_ratio_id}"][:value]
                                            rescue
                                              ratio_value = nil
                                            end
                                            temp_values[new_component.id][new_element.id]['profiles']["profile_id_#{new_profile.id}"]["ratio_id_#{new_mp_ratio.id}"] = { value: ratio_value }
                                          #end
                                        else
                                          #puts "Profile nul"
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end

                            new_level_value[new_component.id] = temp_values[new_component.id]
                            ev.send("string_data_#{level}=", new_level_value)
                          end
                        end
                      else
                        #ev_level = new_level_value.delete(old_component.id)

                        new_level_value[new_component.id.to_i] = old_level_value[old_component.id.to_i]
                        ev.send("string_data_#{level}=", new_level_value)

                        # case level
                        #   when "low"
                        #     ev_low = ev.string_data_low.delete(old_component.id)
                        #     ev.string_data_low[new_component.id.to_i] = ev_low
                        #   when "most_likely"
                        #     ev_most_likely = ev.string_data_most_likely.delete(old_component.id)
                        #     ev.string_data_most_likely[new_component.id.to_i] = ev_most_likely
                        #   when "high"
                        #     ev_high = ev.string_data_high.delete(old_component.id)
                        #     ev.string_data_high[new_component.id.to_i] = ev_high
                        #   when "probable"
                        #     ev_probable = ev.string_data_probable.delete(old_component.id)
                        #     ev.string_data_probable[new_component.id.to_i] = ev_probable
                        # end

                      end
                    end

                  end  ###

                  #puts "hello"
                  #puts "hello2"

                  # ev_low = ev.string_data_low.delete(old_component.id)
                  # ev_most_likely = ev.string_data_most_likely.delete(old_component.id)
                  # ev_high = ev.string_data_high.delete(old_component.id)
                  # ev_probable = ev.string_data_probable.delete(old_component.id)
                  #
                  # puts "low = #{ ev.string_data_low}"
                  # puts "ml = #{ ev.string_data_most_likely}"
                  # puts "high = #{ ev.string_data_high}"
                  # puts "probable = #{ ev.string_data_probable}"

                  # ev.string_data_low[new_component.id.to_i] = ev.string_data_low[old_component.id.to_i]
                  # ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely[old_component.id.to_i]
                  # ev.string_data_high[new_component.id.to_i] = ev.string_data_high[old_component.id.to_i]
                  # ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable[old_component.id.to_i]

                  # ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
                  # ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
                  # ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
                  # ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id

                  # ev.string_data_low.delete(old_component.id)
                  # ev.string_data_most_likely.delete(old_component.id)
                  # ev.string_data_high.delete(old_component.id)
                  # ev.string_data_probable.delete(old_component.id)

                  # update ev attribute links (input attribute link from preceding module_project)

                  unless ev.estimation_value_id.nil?
                    project_id = new_prj.id
                    new_evs = EstimationValue.where(copy_id: ev.estimation_value_id).all
                    new_ev = new_evs.select { |est_v| est_v.module_project.project_id == project_id}.first
                    if new_ev
                      ev.estimation_value_id = new_ev.id
                    end
                  end

                  ev.save
                end
              end
            end
          end
        end
      end

    else
      new_prj = nil
    end

    new_prj
  end


  # Create New organization from selected image organization
  # Or duplicate current selected organization
  def create_organization_from_image
    authorize! :manage, Organization

    begin
      case params[:action_name]
      #Duplicate organization
      when "copy_organization"
        organization_image = Organization.find(params[:organization_id])

      #Create the organization from image organization
      when "new_organization_from_image"
        organization_image_id = params[:organization_image]
        if organization_image_id.nil?
          flash[:warning] = "Veuillez sélectionner une organisation image pour continuer"
        elsif params[:organization_name].empty?
          flash[:error] = "Le nom de l'organisation ne peut pas être vide"
          redirect_to :back and return
        else
          organization_image = Organization.find(organization_image_id)
          @organization_name = params[:organization_name]
          @firstname = params[:firstname]
          @lastname = params[:lastname]
          @email = params[:email]
          @login_name = params[:identifiant]
          @password = params[:password]
          if @password.empty?
            @password = SecureRandom.hex(8)
          end
          change_password_required = params[:change_password_required]
        end
      else
        flash[:error] = "Aucune organization sélectionnée"
        redirect_to :back and return
      end

      if organization_image.nil?
        flash[:warning] = "Veuillez sélectionner une organisation pour continuer"
      else

        organization_image.copy_in_progress = true
        organization_image.save

        #new_organization.transaction do
        ActiveRecord::Base.transaction do

          new_organization = organization_image.amoeba_dup

          if params[:action_name] == "new_organization_from_image"
            new_organization.name = @organization_name
          elsif params[:action_name] == "copy_organization"
            new_organization.description << "\n \n Cette organisation est une copie de l'organisation #{organization_image.name}."
            #new_organization.description << "\n #{I18n.l(Time.now)} : #{I18n.t(:organization_copied_by, username: current_user.name)}"
          end

          new_organization.is_image_organization = false

          if new_organization.save(validate: false)

            organization_image.save #Original organization copy number will be incremented to 1

            #Copy the organization estimation_statuses workflow and groups/roles
            new_estimation_statuses = new_organization.estimation_statuses
            new_estimation_statuses.each do |estimation_status|
              copied_status = EstimationStatus.find(estimation_status.copy_id)

              #Get the to_transitions for the Statuses Workflow
              copied_status.to_transition_statuses.each do |to_transition|
                new_to_transition = new_estimation_statuses.where(copy_id: to_transition.id).first
                unless new_to_transition.nil?
                  StatusTransition.create(from_transition_status_id: estimation_status.id, to_transition_status_id: new_to_transition.id)
                end
              end
            end

            #Get the estimation_statuses role / by group
            new_organization.project_security_levels.each do |project_security_level|
              project_security_level.estimation_status_group_roles.each do |group_role|
                new_group = new_organization.groups.where(copy_id: group_role.group_id).first
                estimation_status = new_organization.estimation_statuses.where(copy_id: group_role.estimation_status_id).first
                unless estimation_status.nil?
                  begin
                    group_role.update_attributes(organization_id: new_organization.id, estimation_status_id: estimation_status.id, group_id: new_group.id)
                  rescue
                    ###puts "erreur"
                  end
                end
              end
            end

            #Then copy the image organization estimation models
            if params[:action_name] == "new_organization_from_image"
              # Create a user in the Admin group of the new organization
              admin_user = User.new(first_name: @firstname, last_name: @lastname, login_name: @login_name, email: @email, password: @password, password_confirmation: @password, super_admin: false)
              # Add the user to the created organization
              admin_group = new_organization.groups.where(name: '*USER').first #first_or_create(name: "*USER", organization_id: new_organization.id, description: "Groupe créé par défaut dans l'organisation pour la gestion des administrateurs")
              unless admin_group.nil?
                admin_user.groups << admin_group
                admin_user.save
              end

            elsif params[:action_name] == "copy_organization"
              # add users to groups
              organization_image.groups.each do |group|
                new_group = new_organization.groups.where(copy_id: group.id).first
                unless new_group.nil?
                  new_group.users = group.users
                  new_group.save
                end
              end
            end

            # Copie des authorisations (Permissions sur l'organisation / Permissions globales / Permissions sur les modules)
            organization_image.groups.each do |group|
              new_group = new_organization.groups.where(copy_id: group.id).first
              unless new_group.nil?
                new_group.permissions = group.permissions
                new_group.save
              end
            end


            OrganizationsUsers.where(user_id: current_user.id, organization_id: new_organization.id).first_or_create!

            # Copy the WBS-Activities modules's Models instances
            organization_image.wbs_activities.each do |old_wbs_activity|
              new_wbs_activity = old_wbs_activity.amoeba_dup   #amoeba gem is configured in WbsActivity class model
              new_wbs_activity.organization_id = new_organization.id

              new_wbs_activity.transaction do
                if new_wbs_activity.save
                  old_wbs_activity.save  #Original WbsActivity copy number will be incremented to 1

                  #we also have to save to wbs_activity_ratio
                  old_wbs_activity.wbs_activity_ratios.each do |ratio|
                    ratio.save
                  end

                  # Update the new WBS organization_profiles association
                  # The WBS module's organization_profiles are copied from Amoeba in include_association
                  new_wbs_profiles = []
                  OrganizationProfilesWbsActivity.where(wbs_activity_id: new_wbs_activity.id).all.each do |wbs_profile|
                    new_organization_profile = new_organization.organization_profiles.where(copy_id: wbs_profile.organization_profile_id).last
                    unless new_organization_profile.nil?
                      new_wbs_profiles << new_organization_profile.id
                    end
                  end
                  new_wbs_activity.organization_profile_ids = new_wbs_profiles
                  new_wbs_activity.save

                  #get new WBS Ratio elements
                  new_wbs_activity_ratio_elts = []
                  new_wbs_activity.wbs_activity_ratios.each do |ratio|
                    ratio.wbs_activity_ratio_elements.each do |ratio_elt|
                      new_wbs_activity_ratio_elts << ratio_elt

                      #Update ratio elements profiles
                      ratio_elt.wbs_activity_ratio_profiles.each do |activity_ratio_profile|
                        new_organization_profile = new_organization.organization_profiles.where(copy_id: activity_ratio_profile.organization_profile_id).first
                        unless new_organization_profile.nil?
                          activity_ratio_profile.update_attribute(:organization_profile_id, new_organization_profile.id)
                        end
                      end
                    end

                    #Update Wbs-activity-ratio-varibales
                    old_ratio = old_wbs_activity.wbs_activity_ratios.where(id: ratio.copy_id).first
                    if old_ratio
                      old_ratio.wbs_activity_ratio_variables.each do |old_ratio_variable|
                        new_ratio_variable = old_ratio_variable.dup
                        new_ratio_variable.wbs_activity_ratio_id = ratio.id
                        new_ratio_variable.save
                      end
                    end

                  end

                  #Managing the component tree
                  old_wbs_activity_elements = old_wbs_activity.wbs_activity_elements.order('ancestry_depth asc')
                  old_wbs_activity_elements.each do |old_elt|
                    new_elt = old_elt.amoeba_dup
                    new_elt.wbs_activity_id = new_wbs_activity.id
                    new_elt.save#(:validate => false)

                    unless new_elt.is_root?
                      new_ancestor_ids_list = []
                      new_elt.ancestor_ids.each do |ancestor_id|
                        ancestor = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id)
                        unless ancestor.nil?
                          ancestor_id = ancestor.id
                          new_ancestor_ids_list.push(ancestor_id)
                        end
                      end
                      new_elt.ancestry = new_ancestor_ids_list.join('/')
                    end
                    corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
                      ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
                    end
                    new_elt.save(:validate => false)
                  end
                else
                  flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
                end
              end

              # Update all the new organization module_project's guw_model with the current guw_model
              wbs_activity_copy_id = old_wbs_activity.id
              new_organization.module_projects.where(wbs_activity_id: wbs_activity_copy_id).update_all(wbs_activity_id: new_wbs_activity.id)
            end


            # Copy the modules's Operation Models instances
            new_organization.operation_models.each do |operation_model|
              # Update all the new organization module_project's operation_model with the current operation_model
              operation_model_copy_id = operation_model.copy_id
              new_organization.module_projects.where(operation_model_id: operation_model_copy_id).update_all(operation_model_id: operation_model.id)

              # Terminate duplication
              operation_model.terminate_operation_model_duplication(new_organization_id = new_organization.id)
            end

            # Update the Expert Judgement modules's Models instances
            new_organization.expert_judgement_instances.each do |expert_judgment|
              # Update all the new organization module_project's guw_model with the current guw_model
              expert_judgment_copy_id = expert_judgment.copy_id
              new_organization.module_projects.where(expert_judgement_instance_id: expert_judgment_copy_id).update_all(expert_judgement_instance_id: expert_judgment.id)
            end


            # copy the organization's projects
            organization_image.projects.all.each do |project|
              #OrganizationDuplicateProjectWorker.perform_async(project.id, new_organization.id, current_user.id)
              new_template = execute_duplication(project.id, new_organization.id)
              unless new_template.nil?
                new_template.is_model = project.is_model
                new_template.save
              end
            end

            #update the project's ancestry
            new_organization.projects.all.each do |project|

              new_project_area = new_organization.project_areas.where(copy_id: project.project_area_id).first
              unless new_project_area.nil?
                project.project_area_id = new_project_area.id
              end

              new_project_category = new_organization.project_categories.where(copy_id: project.project_category_id).first
              unless new_project_category.nil?
                project.project_category_id = new_project_category.id
              end

              new_platform_category = new_organization.platform_categories.where(copy_id: project.platform_category_id).first
              unless new_platform_category.nil?
                project.platform_category_id = new_platform_category.id
              end

              new_acquisition_category = new_organization.acquisition_categories.where(copy_id: project.acquisition_category_id).first
              unless new_acquisition_category.nil?
                project.acquisition_category_id = new_acquisition_category.id
              end

              new_provider = new_organization.providers.where(copy_id: project.provider_id).first
              unless new_provider.nil?
                project.provider_id = new_provider.id
              end

              project.save

              unless project.original_model_id.nil?
                new_original_model = new_organization.projects.where(copy_id: project.original_model_id).first
                new_original_model_id = new_original_model.nil? ? nil : new_original_model.id
                project.original_model_id = new_original_model_id
                project.save
              end

              unless project.ancestry.nil?
                new_ancestor_ids_list = []
                project.ancestor_ids.each do |ancestor_id|
                  ancestor = new_organization.projects.where(copy_id: ancestor_id).first
                  unless ancestor.nil?
                    #ancestor_id = ancestor.id
                    new_ancestor_ids_list.push(ancestor.id)
                  end
                end
                project.ancestry = new_ancestor_ids_list.join('/')
                project.save
              end
            end

            # Update the modules's GE Models instances
            new_organization.ge_models.each do |ge_model|
              #Terminate the model duplication with the copie of the factors values
              ge_model.transaction do
                #Then copy the factor values
                ge_model.ge_factors.each do |factor|
                  #get the factor values for each factor of new model

                  # get the original factor from copy_id
                  parent_factor = Ge::GeFactor.find(factor.copy_id)
                  if parent_factor
                    parent_factor.ge_factor_values.each do |parent_factor_value|
                      new_factor_value =  parent_factor_value.dup
                      new_factor_value.ge_model_id = ge_model.id
                      new_factor_value.ge_factor_id = factor.id
                      new_factor_value.save
                    end
                  end
                end
              end

              # Update all the new organization module_project's ge_model with the current ge_model
              ge_copy_id = ge_model.copy_id
              new_organization.module_projects.where(ge_model_id: ge_copy_id).update_all(ge_model_id: ge_model.id)
            end

            # Update the modules's KB Models instances
            new_organization.kb_models.each do |kb_model|
              # Update all the new organization module_project's guw_model with the current guw_model
              kb_copy_id = kb_model.copy_id
              new_organization.module_projects.where(kb_model_id: kb_copy_id).update_all(kb_model_id: kb_model.id)
            end

            # Update the modules's Staffing Models instances
            new_organization.staffing_models.each do |staffing_model|
              # Update all the new organization module_project's guw_model with the current guw_model
              staffing_model_copy_id = staffing_model.copy_id
              module_projects_with_staffing = new_organization.module_projects.where(staffing_model_id: staffing_model_copy_id)
              new_organization.module_projects.where(staffing_model_id: staffing_model_copy_id).update_all(staffing_model_id: staffing_model.id)
            end


            # Copy the modules's GUW Models instances
            new_organization.guw_models.each do |guw_model|

              # Update all the new organization module_project's guw_model with the current guw_model
              guw_model_copy_id = guw_model.copy_id
              new_organization.module_projects.where(guw_model_id: guw_model_copy_id).update_all(guw_model_id: guw_model.id)

              ###### Replace the code below

              old_guw_model = Guw::GuwModel.find(guw_model.copy_id)
              if old_guw_model.nil?
                old_guw_model = guw_model
              end
              guw_model.terminate_guw_model_duplication(old_guw_model, true) #A modifier
            end

            sleep(15)

            if params[:action_name] == "copy_organization"
              description = "#{new_organization.description}" + "\n #{I18n.l(Time.now)} : #{I18n.t(:organization_copied_by, username: current_user.name)}"
              new_organization.description = description
              new_organization.copy_in_progress = false
              new_organization.save(validate: false)
            end

            organization_image.copy_in_progress = false
            organization_image.save(validate: false)

            flash[:notice] = I18n.t(:notice_organization_successful_created)
          else
            flash[:error] = I18n.t('errors.messages.not_saved.one', :resource => I18n.t(:organization))
          end
        end
      end

      respond_to do |format|
        flash[:notice] = "Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation."
        format.html { redirect_to organizationals_params_path and return }
        #format.js { render :js => "window.location.replace('/organizationals_params');"}
        ##format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès'); window.location.replace('/organizationals_params');"}
        #format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation.'); window.location.replace('/organizationals_params');"}

        format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation.');" and return }

        ##format.js { render 'layouts/flashes' }
      end

    rescue
      organization_image.update_attribute(:copy_in_progress, false)

      flash[:error] = "Une erreur est survenue lors de la création de la nouvelle organisation"
      respond_to do |format|
        format.html { redirect_to organizationals_params_path and return }
        format.js { render :js => "window.location.replace('/organizationals_params');"}
      end
    end

  end

  def new
    authorize! :create_organizations, Organization
    @organization = Organization.new
    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:new_organization) => ""
    @groups = @organization.groups
  end

  def edit
    #authorize! :edit_organizations, Organization
    authorize! :show_organizations, Organization

    set_page_title I18n.t(:organizations)
    @organization = Organization.find(params[:id])
    @current_organization = @organization
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""

    @attributes = PeAttribute.all
    @attribute_settings = AttributeOrganization.where(:organization_id => @organization.id).all

    @ot = @organization.organization_technologies.first

    @users = @organization.users
    @fields = @organization.fields

    @organization_profiles = @organization.organization_profiles

    @work_element_types = @organization.work_element_types
  end

  def refresh_value_elements
    @technologies = OrganizationTechnology.all
  end

  def create
    authorize! :create_organizations, Organization

    @organization = Organization.new(params[:organization])

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:new_organization) => ""

    check_if_organization_is_image(@organization)

    # Organization's projects selected columns
    @organization.project_selected_columns = Project.default_selected_columns

    # Add current_user to the organization
    @organization.users << current_user

    #A la sauvegarde, on crée des sous traitants
    if @organization.save

      @current_organization = @organization

      # Add admin and user groups
      admin_group = Group.create(name: "*USER", organization_id: @organization.id, description: "Groupe créé par défaut dans l'organisation pour la gestion des administrateurs")

      # Add MasterData Profiles to Organization
      Profile.all.each do |profile|
        op = OrganizationProfile.new(organization_id: @organization.id, name: profile.name, description: profile.description, cost_per_hour: profile.cost_per_hour)
        op.save
      end

      # Add some Estimations statuses in organization
      estimation_statuses = [
          ['0', 'preliminary', "Préliminaire", "999999", "Statut initial lors de la création de l'estimation"],
          ['1', 'in_progress', "En cours", "3a87ad", "En cours de modification"],
          ['2', 'in_review', "Relecture", "f89406", "En relecture"],
          ['3', 'checkpoint', "Contrôle", "b94a48", "En phase de contrôle"],
          ['4', 'released', "Confirmé", "468847", "Phase finale d'une estimation qui arrive à terme et qui sera retenue comme une version majeure"],
          ['5', 'rejected', "Rejeté", "333333", "L'estimation dans ce statut est rejetée et ne sera pas poursuivi"]
      ]
      estimation_statuses.each do |i|
        status = EstimationStatus.create(organization_id: @organization.id, status_number: i[0], status_alias: i[1], name: i[2], status_color: i[3], description: i[4])
      end

      redirect_to redirect_apply(edit_organization_path(@organization)), notice: "#{I18n.t(:notice_organization_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:id])
    check_if_organization_is_image(@organization)
    @current_organization = @organization

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""

    if @organization.update_attributes(params[:organization])
      flash[:notice] = I18n.t (:notice_organization_successful_updated)
      redirect_to redirect_apply(edit_organization_path(@organization), nil, '/organizationals_params')
    else
      @attributes = PeAttribute.all
      @attribute_settings = AttributeOrganization.where(:organization_id => @organization.id).all
      @ot = @organization.organization_technologies.first
      @technologies = OrganizationTechnology.all
      @organization_profiles = @organization.organization_profiles
      @groups = @organization.groups
      @organization_group = @organization.groups
      @wbs_activities = @organization.wbs_activities
      @projects = @organization.projects
      @fields = @organization.fields
      @guw_models = @organization.guw_models

      render action: 'edit'
    end
  end

  def confirm_organization_deletion
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    authorize! :manage, Organization
  end

  def destroy
    authorize! :manage, Organization

    @organization = Organization.find(params[:id])
    check_if_organization_is_image(@organization)

    @organization_id = @organization.id

    case params[:commit]
      when I18n.t('delete')
        if params[:yes_confirmation] == 'selected'

          @organization.transaction do
            OrganizationsUsers.delete_all("organization_id = #{@organization_id}")
            @organization.groups.each do |group|
              GroupsUsers.delete_all("group_id = #{group.id}")
            end
            @organization.destroy
          end

          if session[:organization_id] == params[:id]
            session[:organization_id] = current_user.organizations.first  #session[:organization_id] = nil
          end
          flash[:notice] = I18n.t(:notice_organization_successful_deleted)
          redirect_to '/organizationals_params' and return

        else
          flash[:warning] = I18n.t('warning_need_organization_check_box_confirmation')
          render :template => 'organizations/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
        end

      when I18n.t('cancel')
        redirect_to '/organizationals_params' and return
      else
        render :template => 'projects/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
    end
  end

  def organizationals_params
    set_page_title I18n.t(:Organizational_Parameters)
    if @current_organization
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@current_organization.id}", "#{I18n.t(:organizations)}" => ""
    else
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", "#{I18n.t(:organizations)}" => ""
    end

    if current_user.super_admin?
      @organizations = Organization.all
    elsif can?(:manage, :all)
      @organizations = Organization.all.reject{|org| org.is_image_organization}
    else
      @organizations = current_user.organizations.all.reject{|org| org.is_image_organization}
    end

    if @organizations.size == 1 && !current_user.super_admin?
      redirect_to organization_estimations_path(@organizations.first)
    end
  end

  def export_user
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    first_row = [I18n.t(:first_name_attribute), I18n.t(:last_name_attribute), I18n.t(:initials_attribute),I18n.t(:email_attribute), I18n.t(:login_name_or_email), I18n.t(:authentication),I18n.t(:description), I18n.t(:label_language), I18n.t(:locked_at),I18n.t(:groups)]
    row = []

    first_row.each_with_index do |name, index|
      worksheet.add_cell(0, index, name)
      if can?(:show_groups, Group) || can?(:manage, Group)
        @organization.users.where('login_name <> ?', 'owner').each_with_index do |user, index_row|
          row =  [user.first_name, user.last_name, user.initials,user.email, user.login_name, user.auth_method ? user.auth_method.name : "Application" , user.description, user.language, user.locked_at.nil? ? 0 : 1] + user.groups.where(organization_id: @organization.id).map(&:name)
          row.each_with_index do |my_case, index|
            worksheet.add_cell(index_row + 1, index, my_case)
          end
        end
      else
        @organization.users.where('login_name <> ?', 'owner').each_with_index do |user, index_row|
          row =  [user.first_name, user.last_name, user.initials,user.email, user.login_name, user.auth_method ? user.auth_method.name : "Application" , user.description, user.language, user.locked_at.nil? ? 0 : 1] + ["####"]
          row.each_with_index do |my_case, index|
            worksheet.add_cell(index_row + 1, index, my_case)
          end
        end
      end
    end

    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Users_List-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
=begin
    @organization = Organization.find(params[:organization_id])
    csv_string = CSV.generate(:col_sep => ",") do |csv|
      csv << ['Prénom', 'Nom', 'Email', 'Login', 'Groupes']
      @organization.users.take(3).each do |user|
        csv << [user.first_name, user.last_name, user.email, user.login_name] + user.groups.where(organization_id: @organization.id).map(&:name)
      end
    end
    send_data(csv_string.encode("ISO-8859-1"), :type => 'text/csv; header=present', :disposition => "attachment; filename=modele_import_utilisateurs.csv")
=end
  end

  # On importe/crée les utilisateurs contenus dans le fichier, mais lorsqu'il y a en un qui existe déjà, il faudra le rattacher à l'organisation et aux groupes du fichier
  def import_user

    authorize! :manage, User

    users_existing = []
    user_with_no_name = []

    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]
        tab = worksheet

        tab.each_with_index do |row, index_row|
        if index_row > 0
          if !row.blank?

            password = SecureRandom.hex(8)
            if row[0] && row[1] && row[4] && row[3]

              user = User.find_by_login_name(row[4].nil? ? '' : row[4].value)
              if user.nil?

                if row[7]
                  langue = Language.find_by_name(row[7].nil? ? '' : row[7].value) ? Language.find_by_name(row[7].nil? ? '' : row[7].value).id : params[:language_id].to_i
                else
                  langue = params[:language_id].to_i
                end

                if row[5]
                  auth_method = AuthMethod.find_by_name(row[5].nil? ? '' : row[5].value) ? AuthMethod.find_by_name(row[5].nil? ? '' : row[5].value).id : AuthMethod.first.id
                else
                  auth_method = AuthMethod.first.id
                end

                user = User.new(first_name: row[0].nil? ? '' : row[0].value,
                                last_name: row[1].nil? ? '' : row[1].value,
                                initials: row[2].nil? ? '' : row[2].value,
                                email: row[3].nil? ? '' : row[3].value,
                                login_name: row[4].nil? ? '' : row[4].value,
                                id_connexion: row[4].nil? ? '' : row[4].value,
                                description: row[6].nil? ? '' : row[6].value,
                                super_admin: false,
                                password: password,
                                password_confirmation: password,
                                language_id: langue,
                                time_zone: "Paris",
                                object_per_page: 50,
                                auth_type: auth_method,
                                locked_at: ((row[8].value == 0 ? nil : Time.now) rescue nil),
                                number_precision: 2,
                                subscription_end_date: Time.now + 1.year)

                if !row[5].nil? && row[5].value.upcase == "SAML"
                  user.skip_confirmation_notification!
                  user.skip_confirmation!
                end
                user.subscription_end_date = Time.now + 1.year
                user.save
              end

              organization_user = OrganizationsUsers.where(organization_id: @current_organization.id, user_id: user.id).first
              if organization_user.nil?

                OrganizationsUsers.create(organization_id: @current_organization.id, user_id: user.id)

                group_index = 9
                if can?(:manage, Group, :organization_id => @current_organization.id)
                   while row[group_index]
                      group = Group.where(name: row[group_index].nil? ? '' : row[group_index].value, organization_id: @current_organization.id).first
                      begin
                        if (group.is_protected_group != true || ( group.is_protected_group == true && ( @current_user.super_admin || @current_user.groups.include?(group)) ))
                          GroupsUsers.create(group_id: group.id, user_id: user.id)
                        end
                      rescue
                        #rien
                      end
                     group_index += 1
                   end
                else
                  @user_group = @current_organization.groups.where(name: '*USER').first_or_create(organization_id: @current_organization.id, name: "*USER")
                  GroupsUsers.create(group_id: @user_group.id, user_id: user.id)
                end
              else
                # L'utilisateur existe dejà et est déjà rattaché à l'organisation
                users_existing << (row[4].nil? ? '' : row[4].value)
              end
            else
              user_with_no_name << index_row
            end
          end
        end
      end
      final_error = []
      flash_err = false
      unless users_existing.empty?
        final_error <<  I18n.t(:user_exist, parameter: users_existing.join(", "))
      end
      unless user_with_no_name.empty?
        final_error << I18n.t(:user_with_no_name, parameter: user_with_no_name.join(", "))
      end
      unless final_error.empty?
        flash[:error] = final_error.join("<br/>").html_safe
        flash_err = true
      end
      if final_error.empty? && flash_err==false
        flash[:notice] = I18n.t(:user_importation_success)
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end

    redirect_to organization_users_path(@current_organization) and return
  end


#   def import_user_SAVE
#
#     authorize! :manage, User
#
#     users_existing = []
#     user_with_no_name = []
#
#     if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
#       workbook = RubyXL::Parser.parse(params[:file].path)
#       worksheet = workbook[0]
#       tab = worksheet
#
#       tab.each_with_index do |row, index_row|
#         if index_row > 0
#           if !row.blank?
#             user = User.find_by_login_name(row[4].nil? ? '' : row[4].value)
#
#             if user.nil?
#               password = SecureRandom.hex(8)
#               if row[0] && row[1] && row[4] && row[3]
#                 if row[7]
#                   langue = Language.find_by_name(row[7].nil? ? '' : row[7].value) ? Language.find_by_name(row[7].nil? ? '' : row[7].value).id : params[:language_id].to_i
#                 else
#                   langue = params[:language_id].to_i
#                 end
#
#                 if row[5]
#                   auth_method = AuthMethod.find_by_name(row[5].nil? ? '' : row[5].value) ? AuthMethod.find_by_name(row[5].nil? ? '' : row[5].value).id : AuthMethod.first.id
#                 else
#                   auth_method = AuthMethod.first.id
#                 end
#
#                 user = User.new(first_name: row[0].nil? ? '' : row[0].value,
#                                 last_name: row[1].nil? ? '' : row[1].value,
#                                 initials: row[2].nil? ? '' : row[2].value,
#                                 email: row[3].nil? ? '' : row[3].value,
#                                 login_name: row[4].nil? ? '' : row[4].value,
#                                 id_connexion: row[4].nil? ? '' : row[4].value,
#                                 description: row[6].nil? ? '' : row[6].value,
#                                 super_admin: false,
#                                 password: password,
#                                 password_confirmation: password,
#                                 language_id: langue,
#                                 time_zone: "Paris",
#                                 object_per_page: 50,
#                                 auth_type: auth_method,
#                                 locked_at: row[8] == 0 ? nil : Time.now,
#                                 number_precision: 2,
#                                 subscription_end_date: Time.now + 1.year)
#
#                 if !row[5].nil? && row[5].value.upcase == "SAML"
#                   user.skip_confirmation_notification!
#                   user.skip_confirmation!
#                 end
#                 user.subscription_end_date = Time.now + 1.year
#                 user.save
#
#                 OrganizationsUsers.create(organization_id: @current_organization.id, user_id: user.id)
#                 group_index = 9
#                 if can?(:manage, Group, :organization_id => @current_organization.id)
#                   while row[group_index]
#                     group = Group.where(name: row[group_index].nil? ? '' : row[group_index].value, organization_id: @current_organization.id).first
#                     begin
#                       GroupsUsers.create(group_id: group.id, user_id: user.id)
#                     rescue
#                       #rien
#                     end
#                     group_index += 1
#                   end
#                 else
#                   @user_group = @current_organization.groups.where(name: '*USER').first_or_create(organization_id: @current_organization.id, name: "*USER")
#                   GroupsUsers.create(group_id: @user_group.id, user_id: user.id)
#                 end
#               else
#                 user_with_no_name << index_row
#               end
#             else
#               users_existing << (row[4].nil? ? '' : row[4].value)
#
#               # On doit rattacher l'utilisateur à l'organisation et aux groupes du fichier
#             end
#           end
#         end
#       end
#       final_error = []
#       flash_err = false
#       unless users_existing.empty?
#         final_error <<  I18n.t(:user_exist, parameter: users_existing.join(", "))
#       end
#       unless user_with_no_name.empty?
#         final_error << I18n.t(:user_with_no_name, parameter: user_with_no_name.join(", "))
#       end
#       unless final_error.empty?
#         flash[:error] = final_error.join("<br/>").html_safe
#         flash_err = true
#       end
#       if final_error.empty? && flash_err==false
#         flash[:notice] = I18n.t(:user_importation_success)
#       end
#     else
#       flash[:error] = I18n.t(:route_flag_error_4)
#     end
#
#     redirect_to organization_users_path(@current_organization) and return
#
# =begin
#     sep = "#{params[:separator].blank? ? I18n.t(:general_csv_separator) : params[:separator]}"
#     error_count = 0
#     file = params[:file]
#     encoding = params[:encoding]
#
#     #begin
#       CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "ISO-8859-1:utf-8") do |csv|
#         csv.each_with_index do |row, i|
#           unless i == 0
#             password = SecureRandom.hex(8)
#
#             user = User.where(login_name: row[3].value).first
#             if user.nil?
#
#               u = User.new(first_name: row[0].value,
#                            last_name: row[1].value,
#                            email: row[2].value,
#                            login_name: row[3].value,
#                            id_connexion: row[3].value,
#                            super_admin: false,
#                            password: password,
#                            password_confirmation: password,
#                            language_id: params[:language_id].to_i,
#                            initials: "#{row[0].value.first}#{row[1].value.first}",
#                            time_zone: "Paris",
#                            object_per_page: 50,
#                            auth_type: AuthMethod.first.id,
#                            number_precision: 2)
#
#               u.save(validate: false)
#
#               OrganizationsUsers.create(organization_id: @current_organization.id,
#                                         user_id: u.id)
#               (row.size - 4).times do |i|
#                 group = Group.where(name: row[4 + i], organization_id: @current_organization.id).first
#                 begin
#                   GroupsUsers.create(group_id: group.id,
#                                      user_id: u.id)
#                 rescue
#                   # nothing
#                 end
#               end
#             end
#           end
#         end
#       end
#     #rescue
#     #  flash[:error] = "Une erreur est survenue durant l'import du fichier. Vérifier l'encodage du fichier (ISO-8859-1 pour Windows, utf-8 pour Mac) ou le caractère de séparateur du fichier"
#     #end
# =end
#   end


  # Update the organization's projects available inline columns
  def set_available_inline_columns
    authorize! :manage_projects_selected_columns, Organization
    redirect_to organization_setting_path(@current_organization, :anchor => 'tabs-select-columns-list')
  end

  def update_available_inline_columns
    # update selected column
    selected_columns = params['selected_inline_columns']
    query_classname = params['query_classname'].constantize
    unless selected_columns.nil?
      case params['query_classname']
        when "Project"
          @current_organization.project_selected_columns = selected_columns
        when "Organization"
          @current_organization.organization_selected_columns = selected_columns
        else
          # ignored
          # type code here
      end
      @current_organization.save
    end

    #respond_to do |format|
    #  format.js
    #  format.json { render json: selected_columns }
    #end
  end

  # Duplicate the organization
  # Function de delete after => is replaced by the create_from_image fucntion
  def duplicate_organization
    authorize! :manage_master_data, :all

    original_organization = Organization.find(params[:organization_id])
    new_organization = original_organization.amoeba_dup
    if new_organization.save
      original_organization.save #Original organization copy number will be incremented to 1
      flash[:notice] = I18n.t(:organization_successfully_copied)
    else
      flash[:error] = "#{ I18n.t(:errors_when_copying_organization)} : #{new_organization.errors.full_messages.join(', ')}"
    end
    redirect_to organizationals_params_path
  end

  def show
    authorize! :show_organizations, Organization
  end

  def export_organization_reference
    cn = {}
    Dir.foreach("#{Rails.root}/app/models") do |model_path|
      class_name = model_path.gsub(".rb", "").classify
      begin
        cn[class_name] = eval(class_name).column_names
      rescue
        # noting to do
      end
    end

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    worksheet.sheet_name = 'Référence Organisation'

    worksheet.add_cell(0, 0, "Table")
    worksheet.add_cell(0, 1, "Champs")
    worksheet.add_cell(0, 2, "Validation")

    i = 1
    cn.each do |k,v|
      v.each do |j|

        worksheet.add_cell(i, 0, k)
        worksheet.add_cell(i, 1, j)

        i = i + 1

      end
    end

    send_data(workbook.stream.string, filename: "reference.xlsx", type: "application/vnd.ms-excel")

  end

  def projects_quantity
    @organizations = Organization.all
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "projects_quantity",
               #template: "organizations/export_to_pdf_projects_quantity.pdf.erb"
               encoding: "UTF-8"
      end
    end
  end


  private
  def check_if_organization_is_image(organization)
    if organization.is_image_organization == true || !current_user.organization_ids.include?(organization.id)
      redirect_to("/organizationals_params",
                  flash: {
                      error: "Vous ne pouvez pas accéder aux estimations d'une organization image"
                  }) and return
    end
  end


end
