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

class Guw::GuwModelsController < ApplicationController

  require 'rubyXL'

  def bug_tracker (tab_error)
    re = [[],[],[]]
    list_tab = [[],[],[]]
    final_message = []
    tab_error.each_with_index do |row_error ,index|
      if index == 0
        unless row_error.empty?
          re[0] = I18n.t(:Coefficient_of_acquisiton)
          list_tab[0] = row_error
        end
      elsif index == 1
        unless row_error.empty?
          re[1] = I18n.t(:organization_technology)
          list_tab[1] = row_error
        end
      elsif index == 2
        unless row_error.empty?
          re[2] = I18n.t(:pe_attributes)
          list_tab[2] = row_error
        end
      end
    end
    re.each_with_index do |ligne, index|
      unless ligne.empty?
        final_message << " - #{ligne} : #{list_tab[index].join(", ")}"
      end
    end
    unless final_message.empty?
      flash[:error] = I18n.t(:error_warning, parameter: final_message.join("<br/>")).html_safe
    end
  end

  def redirect_to_good_path(route_flag, index)
    message = []
    if route_flag == 1
      message << I18n.t(:route_flag_error_1)
    elsif route_flag == 2
     message << I18n.t(:route_flag_error_2)
    elsif route_flag == 3
      message << I18n.t(:route_flag_error_3)
    elsif route_flag == 4
      message << I18n.t(:route_flag_error_4)
    elsif route_flag == 5
      message <<  I18n.t(:route_flag_error_5)
   elsif route_flag == 6
      message <<  I18n.t(:route_flag_error_6, ind: index)
    elsif route_flag == 7
      message << I18n.t(:route_flag_error_7)
    end
      if route_flag == 7 || route_flag == 6 || route_flag == 0
        redirect_to "/organizations/#{@current_organization.id}/module_estimation"
      else
        redirect_to :back
      end
    if route_flag == 0
      flash[:notice] = I18n.t(:importation_success)
    else
      flash[:error] = message.join("<br/>").html_safe
    end
  end

  def statistics
    @guw_model = Guw::GuwModel.find(params[:guw_model])
  end

  def import_new_config

    organization_id = @current_organization.id || params[organization_id]

    ActiveRecord::Base.transaction do
      if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
        @workbook = RubyXL::Parser.parse(params[:file].path)
        @workbook.each_with_index do |worksheet, index|
          tab = worksheet
          if index == 0

            if worksheet.sheet_name != I18n.t(:is_model)
              break
            end

            if tab[0][1].blank?
              break
            end

            @guw_model = Guw::GuwModel.where(organization_id: organization_id, name: tab[0][1].nil? ? nil : tab[0][1].value).first
            if @guw_model.nil?
              @guw_model = Guw::GuwModel.new( organization_id: organization_id,
                                              name: tab[0][1].nil? ? nil : tab[0][1].value,
                                              description: tab[1][1].nil? ? nil : tab[1][1].value,
                                              coefficient_label: tab[2][1].nil? ? nil : tab[2][1].value,
                                              weightings_label: tab[3][1].nil? ? nil : tab[3][1].value,
                                              factors_label: tab[4][1].nil? ? nil : tab[4][1].value,
                                              three_points_estimation: tab[5][1].value.to_i == 1,
                                              retained_size_unit: tab[6][1].nil? ? nil : tab[6][1].value,
                                              hour_coefficient_conversion: tab[7][1].nil? ? nil : tab[7][1].value,
                                              default_display: tab[9][1].nil? ? nil : tab[9][1].value,
                                              allow_technology: false,
                                              allow_ml: (tab[8][1].nil? ? false : tab[8][1].value == "false") ? false : true,
                                              view_data: false)


              # Create orders (coeff and outputs orders)
              orders = Hash.new
              i = 11
              order_value_coeff = tab[i][0].value rescue nil
              jj = 0
              while order_value_coeff.to_s != I18n.t(:config_type)
                begin
                  unless tab[i].nil?
                    unless tab[i][0].nil?
                      k = tab[i][0].value
                      orders["#{k}"] = tab[i][1].value rescue nil
                      i = i+1
                      order_value_coeff = tab[i][0].value rescue nil
                    end
                  end
                rescue
                  # ignored
                end
                jj += 1
                break if jj >= 30
              end

              @guw_model.orders = orders
              @guw_model.config_type = "new"

              begin
                @guw_model.allow_excel = ((tab[i+1][1].value) == "false") ? false : true rescue true
                @guw_model.excel_ml_server = tab[i+2][1].value rescue nil
                @guw_model.allow_ml_excel = ((tab[i+3][1].value) == "false") ? false : true rescue false

                @guw_model.allow_jira = ((tab[i+4][1].value) == "false") ? false : true rescue false
                @guw_model.jira_ml_server = tab[i+5][1].value rescue nil
                @guw_model.allow_ml_jira = ((tab[i+6][1].value) == "false") ? false : true rescue false

                @guw_model.allow_redmine = ((tab[i+7][1].value) == "false") ? false : true rescue false
                @guw_model.redmine_ml_server = tab[i+8][1].value rescue nil
                @guw_model.allow_ml_redmine = ((tab[i+9][1].value) == "false") ? false : true rescue false
              rescue
                @guw_model.allow_excel = true
                @guw_model.excel_ml_server = ""
                @guw_model.allow_ml_excel = false
              end

              @guw_model.save

            else
              flash[:error] = "Erreur : une instance avec le nom '#{@guw_model.name}' existe déjà"
              redirect_to main_app.organization_module_estimation_path(@current_organization.id, anchor: "taille") and return
            end


          elsif index == 1

            tab.each_with_index do |row, i|
              if i != 0 && !row.nil?
                Guw::GuwAttribute.create(organization_id: organization_id,
                                         guw_model_id: @guw_model.id,
                                         name: row[0].value,
                                         description: row[1].value)
              end
            end

          elsif index == 2

            tab.each_with_index do |row, i|
              if i != 0 && !row.nil?
                Guw::GuwCoefficient.create(name: row[0].nil? ? nil : row[0].value,
                                           description: row[1].nil? ? nil : row[1].value,
                                           coefficient_type: row[2].nil? ? nil : row[2].value,
                                           organization_id: organization_id,
                                           guw_model_id: @guw_model.id,
                                           allow_intermediate_value: ((row[3].nil? ? nil : row[3].value) == 0) ? false : true,
                                           deported: ((row[4].nil? ? nil : row[4].value) == 0) ? false : true,
                                           show_coefficient_label: ((row[5].nil? ? nil : row[5].value) == 0) ? false : true)
              end
            end

          elsif index >= 3 && index <= (3 + @guw_model.guw_coefficients.size - 1)

            unless tab[0].nil?
              coefficient = Guw::GuwCoefficient.where(organization_id: organization_id,
                                                      guw_model_id: @guw_model.id,
                                                      name: tab[0][1].nil? ? nil : tab[0][1].value).first

              tab.each_with_index do |row, i|
                if i >= 3 && !row.nil?
                  gce = Guw::GuwCoefficientElement.new(name: row[1].nil? ? nil : row[1].value,
                                                       description: row[2].nil? ? nil : row[2].value,
                                                       value: row[3].nil? ? nil : row[3].value,
                                                       default_display_value: row[4].nil? ? nil : row[4].value,
                                                       display_order: row[5].nil? ? nil : row[5].value,
                                                       guw_coefficient_id: coefficient.nil? ? nil : coefficient.id,
                                                       organization_id: organization_id,
                                                       guw_model_id: @guw_model.id,
                                                       default_value: (row[6].nil? ? 0 : row[6].value.to_s == "true") ? 1 : 0,
                                                       #default: (row[6].nil? ? 1 : row[6].value.to_s == "true") ? 1 : 0,
                                                       default: row[6].nil? ? nil : row[6].value,
                                                       color_code: row[7].nil? ? nil : row[7].value,
                                                       color_priority: row[8].nil? ? nil : row[8].value)
                  gce.save(validate: false)
                end
              end
            end

          elsif index == (3 + @guw_model.guw_coefficients.size)

            tab.each_with_index do |row, i|
              if i >= 1 && !row.nil?
                unless row[0].blank?
                  guw_output = Guw::GuwOutput.create(name: row[0].nil? ? nil : row[0].value,
                                                     output_type: row[1].nil? ? nil : row[1].value,
                                                     organization_id: organization_id,
                                                     guw_model_id: @guw_model.id,
                                                     allow_intermediate_value: (row[2].nil? ? false : row[2].value == 0) ? false : true,
                                                     standard_coefficient: row[4].nil? ? nil : row[4].value,
                                                     display_order: row[5].nil? ? nil : row[5].value,
                                                     unit: row[6].nil? ? nil : row[6].value,
                                                     allow_subtotal: row[7].nil? ? false : row[7].value)

                  attr = PeAttribute.where(alias: guw_output.name.to_s.underscore.gsub(" ", "_"),
                                           name: guw_output.name,
                                           description: guw_output.name,
                                           guw_model_id: guw_output.guw_model_id).first_or_create!

                  pm = Pemodule.where(alias: "guw").first

                  am = AttributeModule.where(pe_attribute_id: attr.id,
                                             pemodule_id: pm.id,
                                             in_out: "both",
                                             guw_model_id: guw_output.guw_model_id).first_or_create!

                  @guw_model.module_projects.where(organization_id: organization_id).each do |module_project|
                    ['input', 'output'].each do |in_out|
                      mpa = EstimationValue.create(organization_id: organization_id,
                                                   module_project_id: module_project.id,
                                                   pe_attribute_id: attr.id,
                                                   in_out: in_out,
                                                   string_data_low: { :pe_attribute_name => @guw_output.name },
                                                   string_data_most_likely: { :pe_attribute_name => @guw_output.name },
                                                   string_data_high: { :pe_attribute_name => @guw_output.name })
                    end
                  end
                end

              end
            end

          else

            @guw_type = Guw::GuwType.create(name: worksheet.sheet_name,
                                            description: tab[1][0].nil? ? nil : tab[1][0].value,
                                            allow_quantity: (tab[5][1].nil? ? nil : tab[5][1].value) == 1,
                                            allow_retained: (tab[4][1].nil? ? nil : tab[4][1].value) == 1,
                                            allow_complexity: (tab[7][1].nil? ? nil : tab[7][1].value) == 1,
                                            allow_criteria: (tab[2][1].nil? ? nil : tab[2][1].value) == 1,
                                            attribute_type: (tab[3][1].value == "Pourcentage") ? "Pourcentage" : "Coefficient",
                                            display_threshold: tab[6][1].nil? ? nil : tab[6][1].value == 1,
                                            color_priority: tab[0][4].nil? ? nil : tab[0][4].value,
                                            color_code: tab[1][4].nil? ? nil : tab[1][4].value,
                                            allow_line_color: tab[2][4].value == "true" ? true : false,
                                            organization_id: organization_id,
                                            guw_model_id: @guw_model.id)

            [2,7,12].each do |column_index|
              name = tab[9][column_index].nil? ? nil : tab[9][column_index].value
              default_value = (tab[9][column_index + 1].nil? ? nil : tab[9][column_index + 1].value) == "true" ? true : false

              unless name.blank?
                @guw_complexity = Guw::GuwComplexity.new(organization_id: organization_id,
                                                         guw_model_id: @guw_model.id,
                                                         name: name,
                                                         default_value: default_value,
                                                         guw_type_id: @guw_type.id,
                                                         bottom_range: tab[11][column_index + 1].nil? ? nil : tab[11][column_index + 1].value,
                                                         top_range: tab[11][column_index + 2].nil? ? nil : tab[11][column_index + 2].value,
                                                         weight: tab[11][column_index + 3].nil? ? nil : tab[11][column_index + 3].value,
                                                         weight_b: tab[11][column_index + 4].nil? ? nil : tab[11][column_index + 4].value,
                                                         enable_value: (tab[11][column_index].value == 0) ? false : true)

                # begin
                  @guw_complexity.save(validate: false)
                # rescue
                #   @guw_complexity
                # end


                @guw_model.guw_outputs.order("display_order ASC").each_with_index do |guw_output, i|

                  Guw::GuwOutputComplexityInitialization.create(organization_id: organization_id,
                                                                guw_model_id: @guw_model.id,
                                                                guw_complexity_id: @guw_complexity.id,
                                                                guw_output_id: guw_output.id,
                                                                init_value: tab[13][column_index + i].nil? ? nil : tab[13][column_index + i].value)

                  Guw::GuwOutputComplexity.create(organization_id: organization_id,
                                                  guw_model_id: @guw_model.id,
                                                  guw_complexity_id: @guw_complexity.id,
                                                  guw_output_id: guw_output.id,
                                                  value: tab[14][column_index + i].nil? ? nil : tab[14][column_index + i].value)

                  @guw_model.guw_outputs.order("display_order ASC").each_with_index do |aguw_output, j|

                    oa = Guw::GuwOutputAssociation.new(organization_id: organization_id,
                                                       guw_model_id: @guw_model.id,
                                                       guw_complexity_id: @guw_complexity.id,
                                                       guw_output_associated_id: aguw_output.id,
                                                       guw_output_id: guw_output.id,
                                                       value: tab[15 + j][column_index + i].nil? ? nil : tab[15 + j][column_index + i].value)
                    oa.save

                    Guw::GuwOutputType.create(organization_id: organization_id,
                                              guw_model_id: @guw_model.id,
                                              guw_output_id: aguw_output.id,
                                              guw_type_id: @guw_type.id,
                                              display_type: tab[15 + j][1].nil? ? nil : tab[15 + j][1].value)
                  end

                  nb_output = @guw_model.guw_outputs.where(organization_id: organization_id, guw_model_id: @guw_model.id).order("display_order ASC").size
                  next_item = 15 + nb_output
                  @guw_model.guw_coefficients.where(organization_id: organization_id).each do |guw_coefficient|
                    guw_coefficient.guw_coefficient_elements.each_with_index do |guw_coefficient_element, k|

                      next_item = next_item + 1

                      begin
                        value = tab[next_item][column_index + i].nil? ? nil : tab[next_item][column_index + i].value
                      rescue
                        value = ""
                      end

                      Guw::GuwComplexityCoefficientElement.create(organization_id: organization_id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_complexity_id: @guw_complexity.id,
                                                                  guw_coefficient_element_id: guw_coefficient_element.id,
                                                                  guw_output_id: guw_output.id,
                                                                  guw_type_id: @guw_type.id,
                                                                  value: value.is_a?(Numeric) ? value : nil)

                    end
                    next_item = next_item + 1
                  end
                end
              end
            end

            row_number = 0

            [1,6,11].each do |column_index|

              (0..9999).each do |i|
                unless tab[i].nil?
                  unless tab[i][0].nil?
                    if tab[i][0].value == "Seuils de Complexités Attributs"
                      row_number = i
                      break
                    end
                  end
                end
              end

              name = tab[row_number][column_index].nil? ? nil : tab[row_number][column_index].value

              unless name.nil?
                @guw_att_complexity = Guw::GuwTypeComplexity.create(name: name,
                                                                    organization_id: organization_id,
                                                                    guw_model_id: @guw_model.id,
                                                                    guw_type_id: @guw_type.id,
                                                                    value: tab[row_number][column_index + 1].nil? ? nil : tab[row_number][column_index + 1].value)

                @guw_model.guw_attributes.each_with_index do |att, j|

                  unless tab[row_number + j + 2].nil?
                    Guw::GuwAttributeComplexity.create(organization_id: organization_id,
                                                       guw_model_id: @guw_model.id,
                                                       guw_type_complexity_id: @guw_att_complexity.id,
                                                       guw_attribute_id: att.id,
                                                       guw_type_id: @guw_type.id,
                                                       enable_value: ((tab[row_number + j + 2][column_index].nil? ? nil : tab[row_number + j + 2][column_index].value) == 0) ? false : true,
                                                       bottom_range: tab[row_number + j + 2][column_index + 1].nil? ? nil : tab[row_number + j + 2][column_index + 1].value,
                                                       top_range: tab[row_number + j + 2][column_index + 2].nil? ? nil : tab[row_number + j + 2][column_index + 2].value,
                                                       value: tab[row_number + j + 2][column_index + 3].nil? ? nil : tab[row_number + j + 2][column_index + 3].value,
                                                       value_b: tab[row_number + j + 2][column_index + 4].nil? ? nil : tab[row_number + j + 2][column_index + 4].value)

                    Guw::GuwAttributeType.where(organization_id: organization_id,
                                                guw_model_id: @guw_model.id,
                                                guw_attribute_id: att.id,
                                                guw_type_id: @guw_type.id).first_or_create(default_value: tab[row_number + j + 2][16].nil? ? nil : tab[row_number + j + 2][16].value)

                  end
                end
                row_number += 1
              end
            end
          end
        end
      end
    end

    if @guw_model.nil?
      redirect_to :back
    else
      redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id, anchor: "taille")
    end
  end

  def import_old_config

    element_found_flag = false
    route_flag = 0
    sheet_error = 0
    critical_flag = true
    action_type_aquisition_flag = false
    action_technologie_flag = false
    action_attribute_flag = false
    tab_error = [[], [], []]
    ind = 1
    ind2 = 10
    ind3 = 0
    save_position = 0
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      @workbook = RubyXL::Parser.parse(params[:file].path)
      @workbook.each_with_index do |worksheet, index|
       tab = worksheet
       if !tab.empty?
          if index == 0
            if worksheet.sheet_name != I18n.t(:is_model)
              route_flag = 5
              break
            end
            if tab[0][1].nil? || tab[0][1].empty?
              route_flag = 2
              break
            end
            @guw_model = Guw::GuwModel.where(name: tab[0][1],
                                             organization_id: @current_organization.id).first
            if @guw_model.nil?
              @guw_model = Guw::GuwModel.create(name: tab[0][1],
                                                description: tab[1][1],
                                                coefficient_label: tab[2][1],
                                                weightings_label: tab[3][1],
                                                factors_label: tab[4][1],
                                                three_points_estimation: tab[5][1].to_i == 1,
                                                retained_size_unit: tab[6][1],
                                                hour_coefficient_conversion: tab[7][1],
                                                organization_id: @current_organization.id)
              critical_flag = false
            else
              route_flag = 1
              break
            end
          elsif index == 1
            if critical_flag || worksheet.sheet_name != I18n.t(:attribute_description)
              route_flag = 5
              break
            end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
               Guw::GuwAttribute.create(name: row[0].value,
                                        description: row[1].value,
                                        guw_model_id: @guw_model.id)
              end
            end
          elsif index == 2

            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                 Guw::GuwWorkUnit.create(name:row[0].value,
                                         value: row[1].value,
                                         display_order: row[2].nil? ? nil : row[2].value,
                                         guw_model_id: @guw_model.id)
              end
            end
          elsif index == 3

            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                Guw::GuwWeighting.create(name:row[0].value,
                                        value: row[1].value,
                                        display_order: row[2].nil? ? nil : row[2].value,
                                        guw_model_id: @guw_model.id)
              end
            end
          elsif index == 4

            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                Guw::GuwFactor.create(name: row[0].value,
                                      value: row[1].value,
                                      display_order: row[2].value,
                                      guw_model_id: @guw_model.id)
              end
            end
          else
            if worksheet.sheet_name == "Matrice"
              begin
                if !tab[0].nil? && !tab[1].nil? && !tab[2].nil? && !tab[3].nil?
                  [[@guw_model.coefficient_label, "work_unit"], [@guw_model.weightings_label, "weighting"], [@guw_model.factors_label, "factor"]].each_with_index do |ts, i|
                    ["size", "effort", "cost"].each_with_index do |ta, j|
                      if tab[j+1][i+1] == 1
                        gsma = Guw::GuwScaleModuleAttribute.new(guw_model_id: @guw_model.id,
                                                                type_attribute: ta,
                                                                type_scale: ts[1])
                        gsma.save
                      end
                    end
                  end
                else
                  route_flag = 6
                end
              rescue
                # ignored
              end
            else
              if worksheet.sheet_name != I18n.t(:is_model) && worksheet.sheet_name != I18n.t(:attribute_description)# && worksheet.sheet_name != I18n.t(:Type_acquisitions)
                if !tab[0].nil? && !tab[2].nil? && !tab[3].nil? && !tab[1].nil? && !tab[4].nil?
                  @guw_type = Guw::GuwType.create(name: worksheet.sheet_name,
                                                  description: tab[0][0],
                                                  allow_quantity: tab[2][1] == 1,
                                                  allow_retained: tab[1][1] == 1,
                                                  allow_complexity: tab[3][1] == 1,
                                                  allow_criteria: tab[4][1] == 1,
                                                  guw_model_id: @guw_model.id)

                  if !tab[8].nil? && !tab[9].nil? && tab[8][0] == I18n.t(:threshold) && !tab[6].empty?# && tab[9][0] == I18n.t(:Coefficient_of_acquisiton)
                    while !tab[6][ind].nil?
                      @guw_complexity = Guw::GuwComplexity.create(guw_type_id: @guw_type.id,
                                                                 name: tab[6][ind],
                                                                 enable_value: tab[8][ind] == 1,
                                                                 bottom_range: tab[8][ind + 1],
                                                                 top_range: tab[8][ind + 2],
                                                                 weight:  tab[8][ind + 3] ? tab[8][ind + 3] : 1)

                      @guw_model.guw_work_units.each do |wu|
                        while !tab[ind2].nil? && tab[ind2][0] != wu.name #&& tab[ind2][0] != I18n.t(:organization_technology)
                          ind2 += 1
                        end
                        if !tab[ind2].nil?# && tab[ind2][0] != I18n.t(:organization_technology)
                          Guw::GuwComplexityWorkUnit.create(guw_complexity_id: @guw_complexity.id,
                                                            guw_work_unit_id: wu.id,
                                                            value: tab[ind2][ind + 3],
                                                            guw_type_id: @guw_type.nil? ? nil : @guw_type.id)
                        end
                        # elsif tab[ind2].nil?
                        #   route_flag = 3
                        #   break
                        # end
                        ind2 = 10
                        action_type_aquisition_flag = true
                      end

                      @guw_model.guw_weightings.each do |we|
                        while !tab[ind2].nil? && tab[ind2][0] != we.name# && tab[ind2][0] != I18n.t(:organization_technology)
                          ind2 += 1
                        end
                        if !tab[ind2].nil? #&& tab[ind2][0] != I18n.t(:organization_technology)
                          Guw::GuwComplexityWeighting.create(guw_complexity_id: @guw_complexity.id,
                                                             guw_weighting_id: we.id,
                                                             value: tab[ind2][ind + 3],
                                                             guw_type_id: @guw_type.nil? ? nil : @guw_type.id)
                        end
                        # elsif tab[ind2].nil?
                        #   route_flag = 3
                        #   break
                        # end
                        ind2 = 10
                        action_type_aquisition_flag = true
                      end

                      @guw_model.guw_factors.each do |fa|
                        while !tab[ind2].nil? && tab[ind2][0] != fa.name# && tab[ind2][0] != I18n.t(:organization_technology)
                          ind2 += 1
                        end
                        if !tab[ind2].nil? #&& tab[ind2][0] != I18n.t(:organization_technology)
                          Guw::GuwComplexityFactor.create(guw_complexity_id: @guw_complexity.id,
                                                          guw_factor_id: fa.id,
                                                          value: tab[ind2][ind + 3],
                                                          guw_type_id: @guw_type.nil? ? nil : @guw_type.id)
                        end

                      end

                      while !tab[ind2].nil? && tab[ind2][0] != I18n.t(:organization_technology)
                        ind2 += 1
                      end
                      ind3 = ind2
                      if !tab[ind2].nil? && tab[ind2][0] == I18n.t(:organization_technology)
                        @current_organization.organization_technologies.each do |techno|
                         while !tab[ind2].nil? && tab[ind2][0] != techno.name
                           ind2 += 1
                         end
                         if !tab[ind2].nil?
                           Guw::GuwComplexityTechnology.create(guw_complexity_id: @guw_complexity.id,
                                                               organization_technology_id: techno.id,
                                                               coefficient: tab[ind2][ind + 3],
                                                               guw_type_id: @guw_type.nil? ? nil : @guw_type.id)
                         end
                         ind2 = ind3
                        end
                        if save_position == 0
                          while !tab[ind2].nil?
                            ind2 += 1
                          end
                          save_position = ind2 + 1
                        end
                        action_technologie_flag = true
                      end
                      ind2 = 10
                      ind += 4
                    end
                    ind = 1
                  end
                  if !tab[save_position].nil?# && tab[save_position][0] == I18n.t(:complexity_threshold) && tab[save_position + 1][0] == I18n.t(:pe_attributes)
                    ind3 = save_position + 2
                    ind = 1
                    while !tab[save_position][ind].nil?
                      if tab[save_position].nil?
                        value = nil
                      else
                        value = tab[save_position][ind + 1]
                      end
                     @guw_att_complexity =  Guw::GuwTypeComplexity.create(guw_type_id: @guw_type.id,
                                                                          name: tab[save_position][ind],
                                                                          value: value)
                      @guw_model.guw_attributes.each do |att|
                        while !tab[ind3].nil? && tab[ind3][0] != att.name
                          ind3 += 1
                        end
                        if !tab[ind3].nil?
                          toto = Guw::GuwAttributeComplexity.create(guw_type_complexity_id: @guw_att_complexity.id,
                                                             guw_attribute_id: att.id,
                                                             guw_type_id: @guw_type.id,
                                                             enable_value: tab[ind3][ind] == 1,
                                                             bottom_range: tab[ind3][ind + 1],
                                                             top_range: tab[ind3][ind + 2],
                                                             value: tab[ind3][ind + 3] ? tab[ind3][ind + 3] : (tab[ind3][ind + 2] && tab[ind3][ind + 1] ? 1 : nil))
                        end
                        ind3 = save_position + 2
                      end
                     ind += 4
                    end
                    ind3 = 0
                    ind = 1
                    action_attribute_flag = true
                  end

                  unless action_type_aquisition_flag
                    tab_error[0].push(@guw_type.name)
                  end
                  unless action_technologie_flag
                    tab_error[1].push(@guw_type.name)
                  end
                  unless action_attribute_flag
                    tab_error[2].push(@guw_type.name)
                  end
                  action_attribute_flag = false
                  action_technologie_flag = false
                  action_type_aquisition_flag = false
                else
                  route_flag = 6
                  sheet_error += 1
                end
              else
                route_flag = 7
                break
              end
            end
          end
        else
          route_flag = 6
          sheet_error += 1
        end
        save_position = 0
        end
      else
        route_flag = 4
    end
    redirect_to_good_path(route_flag, sheet_error)
    bug_tracker(tab_error)
  end

  def the_most_largest(my_string)
    ind = 0
    len = 0
    len2 = 0
    if my_string.nil?
      return 1
    end
    while my_string[ind]
      if my_string[ind] == "\n" || my_string[ind + 1] == nil
        if len2 < len
          len2 = len
        end
        len = 0
      else
        len += 1
      end
      ind += 1
    end
    len2
  end


  # Export de l'ancien module de Taille
  def export_old_config

    workbook = RubyXL::Workbook.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_organisation = @guw_model.organization
    @guw_types = @guw_model.guw_types
    first_page = [[I18n.t(:model_name),  @guw_model.name],
                  [I18n.t(:model_description), @guw_model.description ],
                  [I18n.t(:work_unit_label),  @guw_model.coefficient_label.blank? ? 'Facteur sans nom 1' : @guw_model.coefficient_label],
                  [I18n.t(:weightings_label),  @guw_model.weightings_label.blank? ? 'Facteur sans nom 2' : @guw_model.weightings_label],
                  [I18n.t(:factors_label),  @guw_model.factors_label.blank? ? 'Facteur sans nom 3' : @guw_model.factors_label],
                  [I18n.t(:three_points_estimation), @guw_model.three_points_estimation ? 1 : 0],
                  [I18n.t(:retained_size_unit), @guw_model.retained_size_unit],
                  [I18n.t(:hour_coefficient_conversion), @guw_model.hour_coefficient_conversion],
                  [I18n.t(:advice), ""]]
    ind = 0
    ind2 = 1
    ind3 = 5
    used_column = []

    worksheet = workbook[0]
    worksheet.sheet_name = I18n.t(:is_model)
    workbook.add_worksheet(I18n.t(:attribute_description))
    workbook.add_worksheet(@guw_model.coefficient_label.blank? ? 'Facteur sans nom 1' : @guw_model.coefficient_label)
    workbook.add_worksheet(@guw_model.weightings_label.blank? ? 'Facteur sans nom 2' : @guw_model.weightings_label)
    workbook.add_worksheet(@guw_model.factors_label.blank? ? 'Facteur sans nom 3' : @guw_model.factors_label)

    first_page.each_with_index do |row, index|
      worksheet.add_cell(index, 0, row[0].value)
      worksheet.add_cell(index, 1, row[1].value).change_horizontal_alignment('center')
      ["bottom", "right"].each do |symbole|
        worksheet[index][0].change_border(symbole.to_sym, 'thin')
        worksheet[index][1].change_border(symbole.to_sym, 'thin')
      end
    end
    worksheet.change_column_bold(0,true)
    worksheet.change_row_height(1, @guw_model.description.count("\n") * 13 + 1)
    worksheet.change_column_width(0, 38)
    worksheet.change_column_width(1, 30)
    # worksheet.merge_cells(6, 0, 6, 1)
    # worksheet.change_row_height(6, 25)

    worksheet = workbook[1]

    counter_line = 1
    worksheet.add_cell(0, 0, I18n.t(:pe_attribute_name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    # worksheet.change_row_bold(0,true)

    worksheet.change_row_horizontal_alignment(0, 'center')
    @guw_model.guw_attributes.order("name ASC").each_with_index do |attribute, indx|
      worksheet.add_cell(indx + 1, 0, attribute.name)
      worksheet.add_cell(indx + 1, 1, attribute.description)
      if ind < attribute.name.size
        worksheet.change_column_width(0, attribute.name.size)
        ind = attribute.name.size
      end
      if ind2 < the_most_largest(attribute.description)
        worksheet.change_column_width(1, the_most_largest(attribute.description))
        ind2 = the_most_largest(attribute.description)
      end
      counter_line += 1
    end

    counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        worksheet[line][0].change_border(symbole.to_sym, 'thin')
        worksheet[line][1].change_border(symbole.to_sym, 'thin')
      end
    end

    ind = 0
    ind2 = 6

    worksheet = workbook[2]
    counter_line = 1
    page = [I18n.t(:name), I18n.t(:value), I18n.t(:display_order)]
    page.each_with_index do |cell_name, index|
      worksheet.add_cell(0, index, cell_name)
      worksheet.change_column_horizontal_alignment(index, 'center')
    end

    worksheet.change_column_width(2, I18n.t(:display_order).size)
    @guw_model.guw_work_units.each_with_index do |aquisitions_type,indx|
      worksheet.add_cell(indx + 1, 0, aquisitions_type.name)
      worksheet.add_cell(indx + 1, 1, aquisitions_type.value)
      worksheet.add_cell(indx + 1, 2, aquisitions_type.display_order)
      if ind < aquisitions_type.name.size
        worksheet.change_column_width(0, aquisitions_type.name.size)
        ind = aquisitions_type.name.size
      end
      counter_line += 1
    end
    counter_line.times do |indx|
      ["bottom", "right"].each do |symbole|
        worksheet[indx][0].change_border(symbole.to_sym, 'thin')
        worksheet[indx][1].change_border(symbole.to_sym, 'thin')
        worksheet[indx][2].change_border(symbole.to_sym, 'thin')
      end
    end

    worksheet = workbook[3]
    counter_line = 1
    page = [I18n.t(:name), I18n.t(:value), I18n.t(:display_order)]
    page.each_with_index do |cell_name, index|
      worksheet.add_cell(0, index, cell_name)
      worksheet.change_column_horizontal_alignment(index, 'center')
    end

    worksheet.change_column_width(2, I18n.t(:display_order).size)
    @guw_model.guw_weightings.each_with_index do |aquisitions_type,indx|
      worksheet.add_cell(indx + 1, 0, aquisitions_type.name)
      worksheet.add_cell(indx + 1, 1, aquisitions_type.value)
      worksheet.add_cell(indx + 1, 2, aquisitions_type.display_order == 0 ? indx : aquisitions_type.display_order)
      if ind < aquisitions_type.name.size
        worksheet.change_column_width(0, aquisitions_type.name.size)
        ind = aquisitions_type.name.size
      end
      counter_line += 1
    end
    counter_line.times do |indx|
      ["bottom", "right"].each do |symbole|
        worksheet[indx][0].change_border(symbole.to_sym, 'thin')
        worksheet[indx][1].change_border(symbole.to_sym, 'thin')
        worksheet[indx][2].change_border(symbole.to_sym, 'thin')
      end
    end

    worksheet = workbook[4]
    counter_line = 1
    page = [I18n.t(:name), I18n.t(:value), I18n.t(:display_order)]
    page.each_with_index do |cell_name, index|
      worksheet.add_cell(0, index, cell_name)
      worksheet.change_column_horizontal_alignment(index, 'center')
    end

    worksheet.change_column_width(2, I18n.t(:display_order).size)
    @guw_model.guw_factors.each_with_index do |aquisitions_type,indx|
      worksheet.add_cell(indx + 1, 0, aquisitions_type.name)
      worksheet.add_cell(indx + 1, 1, aquisitions_type.value)
      worksheet.add_cell(indx + 1, 2, aquisitions_type.display_order == 0 ? indx : aquisitions_type.display_order)
      if ind < aquisitions_type.name.size
        worksheet.change_column_width(0, aquisitions_type.name.size)
        ind = aquisitions_type.name.size
      end
      counter_line += 1
    end
    counter_line.times do |indx|
      ["bottom", "right"].each do |symbole|
        worksheet[indx][0].change_border(symbole.to_sym, 'thin')
        worksheet[indx][1].change_border(symbole.to_sym, 'thin')
        worksheet[indx][2].change_border(symbole.to_sym, 'thin')
      end
    end

    ind = 0

    @guw_types.each do |guw_type|
      worksheet = workbook.add_worksheet(guw_type.name)
      description = Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(guw_type.description)).text
      worksheet.add_cell(0, ind, description)
      worksheet[0][0].change_border(:right, 'thin')
      worksheet[0][0].change_border(:bottom, 'thin')
      worksheet.change_row_height(0, description.count("\n") * 15 + 1)
      worksheet.change_column_width(0, 65)
      [[I18n.t(:enable_restraint),guw_type.allow_retained ? 1 : 0],
       [I18n.t(:enable_amount),   guw_type.allow_quantity ? 1 : 0],
       [I18n.t(:enable_complexity),  guw_type.allow_complexity ? 1 : 0],
       [ I18n.t(:enable_counting),guw_type.allow_criteria ? 1 : 0]].each_with_index do |line, index|
        worksheet.add_cell(index + 1, 0,line[0]).change_font_bold(true)
        worksheet.add_cell(index + 1, 1, line[1]).change_horizontal_alignment('center')
        ["bottom", "right", "top"].each do |symbole|
          worksheet[index + 1][0].change_border(symbole.to_sym, 'thin')
          worksheet[index + 1][1].change_border(symbole.to_sym, 'thin')
        end
      end

      @guw_complexities = guw_type.guw_complexities
      worksheet.add_cell(ind2 , 0,  I18n.t(:UO_type_complexity))
      worksheet[ind2][0].change_border(:top, 'thin')
      worksheet.sheet_data[ind2][0].change_font_bold(true)

      worksheet.add_cell(ind2 + 2, 0, I18n.t(:threshold))
      worksheet[ind2 + 2][0].change_border(:bottom, 'thin')

      worksheet.sheet_data[ind2 + 2][0].change_font_bold(true)
      worksheet.add_cell(ind2 + 3, 0,  I18n.t(:Coefficient_of_acquisiton))
      worksheet[ind2 + 3][0].change_border(:bottom, 'thin')

      @guw_complexities.each do |guw_complexity|

        worksheet.add_cell(ind2, ind + 1, guw_complexity.name).change_horizontal_alignment('center')
        worksheet[ind2][ind + 1].change_border(:top, 'thin')
        worksheet[ind2][ind + 1].change_border(:left, 'thin')
        worksheet[ind2][ind + 1].change_border(:right, 'thin')
        [["Prod", guw_complexity.enable_value ? 1 : 0],
         ["[", guw_complexity.bottom_range],
         ["[", guw_complexity.top_range],
         [I18n.t(:my_display), guw_complexity.weight]].each_with_index do |name_cell, index|
          worksheet.add_cell(ind2 + 1, ind + index+ 1, name_cell[0]).change_horizontal_alignment('center')
          worksheet.add_cell(ind2 + 2, ind + index+ 1, name_cell[1]).change_horizontal_alignment('center')
          ["bottom", "right", "top", "left"].each do |symbole|
            worksheet[ind2 + 1][ind + index + 1].change_border(symbole.to_sym, 'thin')
            worksheet[ind2 + 2][ind + index + 1].change_border(symbole.to_sym, 'thin')
          end
        end

        guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
          @guw_work_unit = guw_complexity_work_unit.guw_work_unit
          unless @guw_work_unit.nil?
            cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
            worksheet.add_cell(ind2 + 4, 0, @guw_work_unit.name)
            worksheet[ind2 + 4][0].change_border(:right, 'thin')

            ["","","",cu.value].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 4, ind + index + 1, val).change_horizontal_alignment('center')
            end
            4.times.each do |index|
              worksheet[10][ind + index + 1].change_border(:top, 'thin')
            end
            worksheet[ind2 + 4][ind + 4].change_border(:right, 'thin')
            ind2 += 1
          end
        end

        worksheet[ind2 + 3][0].change_border(:bottom, 'thin')
        5.times.each do |index|
          # worksheet[ind2 + 3][ind + index].change_border(:bottom, 'thin')
        end

        worksheet.add_cell(ind2 + 4, 0, I18n.t(:organization_technology))
        worksheet[ind2 + 4][0].change_border(:bottom, 'thin')

        block_it = ind2 + 5

        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
          @guw_organisation_technology = complexity_technology.organization_technology
          unless @guw_organisation_technology.nil?
            ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
            worksheet.add_cell(ind2 + 5, 0, @guw_organisation_technology.name)
            worksheet[ind2 + 5][0].change_border(:right, 'thin')

            ["", "", "", ct.coefficient].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 5, ind + index + 1, val).change_horizontal_alignment('center')
              worksheet[block_it][ind + index + 1].change_border(:top, 'thin')

            end
            worksheet[ind2 + 5][ind + 4].change_border(:right, 'thin')
            ind2 += 1
          end
        end
        worksheet[ind2 + 4][0].change_border(:bottom, 'thin')
        unless guw_complexity.guw_complexity_technologies.empty?
          4.times.each_with_index do |index|
            worksheet[ind2 + 4][ind + index + 1].change_border(:bottom, 'thin')
          end
        end

        if ind3 < ind2
          ind3 += (ind2 + 1)
        end
        ind2 = 6
        ind += 4
      end
      ind = 0
      [I18n.t(:complexity_threshold), I18n.t(:pe_attributes)].each_with_index do |val, index|
        worksheet.add_cell(ind3 + index, ind, val)
        worksheet.sheet_data[ind3 + index][ind].change_font_bold(true)
        worksheet[ind3 + index][ind].change_border(:top, 'thin')
        worksheet[ind3 + index][ind].change_border(:bottom, 'thin')
      end


      guw_type.guw_type_complexities.each  do |type_attribute_complexity|
        worksheet.add_cell(ind3, ind + 1, type_attribute_complexity.name).change_horizontal_alignment('center')
        worksheet.add_cell(ind3, ind + 2, type_attribute_complexity.value).change_horizontal_alignment('center')
        worksheet[ind3][ind + 1].change_border(:top, 'thin')
        worksheet[ind3][ind + 1].change_border(:right, 'thin')
        worksheet[ind3][ind + 1].change_border(:left, 'thin')
        ["Prod","[","[",I18n.t(:my_display)].each_with_index do |val, index|
          worksheet.add_cell(ind3 + 1, ind + index + 1, val ).change_horizontal_alignment('center')
          ["top","bottom", "left", "right"].each do |sym_val|
            worksheet[ind3 + 1][ind + index +1].change_border(sym_val.to_sym, 'thin')
          end
        end

        ind4 = ind3 + 2
        @guw_model.guw_attributes.order("name ASC").each do |attribute|
          worksheet.add_cell(ind4, 0, attribute.name)
          worksheet[ind4][0].change_border(:right, 'thin')

          att_val = Guw::GuwAttributeComplexity.where(guw_type_complexity_id: type_attribute_complexity.id, guw_attribute_id: attribute.id).first
          unless att_val.nil?
            [att_val.enable_value ? 1 : 0, att_val.bottom_range,att_val.top_range, att_val.value].each_with_index do |val, index|
              worksheet.add_cell(ind4, ind + index + 1, val).change_horizontal_alignment('center')
              worksheet[ind4][ind + index +1].change_border(:right, 'thin')
            end
          end
          ind4 += 1
        end

        # begin
        #   worksheet[ind4 - 1][0].change_border(:bottom, 'thin')
        #   (@guw_model.guw_attributes.size - 1).times.each do |index|
        #     worksheet[ind4 - 1][ind + index].change_border(:bottom, 'thin')
        #   end
        # rescue
        # end

        ind += 4
      end
      ind = 0
      ind3 = 5
    end

    worksheet = workbook.add_worksheet("Matrice")
    [[@guw_model.coefficient_label, "work_unit"], [@guw_model.weightings_label, "weighting"], [@guw_model.factors_label, "factor"]].each_with_index do |ts, i|
      worksheet.add_cell(0, i+1, ts[0])
      ["size", "effort", "cost"].each_with_index do |ta, j|
        worksheet.add_cell(j+1, 0, ta.to_s.humanize)
        gsma = Guw::GuwScaleModuleAttribute.where(guw_model_id: @guw_model.id,
                                                  type_attribute: ta,
                                                  type_scale: ts[1]).first
        worksheet.add_cell(j+1, i+1, gsma.nil? ? 0 : 1)
      end
    end

    send_data(workbook.stream.string, filename: "#{@guw_model.name[0.4]}_ModuleUOMXT-#{@guw_model.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end


  # Export de l'ancien module de Taille
  def export_new_config

    workbook = RubyXL::Workbook.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_organisation = @guw_model.organization
    @guw_types = @guw_model.guw_types.where(organization_id: @guw_organisation.id)
    @guw_outputs = @guw_model.guw_outputs.where(organization_id: @guw_organisation.id).order("display_order ASC")

    first_page = [[I18n.t(:model_name),  @guw_model.name],
                  [I18n.t(:model_description), @guw_model.description],
                  [I18n.t(:work_unit_label),  @guw_model.coefficient_label.blank? ? 'Facteur sans nom 1' : @guw_model.coefficient_label],
                  [I18n.t(:weightings_label),  @guw_model.weightings_label.blank? ? 'Facteur sans nom 2' : @guw_model.weightings_label],
                  [I18n.t(:factors_label),  @guw_model.factors_label.blank? ? 'Facteur sans nom 3' : @guw_model.factors_label],
                  [I18n.t(:three_points_estimation), @guw_model.three_points_estimation ? 1 : 0],
                  [I18n.t(:retained_size_unit), @guw_model.retained_size_unit],
                  [I18n.t(:hour_coefficient_conversion), @guw_model.hour_coefficient_conversion],
                  ["Autoriser le comptage automatique", @guw_model.allow_ml],
                  ["Affichage par défaut", @guw_model.default_display],
                  ["Visualisation des données", @guw_model.view_data]
                  ]

    # Add Action & Coeff & coefficientElements
    @guw_model.orders.each do |coefficient, value|
      first_page << [coefficient, value.blank? ? '' : value.to_i]
    end

    first_page << [I18n.t(:config_type), @guw_model.config_type]

    first_page << ["allow_excel", @guw_model.allow_excel]
    first_page << ["excel_ml_server", @guw_model.excel_ml_server]
    first_page << ["allow_ml_excel", @guw_model.allow_ml_excel]

    first_page << ["allow_jira", @guw_model.allow_jira]
    first_page << ["jira_ml_server", @guw_model.jira_ml_server]
    first_page << ["allow_ml_jira", @guw_model.allow_ml_jira]

    first_page << ["allow_redmine", @guw_model.allow_redmine]
    first_page << ["redmine_ml_server", @guw_model.redmine_ml_server]
    first_page << ["allow_ml_redmine", @guw_model.allow_ml_redmine]

    ind = 0
    ind2 = 1

    worksheet = workbook[0]
    worksheet.sheet_name = I18n.t(:is_model)
    workbook.add_worksheet(I18n.t(:attribute_description))

    first_page.each_with_index do |row, index|
      worksheet.add_cell(index, 0, row[0].nil? ? '' : row[0])
      worksheet.add_cell(index, 1, row[1].nil? ? '' : row[1])
    end

    worksheet.change_column_bold(0,true)
    worksheet.change_column_width(0, 45)
    worksheet.change_column_width(1, 45)

    worksheet = workbook[1]

    counter_line = 1
    worksheet.add_cell(0, 0, I18n.t(:pe_attribute_name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    # worksheet.change_row_bold(0,true)

    worksheet.change_row_horizontal_alignment(0, 'center')
    @guw_model.guw_attributes.where(organization_id: @guw_organisation.id).order("name ASC").each_with_index do |attribute, indx|
      worksheet.add_cell(indx + 1, 0, attribute.name)
      worksheet.add_cell(indx + 1, 1, attribute.description)
      if ind < attribute.name.size
        worksheet.change_column_width(0, attribute.name.size)
        ind = attribute.name.size
      end
      if ind2 < the_most_largest(attribute.description)
        worksheet.change_column_width(1, the_most_largest(attribute.description))
        ind2 = the_most_largest(attribute.description)
      end
      counter_line += 1
    end

    counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        worksheet[line][0].change_border(symbole.to_sym, 'thin')
        worksheet[line][1].change_border(symbole.to_sym, 'thin')
      end
    end

    ind = 0
    ind2 = 6

    #==================  GUW-COEFFICIENTS  ==================

    coefficients_worksheet = workbook.add_worksheet("Coefficients")
    counter_line = 1
    coefficients_worksheet.add_cell(0, 0, I18n.t(:name))
    coefficients_worksheet.add_cell(0, 1, I18n.t(:description))
    coefficients_worksheet.add_cell(0, 2, I18n.t(:coefficient_type))
    coefficients_worksheet.add_cell(0, 3, I18n.t(:allow_intermediate_value))
    coefficients_worksheet.add_cell(0, 4, I18n.t(:deported))
    coefficients_worksheet.add_cell(0, 5, I18n.t(:show_coefficient_application_label))

    @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).each_with_index do |coeff, index|
      coefficients_worksheet.add_cell(index + 1, 0, coeff.name)
      coefficients_worksheet.add_cell(index + 1, 1, coeff.description)
      coefficients_worksheet.add_cell(index + 1, 2, coeff.coefficient_type)
      coefficients_worksheet.add_cell(index + 1, 3, (coeff.allow_intermediate_value == true ? 1 : 0))
      coefficients_worksheet.add_cell(index + 1, 4, (coeff.deported == true ? 1 : 0))
      coefficients_worksheet.add_cell(index + 1, 5, (coeff.show_coefficient_label == true ? 1 : 0))

      counter_line += 1
    end

    ###==================  GUW-COEFFICIENTS-ELEMENTS  ==================

    coefficient_elements_attributes = ["name", "description", "value", "default_display_value", "display_order", "default", "color_code", "color_priority"]
    counter_line = 1
    # On cree une feuille par element de coeff
    @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).each_with_index do |coefficient, index|
      # on cree une feuille pour tous les elments de ce coefficients
      workbook.add_worksheet(coefficient.name)

      coeff_elements_worksheet = workbook[coefficient.name]
      coeff_elements_worksheet.add_cell(0, 0, I18n.t(:coefficient_name))
      coeff_elements_worksheet.add_cell(0, 1, coefficient.name)

      counter_line = 2
      coeff_elements_worksheet.add_cell(counter_line, 0, "Elements du coefficient")

      coefficient_elements_attributes.each_with_index do |attr, index|
        column_number = index + 1
        coeff_elements_worksheet.add_cell(counter_line, column_number, I18n.t("#{attr}")).change_horizontal_alignment('center')

        line_number = counter_line + 1
        coefficient.guw_coefficient_elements.where(organization_id: @guw_organisation.id, guw_model_id: @guw_model.id).order('display_order ASC').each do |coeff_element|
          column_value = coeff_element.send(attr)
          if attr == "default"
            column_value = coeff_element.default ? 1 : 0
          end
          coeff_elements_worksheet.add_cell(line_number, column_number, column_value)
          line_number += 1
        end
      end

      coeff_elements_worksheet.change_column_bold(0,true)
      counter_line += coefficient.guw_coefficient_elements.where(organization_id: @guw_organisation.id, guw_model_id: @guw_model.id).all.size

      counter_line.times do |indx|
        3.times do |col|
          ["bottom", "right", "top"].each do |symbole|
            begin
              coeff_elements_worksheet[indx][col].change_border(symbole.to_sym, 'thin')
            rescue
              # ignored
            end
          end
        end
      end

    end


    # ================== GUW-OUTPUTS ==================

    counter_line = 1

    workbook.add_worksheet(I18n.t(:outputs))
    outputs_worksheet = workbook[I18n.t(:outputs)]
    outputs_attributes = ["name", "output_type", "allow_intermediate_value", "allow_subtotal", "standard_coefficient", "display_order", "unit"]

    outputs_attributes.each_with_index do |attr, index|
      outputs_worksheet.add_cell(0, index, I18n.t("#{attr}")).change_horizontal_alignment('center')
      outputs_worksheet.change_column_width(index, I18n.t("#{attr}").size)
    end

    line_number = 1
    @guw_outputs.each do |output|
      outputs_attributes.each_with_index do |attr, index|
        column_value = output.send(attr)
        outputs_worksheet.add_cell(line_number, index, column_value)

        column_width = outputs_worksheet.get_column_width(index)
        if column_value.to_s.size > column_width
          outputs_worksheet.change_column_width(index, column_value.size)
        end
      end
      line_number += 1
    end

    # outputs_worksheet.change_row_bold(0,true)
    counter_line += @guw_outputs.size

    counter_line.times do |indx|
      outputs_attributes.each_with_index do |attr, col|
        ["bottom", "right", "top"].each do |symbole|
          begin
            outputs_worksheet[indx][col].change_border(symbole.to_sym, 'thin')
          rescue
            # ignored
          end
        end
      end
    end


    #===================  Pour chaque type d'UO    ==================

    @guw_types.each do |guw_type|
      worksheet = workbook.add_worksheet(guw_type.name)

      ind = 0
      counter_line = 1

      description = Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(guw_type.description)).text
      guw_type_attributes = [
           [I18n.t(:name), guw_type.name],
           [I18n.t(:description), description],
           [I18n.t(:Changing_the_count_enter), guw_type.allow_criteria ? 1 : 0],
           [I18n.t(:attribute_type), guw_type.attribute_type],
           [I18n.t(:Changing_of_the_size_enter), guw_type.allow_retained ? 1 : 0],
           [I18n.t(:Changing_the_quantity_enter), guw_type.allow_quantity ? 1 : 0],
           [I18n.t(:display_threshold), guw_type.display_threshold ? 1 : 0],
           [I18n.t(:Changing_the_complexity_enter), guw_type.allow_complexity ? 1 : 0],
      ]

      guw_type_attributes.each_with_index do |line, index|
        worksheet.add_cell(index, 0, line[0]).change_font_bold(true)
        worksheet.add_cell(index, 1, line[1])

        counter_line += 1
      end

      worksheet.add_cell(0, 3, "Color priority")
      worksheet.add_cell(1, 3, "Color code")
      worksheet.add_cell(2, 3, "Allow line color")

      worksheet.add_cell(0, 4, guw_type.color_priority)
      worksheet.add_cell(1, 4, guw_type.color_code)
      worksheet.add_cell(2, 4, guw_type.allow_line_color.nil? ? "false" : "true")

      unless description.empty?
        description_row_height = description.count("\n") * 15 + 1
        worksheet.change_row_height(1, description_row_height)
      end

      worksheet.change_column_width(0, 65)

      #======= GUW-COMPLEXITES ===============

      #counter_line += 1
      ind2 = counter_line
      guw_complexity_attributes = ["name", "bottom_range", "top_range", "enable_value", "default_value", "weight", "weight_b", "display_order"]

      @guw_complexities = guw_type.guw_complexities.where(organization_id: @guw_organisation.id, guw_model_id: @guw_model.id).order("display_order asc")

      worksheet.add_cell(ind2, 0,  I18n.t(:UO_type_complexity)).change_font_bold(true)
      worksheet.add_cell(ind2 + 2, 0, I18n.t(:threshold)).change_font_bold(true)

      #======   Colonne 0 =============
      # Valeur initiale (Σ)
      # worksheet.change_row_bold(ind2 + 3,true)
      worksheet.add_cell(ind2 + 3, 0, "Valeur initiale").change_font_bold(true)

      # Un (1)
      worksheet.add_cell(ind2 + 4, 0, "Un (1)").change_font_bold(true)
      un_line_number = ind2 + 4

      # UO CPLX
      worksheet.add_cell(ind2 + 5, 0, "UO CPLX").change_font_bold(true)
      uo_cplx_line_number = ind2 + 5

      # OUTPUTS
      output_line = ind2 + 6
      @guw_outputs.each do |guw_output|
        worksheet.add_cell(output_line, 0, guw_output.name)

        got = Guw::GuwOutputType.where(organization_id: @guw_organisation.id,
                                       guw_model_id: @guw_model.id,
                                       guw_output_id: guw_output.id,
                                       guw_type_id: guw_type.id).first

        worksheet.add_cell(output_line, 1, got.nil? ? nil : got.display_type)

        output_line += 1
      end

      # UN (1) : un_line_number Values
      # UO CPLX VALUES : uo_cplx_line_number
      un_column_number = 2
      cn = 2
      guw_type.guw_complexities.where(organization_id: @guw_organisation.id, guw_model_id: @guw_model.id).order("display_order asc").each do |guw_complexity|

        @guw_outputs.each_with_index do |guw_output, ii|
          oci = Guw::GuwOutputComplexityInitialization.where(organization_id: @guw_organisation.id,
                                                             guw_model_id: @guw_model.id,
                                                             guw_output_id: guw_output.id,
                                                             guw_complexity_id: guw_complexity.id).first
          oci_value = oci.nil? ? '' : oci.init_value
          worksheet.add_cell(13, un_column_number + ii, oci_value)

          oc = Guw::GuwOutputComplexity.where(organization_id: @guw_organisation.id,
                                              guw_model_id: @guw_model.id,
                                              guw_output_id: guw_output.id,
                                              guw_complexity_id: guw_complexity.id).first
          oc_value = (oc.nil? ? '' : oc.value)
          worksheet.add_cell(14, un_column_number + ii, oc_value)
        end

        sn = 15
        @guw_outputs.each do |aguw_output|
          @guw_outputs.each_with_index do |guw_output, j|

            oa = Guw::GuwOutputAssociation.where(organization_id: @guw_organisation.id,
                                                 guw_model_id: @guw_model.id,
                                                 guw_output_id: guw_output.id,
                                                 guw_complexity_id: guw_complexity.id,
                                                 guw_output_associated_id: aguw_output.id).first
            oa_value = (oa.nil? ? '' : oa.value)

            worksheet.add_cell(sn, cn+j, oa_value)
          end
          sn += 1
        end

        cn += 5

        if @guw_outputs.size <= 5
          un_column_number = un_column_number + 5
        else
          un_column_number = (2 + @guw_outputs.size)
        end

      end

      column_number = ind + 2

      cn = 2
      @guw_complexities.each_with_index do |guw_complexity|

        guw_complexity_attributes_values = [
            ["Prod", guw_complexity.enable_value ? 1 : 0],
            ["[", guw_complexity.bottom_range],
            ["[", guw_complexity.top_range],
            ["#{I18n.t(:my_display)}(a)", guw_complexity.weight],
            ["#{I18n.t(:my_display)}(b)", guw_complexity.weight_b]
        ]

        worksheet.add_cell(ind2, column_number, guw_complexity.name)
        worksheet.add_cell(ind2, column_number + 1, guw_complexity.default_value)

        guw_complexity_attributes_values.each_with_index do |name_cell, index|
          worksheet.add_cell(ind2 + 1, column_number + index, name_cell[0])
          worksheet.add_cell(ind2 + 2, column_number + index, name_cell[1])
        end

        counter_line = ind2 + 3
        @guw_outputs.each_with_index do |guw_output, index|
          worksheet.add_cell(counter_line, column_number + index, guw_output.name)
        end

        output_line = 15 + @guw_outputs.size
        @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).each do |guw_coefficient|

          worksheet.add_cell(output_line, 0, guw_coefficient.name)
          # worksheet.change_row_bold(output_line, true)

          @guw_outputs.each_with_index do |guw_output, index|
            worksheet.add_cell(output_line, column_number + index, guw_output.name)
          end

          output_line += 1

          guw_coefficient.guw_coefficient_elements.where(organization_id: @guw_organisation.id, guw_model_id: @guw_model.id).order('display_order ASC').each do |guw_coefficient_element|

            worksheet.add_cell(output_line, 0, guw_coefficient_element.name)

            @guw_outputs.each_with_index do |guw_output, j|

              cf = Guw::GuwComplexityCoefficientElement.where(organization_id: @guw_organisation.id,
                                                              guw_model_id: @guw_model.id,
                                                              guw_output_id: guw_output.id,
                                                              guw_complexity_id: guw_complexity.id,
                                                              guw_coefficient_element_id: guw_coefficient_element.id).first

              worksheet.add_cell(output_line, cn+j, (cf.nil? ? nil : cf.value))
            end
            output_line += 1
          end
        end
        cn += 5

        column_number += guw_complexity_attributes_values.size
      end

      sln = 16 + @guw_outputs.size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).map(&:guw_coefficient_elements).flatten.size
      scn = 0

      aln1 = 17 + @guw_outputs.size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).map(&:guw_coefficient_elements).flatten.size
      an = 1

      aln2 = 18 + @guw_outputs.size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).size + @guw_model.guw_coefficients.where(organization_id: @guw_organisation.id).map(&:guw_coefficient_elements).flatten.size
      an2 = 1

      worksheet.add_cell(sln, 0, "Seuils de Complexités Attributs").change_font_bold(true)
      worksheet.add_cell(aln1, 0, "Attributs").change_font_bold(true)

      guw_type.guw_type_complexities.where(organization_id: @guw_organisation.id,
                                           guw_model_id: @guw_model.id).each do |type_attribute_complexity|

        worksheet.add_cell(sln, scn + 1, type_attribute_complexity.name).change_font_bold(true)
        worksheet.add_cell(sln, scn + 2, type_attribute_complexity.value)
        scn += 5

        ["Prod","[","[","A","B", "Valeur par defaut de l'attribut"].each_with_index do |val, index|
          worksheet.add_cell(aln1, an + index, val).change_font_bold(true)
        end
        an += 5

        @guw_model.guw_attributes.where(organization_id: @guw_organisation.id).order("name ASC").each_with_index do |attribute, index|
          worksheet.add_cell(aln2 + index, 0, attribute.name)

          att_val = Guw::GuwAttributeComplexity.where(organization_id: @guw_organisation.id,
                                                      guw_model_id: @guw_model.id,
                                                      guw_attribute_id: attribute.id,
                                                      guw_type_complexity_id: type_attribute_complexity.id).first
          unless att_val.nil?

            @guw_model = Guw::GuwModel.where(organization_id: @guw_organisation.id, id: params[:guw_model_id]).first

            [att_val.enable_value ? 1 : 0, att_val.bottom_range, att_val.top_range, att_val.value, att_val.value_b].each_with_index do |val, j|
              worksheet.add_cell(aln2 + index, an2 + j, val)
            end

            begin
              guw_attribute_type = Guw::GuwAttributeType.where(organization_id: @guw_organisation.id,
                                                               guw_model_id: @guw_model.id,
                                                               guw_attribute_id: attribute.id,
                                                               guw_type_id: guw_type.id).first
              worksheet.add_cell(aln2 + index, 16, (guw_attribute_type.nil? ? nil : guw_attribute_type.default_value))
            rescue
              # ignored
            end

          end
        end
        an2 += 5

      end
    end

    send_data(workbook.stream.string, filename: "#{@guw_model.name[0.4]}_ModuleUOMXT-#{@guw_model.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end


  def show
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization
    session[:organization_id] = @organization.id
    @current_organization = @organization

    set_page_title @guw_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(@organization, anchor: "taille"), @guw_model.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @guw_model = Guw::GuwModel.new
    @guw_types = @guw_model.guw_types
    @guw_attributes = @guw_model.guw_attributes.order("name ASC")
    @guw_work_units = @guw_model.guw_work_units
    @guw_weightings = @guw_model.guw_weightings
    @guw_factors = @guw_model.guw_factors
    @guw_outputs = @guw_model.guw_outputs
    @guw_coefficients = @guw_model.guw_coefficients

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "taille"), I18n.t(:new) => ""
    set_page_title I18n.t(:new_UO_model)
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization
    @guw_types = @guw_model.guw_types
    @guw_attributes = @guw_model.guw_attributes.order("name ASC")
    @guw_work_units = @guw_model.guw_work_units
    @guw_weightings = @guw_model.guw_weightings
    @guw_factors = @guw_model.guw_factors
    @guw_outputs = @guw_model.guw_outputs.order("display_order ASC")
    @guw_coefficients = @guw_model.guw_coefficients

    set_page_title I18n.t(:edit_project_element_name, parameter: @guw_model.name)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(@organization, anchor: "taille"), @guw_model.name => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:guw_model][:organization_id])
    @guw_model = Guw::GuwModel.new(params[:guw_model])
    @guw_model.organization_id = params[:guw_model][:organization_id].to_i

    @guw_types = @guw_model.guw_types
    @guw_attributes = @guw_model.guw_attributes.order("name ASC")
    @guw_work_units = @guw_model.guw_work_units
    @guw_weightings = @guw_model.guw_weightings
    @guw_factors = @guw_model.guw_factors
    @guw_outputs = @guw_model.guw_outputs
    @guw_coefficients = @guw_model.guw_coefficients

    if @guw_model.save

      if @guw_model.config_type == "new"

        #Common attributes
        attrs = [
            ["Number of modified unit of work", "flagged_unit_of_work"],
            ["Number of offlined unit of work", "offline_unit_of_work"],
            ["Number of selected unit of work", "selected_of_unit_of_work"],
            ["Number of unit of work", "number_of_unit_of_work"],
            # ["Effort", "effort"],
        ]
        attrs.each do |attr|
          at = PeAttribute.where(name: attr[0], alias: attr[1], description: attr[0]).first
          pm = Pemodule.where(alias: "guw").first

          AttributeModule.where(pe_attribute_id: at.nil? ? nil : at.id,
                                pemodule_id:  pm.nil? ? nil : pm.id,
                                in_out: "both",
                                guw_model_id: @guw_model.id).first_or_create
        end
      end

      redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id), nil, guw.guw_model_path(@guw_model))
    else
      render action: :new
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])

    @guw_types = @guw_model.guw_types
    @guw_attributes = @guw_model.guw_attributes.order("name ASC")
    @guw_work_units = @guw_model.guw_work_units
    @guw_weightings = @guw_model.guw_weightings
    @guw_factors = @guw_model.guw_factors
    @guw_outputs = @guw_model.guw_outputs
    @guw_coefficients = @guw_model.guw_coefficients

    @organization = @guw_model.organization

    if @guw_model.update_attributes(params[:guw_model])

      if params[:items].present?
        @guw_model.orders = params[:items].to_hash
      end

      @guw_model.save

      if @guw_model.config_type == "new"
        #Common attributes
        attrs = [
            ["Number of modified unit of work", "flagged_unit_of_work"],
            ["Number of offlined unit of work", "offline_unit_of_work"],
            ["Number of selected unit of work", "selected_of_unit_of_work"],
            ["Number of unit of work", "number_of_unit_of_work"]
        ]
        attrs.each do |attr|
          at = PeAttribute.where(name: attr[0], alias: attr[1], description: attr[0], guw_model_id: @guw_model.id).first_or_create
          pm = Pemodule.where(alias: "guw").first

            AttributeModule.where(pe_attribute_id: at.id,
                                  pemodule_id: pm.id,
                                  in_out: "both",
                                  guw_model_id: @guw_model.id).first_or_create
        end
      end

      if @guw_model.default_display == "list"
        redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id), nil, guw.guw_model_all_guw_types_path(@guw_model)) and return
      else
        redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id), nil ,guw.guw_model_path(@guw_model)) and return
      end
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    organization_id = @guw_model.organization_id

    @guw_model.module_projects.each do |mp|
      mp.destroy
    end
    @guw_model.delete
    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id, anchor: "taille")
  end

  def duplicate
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    new_guw_model = @guw_model.amoeba_dup

    new_copy_number = @guw_model.copy_number.to_i+1
    new_guw_model.name = "#{@guw_model.name}(#{new_copy_number})"
    new_guw_model.copy_number = 0
    @guw_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_guw_model.transaction do
      if new_guw_model.save
        @guw_model.save
        new_guw_model.terminate_guw_model_duplication(@guw_model)
      end
    end
    
    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id, anchor: "taille")
  end

  def export_with_wbs
    current_mp = current_module_project
    @guw_model = current_mp.guw_model
    organization_id = @guw_model.organization_id
    project_id = current_mp.project_id

    @wbs_activity_module_project = current_mp.nexts.first
    unless @wbs_activity_module_project.nil?
      @wbs_activity = @wbs_activity_module_project.wbs_activity
    end

    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                  guw_model_id: @guw_model.id,
                                                  project_id: project_id,
                                                  module_project_id: current_mp.id,
                                                  pbs_project_element_id: @component.id)

    hash = @guw_model.orders
    hash.delete("Critères")
    hash.delete("Coeff. de Complexité")

    @guw_unit_of_works.each do |i|
      if i.nil?
        i.destroy
      end
    end

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    tab_size = [I18n.t(:estimation).length, I18n.t(:version_number).length,
                I18n.t(:group).length, I18n.t(:selected).length,
                I18n.t(:name).length, I18n.t(:description).length,
                20,
                20,
                20,
                I18n.t(:organization_technology).length, I18n.t(:quantity).length,
                I18n.t(:tracability).length, I18n.t(:cotation).length,
                I18n.t(:results).length, I18n.t(:retained_result).length,
                I18n.t(:pe_attribute_name).length, I18n.t(:low).length,
                I18n.t(:likely).length, I18n.t(:high).length]

    header = [
        "Nom du CDS",
        "Nom du fournisseur",
        "Nom de l'application",
        "Besoin métier",
        "Statut du devis",
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
        "Coeff. de complexité"] + hash.sort_by { |k, v| v.to_f }.map{|i| i.first } + @guw_model.guw_attributes.order("name ASC").map{|i| [i.name, "Commentaires"] }.flatten + (@wbs_activity.nil? ? [] : (@wbs_activity.wbs_activity_elements.select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten) + ["TJM Moyen"])

    header.each_with_index do |val, index|
      worksheet.add_cell(0, index, val)
    end

    # worksheet.change_row_bold(0,true)

    jj = 18 + @guw_model.guw_outputs.where(organization_id: organization_id).size + @guw_model.guw_coefficients.where(organization_id: organization_id).size

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

      worksheet.add_cell(ind, 0, current_mp.project.organization.name)
      worksheet.add_cell(ind, 1, current_mp.project.provider.name)
      worksheet.add_cell(ind, 2, current_mp.project.application.name)
      worksheet.add_cell(ind, 3, current_mp.project.business_need)
      worksheet.add_cell(ind, 4, current_mp.project.estimation_status.nil? ? nil : current_mp.project.estimation_status.name)
      worksheet.add_cell(ind, 5, current_mp.project.project_area.nil? ? nil : current_mp.project.project_area.name)
      worksheet.add_cell(ind, 6, current_mp.project.acquisition_category.nil? ? nil : current_mp.project.acquisition_category.name)
      worksheet.add_cell(ind, 7, current_mp.project.platform_category.nil? ? nil : current_mp.project.platform_category.name)
      worksheet.add_cell(ind, 8, current_mp.project.title)
      worksheet.add_cell(ind, 9, current_mp.project.version_number)
      worksheet.add_cell(ind, 10, guow.guw_unit_of_work_group.nil? ? '-' : guow.guw_unit_of_work_group.name)
      worksheet.add_cell(ind, 11, guow.selected ? 1 : 0)
      worksheet.add_cell(ind, 12, guow.name)
      worksheet.add_cell(ind, 13, (guow.guw_type.nil? ? '-' : guow.guw_type.name))
      worksheet.add_cell(ind, 14, guow.comments.to_s.gsub!(/[^a-zA-ZàâäôéèëêïîçùûüÿæœÀÂÄÔÉÈËÊÏÎŸÇÙÛÜÆŒ ]/, ''))
      worksheet.add_cell(ind, 15, guow.quantity)
      worksheet.add_cell(ind, 16, guow.tracking)
      worksheet.add_cell(ind, 17, cplx)
      worksheet.add_cell(ind, 18, guow.intermediate_weight)

      hash.sort_by { |k, v| v.to_f }.each_with_index do |i, j|
        if Guw::GuwCoefficient.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first.class == Guw::GuwCoefficient
          guw_coefficient = Guw::GuwCoefficient.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first
          unless guw_coefficient.nil?
            unless guw_coefficient.guw_coefficient_elements.empty?
              ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                guw_model_id: @guw_model.id,
                                                                guw_coefficient_id: guw_coefficient.id,
                                                                project_id: project_id,
                                                                module_project_id: guow.module_project_id,
                                                                guw_unit_of_work_id: guow.id).first

              if guw_coefficient.coefficient_type == "Pourcentage"
                worksheet.add_cell(ind, 19+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
              elsif guw_coefficient.coefficient_type == "Coefficient"
                worksheet.add_cell(ind, 19+j, (ceuw.nil? ? 100 : ceuw.percent.to_f.round(2)).to_s)
              else
                worksheet.add_cell(ind, 19+j, ceuw.nil? ? '' : ceuw.guw_coefficient_element.nil? ? ceuw.percent : ceuw.guw_coefficient_element.name)
              end
            end
          end
        elsif Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first.class == Guw::GuwOutput
          guw_output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first
          unless guow.guw_type.nil?
            unless guw_output.nil?
              v = (guow.size.nil? ? '' : (guow.size.is_a?(Numeric) ? guow.size : guow.size["#{guw_output.id}"].to_f.round(2)))
              worksheet.add_cell(ind, 19 + j, v.to_s)
            end
          end
        end
      end

      ii = 0
      @guw_model.guw_attributes.where(organization_id: organization_id).order("name ASC").each_with_index do |guw_attribute, i|
        guw_type = guow.guw_type
        guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: organization_id,
                                                  guw_model_id: @guw_model.id,
                                                  guw_attribute_id: guw_attribute.id,
                                                  guw_type_id: guw_type.nil? ? nil : guw_type.id,
                                                  project_id: project_id,
                                                  module_project_id: guow.module_project_id,
                                                  guw_unit_of_work_id: guow.id).first

        unless guowa.nil?
          gat = Guw::GuwAttributeType.where(organization_id: organization_id,
                                            guw_model_id: @guw_model.id,
                                            guw_attribute_id: guowa.guw_attribute_id,
                                            guw_type_id: guw_type.id).first
          worksheet.add_cell(ind, jj + ii, guowa.most_likely.nil? ? (gat.nil? ? "N/A" : gat.default_value.to_s) : guowa.most_likely)
          worksheet.add_cell(ind, jj + ii + 1, guowa.nil? ? '' : guowa.comments)
        else
          p "GUOWA is nil"
        end
        ii = ii + 2
      end

      ii = 0
      @guw_model.guw_attributes.where(organization_id: organization_id).each do |guw_attribute|
        worksheet.add_cell(0, jj + ii, guw_attribute.name)
        worksheet.add_cell(0, jj + ii + 1, "Commentaires")
        ii = ii + 2
      end

      kk = header.size - (@guw_model.guw_attributes.where(organization_id: organization_id).order("name ASC").map{|i| [i.name, "Commentaires"] }.flatten).size - (@wbs_activity.nil? ? 0 : @wbs_activity.wbs_activity_elements.where(organization_id: organization_id).select{|i| !i.root? }.map{|i| ["#{i.name} (Effort)", "#{i.name} (Cout)"] }.flatten.size) - 1 #-1 for TJM moyen
      @wbs_activity_ratio = @wbs_activity.nil? ? nil : @wbs_activity.wbs_activity_ratios.where(organization_id: organization_id).first
      @module_project_ratio_elements = @wbs_activity_module_project.nil? ? nil : @wbs_activity_module_project.get_module_project_ratio_elements(@wbs_activity_ratio, current_component)
      @root_module_project_ratio_element = @module_project_ratio_elements.nil? ? nil : @module_project_ratio_elements.select{|i| i.root? }.first

      tjm_array = []

      calculator = Dentaku::Calculator.new
      unless @wbs_activity.nil?
        @wbs_activity.wbs_activity_elements.where(organization_id: organization_id).select{|i| !i.root? }.each_with_index do |wbs_activity_element|

          guw_output_effort = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id,
                                                   name: ["Charge RTU (jh)", "Charge RIS (jh)", "UC Dév. Dg", "Charge RTU Avec Dégr."]).first

          guw_output_test = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id,
                                                 name: ["Assiette Test", "Assiette Test (jh)", "Charges T (jh)", "UC Test Dg"]).first

          mp_ratio_element = @module_project_ratio_elements.select { |mp_ratio_elt| mp_ratio_elt.wbs_activity_element_id == wbs_activity_element.id }.first

          guw_output_effort_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"].to_f.round(2)))

          begin
            guw_output_test_value = (guow.size.nil? ? '' : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_test.id}"].to_f.round(2)))
          rescue
            guw_output_test_value = ""
          end

          corresponding_ratio_elt = WbsActivityRatioElement.where(organization_id: organization_id, wbs_activity_id: @wbs_activity.id, wbs_activity_ratio_id: @wbs_activity_ratio.id, wbs_activity_element_id: wbs_activity_element.id).first

          unless corresponding_ratio_elt.nil?
            final_formula = corresponding_ratio_elt.formula
                                .gsub("RTU", guw_output_effort_value.to_s)
                                .gsub("TEST", guw_output_test_value.to_s)
                                .gsub('%', ' * 0.01 ')
          end

          begin
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

    send_data(workbook.stream.string, filename: "#{@current_organization.name[0..4]}-#{@project.title}-#{@project.version_number}-#{@guw_model.name}(#{("A".."Z").to_a[current_module_project.position_x.to_i]},#{current_module_project.position_y})-Export_UO-#{Time.now.strftime('%Y-%m-%d_%H-%M')}.xlsx", type: "application/vnd.ms-excel")
  end

  def export
    current_mp = current_module_project
    current_mp_project = current_mp.project
    project_id = current_mp.project_id
    @guw_model = current_mp.guw_model
    organization_id = @guw_model.organization_id
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                  guw_model_id: @guw_model.id,
                                                  project_id: project_id,
                                                  module_project_id: current_mp.id,
                                                  pbs_project_element_id: @component.id).order("display_order ASC")

     @guow_guw_coefficient_element_unit_of_works_with_coefficients = {} 
     Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                guw_model_id: @guw_model.id,
                                                project_id: project_id,
                                                module_project_id: current_mp.id).order("updated_at ASC").each do |gceuw|
       @guow_guw_coefficient_element_unit_of_works_with_coefficients["#{gceuw.guw_unit_of_work_id}_#{gceuw.guw_coefficient_id}"] = gceuw 
     end 

    hash = @guw_model.orders
    hash.delete("Critères")
    hash.delete("Coeff. de Complexité")

    @guw_unit_of_works.each do |i|
      if i.nil?
        i.destroy
      end
    end

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]

    vals = RubyXL::DataValidations.new
    worksheet.data_validations = vals

    tab_size = [I18n.t(:estimation).length, I18n.t(:version_number).length,
                I18n.t(:group).length, I18n.t(:selected).length,
                I18n.t(:name).length, I18n.t(:description).length,
                20,
                20,
                20,
                I18n.t(:organization_technology).length, I18n.t(:quantity).length,
                I18n.t(:tracability).length, I18n.t(:cotation).length,
                I18n.t(:results).length, I18n.t(:retained_result).length,
                I18n.t(:pe_attribute_name).length, I18n.t(:low).length,
                I18n.t(:likely).length, I18n.t(:high).length]

    ([
        "Nom du CDS",
        "Nom du fournisseur",
        "Nom de l'application",
        "Besoin Métier",
        "Statut du devis",
        "Services",
        "Domaine",
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
        "Coeff de complexité"] + hash.sort_by { |k, v| v.to_f }.map{|i| i.first }).each_with_index do |val, index|
      worksheet.add_cell(0, index, val)
    end

    # worksheet.change_row_bold(0,true)

    jj = 20 + @guw_model.guw_outputs.where(organization_id: organization_id).size + @guw_model.guw_coefficients.where(organization_id: organization_id).size

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

      worksheet.add_cell(ind, 0, current_mp_project.organization.nil? ? nil : current_mp_project.organization.name)
      worksheet.add_cell(ind, 1, current_mp_project.provider.nil? ? nil : current_mp_project.provider.name)
      worksheet.add_cell(ind, 2, current_mp_project.application.nil? ? nil : current_mp_project.application.name)
      worksheet.add_cell(ind, 3, current_mp_project.business_need)
      worksheet.add_cell(ind, 4, current_mp_project.estimation_status.nil? ? nil : current_mp_project.estimation_status.name)
      worksheet.add_cell(ind, 5, current_mp_project.project_area.nil? ? nil : current_mp_project.project_area.name)
      worksheet.add_cell(ind, 6, current_mp_project.acquisition_category.nil? ? nil : current_mp_project.acquisition_category.name)
      worksheet.add_cell(ind, 7, current_mp_project.platform_category.nil? ? nil : current_mp_project.platform_category.name)
      worksheet.add_cell(ind, 8, current_mp_project.title)
      worksheet.add_cell(ind, 9, current_mp_project.version_number)
      worksheet.add_cell(ind, 10, guow.guw_unit_of_work_group.nil? ? '-' : guow.guw_unit_of_work_group.name)
      worksheet.add_cell(ind, 11, guow.selected ? 1 : 0)
      worksheet.add_cell(ind, 12, guow.name)
      worksheet.add_cell(ind, 13, (guow.guw_type.nil? ? '-' : guow.guw_type.name))
      worksheet.add_cell(ind, 14, guow.comments.to_s.gsub!(/[^a-zA-ZàâäôéèëêïîçùûüÿæœÀÂÄÔÉÈËÊÏÎŸÇÙÛÜÆŒ ]/, ''))
      worksheet.add_cell(ind, 15, guow.quantity)
      worksheet.add_cell(ind, 16, guow.tracking)
      worksheet.add_cell(ind, 17, cplx)
      worksheet.add_cell(ind, 18, guow.intermediate_weight)


      hash.sort_by { |k, v| v.to_f }.each_with_index do |i, j|
        if Guw::GuwCoefficient.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first.class == Guw::GuwCoefficient
          guw_coefficient = Guw::GuwCoefficient.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first
          unless guw_coefficient.nil?
            unless guw_coefficient.guw_coefficient_elements.empty?
              ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                guw_model_id: @guw_model.id,
                                                                guw_coefficient_id: guw_coefficient.id,
                                                                project_id: project_id,
                                                                module_project_id: guow.module_project_id,
                                                                guw_unit_of_work_id: guow.id).last

              if guw_coefficient.coefficient_type == "Pourcentage" || guw_coefficient.coefficient_type == "Coefficient"

                begin
                  ceuw = @guow_guw_coefficient_element_unit_of_works_with_coefficients["#{guow.id}_#{@guw_coefficient.id}"]
                rescue
                  ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                    guw_model_id: @guw_model.id,
                                                                    guw_coefficient_id: guw_coefficient.id,
                                                                    project_id: project_id,
                                                                    module_project_id: guow.module_project_id,
                                                                    guw_unit_of_work_id: guow.id).last
                end

                results = guw_coefficient.guw_coefficient_elements.map{|i| i.guw_complexity_coefficient_elements
                                                                                .includes(:guw_coefficient_element)
                                                                                .where(organization_id: organization_id,
                                                                                       guw_model_id: @guw_model.id,
                                                                                       guw_type_id: guow.guw_type_id)
                                                                                .select{|ct| ct.value != nil }
                                                                                .map{|i| i.guw_coefficient_element }.uniq }.flatten.compact.sort! { |a, b|  a.display_order.to_i <=> b.display_order.to_i }

                unless results.empty?
                  worksheet.add_cell(ind, 19+j, (ceuw.nil? ? 1 : (ceuw.percent.nil? ? '' : ceuw.percent.to_f.round(2))).to_s)
                end

                # worksheet.add_hint(ind, 20+j, nil, 'Commentaire', ceuw.nil? ? '' : ceuw.comments)
              else
                worksheet.add_cell(ind, 19+j, ceuw.nil? ? '' : ceuw.guw_coefficient_element.nil? ? ceuw.percent : ceuw.guw_coefficient_element.name)
              end
            end
          end
        elsif Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first.class == Guw::GuwOutput
          guw_output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: @guw_model.id, name: i[0]).first
          unless guow.guw_type.nil?
            unless guw_output.nil?
              v = (guow.size.nil? ? '' : (guow.size.is_a?(Numeric) ? guow.size : guow.size["#{guw_output.id}"].to_f))
              worksheet.add_cell(ind, 19 + j, v.to_s)
            end
          end
        end
      end

      ii = 0
      @guw_model.guw_attributes.where(organization_id: organization_id).order("name ASC").each_with_index do |guw_attribute, i|
        guw_type = guow.guw_type
        guowa = Guw::GuwUnitOfWorkAttribute.where(organization_id: organization_id,
                                                  guw_model_id: @guw_model.id,
                                                  guw_attribute_id: guw_attribute.id,
                                                  guw_type_id: guw_type.nil? ? nil : guw_type.id,
                                                  project_id: project_id,
                                                  module_project_id: guow.module_project.id,
                                                  guw_unit_of_work_id: guow.id).first

        unless guowa.nil?
          gat = Guw::GuwAttributeType.where(organization_id: organization_id,
                                            guw_model_id: @guw_model.id,
                                            guw_attribute_id: guowa.guw_attribute_id,
                                            guw_type_id: guw_type.id).first
          worksheet.add_cell(ind, jj + ii, guowa.most_likely.nil? ? (gat.nil? ? "N/A" : gat.default_value.to_s) : guowa.most_likely)
          worksheet.add_cell(ind, jj + ii + 1, guowa.nil? ? '' : guowa.comments)
        else
          p "GUOWA is nil"
        end
        ii = ii + 2
      end
    end

    ii = 0
    @guw_model.guw_attributes.where(organization_id: organization_id).each do |guw_attribute|
      worksheet.add_cell(0, jj + ii, guw_attribute.name)
      worksheet.add_cell(0, jj + ii + 1, "Commentaires")
      ii = ii + 2
    end

    send_data(workbook.stream.string, filename: "#{@current_organization.name[0..4]}-#{@project.title}-#{@project.version_number}-#{@guw_model.name}(#{("A".."Z").to_a[current_module_project.position_x.to_i]},#{current_module_project.position_y})-Export_UO-#{Time.now.strftime('%Y-%m-%d_%H-%M')}.xlsx", type: "application/vnd.ms-excel")
  end

  def my_verrif_tab_error(tab_error, indexing_field_error)

    final_mess = []

    tab_error.each_with_index do |error_type, index|
      if error_type[0] == true
        case
          when index == 0
            final_mess << I18n.t(:route_flag_error_8, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 1
            final_mess << I18n.t(:route_flag_error_9, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 2
            final_mess << I18n.t(:route_flag_error_10,mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 3
            final_mess << I18n.t(:route_flag_error_11,mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 4
            final_mess << I18n.t(:route_flag_error_12,mess_error: error_type[1..error_type.size - 1].join(", "))
          else
            nothing = 42
        end
      end
    end
    indexing_field_error.each_with_index do |error_type, index|
      if error_type.size > 1
        case
          when index == 0
            final_mess << I18n.t(:route_flag_error_13, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 1
            final_mess << I18n.t(:route_flag_error_14, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 2
            final_mess << I18n.t(:route_flag_error_15, mess_error: error_type[1..error_type.size - 1].join(", "))
          when index == 3
            final_mess << I18n.t(:route_flag_error_16, mess_error: error_type[1..error_type.size - 1].join(", "))
          else
            nothing = 42
        end
      end
    end

    unless final_mess.empty?
      flash[:error] = final_mess.join("<br/>").html_safe
    end
  end

  def all_guw_types
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_types = @guw_model.guw_types
    @organization = @guw_model.organization
    set_page_title "Liste des unités d'oeuvres"
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:uo_model) => main_app.edit_organization_path(@organization), @organization => ""
  end

  def save_scale_module_attributes
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    Guw::GuwScaleModuleAttribute.destroy_all(guw_model_id: @guw_model)

    unless params['attributes_matrix'].nil?
      params['attributes_matrix'].each_with_index do |i, j|
        i[1].each do |k|
          Guw::GuwScaleModuleAttribute.create(guw_model_id: @guw_model.id,
                                              guw_output_id: k[0],
                                              guw_coefficient_id: i[0])
        end
      end
    end

    redirect_to :back
  end

  # Affiche le modele de données
  def show_data_model
    @module_project = ModuleProject.find(params[:module_project_id])
    @guw_model = @module_project.guw_model #current_module_project.guw_model
    component_id = params[:component_id] #current_component
    module_project_id = params[:module_project_id]

    @unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(organization_id: @guw_model.organization_id,
                                                         guw_model_id: @guw_model.id,
                                                         project_id: @module_project.project_id,
                                                         module_project_id: module_project_id,
                                                         pbs_project_element_id: component_id).all

    # Create and Get data from Guw_unit_work
    @word_trees_data_model = [['Phrases']]
    @unit_of_work_groups.each_with_index do |uowg, j|
      #uowg.guw_unit_of_works.includes(:guw_type, :guw_complexity).where("guw_guw_types.name IN (?)", ["ILF", "GDI"]).order("display_order ASC, name ASC").each_with_index do |guow, i|
      #uowg.guw_unit_of_works.includes(:guw_type, :guw_complexity).where(guw_guw_types: { name: ["ILF", "GDI"]}).order("display_order ASC, name ASC").each_with_index do |guow, i|
      uowg.guw_unit_of_works.where(organization_id: @guw_model.organization_id, guw_model_id: @guw_model.id).includes(:guw_type).where(guw_guw_types: { name: ["ILF", "GDI", "EIF", "GDE"]}).each_with_index do |guow, i|
        comments = guow.comments.split(",")
        unless comments.empty?
          comments.each do |comment|
            comment = comment.lstrip

            if comment.blank?
              final_comment = ""
            else
              #comment_without_special_char = comment.gsub(/[^0-9a-zA-Z. û ]/,'')
              #final_comment = comment_without_special_char.blank? ? "" : comment_without_special_char.gsub(' ', '_')
              #final_comment = ActiveSupport::Inflector.transliterate(comment.downcase.gsub(/[^0-9a-zA-Z. û ]/,'').gsub(/\s/,"_"))
              final_comment = ActiveSupport::Inflector.transliterate(comment.downcase.gsub(/\s/,"_"))
            end

            #guow_name = guow.name.blank? ? "" : guow.name.gsub(' ', '_')
            guow_name = guow.name.blank? ? "" : ActiveSupport::Inflector.transliterate( guow.name.downcase.gsub(/\s/,"_") )
            if final_comment.blank?
              @word_trees_data_model << ["Data #{guow.guw_type.name.upcase} #{guow_name}"]
            else
              @word_trees_data_model << ["Data #{guow.guw_type.name.upcase} #{guow_name} #{final_comment}"]
            end
          end

        end
      end
    end

    @word_trees_data_model
  end
end