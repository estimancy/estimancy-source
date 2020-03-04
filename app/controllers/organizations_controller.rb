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
  require 'rounding'
  include ProjectsHelper
  include OrganizationsHelper
  include ActionView::Helpers::NumberHelper


  #====================  IMPORT/EXPORT  MODELE D'ESTIMATION  =======================#
  #Pour Exporter un modèle d'estimation
  def export_estimation_model

    organization_id = params[:organization_id]
    project_id = params[:project_id]
    tab_errors = []

    # Thread.new do
    #   ActiveRecord::Base.connection_pool.with_connection do

    ActiveRecord::Base.transaction do

        workbook = RubyXL::Workbook.new

        @project = Project.where(organization_id: organization_id, id: project_id).first
        @organization = Organization.find(organization_id)
        
        worksheet_properties = workbook.worksheets[0]
        worksheet_properties.sheet_name = I18n.t(:global_properties)
        worksheet_estimation_plan = workbook.add_worksheet(I18n.t(:estimation_plan))
        worksheet_security = workbook.add_worksheet(I18n.t(:securities))
        worksheet_view_widgets = workbook.add_worksheet(I18n.t(:views_widgets))

        label_platform_category =  I18n.t('platform_category')
        if @organization.name.downcase.include?("distribution transporteur")
          label_platform_category =  "TM"
        elsif @organization.name.downcase.include?("cds voyageurs")
          label_platform_category =  "Urgence Devis"
        end

        # Proprietes globales
        global_properties = [[I18n.t(:organizations), @project.organization.name],
                            [I18n.t(:label_project_name),  @project.title],
                            [I18n.t(:business_need), @project.business_need],
                            [I18n.t(:request_number), @project.request_number],
                            [I18n.t(:is_model), @project.is_model ? 1 : 0 ],
                            [I18n.t(:use_automatic_quotation_number), @project.use_automatic_quotation_number ? 1 : 0 ],
                            [I18n.t(:allow_export_pdf), @project.allow_export_pdf ? 1 : 0],
                            [I18n.t(:version_number), @project.version_number],
                            [I18n.t(:private_estimation), @project.private ? 1 : 0 ],
                            [I18n.t(:label_product_name), @project.application_name],
                            [I18n.t(:applications), @project.applications.map(&:name)],
                            [I18n.t(:selected_application), (@project.application.name rescue nil)],
                            [I18n.t(:original_model), @project.original_model],
                            [I18n.t(:original_model_version), (@project.original_model.version_number rescue nil)],
                            [I18n.t(:description), @project.description],
                            [I18n.t(:start_date), I18n.l(@project.start_date)],
                            [I18n.t(:creator), @project.creator],
                            [I18n.t(:status_alias), (@project.estimation_status.status_alias rescue nil)],
                            [I18n.t(:estimation_status), (@project.estimation_status.name rescue nil)],
                            [I18n.t(:status_comment), @project.status_comment],
                            [I18n.t(:project_area), (@project.project_area.name rescue nil )],
                            [I18n.t(:acquisition_category), (@project.acquisition_category.name rescue nil)],
                            ["#{label_platform_category}", (@project.platform_category.name rescue nil)],
                            [I18n.t(:project_category), (@project.project_category.name rescue nil)],
                            [I18n.t(:provider), (@project.provider.name rescue nil)],
                            [I18n.t(:nb_module_projects), @project.module_projects.all.size]]

        global_properties.each_with_index do |row, index|
          worksheet_properties.add_cell(index, 0, row[0])
          worksheet_properties.add_cell(index, 1, row[1])#.change_horizontal_alignment('center')
          ["bottom", "right"].each do |symbole|
            worksheet_properties[index][0].change_border(symbole.to_sym, 'thin')
            worksheet_properties[index][1].change_border(symbole.to_sym, 'thin')
          end
        end

        worksheet_properties.change_column_bold(0,true)
        worksheet_properties.change_column_width(0, 60)
        worksheet_properties.change_column_width(1, 100)
        worksheet_properties.sheet_data[1][1].change_horizontal_alignment('left') rescue nil

        i = 0
        #Plan d'estimation : worksheet_estimation_plan
        worksheet_estimation_plan.add_cell(0, i, I18n.t(:pe_module))
        worksheet_estimation_plan.add_cell(0, i += 1, "#{I18n.t(:pe_module)} Alias")
        #worksheet_estimation_plan.add_cell(0, i += 1, "ID ModuleProject")
        worksheet_estimation_plan.add_cell(0, i += 1, I18n.t(:module_name))
        worksheet_estimation_plan.add_cell(0, i += 1, "Position_x")
        worksheet_estimation_plan.add_cell(0, i += 1, "Position_y")
        worksheet_estimation_plan.add_cell(0, i += 1, "Left_position")
        worksheet_estimation_plan.add_cell(0, i += 1, "Top_position")
        worksheet_estimation_plan.add_cell(0, i += 1, I18n.t(:creation_order))
        worksheet_estimation_plan.add_cell(0, i += 1, I18n.t(:show_results_view))
        worksheet_estimation_plan.add_cell(0, i += 1, "Guw_model")
        worksheet_estimation_plan.add_cell(0, i += 1, "Ge_model")
        worksheet_estimation_plan.add_cell(0, i += 1, "Wbs_activity")
        worksheet_estimation_plan.add_cell(0, i += 1, I18n.t(:ratio))
        worksheet_estimation_plan.add_cell(0, i += 1, "Expert_judgement_instance")
        worksheet_estimation_plan.add_cell(0, i += 1, "Staffing_model")
        worksheet_estimation_plan.add_cell(0, i += 1, "Kb_model")
        worksheet_estimation_plan.add_cell(0, i += 1, "Skb_model")
        worksheet_estimation_plan.add_cell(0, i += 1, "Operation_model")
        worksheet_estimation_plan.add_cell(0, i += 1, I18n.t(:associated_module_projects))
        worksheet_estimation_plan.add_cell(0, i += 1, "Configuration Entrées/Sorties du module")
        worksheet_estimation_plan.add_cell(0, i += 1, "Groupe par défaut")

        worksheet_estimation_plan.change_column_width(0, 40)
        worksheet_estimation_plan.change_column_width(2, 30)

        nb_mp = 0
        module_projects = @project.module_projects
        module_projects.each_with_index do |module_project, index|
          j = 0
          module_project_name = module_project.module_project_name
          if module_project.pemodule.alias == "initialization"
            module_project_name = "Initialization"
          end

          worksheet_estimation_plan.add_cell(index+1, j, module_project.pemodule.title)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.pemodule.alias)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project_name)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.position_x)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.position_y)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.left_position)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.top_position)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.creation_order)
          worksheet_estimation_plan.add_cell(index+1, j += 1, module_project.show_results_view ? 1 : 0)
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.guw_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.ge_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.wbs_activity.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.wbs_activity_ratio.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.expert_judgement_instance.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.staffing_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.kb_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.skb_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.operation_model.name rescue nil))
          worksheet_estimation_plan.add_cell(index+1, j += 1, (module_project.associated_module_projects_table.inspect rescue nil))

          #===== Liaisons entre les atributs du plan d'estimation
          associated_estimation_values = Hash.new
          module_project.estimation_values.where(organization_id: @organization.id).each do |est_val|
            estimation_value_id = est_val.estimation_value_id
            unless est_val.estimation_value_id.nil?
              association_hash = Hash.new
              estimation_value = est_val.associated_estimation_value
              unless estimation_value.nil?
                association_hash[:pe_attribute_name] = estimation_value.pe_attribute.name
                association_hash[:module_project_name] = estimation_value.module_project.module_project_name
                association_hash[:in_out] = estimation_value.in_out
                associated_estimation_values[est_val.pe_attribute.name] = association_hash
              end
            end
          end

          associated_estimation_values_str = (associated_estimation_values.blank? ? "" : associated_estimation_values.inspect) rescue nil
          # Associated_estimation_values_between attributes
          worksheet_estimation_plan.add_cell(index+1, j += 1, associated_estimation_values_str)

          # Groupe par défaut - module de taille
          default_groups_array = nil
          if module_project.pemodule.alias == "guw"
            default_groups = module_project.guw_unit_of_work_groups.all.map(&:name)
            if default_groups.blank?
              default_groups_array = nil
            else
              default_groups_array = default_groups.inspect
            end
          end
          worksheet_estimation_plan.add_cell(index+1, j += 1, default_groups_array) #for GuwGroup
        end


        ##===================   Les Vues et Vignettes : worksheet_view_widgets   =========================
        vw = 0
        worksheet_view_widgets.add_cell(0, vw, I18n.t(:name))
        #worksheet_view_widgets.add_cell(0, vw += 1, "Vue")
        worksheet_view_widgets.add_cell(0, vw += 1, "#{I18n.t(:view_name)} ModuleProject")
        worksheet_view_widgets.add_cell(0, vw += 1, "ModuleProject")
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:pe_attribute_name))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:in_out))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:show_name))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:show_tjm))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:equation))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:comments))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:is_label_widget))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:is_kpi_widget))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:kpi_unit))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:use_organization_effort_unit))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:is_project_data_widget))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:project_attribute_name))
        worksheet_view_widgets.add_cell(0, vw += 1, "Icon")
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:color_code))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:show_min_max))
        worksheet_view_widgets.add_cell(0, vw += 1, "Width")
        worksheet_view_widgets.add_cell(0, vw += 1, "Height")
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:widget_type))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:position))
        worksheet_view_widgets.add_cell(0, vw += 1, "Position_x")
        worksheet_view_widgets.add_cell(0, vw += 1, "Position_y")
        worksheet_view_widgets.add_cell(0, vw += 1, "Min.")
        worksheet_view_widgets.add_cell(0, vw += 1, "Max.")
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:validation_options)) #validation_text
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:show_wbs_activity_ratio))
        worksheet_view_widgets.add_cell(0, vw += 1, I18n.t(:fields))  #project_fields

        #Then copy the widgets of the dafult view
        module_projects.each do |module_project|
          mp_view = module_project.view
          if mp_view
            mp_view.views_widgets.each_with_index do |view_widget, index|
              k = 0

              if module_project.pemodule.alias == "initialization"
                mp_view_module_project_name = "Initialization"
              else
                mp_view_module_project_name = module_projects.where(view_id: mp_view.id).first.module_project_name rescue nil
              end

              widget_est_val = view_widget.estimation_value
              in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
              #estimation_value = module_project.estimation_values.where(:organization_id => @organization.id, pe_attribute_id: view_widget.estimation_value.pe_attribute_id, in_out: in_out).last

              if view_widget.is_kpi_widget?
                equation = view_widget.equation
                unless equation.blank?
                  formula = equation["formula"]

                  ["A", "B", "C", "D", "E"].each do |letter|
                    equation_letter = Hash.new
                    begin
                      unless equation[letter].blank?
                        #equation[letter] = [params[letter.to_sym].upcase, params["module_project"][letter]]
                        letter_array = equation[letter]
                        unless letter_array.nil?
                          mp_id = letter_array.last
                          est_val_id = letter_array.first

                          mp = module_projects.where(id: mp_id).first
                          est_val = mp.estimation_values.where(id: est_val_id).first

                          equation_letter[:pe_attribute_name] = est_val.pe_attribute.name
                          equation_letter[:module_project_name] = mp.module_project_name
                          equation_letter[:in_out] = est_val.in_out
                          equation_letter[:pemodule_alias] = mp.pemodule.alias
                          #equation[letter] = [est_val.pe_attribute.name, est_val.in_out, mp.module_project_name]
                          equation[letter] = equation_letter
                        end
                      end
                    rescue
                      # ignored
                    end
                  end
                end
              end

              worksheet_view_widgets.add_cell(index+1, k, view_widget.name)
              #worksheet_view_widgets.add_cell(index+1, k += 1, mp_view.id)
              worksheet_view_widgets.add_cell(index+1, k += 1, mp_view_module_project_name)
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.module_project.module_project_name rescue nil))  #module_project.module_project_name
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.estimation_value.pe_attribute.name rescue nil))   # EstimationValue
              worksheet_view_widgets.add_cell(index+1, k += 1, in_out)   # EstimationValue
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.show_name ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.show_tjm ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, (equation.blank? ? "" : equation.inspect))
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.comment)
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.is_label_widget ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.is_kpi_widget ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.kpi_unit)
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.use_organization_effort_unit ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.is_project_data_widget ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.project_attribute_name)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.icon_class)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.color)
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.show_min_max ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.width)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.height)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.widget_type)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.position)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.position_x)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.position_y)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.min_value)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.max_value)
              worksheet_view_widgets.add_cell(index+1, k += 1, view_widget.validation_text)
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.show_wbs_activity_ratio ? 1 : 0))
              worksheet_view_widgets.add_cell(index+1, k += 1, (view_widget.project_fields.last.field.name rescue nil))
            end
          end
        end

        #=====
        # Send the file
        send_data(workbook.stream.string, filename: "#{@organization.name}-#{@project.title.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
      #end
    end
    #redirect_to projects_from_path(organization_id: organization_id)
  end

  # Pour Importer un modèle d'estimation
  def import_estimation_model

    ActiveRecord::Base.transaction do

      organization_id = params[:organization_id]
      is_model = params[:is_model]
      #project_id = params[:project_id]
      @module_project_ids = Hash.new
      @widgets_view_ids = Hash.new
      @associated_module_projects = Hash.new
      @associated_estimation_values = Hash.new
      @initialization_name = "Initialization"

      #if a organization exists
      if !organization_id.blank?
        @organization = Organization.find(organization_id)

        if params[:file]
          if !params[:file].nil? && (File.extname(params[:file].original_filename).to_s.downcase == ".xlsx")

            #get the file data
            workbook = RubyXL::Parser.parse(params[:file].path)

            worksheet_properties = workbook[I18n.t(:global_properties)]
            worksheet_estimation_plan = workbook[I18n.t(:estimation_plan)]
            worksheet_security = workbook[I18n.t(:securities)]
            worksheet_view_widgets = workbook[I18n.t(:views_widgets)]


            worksheet_properties_order_attributes = ["title", "business_need", "request_number", "is_model", "use_automatic_quotation_number",
                                                     "allow_export_pdf", "version_number", "private", "application_name", "application_id", "original_model", "original_model_version",
                                                      "description", "start_date", "creator", "estimation_status", "status_comment", "project_area", "acquisition_category",
                                                     "platform_category", "project_category", "provider"]

            if !worksheet_properties.nil?
              @project = Project.new
              @project.organization = @organization

              row = 0
              @project.title = worksheet_properties[1][1].value rescue nil
              @project.business_need = worksheet_properties[2][1].value rescue nil
              @project.request_number = worksheet_properties[3][1].value rescue nil
              @project.is_model = worksheet_properties[4][1].value rescue nil
              @project.is_model = is_model
              @project.use_automatic_quotation_number = worksheet_properties[5][1].value rescue nil
              @project.allow_export_pdf = worksheet_properties[6][1].value rescue nil
              @project.version_number = worksheet_properties[7][1].value rescue nil
              @project.private = worksheet_properties[8][1].value rescue nil
              @project.application_name = worksheet_properties[9][1].value rescue nil

              # Applications
              applications = worksheet_properties[10][1].value rescue nil
              unless applications.blank?
                #split
              end

              # Application
              selected_application_name = worksheet_properties[11][1].value rescue nil
              unless selected_application_name.blank?
                selected_application = Application.where(organization_id: organization_id, name: selected_application_name).first_or_create
                @project.application_id = selected_application.id rescue nil
              end

              #"original_model"
              original_model_name = worksheet_properties[12][1].value rescue nil

              # "original_model_version"
              original_model_version = worksheet_properties[13][1].value rescue nil

              @project.description = worksheet_properties[14][1].value rescue nil
              @project.start_date = worksheet_properties[15][1].value rescue nil
              ##creator  : worksheet_properties[16][1].value
              @project.creator_id = @current_user.id

              # EstimationStatus
              estimation_status_alias = worksheet_properties[17][1].value rescue nil
              estimation_status_name = worksheet_properties[18][1].value rescue nil
              unless estimation_status_name.blank?
                selected_status = EstimationStatus.where(organization_id: organization_id, status_alias: estimation_status_alias).first_or_create(name: selected_application_name)
                @project.estimation_status_id = selected_status.id rescue nil
              end
              @project.status_comment = worksheet_properties[19][1].value rescue nil

              #ProjectArea
              project_area_name = worksheet_properties[20][1].value rescue nil
              unless project_area_name.blank?
                selected_project_area = ProjectArea.where(organization_id: organization_id, name: project_area_name).first_or_create
                @project.project_area_id = selected_project_area.id rescue nil
              end

              #acquisition_category
              project_acquisition_category_name = worksheet_properties[21][1].value rescue nil
              unless project_acquisition_category_name.blank?
                selected_project_acquisition_category = AcquisitionCategory.where(organization_id: organization_id, name: project_acquisition_category_name).first_or_create
                @project.acquisition_category_id = selected_project_acquisition_category.id rescue nil
              end

              #platform_category
              platform_category_name = worksheet_properties[22][1].value rescue nil
              unless platform_category_name.blank?
                selected_platform_category = PlatformCategory.where(organization_id: organization_id, name: platform_category_name).first_or_create
                @project.platform_category_id = selected_platform_category.id rescue nil
              end

              #project_category
              project_category_name = worksheet_properties[23][1].value rescue nil
              unless project_category_name.blank?
                selected_project_category = ProjectCategory.where(organization_id: organization_id, name: project_category_name).first_or_create
                @project.project_category_id = selected_project_category.id rescue nil
              end

              #provider
              provider_name = worksheet_properties[24][1].value rescue nil
              unless provider_name.blank?
                selected_provider = Provider.where(organization_id: organization_id, name: provider_name).first_or_create
                @project.provider_id = selected_provider.id rescue nil
              end


              ##====  Creation du PBS et de initialisation
              Project.transaction do
                begin
                  @project.add_to_transaction

                  if @project.save

                    #New default Pe-Wbs-Project
                    pe_wbs_project_product = @project.pe_wbs_projects.build(:name => "#{@project.title}", :wbs_type => 'Product')
                    pe_wbs_project_product.add_to_transaction
                    pe_wbs_project_product.save!

                    ##New root Pbs-Project-Element
                    if @project.application.nil?
                      @product_name = @project.application_name
                    else
                      @product_name = @project.application.name
                    end

                    @project_title = @project.title
                    default_work_element_type = @organization.work_element_types.first_or_create(name: "Default", alias: "default")
                    pbs_project_element = pe_wbs_project_product.pbs_project_elements.build(:name => "#{@product_name.blank? ? @project_title : @product_name}",
                                                                                            :is_root => true, :start_date => Time.now, :position => 0, :work_element_type_id => default_work_element_type.id)
                    pbs_project_element.add_to_transaction
                    pbs_project_element.save!
                    pe_wbs_project_product.save!

                    #Get the initialization module from ApplicationController
                    #When creating project, we need to create module_projects for created initialization
                    @initialization_module = Pemodule.where(alias: 'initialization').first
                    unless @initialization_module.nil?
                      # Create the project's Initialization module
                      cap_module_project = ModuleProject.new(:organization_id => @organization.id, :pemodule_id => @initialization_module.id, :project_id => @project.id, :position_x => 0, :position_y => 0, show_results_view: true)

                      # Create the Initialization module view
                      cap_module_project.build_view(name: "#{cap_module_project.to_s} - Initialization View", pemodule_id: cap_module_project.pemodule_id, organization_id: @project.organization_id)

                      if cap_module_project.save!
                        #Create the corresponding EstimationValues
                        unless @project.organization.nil? || @project.organization.attribute_organizations.nil?
                          @project.organization.attribute_organizations.each do |am|
                            ['input', 'output'].each do |in_out|
                              EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                                     :organization_id => @organization.id,
                                                     :module_project_id => cap_module_project.id,
                                                     :in_out => in_out,
                                                     :is_mandatory => am.is_mandatory,
                                                     :description => am.pe_attribute.description,
                                                     :display_order => nil,
                                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                            end
                          end
                        end

                        module_project_name = cap_module_project.module_project_name
                        @module_project_ids["Initialization"] = cap_module_project.id
                        @widgets_view_ids["Initialization"] = cap_module_project.view_id
                      end
                    end

                    # On remet à jour ce champs pour la gestion des Trigger
                    @project.update_attribute(:is_new_created_record, false)

                    #============= Ajout des module_projects  : worksheet_estimation_plan = workbook[I18n.t(:estimation_plan)]
                    if !worksheet_estimation_plan.nil?
                      worksheet_estimation_plan.each_with_index do | row, index |
                        if index >= 1
                          pemodule_alias = row.cells[1].value rescue nil
                          module_project_name = row.cells[2].value rescue nil
                          @associated_module_projects["#{module_project_name}"] = eval(row.cells[18].value) rescue nil
                          @associated_estimation_values["#{module_project_name}"] = eval(row.cells[19].value) rescue nil
                          guw_unit_of_work_groups = eval(row.cells[20].value) rescue nil

                          unless pemodule_alias.nil?
                            if pemodule_alias == "initialization"
                              @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
                              unless @initialization_module_project.nil?
                                @initialization_module_project.update_attributes(show_results_view: (row.cells[8].value rescue nil))
                              end
                            else
                              # Append_pemodule
                              instance_model = nil

                              case pemodule_alias.to_s
                                when "guw"
                                  instance_model = @organization.guw_models.where(name: module_project_name).first
                                when "kb"
                                  instance_model = @organization.kb_models.where(name: module_project_name).first
                                when "skb"
                                  instance_model = @organization.skb_models.where(name: module_project_name).first
                                when "ge"
                                  instance_model = @organization.ge_models.where(name: module_project_name).first
                                when "operation"
                                  instance_model = @organization.operation_models.where(name: module_project_name).first
                                when "staffing"
                                  instance_model = @organization.staffing_models.where(name: module_project_name).first
                                when "effort_breakdown"
                                  instance_model = @organization.wbs_activities.where(name: module_project_name).first
                                when "expert_judgement"
                                  instance_model = @organization.expert_judgement_instances.where(name: module_project_name).first
                              end

                              if instance_model.nil?
                                flash[:error] = "L'instance de module #{pemodule_alias} : #{module_project_name} n'existe pas"
                              else
                                pemodule = Pemodule.where(alias: pemodule_alias).first
                                module_selected = "#{instance_model.id},#{pemodule.id}"
                                project_id = @project.id
                                pbs_project_element_id = @project.pbs_project_elements.first

                                mp_params = params.merge(project_id: project_id, module_selected: module_selected, pbs_project_element_id: pbs_project_element_id)
                                #append_pemodule(mp_params)
                                #ProjectsController.process(:append_pemodule)
                                module_project = Project.append_pemodule(project_id, pbs_project_element_id, module_selected)

                                if module_project.nil?
                                  flash[:error] = "Erreur d'ajout du module #{module_project_name}"
                                else
                                  if pemodule_alias.to_s == "effort_breakdown"
                                    wbs_activity_ratio_name = row.cells[12].value.to_f rescue nil
                                    if wbs_activity_ratio_name.blank?
                                      wbs_activity_ratio_id = nil
                                    else
                                      wbs_activity_ratio_id = module_project.wbs_activity.wbs_activity_ratios.where(name: wbs_activity_ratio_name).first.id rescue nil
                                    end
                                  elsif pemodule_alias.to_s == "guw"
                                    #On crée les groupes par défaut
                                    unless guw_unit_of_work_groups.blank?
                                      guw_unit_of_work_groups.each do |group_name|
                                        Guw::GuwUnitOfWorkGroup.create(name: group_name, organization_id: @organization.id,
                                                                            project_id: @project.id,
                                                                            module_project_id: module_project.id,
                                                                            guw_model_id: module_project.guw_model_id,
                                                                            pbs_project_element_id: pbs_project_element_id)
                                      end
                                    end
                                  end
                                  # Update the Module-Project positions (left = position_x, top = position_y)
                                  module_project.update_attributes(position_x: (row.cells[3].value.to_f rescue nil),
                                                                   position_y: (row.cells[4].value.to_f rescue nil),
                                                                   left_position: (row.cells[5].value.to_f rescue nil),
                                                                   top_position: (row.cells[6].value.to_f rescue nil),
                                                                   creation_order: (row.cells[7].value.to_f rescue nil),
                                                                   show_results_view: (row.cells[8].value.to_f rescue nil),
                                                                   wbs_activity_ratio_id: wbs_activity_ratio_id)

                                  @module_project_ids["#{module_project_name}"] = module_project.id
                                  @widgets_view_ids["#{module_project_name}"] = module_project.view_id
                                end
                              end
                            end
                          end
                        end
                      end

                      #============= Apres avoir créé tous les module_projects, on ajoute les relations/liens entre les modules
                      project_module_projects = @project.module_projects
                      @associated_module_projects.each do |module_project_name, associated_module_projects_array|
                        module_project = project_module_projects.all.select { |i| i.module_project_name ==  module_project_name }.first
                        associated_module_project_ids = []
                        if module_project
                          unless associated_module_projects_array.blank?
                            associated_module_projects_array.each do |amp_name|
                              if amp_name == "Initialization"
                                associated_module_project_ids << @initialization_module_project.id rescue nil
                              else
                                #associated_module_project_ids << project_module_projects.all.select { |i| i.module_project_name ==  amp_name }.first.id rescue nil
                                associated_module_project_ids << @module_project_ids["#{amp_name}"]
                              end
                            end

                            module_project.associated_module_project_ids = associated_module_project_ids.flatten.uniq.compact rescue nil
                            module_project.save
                          end
                        end
                      end

                      #======= Apres on ajoute les relations entre les entrée/sortie des modules
                      @associated_estimation_values.each do |module_project_name, associated_estimation_value_hash|
                        associated_module_project_ids = []
                        unless associated_estimation_value_hash.blank?
                          #module_project = project_module_projects.all.select { |i| i.module_project_name ==  module_project_name }.first
                          module_project = ModuleProject.find(@module_project_ids["#{module_project_name}"]) rescue nil
                          unless module_project.nil?
                            associated_estimation_value_hash.each do |mp_pe_attribute_name, ass_estimation_hash|
                              #======
                              effort_ids = []
                              output_attribute_ids = []
                              module_project_attributes = module_project.pemodule.pe_attributes

                              case module_project.pemodule.alias
                                when "effort_breakdown"
                                effort_ids = module_project_attributes.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten
                              when "ge"
                                effort_ids = module_project_attributes.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:id).flatten
                                output_attribute_ids = module_project_attributes.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:id).flatten
                              when "staffing"
                                staffing_input_pe_attributes = module_project_attributes.includes(:attribute_modules).where(:attribute_modules => { in_out: ['input', 'output', 'both'] }).all
                                effort_ids = staffing_input_pe_attributes.map(&:id).flatten
                              when "kb"
                                effort_ids = module_project_attributes.where(alias: Kb::KbModel::INPUT_ATTRIBUTES_ALIAS).map(&:id).flatten
                              when "skb"
                                effort_ids = module_project_attributes.where(alias: Skb::SkbModel::INPUT_ATTRIBUTES_ALIAS).map(&:id).flatten
                              when "expert_judgement"
                                effort_ids = module_project_attributes.where(alias: ExpertJudgement::Instance::INPUT_ATTRIBUTES_ALIAS).map(&:id).flatten
                              when "operation"
                                effort_ids = module_project_attributes.where(operation_model_id: @module_project.operation_model_id).map(&:id).flatten
                              else
                                effort_ids = module_project_attributes.where(alias: Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS).map(&:id).flatten
                              end

                              current_evs = module_project.estimation_values.where(organization_id: @organization.id, pe_attribute_id: effort_ids, in_out: "input")
                              estimation_value = current_evs.all.select{ |ev| ev.pe_attribute.name == mp_pe_attribute_name }.first

                              # Liaison
                              ass_pe_attribute_name = ass_estimation_hash[:pe_attribute_name]
                              ass_in_out = ass_estimation_hash[:in_out]
                              ass_module_project_name = ass_estimation_hash[:module_project_name]
                              ass_module_project = project_module_projects.all.select { |i| i.module_project_name ==  ass_module_project_name }.first

                              unless ass_module_project.nil?
                                ass_estimation_values = ass_module_project.estimation_values.where(organization_id: @organization.id, in_out: ass_in_out)
                                ass_estimation_values_pe_attributes = ass_estimation_values.all.map(&:pe_attribute)
                                ass_matched_pe_attribute = ass_estimation_values_pe_attributes.select {|attr| attr.name == ass_pe_attribute_name }.first
                                if ass_matched_pe_attribute
                                  ass_estimation_value = ass_estimation_values.where(:organization_id => @organization.id,
                                                                                     :pe_attribute_id => ass_matched_pe_attribute.id,
                                                                                     :in_out => ass_in_out).first
                                  estimation_value.estimation_value_id =  ass_estimation_value.id
                                  estimation_value.save
                                end
                              end

                              # #=====
                              # # Recuperation de l'attribut
                              # if ass_pemodule_alias.in?(["guw", "operation"])
                              #   all_attribute_modules = ass_module_project.pemodule.attribute_modules
                              #   case ass_pemodule_alias
                              #     when "guw"
                              #       ass_attribute_modules = all_attribute_modules.where(guw_model_id: module_project.guw_model_id)
                              #     when "operation"
                              #       ass_attribute_modules = all_attribute_modules.where(operation_model_id: module_project.operation_model_id)
                              #     else
                              #       ass_attribute_modules = all_attribute_modules
                              #   end
                              # else
                              #   ass_attribute_modules = ass_module_project.pemodule.attribute_modules
                              # end
                              #
                              # ass_pe_attributes = []
                              # ass_attribute_modules.each do |am|
                              #   pe_attribute = am.pe_attribute
                              #   unless pe_attribute.nil?
                              #     ass_pe_attributes << pe_attribute
                              #   end
                              # end
                              #
                              # ass_matched_pe_attributes = ass_pe_attributes.select { |attr| attr.name == ass_pe_attribute_name }
                              # ass_pe_attribute_id = ass_matched_pe_attributes.first.id rescue nil
                              # ass_estimation_value = module_project.estimation_values.where(:organization_id => @organization.id,
                              #                                                               :pe_attribute_id => ass_pe_attribute_id,
                              #                                                               :in_out => ass_in_out).first
                              # ass_estimation_value_id = ass_estimation_value.id rescue nil
                              #
                              # estimation_value.estimation_value_id =  ass_estimation_value_id
                              # estimation_value.save
                            end
                            #====
                          end
                        end
                      end
                    end


                    #=============Vignettes : worksheet_view_widgets = workbook[I18n.t(:views_widgets)]
                    #puts "Début Vues et Vignettes"
                    if !worksheet_view_widgets.nil?
                      worksheet_view_widgets.each_with_index do | row, index |
                        if index >= 1
                          view_widget_name = row.cells[0].value rescue nil
                          view_widget_name_mp = row.cells[1].value rescue nil
                          view_id = @widgets_view_ids["#{view_widget_name_mp}"]

                          attribute_name = row.cells[3].value rescue nil
                          in_out = row.cells[4].value rescue nil
                          show_name = row.cells[5].value rescue nil
                          show_tjm = row.cells[6].value rescue nil
                          equation = eval(row.cells[7].value) rescue nil
                          comment = row.cells[8].value rescue nil
                          is_label_widget = row.cells[9].value rescue nil
                          is_kpi_widget = row.cells[10].value rescue nil
                          kpi_unit = row.cells[11].value rescue nil
                          use_organization_effort_unit = row.cells[12].value rescue nil
                          is_project_data_widget = row.cells[13].value rescue nil
                          project_attribute_name = row.cells[14].value rescue nil
                          icon_class = row.cells[15].value rescue nil
                          color = row.cells[16].value rescue nil
                          show_min_max = row.cells[17].value rescue nil
                          width = row.cells[18].value rescue nil
                          height = row.cells[19].value rescue nil
                          widget_type = row.cells[20].value rescue nil
                          position = row.cells[21].value rescue nil
                          position_x = row.cells[22].value rescue nil
                          position_y = row.cells[23].value rescue nil
                          min_value = row.cells[24].value rescue nil
                          max_value = row.cells[25].value rescue nil
                          validation_text = row.cells[26].value rescue nil
                          show_wbs_activity_ratio = row.cells[27].value rescue nil
                          project_field = row.cells[28].value rescue nil

                          field_id = @organization. fields.where(name: project_field).first.id rescue nil
                          estimation_value_id = nil

                          begin
                            module_project_id = @module_project_ids["#{row.cells[2].value}"]
                            module_project = project_module_projects.where(id: module_project_id).first
                            mp_pemodule = module_project.pemodule rescue nil
                            pemodule_alias = mp_pemodule.alias rescue nil
                          rescue
                            module_project_id = nil
                            pemodule_alias = nil
                          end

                          pe_attributes = []
                          if is_label_widget==1 || is_kpi_widget == 1 || is_project_data_widget==1 || module_project_id.nil?
                            estimation_value_id = nil
                          else
                            # Recuperation de l'attribut
                            # if pemodule_alias.in?(["guw", "operation"])
                            #   all_attribute_modules = mp_pemodule.attribute_modules
                            #   case pemodule_alias
                            #     when "guw"
                            #       attribute_modules = all_attribute_modules.where(guw_model_id: module_project.guw_model_id)
                            #     when "operation"
                            #       attribute_modules = all_attribute_modules.where(operation_model_id: module_project.operation_model_id)
                            #     else
                            #       attribute_modules = all_attribute_modules
                            #   end
                            # else
                            #   attribute_modules = mp_pemodule.attribute_modules
                            # end
                            #
                            # attribute_modules.each do |am|
                            #   pe_attribute = am.pe_attribute
                            #   unless pe_attribute.nil?
                            #     pe_attributes << pe_attribute
                            #   end
                            # end
                            #
                            # matched_pe_attributes = pe_attributes.select { |attr| attr.name == attribute_name }
                            # pe_attribute_id = matched_pe_attributes.first.id rescue nil
                            # estimation_value = module_project.estimation_values.where(:organization_id => @organization.id,
                            #                                                           :pe_attribute_id => pe_attribute_id,
                            #                                                           :in_out => in_out).first
                            # estimation_value_id = estimation_value.id rescue nil


                            ####======= TEST ESTIMATION VALUE
                            unless module_project.nil?
                              estimation_values = module_project.estimation_values.where(organization_id: @organization.id, in_out: in_out)
                              estimation_values_pe_attributes = estimation_values.all.map(&:pe_attribute)
                              matched_pe_attribute = estimation_values_pe_attributes.select {|attr| attr.name == attribute_name}.first
                              if matched_pe_attribute
                                estimation_value = estimation_values.where(:organization_id => @organization.id,
                                                                           :pe_attribute_id => matched_pe_attribute.id).first
                                estimation_value_id = estimation_value.id rescue nil
                              end
                            end
                          end

                          if is_kpi_widget == 1
                            # Vignette Commentaires et Vignette KPI  : #Update KPI Widget aquation
                            unless equation.blank?
                              ["A", "B", "C", "D", "E"].each do |letter|
                                equation_letter = equation[letter]
                                letter_pe_attributes = []
                                unless equation_letter.nil?
                                  begin
                                    #===========
                                    mp_name = equation_letter[:module_project_name]
                                    mp_id = @module_project_ids["#{mp_name}"]
                                    mp = project_module_projects.where(id: mp_id).first   #mp = project_module_projects.all.select { |i| i.module_project_name ==  mp_name }.first
                                    ev_in_out = equation_letter[:in_out]

                                    letter_pemodule_alias = equation_letter[:pemodule_alias]
                                    letter_pemodule = mp.pemodule rescue nil

                                    # if letter_pemodule_alias.in?(["guw", "operation"])
                                    #   letter_all_attribute_modules = letter_pemodule.attribute_modules
                                    #   case letter_pemodule_alias
                                    #     when "guw"
                                    #       letter_attribute_modules = letter_all_attribute_modules.where(guw_model_id: mp.guw_model_id)
                                    #     when "operation"
                                    #       letter_attribute_modules = letter_all_attribute_modules.where(operation_model_id: mp.operation_model_id)
                                    #     else
                                    #       letter_attribute_modules = letter_all_attribute_modules
                                    #   end
                                    # else
                                    #   letter_attribute_modules = letter_pemodule.attribute_modules
                                    # end
                                    #
                                    # letter_attribute_modules.each do |am|
                                    #   letter_pe_attribute = am.pe_attribute
                                    #   unless letter_pe_attribute.nil?
                                    #     letter_pe_attributes << letter_pe_attribute
                                    #   end
                                    # end
                                    #
                                    # new_array = []
                                    #ev_pe_attribute_name = equation[letter][:pe_attribute_name]
                                    # ev_pe_attribute = letter_pe_attributes.select { |attr| attr.name == ev_pe_attribute_name }.first
                                    # est_val = mp.estimation_values.where(:organization_id => @organization.id,
                                    #                                      :pe_attribute_id => ev_pe_attribute.id,
                                    #                                      :in_out => ev_in_out).first
                                    # equation[letter] = [est_val.id, mp.id]
                                    #

                                    #==== TEST ESTIMATION VALUE
                                    ev_pe_attribute_name = equation[letter][:pe_attribute_name]
                                    unless mp.nil?
                                      estimation_values = mp.estimation_values.where(organization_id: @organization.id, in_out: ev_in_out)
                                      estimation_values_pe_attributes = estimation_values.all.map(&:pe_attribute)
                                      matched_pe_attribute = estimation_values_pe_attributes.select{ |attr| attr.name == ev_pe_attribute_name}.first
                                      if matched_pe_attribute
                                        estimation_value = estimation_values.where(:organization_id => @organization.id,
                                                                                   :pe_attribute_id => matched_pe_attribute.id).first
                                        estimation_value_id = estimation_value.id rescue nil
                                        equation[letter] = [estimation_value_id, mp.id]
                                      end
                                    end
                                    #==== TEST ESTIMATION VALUE
                                  rescue
                                    equation[letter] = nil
                                  end
                                end
                              end
                            end

                            new_view_widget = ViewsWidget.new(view_id: view_id,
                                                              module_project_id: module_project_id,
                                                              name: view_widget_name,
                                                              show_name: show_name,
                                                              show_tjm: show_tjm,
                                                              is_label_widget: is_label_widget,
                                                              comment: comment,
                                                              is_kpi_widget: is_kpi_widget,
                                                              kpi_unit: kpi_unit,
                                                              equation: equation,
                                                              is_project_data_widget: is_project_data_widget,
                                                              project_attribute_name: project_attribute_name,
                                                              icon_class: icon_class,
                                                              color: color,
                                                              show_min_max: show_min_max,
                                                              widget_type: widget_type,
                                                              width: width,
                                                              height: height,
                                                              position: position,
                                                              position_x: position_x,
                                                              min_value: min_value,
                                                              max_value: max_value,
                                                              validation_text: validation_text,
                                                              position_y: position_y)

                            #new_view_widget.save
                            if new_view_widget.save
                              #Update the copied project_fields
                              unless project_field.blank?
                                unless field_id.nil?
                                  ProjectField.create(project_id: @project.id, views_widget_id: new_view_widget.id, field_id: field_id)
                                end
                              end
                            end
                          else
                            new_view_widget = ViewsWidget.new(view_id: view_id,
                                                              module_project_id: module_project_id,
                                                              estimation_value_id: estimation_value_id,
                                                              name: view_widget_name,
                                                              show_name: show_name,
                                                              show_tjm: show_tjm,
                                                              show_wbs_activity_ratio: show_wbs_activity_ratio,
                                                              is_label_widget: is_label_widget,
                                                              comment: comment,
                                                              is_kpi_widget: is_kpi_widget,
                                                              kpi_unit: kpi_unit,
                                                              equation: equation,
                                                              is_project_data_widget: is_project_data_widget,
                                                              project_attribute_name: project_attribute_name,
                                                              icon_class: icon_class,
                                                              color: color,
                                                              show_min_max: show_min_max,
                                                              widget_type: widget_type,
                                                              use_organization_effort_unit: use_organization_effort_unit,
                                                              width: width,
                                                              height: height,
                                                              position: position,
                                                              position_x: position_x,
                                                              position_y: position_y,
                                                              min_value: min_value,
                                                              max_value: max_value,
                                                              validation_text: validation_text)
                            if new_view_widget.save
                              #Update the copied project_fields
                              unless project_field.blank?
                                unless field_id.nil?
                                  ProjectField.create(project_id: @project.id, views_widget_id: new_view_widget.id, field_id: field_id)
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                    #puts "Fin Vues et Vignettes"
                    flash[:notice] = "Le modèle d'estimation a été importé avec succès"
                    redirect_to edit_project_path(@project, organization_id: @organization.id) and return
                  else
                    flash[:error] = "#{I18n.t(:error_project_creation_failed)}" #Une erreur est survenue lors de la création du devis
                    redirect_to new_project_path(is_model: params[:is_model], organization_id: @organization.id) and return
                  end
                rescue ActiveRecord::UnknownAttributeError, ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid => error
                  #p error
                  flash[:error] = "#{I18n.t (:error_project_creation_failed)} #{@project.errors.full_messages.to_sentence}"
                  redirect_to new_project_path(is_model: params[:is_model], organization_id: @organization.id) and return
                end
              end
            else
              flash[:error] = "La feuille propriétés globales n'existe pas"
            end
          else
            flash[:error] =  I18n.t(:route_flag_error_4)
          end
        else
          flash[:error] = I18n.t(:route_flag_error_17)
          redirect_to new_project_path(is_model: params[:is_model], organization_id: @organization.id) and return
        end
      else
        #Aucune organisation sélectionnée
        flash[:error] = "Aucune organisation sélectionnée"
        redirect_to new_project_path(is_model: params[:is_model], organization_id: @organization.id) and return
      end
    end
    #redirect_to request.referer
    redirect_to new_project_path(is_model: params[:is_model], organization_id: @organization.id) and return
  end


  #====================  IMPORT / EXPORT WORKFLOW STATUTS DES ESTIMATION  ====================#
  # Exporter les statuts des estimations et le Workflow
  def export_estimation_statuses_workflow
    organization_id = params[:organization_id]
    tab_errors = []
    ActiveRecord::Base.transaction do

      workbook = RubyXL::Workbook.new
      @organization = Organization.find(organization_id)

      if @organization
        worksheet_status_list = workbook.worksheets[0]
        worksheet_status_list.sheet_name = "#{I18n.t(:estimation_status)}-Workflow"
        #worksheet_workflow = workbook.add_worksheet("Rôles")
        @organization_groups = @organization.groups

        i = 0
        #Plan d'estimation : worksheet_estimation_plan
        worksheet_status_list.add_cell(0, i, I18n.t(:status_number))
        worksheet_status_list.add_cell(0, i += 1, "Alias")
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:name))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:archive_status))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:new_status))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:create_new_version_when_status_changed))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:status_color))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:description))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:manage_estimations_statuses_workflow))
        worksheet_status_list.add_cell(0, i += 1, I18n.t(:label_role))

        @organization.estimation_statuses.each_with_index do |estimation_status, index|
          j = 0
          worksheet_status_list.add_cell(index+1, j, estimation_status.status_number)
          worksheet_status_list.add_cell(index+1, j += 1, estimation_status.status_alias)
          worksheet_status_list.add_cell(index+1, j += 1, estimation_status.name)
          worksheet_status_list.add_cell(index+1, j += 1, (estimation_status.is_archive_status ? 1 : 0))
          worksheet_status_list.add_cell(index+1, j += 1, (estimation_status.is_new_status ? 1 : 0))
          worksheet_status_list.add_cell(index+1, j += 1, (estimation_status.create_new_version_when_changing_status ? 1 : 0))
          worksheet_status_list.add_cell(index+1, j += 1, estimation_status.status_color)
          worksheet_status_list.add_cell(index+1, j += 1, estimation_status.description)
          worksheet_status_list.add_cell(index+1, j += 1, (estimation_status.to_transition_statuses.map(&:status_alias).uniq.inspect rescue nil))

          status_group_roles = Hash.new

          @organization_groups.each do |group|
            esgr = EstimationStatusGroupRole.where(group_id: group.id,
                                                   estimation_status_id: estimation_status.id,
                                                   organization_id: @organization.id).first

            if esgr
              psl = @organization.project_security_levels.where(id: esgr.project_security_level_id).first
              if psl
                status_group_roles["#{group.name}"] = psl.name
              end
            end
          end
          worksheet_status_list.add_cell(index+1, j += 1, (status_group_roles.inspect rescue nil))
        end

        worksheet_status_list.change_column_width(1, 20)
        worksheet_status_list.change_column_width(2, 30)
        worksheet_status_list.change_column_width(7, 90)
        worksheet_status_list.change_column_width(8, 50)
      else
        flash[:error] = "Aucune organisation sélectionnée"
        redirect_to organization_setting_path(@organization, anchor: "tabs-estimations-statuses") and return
      end

      send_data(workbook.stream.string, filename: "#{@organization.name}-EstimationStatusWorkflow-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
    end
  end



  # Importer les statuts des estimations et le Workflow
  def import_estimation_statuses_workflow
    ActiveRecord::Base.transaction do

      organization_id = params[:organization_id]
      if !organization_id.blank?
        @organization = Organization.find(organization_id)
        @organization_groups = @organization.groups
        @organization_project_security_levels = @organization.project_security_levels

        if params[:file]
          if !params[:file].nil? && (File.extname(params[:file].original_filename).to_s.downcase == ".xlsx")
            #get the file data
            workbook = RubyXL::Parser.parse(params[:file].path)
            worksheet_status_list = workbook.worksheets[0]
            add_or_replace_status = params[:add_or_replace_status]
            @status_transtions = Hash.new
            @new_status_alias = Array.new

            if !worksheet_status_list.nil?

              worksheet_status_list.each_with_index do | row, index |
                if index >= 1
                  status_number = row.cells[0].value rescue nil
                  status_alias = row.cells[1].value rescue nil
                  name = row.cells[2].value rescue nil
                  is_archive_status = row.cells[3].value rescue nil
                  is_new_status = row.cells[4].value rescue nil
                  create_new_version_when_changing_status = row.cells[5].value rescue nil
                  status_color = row.cells[6].value rescue nil
                  description = row.cells[7].value rescue nil
                  to_transition_statuses = eval(row.cells[8].value) rescue nil
                  status_group_roles = eval(row.cells[9].value) rescue nil
                  @status_transtions["#{status_alias}"] = to_transition_statuses

                  estimation_status = @organization.estimation_statuses.where(status_alias: status_alias).first
                  if estimation_status.nil?
                    estimation_status = EstimationStatus.new(organization_id: @organization.id, name: name,
                                                                 status_number: status_number,
                                                                 status_alias: status_alias,
                                                                 is_archive_status: is_archive_status,
                                                                 is_new_status: is_new_status,
                                                                 create_new_version_when_changing_status: create_new_version_when_changing_status,
                                                                 status_color: status_color,
                                                                 description: description)
                    if estimation_status.save
                      @new_status_alias << status_alias

                      #Add Group/Roles
                      unless status_group_roles.blank?
                        status_group_roles.each do |group_name, psl_name|
                          group = @organization_groups.where(name: group_name).first_or_create(organization_id: @organization.id, name: group_name)
                          psl = @organization_project_security_levels.where(name: psl_name).first_or_create(organization_id: @organization.id, name: psl_name)
                          unless psl.nil? || group.nil?
                            estimation_status.estimation_status_group_roles.create(organization_id: @organization.id,
                                                                                   group_id: group.id,
                                                                                   project_security_level_id: psl.id,
                                                                                   originator_id: @current_user.id, event_organization_id: @organization.id)
                          end
                        end
                      end
                    end
                  end
                end
              end

              # On met à jour le Workflow
              @status_transtions.each do |status_alias, to_transition_statuses|
                estimation_status = @organization.estimation_statuses.where(status_alias: status_alias).first
                if estimation_status
                  new_to_transition_status_ids = []
                  to_transition_statuses.each do |to_status_alias|
                    to_status = @organization.estimation_statuses.where(status_alias: to_status_alias).first

                    if to_status && (@new_status_alias.include?(status_alias) || @new_status_alias.include?(to_status_alias))
                      new_to_transition_status_ids << to_status.id
                    end
                  end

                  unless new_to_transition_status_ids.blank?
                    old_to_transition_status_ids = estimation_status.to_transition_status_ids
                    all_to_transition_status_ids = old_to_transition_status_ids + new_to_transition_status_ids
                    estimation_status.update_attribute('to_transition_status_ids', all_to_transition_status_ids.uniq)
                  end
                end
              end

              flash[:notice] = "Les statuts des estimations et le workflow ont été importés avec succès"
              redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-estimations-statuses") and return
            else
              flash[:error] = "La feuille de la liste des statuts des estimations n'existe pas"
            end
          else
            flash[:error] =  I18n.t(:route_flag_error_4)
          end
        else
          flash[:error] = I18n.t(:route_flag_error_17)
          redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-estimations-statuses") and return
        end
      else
        #Aucune organisation sélectionnée
        flash[:error] = "Aucune organisation sélectionnée"
        redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-estimations-statuses") and return
      end
    end
  end

  #====================

  #Pour gestion des rapports personnalisés
  def report_management
  end

  #Calculate Mixed Profiles
  def calculate_mixed_profiles
    @organization = Organization.where(id: params[:organization_id]).first

    OrganizationProfile.transaction do
      begin
        real_profiles_with_dynamic_coeff = @organization.organization_profiles.where(is_real_profile: true, use_dynamic_coefficient: true)
        r_value = 0.25
        tm_value = 0.5
        r_value = params[:r_value].to_f
        tm_value = params[:tm_value].to_f

        real_profiles_with_dynamic_coeff.all.each do |profile|
          used_cost = profile.initial_cost_per_hour.to_f * (1 - (tm_value * r_value))
          profile.cost_per_hour = used_cost
          profile.r_value = r_value
          profile.tm_value = tm_value
          profile.formula = "#{profile.cost_per_hour.to_f} * #{(1 - (tm_value * r_value))}"
          profile.save
        end

        #MAJ de la valeur de TM dans le projet
        platform_category = @organization.platform_categories.first #_or_create(name: "#{tm_value*100} %")
        if platform_category
          platform_category.name = "#{tm_value*100}%"
          platform_category.save
        else
          @organization.platform_categories.create(name: "#{tm_value*100}%")
        end

      rescue
        flash[:error] = "Erreur MAJ profils"
      end
    end

    redirect_to edit_organization_path(@organization, anchor: "tabs-dt")
  end

  # Export PDF de la liste des changements
  def export_to_pdf_security_audit_utilities
    @organization = @current_organization  #Organization.find(params[:organization_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date] || DateTime.now

    redirect_to all_organizations_path if @organization.nil? and return

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
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_areas", partial_name: 'tabs_project_areas')
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
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_categories", partial_name: 'tabs_project_categories')
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
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-platform_categories", partial_name: 'tabs_platform_categories')
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
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-acquisition_categories", partial_name: 'tabs_acquisition_categories')
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
        unless row.nil?
          if index > 0 && !row[0].value.nil?
            new_profile = OrganizationProfile.where(name: row[0].value, organization_id: @organization.id).first
            if new_profile
              tab_warning_messages << " \n\n #{new_profile.name} : #{I18n.t(:warning_already_exist)}"
            else
              #begin
                #new_profile = OrganizationProfile.new(name: (row[0].value rescue nil), description: (row[1].value rescue nil), cost_per_hour: (row[2].value rescue nil), organization_id: @organization.id)
                new_profile = OrganizationProfile.new(name: (row[0].value rescue nil), description: (row[1].value rescue nil), initial_cost_per_hour: (row[2].value rescue nil),
                                                      is_real_profile: (row[3].value rescue nil), use_dynamic_coefficient: (row[4].value rescue nil),
                                                      r_value: (row[5].value rescue nil), tm_value: (row[6].value rescue nil),
                                                      formula: (row[7].value rescue nil), cost_per_hour: (row[8].value rescue nil),
                                                      associated_services: (row[9].value rescue nil),
                                                      organization_id: @organization.id)
                unless new_profile.save
                  tab_error << index + 1
                end
              # rescue
              #   tab_error << index + 1
              # end
            end
          elsif row[0].value.nil?
            tab_error << index + 1
          end
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = "Une erreur est survenue durant l'import"
    end
    flash[:warning] = tab_warning_messages
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-project_profile", partial_name: 'tabs_profiles')
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
    redirect_to organization_setting_path(organization_id: @organization.id, anchor: "tabs-providers", partial_name: 'tabs_providers')
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

    if params[:MYonglet] == "OrganizationProfile"
      # Export des OrganozationProfiles
      organization_profiles = @organization.organization_profiles
      worksheet.add_cell(0, 0, I18n.t(:name))
      worksheet.add_cell(0, 1, I18n.t(:description))
      worksheet.add_cell(0, 2, I18n.t(:initial_cost_per_hour))
      worksheet.add_cell(0, 3, I18n.t(:is_real_profile))
      worksheet.add_cell(0, 4, I18n.t(:use_dynamic_coefficient))
      worksheet.add_cell(0, 5, "R")
      worksheet.add_cell(0, 6, "TM")
      worksheet.add_cell(0, 7, I18n.t(:formula))
      worksheet.add_cell(0, 8, I18n.t(:cost_per_hour))
      worksheet.add_cell(0, 9, I18n.t(:associated_services))

      organization_profiles.each_with_index do |profile, index|
        worksheet.add_cell(index + 1, 0, profile.name)
        worksheet.add_cell(index + 1, 1, profile.description)
        worksheet.add_cell(index + 1, 2, profile.initial_cost_per_hour)
        worksheet.add_cell(index + 1, 3, profile.is_real_profile ? 1 : 0)
        worksheet.add_cell(index + 1, 4, profile.use_dynamic_coefficient ? 1 : 0)
        worksheet.add_cell(index + 1, 5, profile.r_value)
        worksheet.add_cell(index + 1, 6, profile.tm_value)
        worksheet.add_cell(index + 1, 7, profile.formula)
        worksheet.add_cell(index + 1, 8, profile.cost_per_hour)
        worksheet.add_cell(index + 1, 9, profile.associated_services)
      end

    else
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

          app = Application.where(organization_id: @organization.id,
                                  name: row[0].nil? ? nil : row[0].value).first

          if app.nil?

            new_app = Application.new(organization_id: @organization.id,
                                      name: (row.nil? ? flash[:error] = I18n.t(:route_flag_error_3) : (row[0].nil? ? nil : row[0].value)),
                                      is_ignored: row[1].nil? ? nil : row[1].value,
                                      criticality: row[2].nil? ? nil : row[2].value,
                                      coefficient: row[3].nil? ? nil : row[3].value,
                                      coefficient_label: row[4].nil? ? nil : row[4].value)
            unless new_app.save
              tab_error << index + 1
            end

          else
            app.organization_id = @organization.id
            app.is_ignored = row[1].nil? ? nil : row[1].value
            app.coefficient = row[2].nil? ? nil : row[2].value
            app.coefficient_label = row[3].nil? ? nil : row[3].value
            app.save
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
    worksheet.add_cell(0, 1, I18n.t(:is_ignored))
    worksheet.add_cell(0, 2, I18n.t(:coefficient_value))
    worksheet.add_cell(0, 3, I18n.t(:coefficient_label))

    organization_appli.each_with_index do |appli, index|
      worksheet.add_cell(index + 1, 0, appli.name)
      worksheet.add_cell(index + 1, 1, appli.is_ignored ? 1 : 0)
      worksheet.add_cell(index + 1, 2, appli.coefficient)
      worksheet.add_cell(index + 1, 3, appli.coefficient_label)
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
                guw_coefficient = Guw::GuwCoefficient.where(guw_model_id: @guw_model.id, name: i[0]).first
                unless guw_coefficient.nil?
                  unless guw_coefficient.guw_coefficient_elements.empty?
                    ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                      guw_model_id: @guw_model.id,
                                                                      guw_coefficient_id: guw_coefficient.id,
                                                                      project_id: project.id,
                                                                      module_project_id: mp.id,
                                                                      guw_unit_of_work_id: guow.id).first

                    if guw_coefficient.coefficient_type == "Pourcentage"
                      worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                    elsif guw_coefficient.coefficient_type == "Coefficient"
                      worksheet.add_cell(ind, 20+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
                    else
                      worksheet.add_cell(ind, 20+j, ceuw.nil? ? '' : ceuw.guw_coefficient_element.nil? ? ceuw.percent : ceuw.guw_coefficient_element.name)
                    end
                  end
                end
              elsif Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: i[0]).first.class == Guw::GuwOutput
                guw_output = Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: i[0]).first
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
              guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: @organization.id,
                                                        guw_model_id: @guw_model.id,
                                                        guw_attribute_id: guw_attribute.id,
                                                        guw_type_id: guw_type.nil? ? nil : guw_type.id,
                                                        project_id: project.id,
                                                        module_project_id: mp.id,
                                                        guw_unit_of_work_id: guow.id).first

              unless guowa.nil?
                gat = Guw::GuwAttributeType.where(organization_id: @organization.id,
                                                  guw_model_id: @guw_model.id,
                                                  guw_type_id: guw_type.id,
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
              kk = header.size - @wbs_activity.wbs_activity_elements.where(organization_id: @organization.id).select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten.size - 1 #-1 for TJM moyen

              @wbs_activity_ratio = @wbs_activity.wbs_activity_ratios.where(organization_id: @organization.id).first
              @module_project_ratio_elements = @wbs_activity_module_project.get_module_project_ratio_elements(@wbs_activity_ratio, mp)
              @root_module_project_ratio_element = @module_project_ratio_elements.select{|i| i.root? }.first

              tjm_array = []

              calculator = Dentaku::Calculator.new

              @wbs_activity.wbs_activity_elements.where(organization_id: @organization.id).select{|i| !i.root? }.each_with_index do |wbs_activity_element|

                guw_output_effort = Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: "Charge RTU (jh)").first

                if guw_output_effort.nil?
                  guw_output_effort = Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: "Charge RIS (jh)").first
                end
                guw_output_test = Guw::GuwOutput.where(organization_id: @organization.id, guw_model_id: @guw_model.id, name: "Assiette Test (jh)").first

                mp_ratio_element = @module_project_ratio_elements.select { |mp_ratio_elt| mp_ratio_elt.wbs_activity_element_id == wbs_activity_element.id }.first

                begin

                  guw_output_effort_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"].to_f.round(2)))
                  guw_output_test_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_test.id}"].to_f.round(2)))

                  corresponding_ratio_elt = WbsActivityRatioElement.where(organization_id: @organization.id,
                                                                          wbs_activity_id: @wbs_activity.id,
                                                                          wbs_activity_ratio_id: @wbs_activity_ratio.id,
                                                                          wbs_activity_element_id: wbs_activity_element.id).first

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

      @projects = @organization.projects.where(is_model: false).where("title like ?", "%#{params[:title]}%").all

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

      selected_inline_columns.each_with_index do |sic, i|
        worksheet.add_cell(0, i, I18n.t(sic.name))
      end

      @projects.each_with_index do |project, i|
        selected_inline_columns.each_with_index do |column, j|
          worksheet.add_cell(i+1, j, column_content_without_content_tag(@pfs, column, project, @fields_coefficients))
        end
      end

    end

    send_data(workbook.stream.string, filename: "export_estimations.xlsx", type: "application/vnd.ms-excel")

  end

  def generate_report_excel_detail

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    ind = 0

    @organization = @current_organization
    @organization.projects.each do |project|

      module_project = project.module_projects.where(organization_id: @organization.id).select{|i| i.pemodule.alias == "guw" }.first

      unless module_project.nil?
        @guw_model = module_project.guw_model
        @wbs_activity_module_project = module_project.nexts.where.not(wbs_activity_id: nil).first
        unless @wbs_activity_module_project.nil?
          @wbs_activity = @wbs_activity_module_project.wbs_activity
        end

        unless @wbs_activity.nil?
          @component = current_component
          @guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: @organization.id,
                                                        module_project_id: module_project,
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

          # worksheet.change_row_bold(0,true)

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
                guw_coefficient = Guw::GuwCoefficient.where(guw_model_id: @guw_model.id, name: i[0]).first
                unless guw_coefficient.nil?
                  unless guw_coefficient.guw_coefficient_elements.empty?
                    unless module_project.nil?
                      ceuw = Guw::GuwCoefficientElementUnitOfWork.where(module_project_id: module_project.id,
                                                                        guw_unit_of_work_id: guow.id,
                                                                        guw_coefficient_id: guw_coefficient.id).first

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

    send_data(workbook.stream.string, filename: "#{@organization.name}-#{@guw_model.name}-#{Time.now.strftime('%Y-%m-%d-%H-%M')}.xlsx", type: "application/vnd.ms-excel")

  end

  def report
    @organization = Organization.find(params[:organization_id])
    set_page_title I18n.t(:report, parameter: @organization)
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), I18n.t(:report) => ""
    check_if_organization_is_image(@organization)
    @projects = @current_organization.projects.where(is_model: false)
    @reports_list = ["filtered_excel_report", "detailed_excel_report", "detailed_pdf_report", "raw_data_extract", "budget_report", "budget_excel_report"]
    @organization_show_reports_keys = @organization.show_reports.keys
    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

    unless params[:budget_id].blank? || params[:application_id].blank?
      @application = Application.find(params[:application_id])
      @budget = Budget.find(params[:budget_id])
    end
  end

  def authorization
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""
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
    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:Parameter, parameter: @organization)

    #@technologies = @organization.organization_technologies
    @fields = @organization.fields
    @work_element_types = @organization.work_element_types

    @organization_profiles = @organization.organization_profiles.where("name LIKE ?", "%#{params[:advanced_search]}%")

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
    set_page_title (I18n.t('setting_demands'))

    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

    @organization = Organization.find(params[:organization_id])
    @demands = Demand.where(organization_id: @organization.id).all
    @demand_statuses = @organization.demand_statuses.order("status_number ASC")
    @demand_types = DemandType.where(organization_id: @organization.id).all
    @livrables = Livrable.where(organization_id: @organization.id).all
    @services = Service.where(organization_id: @organization.id).all
    @allow_demand = params[:allow_demand]

  end

  def module_estimation
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), I18n.t(:label_estimation_modules) => ""
    set_page_title I18n.t(:module ,parameter: @organization)
    @guw_models = @organization.guw_models.order("name asc")
    @skb_models = @organization.skb_models.order("name asc")
    @wbs_activities = @organization.wbs_activities.order("name asc")
  end

  def users
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:spec_users, parameter: @organization)
  end

  def async_estimations
    #
    # @organization = Organization.find(params[:organization_id])
    #
    # if params[:filter_version].present?
    #   @filter_version = params[:filter_version]
    # else
    #   @filter_version = '4'
    # end
    #
    # @object_per_page = (current_user.object_per_page || 10)
    #
    # if params[:min].present? && params[:max].present?
    #   @min = params[:min].to_i
    #   @max = params[:max].to_i
    # else
    #   @min = 0
    #   @max = @object_per_page
    # end
    #
    # if session[:sort_action].blank?
    #   session[:sort_action] = "true"
    # end
    #
    # if session[:sort_column].blank?
    #   session[:sort_column] = "start_date"
    # end
    #
    # if session[:sort_order].blank?
    #   session[:sort_order] ="desc"
    # end
    #
    # @sort_action = params[:sort_action].blank? ? session[:sort_action] : params[:sort_action]
    # @sort_column = params[:sort_column].blank? ? session[:sort_column] : params[:sort_column]
    # @sort_order = params[:sort_order].blank? ? session[:sort_order] : params[:sort_order]
    #
    # @search_column = session[:search_column]
    # @search_value = session[:search_value]
    # @search_hash = (params['search'].blank? ? session[:search_hash] : params['search'])
    # @search_hash ||=  {}
    # @search_string = ""
    #
    # # Pour garder le tri même lors du rafraichissement de la page
    # projects = @organization.projects.where(:is_model => [nil, false])
    # organization_projects = get_sorted_estimations(@organization.id, projects, @sort_column, @sort_order, @search_hash)
    #
    # res = []
    # organization_projects.each do |p|
    #   if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
    #     res << p
    #   end
    #
    #   # if can?(:see_project, p.project, estimation_status_id: p.project.estimation_status_id)
    #   #   res << p.project
    #   # end
    # end
    #
    # @projects = res[@min..@max].nil? ? [] : res[@min..@max-1]
    #
    # last_page = res.paginate(:page => 1, :per_page => @object_per_page).total_pages
    # @last_page_min = (last_page.to_i-1) * @object_per_page
    # @last_page_max = @last_page_min + @object_per_page
    #
    # if params[:is_last_page] == "true" || (@min == @last_page_min)
    #   @is_last_page = "true"
    # else
    #   @is_last_page = "false"
    # end
    #
    # session[:sort_column] = @sort_column
    # session[:sort_order] = @sort_order
    # session[:sort_action] = @sort_action
    # session[:is_last_page] = @is_last_page
    # session[:search_column] = @search_column
    # session[:search_value] = @search_value
    # session[:search_hash] = @search_hash
    #
    # @fields_coefficients = {}
    # @pfs = {}
    #
    # fields = @organization.fields
    # ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
    #   begin
    #     if pf.field_id.in?(fields.map(&:id))
    #       if pf.project && pf.views_widget
    #         if pf.project_id == pf.views_widget.module_project.project_id
    #           @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
    #         else
    #           pf.delete
    #         end
    #       else
    #         pf.delete
    #       end
    #     else
    #       pf.delete
    #     end
    #
    #   rescue
    #     #puts "erreur"
    #   end
    # end
    #
    # fields.each do |f|
    #   @fields_coefficients[f.id] = f.coefficient
    # end
    #
    # render :partial => 'organizations/organization_projects', object: [@organization, @projects]
  end

  def estimations
    @organization = Organization.find(params[:organization_id])

    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""
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
      #session[:sort_column] = "start_date"
      project_selected_columns = @organization.project_selected_columns
      default_sort_column = @organization.default_estimations_sort_column rescue nil
      default_sort_order = @organization.default_estimations_sort_order rescue nil

      if !default_sort_column.blank? && default_sort_column.in?(project_selected_columns)
        session[:sort_column] = default_sort_column
        session[:sort_order] = default_sort_order
      else
        # session[:sort_column] = "title"
        # session[:sort_order] = "asc"

        session[:sort_column] = "created_at"
        session[:sort_order] = "desc"
      end
    end

    if session[:sort_order].blank?
      if session[:sort_column].in?(["start_date", "created_at"])
        session[:sort_order] ="desc"
      end
    end

    @sort_action = params[:sort_action].blank? ? session[:sort_action] : params[:sort_action]
    @sort_column = params[:sort_column].blank? ? session[:sort_column] : params[:sort_column]
    @sort_order = params[:sort_order].blank? ? session[:sort_order] : params[:sort_order]

    # @search_column = session[:search_column]
    # @search_value = session[:search_value]
    #@search_hash =  {} #session[:search_hash] || {}
    # @search_hash = (params['search'].blank? ? session[:search_hash] : params['search'])
    # @search_hash ||=  {}
    @search_hash = nil
    # @search_string = ""
    final_results = []

    # Pour garder le tri même lors du raffraichissement de la page

    # statuts = EstimationStatus.where(name: ["En cours", "En relecture","A valider", "Brouillon","Préliminaire", "A revoir"]).all
    # projects = @organization.projects.where(:is_model => [nil, false], :estimation_status_id => statuts)

    organization_projects = @organization.projects.where(:is_model => [nil, false])
    if params[:archive].present?
      esids = EstimationStatus.where(name: ["Archivé", "Rejeté", "Abandonnée", "Archived", "Rejected"]).map(&:id)
      @all_projects = organization_projects.where(estimation_status_id: esids)
    else
      esids = EstimationStatus.where(name: ["Archivé", "Rejeté", "Abandonnée", "Archived", "Rejected"]).map(&:id)
      @all_projects = organization_projects.where.not(estimation_status_id: esids)
    end

    organization_projects = get_sorted_estimations(@organization.id, @all_projects, @sort_column, @sort_order, @search_hash)

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

    @fields_coefficients = {}
    @pfs = {}

    fields = @organization.fields
    ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(fields.map(&:id))
          if pf.project && pf.views_widget
            if pf.project_id == pf.views_widget.module_project.project_id

              if pf.field.name.to_s.in?(["Max. Staff.", "Staff. max."])
                @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = (pf.value.blank? ? nil : pf.value.to_f.round_up_by_step(0.1).round(1))
              else
                @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
              end
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

    # if user_signed_in?
    #   Monitoring.create(user: User.current, action: "Accéder à la liste des devis de l'organisation #{@organization.name}", action_at: Time.now+3600)
    # end

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
    #old_prj = Project.where(organization_id: new_organization_id, id: project_id).first #.find(project_id)
    old_prj = Project.where(id: project_id).first #.find(project_id)
    old_organization_id = old_prj.organization_id
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
        app = Application.where(organization_id: new_organization.id, name: application.name).first
        ap = ApplicationsProjects.create(application_id: app.id, project_id: new_prj.id)
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

      ###======= Ajout apres gestion Temps reponse
      #update Projects ModulesProjects

      new_prj.module_projects.update_all(organization_id: new_organization_id)
      new_prj.module_projects.each do |module_project|
        module_project.estimation_values.update_all(organization_id: new_organization_id)
      end

      ###======= Fin Ajout apres gestion Temps reponse

      #Update the project securities for the current user who create the estimation from model
      #if params[:action_name] == "create_project_from_template"
      if old_prj.is_model
        unless old_prj.creator.nil?
          creator_securities = old_prj.creator.project_securities_for_select(new_prj.id, new_organization.id)
          unless creator_securities.nil?
            creator_securities.update_attribute(:user_id, user.id)
          end
        end
      end
      #Other project securities for groups
      new_prj.project_securities.where(organization_id: new_organization.id).where.not(group_id: nil).each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        new_group = new_organization.groups.where(copy_id: project_security.group_id).first
        if new_security_level.nil? || new_group.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id, group_id: new_group.id)
        end
      end

      #Other project securities for users
      new_prj.project_securities.where(organization_id: new_organization.id).where.not(user_id: nil).each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        if new_security_level.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id)
        end
      end

      # For ModuleProject associations
      old_prj.module_projects.where(organization_id: old_organization_id).group(:id).each do |old_mp|
        new_mp = ModuleProject.where(organization_id: new_organization_id, project_id: new_prj.id, copy_id: old_mp.id).first #.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

        # ModuleProject Associations for the new project
        old_mp.associated_module_projects.each do |associated_mp|
          new_associated_mp = ModuleProject.where(organization_id: new_organization.id, project_id: new_prj.id, copy_id: associated_mp.id).first
          new_mp.associated_module_projects << new_associated_mp
        end

        ##========================== NEW =======
        # Wbs activity create module_project ratio elements
        old_mp.module_project_ratio_elements.where(organization_id: old_organization_id).each do |old_mp_ratio_elt|
          #wbs_activity
          old_wbs_activity_id = old_mp_ratio_elt.wbs_activity_ratio.wbs_activity_id
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: old_wbs_activity_id).first

          mp_ratio_element = old_mp_ratio_elt.dup
          mp_ratio_element.module_project_id = new_mp.id
          mp_ratio_element.copy_id = old_mp_ratio_elt.id
          mp_ratio_element.organization_id = new_organization_id
          mp_ratio_element.wbs_activity_id = new_wbs_activity.id

          # pbs
          pbs = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first
          pbs_id = pbs.nil? ? nil : pbs.id
          mp_ratio_element.pbs_project_element_id = pbs_id


          if new_wbs_activity.nil?
            mp_ratio_element.wbs_activity_element_id = nil
            mp_ratio_element.wbs_activity_ratio_id = nil
            mp_ratio_element.wbs_activity_ratio_element_id = nil
          else
            # wbs_activity_element
            new_wbs_activity_element = new_wbs_activity.wbs_activity_elements.where(organization_id: new_organization.id, copy_id: old_mp_ratio_elt.wbs_activity_element_id).first
            new_wbs_activity_element_id = new_wbs_activity_element.nil? ? nil : new_wbs_activity_element.id
            mp_ratio_element.wbs_activity_element_id = new_wbs_activity_element_id

            # wbs_activity_ratio
            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(organization_id: new_organization.id, copy_id: old_mp_ratio_elt.wbs_activity_ratio_id).first

            if new_wbs_activity_ratio.nil?
              mp_ratio_element.wbs_activity_ratio_id = nil
              mp_ratio_element.wbs_activity_ratio_element_id = nil
            else
              mp_ratio_element.wbs_activity_ratio_id = new_wbs_activity_ratio.id

              # wbs_activity_ratio_element
              new_wbs_activity_ratio_element = new_wbs_activity_ratio.wbs_activity_ratio_elements.where(organization_id: new_organization.id, copy_id: old_mp_ratio_elt.wbs_activity_ratio_element_id).first
              wbs_activity_ratio_element_id = new_wbs_activity_ratio_element.nil? ? nil : new_wbs_activity_ratio_element.id

              mp_ratio_element.wbs_activity_ratio_element_id = wbs_activity_ratio_element_id
            end
          end

          mp_ratio_element.save
        end

        new_mp_ratio_elements = new_mp.module_project_ratio_elements.where(organization_id: new_organization.id)
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

        #module_project_ratio_variables
        old_mp.module_project_ratio_variables.each do |old_mp_ratio_variable|
          #wbs_activity
          old_wbs_activity_id = old_mp_ratio_variable.wbs_activity_ratio.wbs_activity_id
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: old_wbs_activity_id).first

          mp_ratio_variable = old_mp_ratio_variable.dup
          mp_ratio_variable.module_project_id = new_mp.id
          mp_ratio_variable.copy_id = old_mp_ratio_variable.id
          mp_ratio_variable.organization_id = new_organization_id
          mp_ratio_variable.wbs_activity_id = new_wbs_activity.id

          # pbs
          pbs = new_prj_components.where(copy_id: old_mp_ratio_variable.pbs_project_element_id).first
          pbs_id = pbs.nil? ? nil : pbs.id
          mp_ratio_variable.pbs_project_element_id = pbs_id

          if new_wbs_activity.nil?
            mp_ratio_variable.wbs_activity_ratio_id = nil
            mp_ratio_variable.wbs_activity_ratio_variable_id = nil
          else
            # wbs_activity_ratio
            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(organization_id: new_organization.id, copy_id: old_mp_ratio_variable.wbs_activity_ratio_id).first

            if new_wbs_activity_ratio.nil?
              mp_ratio_variable.wbs_activity_ratio_id = nil
              mp_ratio_variable.wbs_activity_ratio_variable_id = nil
            else
              mp_ratio_variable.wbs_activity_ratio_id = new_wbs_activity_ratio.id

              # wbs_activity_ratio_variable
              new_wbs_activity_ratio_variable = new_wbs_activity_ratio.wbs_activity_ratio_variables.where(organization_id: new_organization.id, copy_id: old_mp_ratio_variable.wbs_activity_ratio_variable_id).first
              wbs_activity_ratio_variable_id = new_wbs_activity_ratio_variable.nil? ? nil : new_wbs_activity_ratio_variable.id
              mp_ratio_variable.wbs_activity_ratio_variable_id = wbs_activity_ratio_variable_id
            end
          end

          mp_ratio_variable.save
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

        new_view = View.create(organization_id: new_organization_id, pemodule_id: new_mp.pemodule_id, name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "", initial_view_id: old_mp.view_id)
        # We have to copy all the selected view's widgets in a new view for the current module_project
        if old_mp.view
          old_mp_view_widgets = old_mp.view.views_widgets.all
        else
          old_mp_view_widgets = old_mp.views_widgets.all
        end

        unless old_mp_view_widgets.blank?
          old_mp_view_widgets.each do |view_widget|
            new_view_widget_mp = ModuleProject.where(organization_id: new_organization.id, project_id: new_prj.id, copy_id: view_widget.module_project_id).first  #.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
            new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
            widget_est_val = view_widget.estimation_value
            unless widget_est_val.nil?
              in_out = widget_est_val.in_out
              widget_pe_attribute_id = widget_est_val.pe_attribute_id
              unless new_view_widget_mp.nil?
                new_estimation_value = new_view_widget_mp.estimation_values.where(organization_id: new_organization_id, pe_attribute_id: widget_pe_attribute_id, in_out: in_out).last
                estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
                widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id,
                                                 name: view_widget.name, show_name: view_widget.show_name,
                                                 show_tjm: view_widget.show_tjm,
                                                 equation: view_widget.equation,
                                                 comment: view_widget.comment,
                                                 is_kpi_widget: view_widget.is_kpi_widget,
                                                 kpi_unit: view_widget.kpi_unit,
                                                 is_project_data_widget: view_widget.is_project_data_widget,
                                                 project_attribute_name: view_widget.project_attribute_name,
                                                 icon_class: view_widget.icon_class, color: view_widget.color,
                                                 show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                 width: view_widget.width, height: view_widget.height, position: view_widget.position,
                                                 position_x: view_widget.position_x,
                                                 position_y: view_widget.position_y,
                                                 min_value: view_widget.min_value,
                                                 max_value: view_widget.max_value,
                                                 validation_text: view_widget.validation_text
                )
                #===
                # #Update KPI Widget aquation
                unless view_widget.equation.empty?
                  ["A", "B", "C", "D", "E"].each do |letter|
                    unless view_widget.equation[letter].nil?

                      new_array = []
                      est_val_id = view_widget.equation[letter].first
                      mp_id = view_widget.equation[letter].last

                      begin
                        new_mpr = new_prj.module_projects.where(organization_id: new_organization_id, copy_id: mp_id).first
                        new_mpr_id = new_mpr.id
                        begin
                          new_est_val_id = new_mpr.estimation_values.where(organization_id: new_organization_id, copy_id: est_val_id).first.id
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
        ###======= Ajout ligne suivante apres gestion Temps reponse  #puts "\nGuwUnitOfWorkGroup"
        new_mp.guw_unit_of_work_groups.update_all(organization_id: new_organization_id, guw_model_id: new_mp.guw_model_id, project_id: new_prj.id)

        new_mp.guw_unit_of_work_groups.where(organization_id: new_organization_id, project_id: new_prj.id).each do |guw_group|
          new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
          new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id

          #technology
          # new_technology = new_organization.organization_technologies.where(copy_id: guw_group.organization_technology_id).first
          # new_technology_id = new_technology.nil? ? nil : new_technology.id

          guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id, project_id: new_prj.id, organization_id: new_organization_id)

          # Update the group unit of works and attributes
          #guw_group.guw_unit_of_works.where(organization_id: new_organization_id, project_id: new_prj.id).each do |guw_uow|
          guw_group.guw_unit_of_works.each do |guw_uow|
            #new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
            new_uow_mp = ModuleProject.where(organization_id: new_organization_id, project_id: new_prj.id, copy_id: guw_uow.module_project_id).first
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
            # uow_new_technology = new_organization.organization_technologies.where(copy_id: guw_uow.organization_technology_id).first
            # uow_new_technology_id = uow_new_technology.nil? ? nil : uow_new_technology.id

            guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id, guw_model_id: new_guw_model_id,
                                      guw_type_id: new_guw_type_id, guw_work_unit_id: new_guw_work_unit_id, guw_complexity_id: new_complexity_id,
                                      project_id: new_prj.id, organization_id: new_organization_id)

            # MAJ apres Temps reponse
            guw_uow.guw_coefficient_element_unit_of_works.update_all(organization_id: new_organization_id, guw_model_id: new_guw_model_id, project_id: new_prj.id, module_project_id: new_uow_mp_id)
            guw_uow.guw_unit_of_work_attributes.update_all(organization_id: new_organization_id, guw_model_id: new_guw_model_id, project_id: new_prj.id, module_project_id: new_uow_mp_id)
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

              wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(organization_id: new_organization_id, copy_id: activity_input.wbs_activity_ratio_id).first
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
                ev = new_mp.estimation_values.where(organization_id: new_organization_id, pe_attribute_id: attr.id, in_out: io).first
                unless ev.nil?

                  ["low", "most_likely", "high", "probable"].each do |level|

                    old_level_value = ev.send("string_data_#{level}")
                    new_level_value = ev.send("string_data_#{level}")

                    if new_level_value.nil?
                      ev.send("string_data_#{level}=", new_level_value)
                    else
                      # old_pbs_level_value = old_level_value.delete(old_component.id.to_i)
                      # new_level_value[new_component.id.to_i] = old_pbs_level_value

                      #if level == "probable" && new_mp.pemodule.alias == "effort_breakdown"
                      if new_mp.pemodule.alias == "effort_breakdown"

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
                                new_element = new_mp.wbs_activity_elements.where(organization_id: new_organization_id, wbs_activity_id: wbs_activity.id, copy_id: element_id).first

                                if new_element

                                  if level != "probable"
                                    temp_values[new_component.id][new_element.id] = new_pbs_level_value[element_id]
                                  else
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
                                end  #end if new_element
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

                      end
                    end

                  end  ###

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

    # begin
    #begin
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
        # ActiveRecord::Base.transaction do

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

                  ##======  Apres msj Temps Reponse  ======#
                  #new_wbs_activity.wbs_activity_elements.update_all(organization_id: new_organization.id)
                  new_wbs_activity.wbs_activity_ratios.update_all(organization_id: new_organization.id)

                  #get new WBS Ratio elements
                  new_wbs_activity_ratio_elts = []
                  new_wbs_activity.wbs_activity_ratios.each do |ratio|

                    ratio.wbs_activity_ratio_elements.update_all(organization_id: new_organization.id, wbs_activity_id: new_wbs_activity.id)

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
                        new_ratio_variable.copy_id = old_ratio_variable.id
                        new_ratio_variable.organization_id = new_organization.id
                        new_ratio_variable.wbs_activity_id = new_wbs_activity.id
                        new_ratio_variable.save
                      end
                    end
                  end

                  #Managing the component tree
                  old_wbs_activity_elements = old_wbs_activity.wbs_activity_elements.order('ancestry_depth asc')
                  old_wbs_activity_elements.each do |old_elt|
                    new_elt = old_elt.amoeba_dup
                    new_elt.wbs_activity_id = new_wbs_activity.id
                    new_elt.organization_id = new_organization.id
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

              # Update all the new organization module_project's ge_model with the current ge_model
              ge_copy_id = ge_model.copy_id
              new_organization.module_projects.where(ge_model_id: ge_copy_id).update_all(ge_model_id: ge_model.id)

              #Terminate the model duplication with the copie of the factors values
              ge_model.transaction do
                #Then copy the factor values
                ge_model.ge_factors.each do |factor|
                  #get the factor values for each factor of new model

                  # get the original factor from copy_id
                  parent_factor = Ge::GeFactor.find(factor.copy_id)
                  if parent_factor
                    parent_factor.ge_factor_values.each do |parent_factor_value|
                      new_factor_value = parent_factor_value.dup
                      new_factor_value.ge_model_id = ge_model.id
                      new_factor_value.ge_factor_id = factor.id
                      new_factor_value.save
                    end
                  end
                end

                # GeInputs
                ge_model.ge_inputs.each do |ge_input|
                  ge_input.organization_id = new_organization.id
                  new_mp = new_organization.module_projects.where(ge_model_id: ge_model.id, copy_id: ge_input.module_project_id).first
                  ge_input.module_project_id = (new_mp.nil? ? nil : new_mp.id)
                  ge_input.save
                end
              end


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
      # end

      respond_to do |format|
        flash[:notice] = "Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation."
        format.html { redirect_to all_organizations_path and return }
        #format.js { render :js => "window.location.replace('/all_organizations');"}
        ##format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès'); window.location.replace('/all_organizations');"}
        #format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation.'); window.location.replace('/all_organizations');"}

        format.js { render :js => "alert('Fin de copie: la nouvelle organisation a été créée avec succès. Veuiller recharger la page pour voir apparaître votre nouvelle organisation.');" and return }

        ##format.js { render 'layouts/flashes' }
      end

    # rescue
    #rescue
      organization_image.update_attribute(:copy_in_progress, false)

      flash[:error] = "Une erreur est survenue lors de la création de la nouvelle organisation"
      respond_to do |format|
        format.html { redirect_to all_organizations_path and return }
        format.js { render :js => "window.location.replace('/all_organizations');"}
      end
    # end
    #end

  end

  def new
    authorize! :create_organizations, Organization
    @organization = Organization.new
    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", I18n.t(:new_organization) => ""
    @groups = @organization.groups
    @reports_list = ["filtered_excel_report", "detailed_excel_report", "detailed_pdf_report",  "raw_data_extract", "budget_report", "budget_excel_report"]
    @kpi_list = ["quote_creation_duration_kpi", "fp_delivered_number_kpi", "global_budget", "estimations_total_kpi", "projects_stability_indicators"]
    @organization_show_reports_keys = []
    @organization_show_kpi_keys = []
  end

  def edit
    #authorize! :edit_organizations, Organization
    authorize! :show_organizations, Organization

    set_page_title I18n.t(:organizations)
    @organization = Organization.find(params[:id])
    @current_organization = @organization
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""

    @attributes = PeAttribute.all
    @attribute_settings = AttributeOrganization.where(:organization_id => @organization.id).all

    @users = @organization.users
    @fields = @organization.fields

    @organization_profiles = @organization.organization_profiles
    @work_element_types = @organization.work_element_types

    @reports_list = ["filtered_excel_report", "detailed_excel_report", "detailed_pdf_report", "raw_data_extract", "budget_report", "budget_excel_report"]
    @kpi_list = ["quote_creation_duration_kpi", "fp_delivered_number_kpi", "global_budget", "estimations_total_kpi", "projects_stability_indicators"]

    @organization_show_reports_keys = @organization.show_reports.keys
    @organization_show_kpi_keys = @organization.show_kpi.keys

    # get organization estimations per year
    #@projects_per_year = @organization.projects.group_by{ |t| t.created_at.year }.sort_by{|created_at, _extras| created_at }
    @projects_per_year = @organization.projects.group_by{ |t| t.created_at.year }.sort {|k, v| k[1] <=> v[1] }

    # Budget global
    @data_for_global_budget = []
    @bt_colors = []
    budget_header = ["Budgets"]
    organization_budget_types = @organization.budget_types
    @nb_series = organization_budget_types.all.size

    organization_budget_types.each do |bt|
      budget_header << bt.name
      @bt_colors << bt.color
    end
    @bt_colors << '#007DAB'

    budget_header << I18n.t(:planned_budget)
    #budget_header << { role: 'annotation' }
    @data_for_global_budget << budget_header

    @organization.budgets.each do |budget|
      budget_values = ["#{budget.name}"]
      budget_sum = 0.0
      budget_used_applications = budget.application_budgets.where(is_used: true).map(&:application)

      # budget_used_applications.each do |application|
      #   application_values = []
      #   data = Budget::fetch_project_field_data(@organization, budget, application)
      #   organization_budget_types.each do |budget_type|
      #     application_values << data["#{budget_type.name}"].to_f
      #   end
      #   budget_sum = application_values.sum
      #   budget_values << budget_sum
      # end

      organization_budget_types.each do |budget_type|
        budget_type_values = []
        budget_used_applications.each do |application|
          data = Budget::fetch_project_field_data(@organization, budget, application)
          budget_type_values << data["#{budget_type.name}"].to_f
        end
        budget_sum = budget_type_values.sum
        budget_values << budget_sum
      end

      budget_values << budget.sum
      #budget_values << ''
      @data_for_global_budget << budget_values
    end

    #toutes applications

    # @data_actions_all_applis = []
    #
    # @create_all_applis_tab = ["Create", create_all_applis, '#76A7FA']
    # @modify_all_applis_tab = ["Modify", modify_all_applis, '#b87333']
    # @delete_all_applis_tab = ["Delete", delete_all_applis, 'silver']
    #
    # @data_actions_all_applis << @create_all_applis_tab
    # @data_actions_all_applis << @modify_all_applis_tab
    # @data_actions_all_applis << @modify_all_applis_tab
    #
    # #per application
    # selected_appli = params['application']
    # @data_actions_per_appli = projects_per_application_stability_indicators(selected_appli)


  end


  # Get budget par Application graph (for selected budget)
  def get_budget_details
    @organization = Organization.find(params[:organization_id])
    @data = []
    @bt_colors = []
    header = ["Applications"]
    @budget_name = ""
    @nb_series = 0

    unless params[:budget_id].blank?
      budget = Budget.find(params[:budget_id])
      if budget
        @budget_name = budget.name
        budget_budget_types = budget.budget_types
        @nb_series = budget_budget_types.all.size

        budget_budget_types.each do |bt|
          header << bt.name
          @bt_colors << bt.color
        end
        @bt_colors << '#007DAB'

        header << I18n.t(:planned_budget)
        header << { role: 'annotation' }
        @data << header

        budget_used_applications = budget.application_budgets.where(is_used: true).map(&:application)
        budget_used_applications.each do |application|
          application_values = ["#{application.name}"]
          data = Budget::fetch_project_field_data(@organization, budget, application)

          budget_budget_types.each do |budget_type|
            application_values << data["#{budget_type.name}"].to_f
          end

          budget_application = budget.application_budgets.where(application_id: application.id).first
          application_values << (budget_application.nil? ? 0 : budget_application.montant.to_f)
          application_values << ''

          @data << application_values
        end
      end
    end
    @data
  end


  def refresh_value_elements
    @technologies = OrganizationTechnology.all
  end

  def create
    authorize! :create_organizations, Organization

    @organization = Organization.new(params[:organization])

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", I18n.t(:new_organization) => ""

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
      redirect_to(edit_organization_path(@organization), notice: I18n.t(:notice_organization_successful_created)) and return
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
    set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => ""

    if @organization.update_attributes(params[:organization].merge(show_reports: params[:show_reports], show_kpi: params[:show_kpi]))
      flash[:notice] = I18n.t (:notice_organization_successful_updated)
      redirect_to redirect_apply(edit_organization_path(@organization), nil, '/all_organizations')
    else
      @attributes = PeAttribute.all
      @attribute_settings = AttributeOrganization.where(:organization_id => @organization.id).all
      @organization_profiles = @organization.organization_profiles
      @groups = @organization.groups
      @organization_group = @organization.groups
      @wbs_activities = @organization.wbs_activities
      @projects = @organization.projects
      @fields = @organization.fields
      @guw_models = @organization.guw_models
      # get organization estimations per year
      @projects_per_year = @organization.projects.group_by{ |t| t.created_at.year }.sort {|k, v| k[1] <=> v[1] }

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
            if current_user.organizations.all.size == 1
              session[:organization_id] = current_user.organizations.first
            else
              session[:organization_id] = nil
            end
          end
          flash[:notice] = I18n.t(:notice_organization_successful_deleted)
          redirect_to '/all_organizations' and return
        else
          flash[:warning] = I18n.t('warning_need_organization_check_box_confirmation')
          render :template => 'organizations/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
        end

      when I18n.t('cancel')
        redirect_to '/all_organizations' and return
      else
        render :template => 'projects/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
    end
  end

  def all_organizations
    set_page_title I18n.t(:Organizational_Parameters)
    if @current_organization
      set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@current_organization.id}", "#{I18n.t(:organizations)}" => ""
    else
      set_breadcrumbs I18n.t(:organizations) => "/all_organizations", "#{I18n.t(:organizations)}" => ""
    end

    if current_user
      if current_user.super_admin?
        @organizations = Organization.all
      elsif can?(:manage, :all)
        @organizations = Organization.all.reject{|org| org.is_image_organization}
      else
        @organizations = current_user.organizations.all.reject{|org| org.is_image_organization}
      end

      if !current_user.super_admin? && (current_user.subscription_end_date && current_user.subscription_end_date < Time.now)
        flash[:warning] = I18n.t(:subscription_end_date_has_expired, :resource_name => current_user.name, :subscription_end_date => current_user.subscription_end_date.strftime("%-d %b %Y"))
      else
        if @organizations.size == 1 && !current_user.super_admin?
          redirect_to organization_estimations_path(@organizations.first) and return
        end
      end
    else
      redirect_to sign_in_path
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
                      group = Group.where(organization_id: @current_organization.id, name: row[group_index].nil? ? '' : row[group_index].value).first
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
    redirect_to organization_setting_path(@current_organization, :anchor => 'tabs-select-columns-list', partial_name: 'tabs_select_columns_list')
  end

  def update_available_inline_columns
    # update selected columne
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
      @current_organization.default_estimations_sort_column = params[:default_estimations_sort_column]
      @current_organization.default_estimations_sort_order = params[:default_estimations_sort_order]
      @current_organization.save
    end

    respond_to do |format|
     format.html { redirect_to organization_setting_path(@current_organization, :anchor => 'tabs-select-columns-list', partial_name: 'tabs_select_columns_list')}
     format.js
     format.json { render json: selected_columns }
    end
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
    redirect_to all_organizations_path
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


  def show_original_image
    @image_name = params[:image_name]
  end

  #########   Organization settings pages      ###################

  def estimation_settings
    @organization = Organization.find(params[:organization_id])
    @partial_name = params[:partial_name]
    @item_title = params[:item_title]

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

  #guow : guw_unit_of_works
  #gcoeff : @guw_coefficient
  def guw_coeff_chart(guow, gcoeff)
    @coeff_data = []
    @colors = []
    create_nb, modif_nb, delete_nb, dup_nb, redund_nb, registered_nb = 0

    @organization = Organization.find(:id)
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    unless params[:guw_coefficient["#{guow.id}][#{gcoeff.id}]"]].blank?
      coeff_cplx = params[:guw_coefficient["#{guow.id}][#{gcoeff.id}]"]]
      case coeff_cplx
      when 1
        create_nb = create_nb + 1
      when 2
        modif_nb = modif_nb + 1
      when 3
        delete_nb = delete_nb + 1
      when 4
        dup_nb = dup_nb + 1
      when 5
        redund_nb = redund_nb + 1
      when 6
        registered_nb = registered_nb + 1
      end
    end

    @colors << '#007DAB'
    @colors << '#78B2FF'
    @colors << '#FFFA6E'
    @colors << '#D96675'
    @colors << '#D95F18'


    @organization.applications.each do |app|
      @coeff_data << ["#{app.name}"]
      @coeff_data << create_nb << modif_nb << delete_nb << dup_nb<< redund_nb << registered_nb
    end

  end

  def kpi
      @organization = Organization.find(params[:organization_id])
      @attributes = PeAttribute.all
      @attribute_settings = AttributeOrganization.where(:organization_id => @organization.id).all

      @users = @organization.users
      @fields = @organization.fields

      @organization_profiles = @organization.organization_profiles
      @work_element_types = @organization.work_element_types

      # get organization estimations per year
      #@projects_per_year = @organization.projects.group_by{ |t| t.created_at.year }.sort_by{|created_at, _extras| created_at }
      @projects_per_year = @organization.projects.group_by{ |t| t.created_at.year }.sort {|k, v| k[1] <=> v[1] }

      # Budget global
      @data_for_global_budget = []
      @bt_colors = []
      budget_header = ["Budgets"]
      organization_budget_types = @organization.budget_types
      @nb_series = organization_budget_types.all.size
      @kpi_list = ["quote_creation_duration_kpi", "fp_delivered_number_kpi", "global_budget", "estimations_total_kpi", "projects_stability_indicators"]
      @organization_show_kpi_keys = @organization.show_kpi.keys
      @partial_name = params[:partial_name]
      @item_title = params[:item_title]

      organization_budget_types.each do |bt|
        budget_header << bt.name
        @bt_colors << bt.color
      end
      @bt_colors << '#007DAB'

      budget_header << I18n.t(:planned_budget)
      #budget_header << { role: 'annotation' }
      @data_for_global_budget << budget_header

      @organization.budgets.each do |budget|
        budget_values = ["#{budget.name}"]
        budget_sum = 0.0
        budget_used_applications = budget.application_budgets.where(is_used: true).map(&:application)

        # budget_used_applications.each do |application|
        #   application_values = []
        #   data = Budget::fetch_project_field_data(@organization, budget, application)
        #   organization_budget_types.each do |budget_type|
        #     application_values << data["#{budget_type.name}"].to_f
        #   end
        #   budget_sum = application_values.sum
        #   budget_values << budget_sum
        # end

        organization_budget_types.each do |budget_type|
          budget_type_values = []
          budget_used_applications.each do |application|
            data = Budget::fetch_project_field_data(@organization, budget, application)
            budget_type_values << data["#{budget_type.name}"].to_f
          end
          budget_sum = budget_type_values.sum
          budget_values << budget_sum
        end

        budget_values << budget.sum
        #budget_values << ''
        @data_for_global_budget << budget_values
      end


      #toutes appplications
      @projects_orga = @organization.projects
      @stability_ind = projects_stability_indicators(@projects_orga)

      #per application
      #selected_appli = params['application']
      #@data_actions_per_appli = projects_per_application_stability_indicators(selected_appli)

  end

  def save_show_reports
    @organization = Organization.find(params[:organization_id])
    @show_reports = @organization.show_reports
    @show_kpi = @organization.show_kpi
    @show_reports = Hash.new
    @show_kpi = Hash.new

    @show_reports["allow_filtered_excel"] = 1
    @show_reports["allow_detailed_excel"] = 1
    @show_reports["allow_detailed_pdf"] = 1
    @show_reports["allow_budget_report"] = 1
    @show_reports["allow_raw_data_extraction"] = 1
    @show_reports["allow_extraction_impression"] = 1

    @show_kpi["allow_quote_creation_duration_img"] = 1
    @show_kpi["allow_fp_delivered_number_img"] = 1
    @show_kpi["allow_global_budget"] = 1
    @show_kpi["allow_estimations_total"] = 1
    @show_kpi["allow_stability_indicators"] = 1
  end


  def projects_per_application_stability_indicators(application)
    application_projects = @current_organization.projects.where(application_id: application.id)
    projects_stability_indicators(application_projects)
  end


  def get_projects_stability_indicators
    stability_id = params[:stability_id]
    application_id = params[:application_id]
    @stability_ind = []
    case stability_id
    when 'all_projects'
      @stability_ind = projects_stability_indicators(@current_organization.projects)
    when 'prj_per_appli'
      if application_id.blank?
        @stability_ind = projects_stability_indicators(@current_organization.projects)
      else
        application = @current_organization.applications.where(id: application_id).first
        @stability_ind = projects_per_application_stability_indicators(application)
      end
    when 'proj_bad_stability'

    end
    @stability_ind
  end

  def projects_stability_indicators(projects)
    @guw_coeffs = ["Work Type", "Activité", "Travail", "Actions", "Action", "Operation"]
    @creations = ["Créer", "Création", "Create"]
    @modifs = ["Modifier", "Modif", "Modification", "Modify"]
    @deletions = ["Supprim.", "Supp.", "Suppression", "Delete"]

    create = 0
    modification = 0
    delete = 0

    projects.each do |project|
      module_projects = project.module_projects.where.not(guw_model_id: nil)
      module_projects.each do |module_project|
        @guw_model = module_project.guw_model #module_project belongs_to :guw_model
        @guows = module_project.guw_unit_of_works #module_project has_many :guw_unit_of_works
        @guows.each do |guow|
          @guw_coefficient_element_unit_of_works = guow.guw_coefficient_element_unit_of_works
          @guw_coefficient_element_unit_of_works.each do |guw_coefficient_element_unit_of_work|
            @guw_coefficient_element = guw_coefficient_element_unit_of_work.guw_coefficient_element
            if @guw_coefficient_element
              if @guw_coefficient_element.name.in? (@creations)
                create += 1
              elsif @guw_coefficient_element.name.in? (@modifs)
                modification += 1
              elsif @guw_coefficient_element.name.in? (@deletions)
                delete += 1
              end
            end
          end
        end
      end
    end

    @res = []
    @res << ['Element', I18n.t(:sum_create), I18n.t(:sum_modify), I18n.t(:sum_delete)]
    @res << ['Total', create, modification, delete]
    @res
  end

  #########   END Organization settings pages  ###################

  private
  def check_if_organization_is_image(organization)
    unless organization.new_record?
      if organization.is_image_organization == true || !current_user.organization_ids.include?(organization.id)
        error_message = (organization.is_image_organization == true)? I18n.t(:can_not_access_the_estimates_of_an_image_organization) : I18n.t(:not_authorized_to_access_this_organization)
        redirect_to("/all_organizations", flash: { error: error_message }) and return
      end
    end
  end

end
