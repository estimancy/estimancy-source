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

  def importxl

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
    if !params[:file].nil?# && (File.extname(params[:file].original_filename) == ".xls" || File.extname(params[:file].original_filename) == ".xlsx")
      @workbook = RubyXL::Parser.parse(params[:file].path)
      @workbook.each_with_index do |worksheet, index|
       tab = worksheet.extract_data
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
            @guw_model = Guw::GuwModel.where(name: tab[0][1], organization_id: @current_organization.id).first
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
               Guw::GuwAttribute.create(name: row[0],
                                        description: row[1],
                                        guw_model_id: @guw_model.id)
              end
            end
          elsif index == 2
            # if critical_flag || worksheet.sheet_name != @guw_model.coefficient_label
            #   route_flag = 5
            #   break
            # end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                 Guw::GuwWorkUnit.create(name:row[0],
                                         value: row[1],
                                         display_order: row[2],
                                         guw_model_id: @guw_model.id)
              end
            end
          elsif index == 3
            # if critical_flag || worksheet.sheet_name != @guw_model.weightings_label
            #   route_flag = 5
            #   break
            # end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                Guw::GuwWeighting.create(name:row[0],
                                        value: row[1],
                                        display_order: row[2],
                                        guw_model_id: @guw_model.id)
              end
            end
          elsif index == 4
            # if critical_flag || worksheet.sheet_name != @guw_model.factors_label
            #   route_flag = 5
            #   break
            # end
            tab.each_with_index do |row, index|
              if index != 0 && !row.nil?
                Guw::GuwFactor.create(name:row[0],
                                      value: row[1],
                                      display_order: row[2],
                                      guw_model_id: @guw_model.id)
              end
            end
          else
            # if critical_flag
            #   route_flag = 5
            #   break
            # end
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
                      # elsif tab[ind2].nil?
                      #   route_flag = 3
                      #   break
                      # end
                      ind2 = 10
                      action_type_aquisition_flag = true
                    end

                    # if tab[ind2].nil? || route_flag == 3
                    #   route_flag = 3
                    #   break
                    # end
                    while !tab[ind2].nil? && tab[ind2][0] != I18n.t(:organization_technology)
                      ind2 += 1
                    end
                    ind3 = ind2
                    if !tab[ind2].nil? && tab[ind2][0] == I18n.t(:organization_technology)
                      @current_organization.organization_technologies.each do |techno|
                       while !tab[ind2].nil? && tab[ind2][0].to_s.downcase != techno.name.to_s.downcase
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
                   @guw_att_complexity =  Guw::GuwTypeComplexity.create(guw_type_id: @guw_type.id, name: tab[save_position][ind], value: 4)
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

  def exportxl

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
      worksheet.add_cell(index, 0, row[0])
      worksheet.add_cell(index, 1, row[1]).change_horizontal_alignment('center')
      ["bottom", "right"].each do |symbole|
        worksheet[index][0].change_border(symbole.to_sym, 'thin')
        worksheet[index][1].change_border(symbole.to_sym, 'thin')
      end
    end
    worksheet.change_column_bold(0,true)
    worksheet.change_row_height(1, @guw_model.description.count("\n") * 13 + 1)
    worksheet.change_column_width(0, 38)
    worksheet.change_column_width(1, the_most_largest(@guw_model.description))
    worksheet.merge_cells(6, 0, 6, 1)
    worksheet.change_row_height(6, 25)

    worksheet = workbook[1]

    counter_line = 1
    worksheet.add_cell(0, 0, I18n.t(:pe_attribute_name))
    worksheet.add_cell(0, 1, I18n.t(:description))
    worksheet.change_row_bold(0,true)

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
    worksheet.change_row_bold(0,true)
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
    worksheet.change_row_bold(0,true)
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
    worksheet.change_row_bold(0,true)
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
      worksheet.change_row_bold(ind2 + 3,true)

      j = ind2 + 3
      # worksheet.add_cell(j, 0, @guw_model.coefficient_label)
      # worksheet.change_row_bold(j, true)

      k = j + @guw_model.guw_work_units.size.to_i
      # worksheet.add_cell(k, 0, @guw_model.factors_label)
      # worksheet.change_row_bold(k, true)

      l = k + @guw_model.guw_factors.size.to_i
      # worksheet.add_cell(l, 0, @guw_model.weightings_label)
      # worksheet.change_row_bold(l, true)


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

        #### ComplexityWorkUnit
        guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
          @guw_work_unit = guw_complexity_work_unit.guw_work_unit
          unless @guw_work_unit.nil?
            cu = Guw::GuwComplexityWorkUnit.where(guw_complexity_id: guw_complexity.id, guw_work_unit_id: @guw_work_unit.id).first
            worksheet.add_cell(ind2 + 4, 0, @guw_work_unit.name)
            ["","","",cu.value].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 4, ind + index + 1, val).change_horizontal_alignment('center')
            end
            # 4.times.each do |index|
            #   worksheet[10][ind + index + 1].change_border(:top, 'thin')
            # end
            # worksheet[ind2 + 4][ind + 4].change_border(:right, 'thin')
            ind2 += 1
          end
        end

        #### ComplexityWeighting
        guw_complexity.guw_complexity_weightings.each do |guw_complexity_weighting|
          @guw_weighting = guw_complexity_weighting.guw_weighting
          unless @guw_weighting.nil?
            cu = Guw::GuwComplexityWeighting.where(guw_complexity_id: guw_complexity.id, guw_weighting_id: @guw_weighting.id).first
            worksheet.add_cell(ind2 + 5, 0, @guw_weighting.name)
            ["","","",cu.value].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 5, ind + index + 1, val).change_horizontal_alignment('center')
            end
            # 4.times.each do |index|
            #   worksheet[10][ind + index + 1].change_border(:top, 'thin')
            # end
            # worksheet[ind2 + 6][ind + 6].change_border(:right, 'thin')
            ind2 += 1
          end
        end

        #### ComplexityFactor
        guw_complexity.guw_complexity_factors.each do |guw_complexity_factor|
          @guw_factor = guw_complexity_factor.guw_factor
          unless @guw_factor.nil?
            cu = Guw::GuwComplexityFactor.where(guw_complexity_id: guw_complexity.id, guw_factor_id: @guw_factor.id).first
            worksheet.add_cell(ind2 + 6, 0, @guw_factor.name)
            ["","","",cu.value].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 6, ind + index + 1, val).change_horizontal_alignment('center')
            end
            # 4.times.each do |index|
            #   worksheet[10][ind + index + 1].change_border(:top, 'thin')
            # end
            # worksheet[ind2 + 5][ind + 5].change_border(:right, 'thin')
            ind2 += 1
          end
        end

        #### Complexity Technology
        worksheet.change_row_bold(ind2 + 7, true)
        worksheet.add_cell(ind2 + 7, 0, I18n.t(:organization_technology))
        guw_complexity.guw_complexity_technologies.each do |complexity_technology|
          @guw_organisation_technology = complexity_technology.organization_technology
          unless @guw_organisation_technology.nil?
            ct = Guw::GuwComplexityTechnology.where(guw_complexity_id: guw_complexity.id, organization_technology_id: @guw_organisation_technology.id).first
            worksheet.add_cell(ind2 + 7, 0, @guw_organisation_technology.name)
            worksheet[ind2 + 7][0].change_border(:right, 'thin')
            ["", "", "", ct.coefficient].each_with_index do |val, index|
              worksheet.add_cell(ind2 + 7, ind + index + 1, val).change_horizontal_alignment('center')
            end
            # 4.times.each do |index|
            #   worksheet[10][ind + index + 1].change_border(:top, 'thin')
            # end
            # worksheet[ind2 + 7][ind + 7].change_border(:right, 'thin')
            ind2 += 1
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

        worksheet[ind4 - 1][0].change_border(:bottom, 'thin')
        4.times.each {|index| worksheet[ind4 - 1][ind + index + 1].change_border(:bottom, 'thin')}

        ind += 4
      end
      ind = 0
      ind3 = 5
    end
    send_data(workbook.stream.string, filename: "#{@guw_model.name[0.4]}_ModuleUOMXT-#{@guw_model.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.est", type: "application/vnd.ms-excel")
  end

  def show
    authorize! :show_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization

    set_page_title @guw_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(@organization, anchor: "taille"), @guw_model.name => ""
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

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "taille"), I18n.t(:new) => ""
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

    set_page_title I18n.t(:edit_project_element_name, parameter: @guw_model.name)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:uo_modules) => main_app.organization_module_estimation_path(@organization, anchor: "taille"), @guw_model.name => ""
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:guw_model][:organization_id])
    @guw_model = Guw::GuwModel.new(params[:guw_model])
    @guw_model.organization_id = params[:guw_model][:organization_id].to_i

    if @guw_model.save
      redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id), nil, guw.guw_model_path(@guw_model))
    else
      render action: :new
    end
  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @guw_model = Guw::GuwModel.find(params[:id])
    @organization = @guw_model.organization

    if @guw_model.update_attributes(params[:guw_model])
      if @guw_model.default_display == "list"
        redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id),
                                   nil,
                                   guw.guw_model_all_guw_types_path(@guw_model, organization_id: @organization.id)) and return
      else
        redirect_to redirect_apply(guw.edit_guw_model_path(@guw_model, organization_id: @organization.id),
                                   nil,
                                   guw.guw_model_path(@guw_model)) and return
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
        new_guw_model.terminate_guw_model_duplication
      end
    end

    redirect_to main_app.organization_module_estimation_path(@guw_model.organization_id, anchor: "taille")
  end

  def export
    @guw_model = current_module_project.guw_model
    @component = current_component
    @guw_unit_of_works = Guw::GuwUnitOfWork.where(module_project_id: current_module_project.id,
                                                  pbs_project_element_id: @component.id,
                                                  guw_model_id: @guw_model.id)
    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    tab_size = [I18n.t(:estimation).length, I18n.t(:version).length,
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

    [I18n.t(:estimation),
     I18n.t(:version),
     I18n.t(:group),
     I18n.t(:selected),
     I18n.t(:name),
     I18n.t(:description),
     "Type",
     @guw_model.coefficient_label.blank? ? 'Facteur sans nom 1' : @guw_model.coefficient_label.to_s,
     @guw_model.weightings_label.blank? ? 'Facteur sans nom 2' : @guw_model.weightings_label,
     @guw_model.factors_label.blank? ? 'Facteur sans nom 3' : @guw_model.factors_label,
     I18n.t(:organization_technology),
     I18n.t(:quantity),
     I18n.t(:tracability),
     I18n.t(:cotation),
     I18n.t(:results),
     I18n.t(:retained_result)].each_with_index do |val, index|
      worksheet.add_cell(0, index, val)
    end

    worksheet.change_row_bold(0,true)
    @guw_unit_of_works.each_with_index do |guow, i|

      ind = i + 1

      if guow.off_line
        cplx = "HSAT"
      elsif guow.off_line_uo
        cplx = "HSUO"
      elsif guow.guw_complexity.nil?
        cplx = "-"
      else
        cplx = guow.guw_complexity.name
      end

      worksheet.add_cell(ind, 0, current_module_project.project.title)
      tab_size[0]= tab_size[0] < current_module_project.project.title.length ? current_module_project.project.title.length : tab_size[0]
      worksheet.change_column_width(0, tab_size[0])

      worksheet.add_cell(ind, 1, current_module_project.project.version)

      worksheet.add_cell(ind, 2, guow.guw_unit_of_work_group.name)
      tab_size[2] = tab_size[2] < guow.guw_unit_of_work_group.name.length ? guow.guw_unit_of_work_group.name.length : tab_size[2]
      worksheet.change_column_width(2, tab_size[2])

      worksheet.add_cell(ind, 3, guow.selected ? 1 : 0)

      worksheet.add_cell(ind, 4, guow.name)
      tab_size[4] = tab_size[4] < guow.name.length ? guow.name.length : tab_size[4]
      worksheet.change_column_width(4, tab_size[4])

      worksheet.add_cell(ind, 6, guow.guw_type.name)
      tab_size[6] = tab_size[6] < guow.guw_type.name.to_s.length ? guow.guw_type.name.to_s.length : tab_size[6]
      worksheet.change_column_width(6, tab_size[6])

      worksheet.add_cell(ind, 5, guow.comments)

      worksheet.add_cell(ind, 7, guow.guw_work_unit)

      worksheet.add_cell(ind, 8, guow.guw_weighting)

      worksheet.add_cell(ind, 9, guow.guw_factor)

      worksheet.add_cell(ind, 10, guow.organization_technology)
      tab_size[10] = tab_size[10] < guow.organization_technology.to_s.length ? guow.organization_technology.to_s.length : tab_size[10]
      worksheet.change_column_width(8, tab_size[10])

      worksheet.add_cell(ind, 11, guow.quantity)

      worksheet.add_cell(ind, 12, guow.tracking)

      worksheet.add_cell(ind, 13, cplx)
      tab_size[13] = tab_size[13] < cplx.length ? cplx.length : tab_size[13]

      worksheet.add_cell(ind, 14, guow.size)

      worksheet.add_cell(ind, 15, guow.ajusted_size)

      @guw_model.guw_attributes.each_with_index do |guw_attribute, i|
        guowa = Guw::GuwUnitOfWorkAttribute.where(guw_unit_of_work_id: guow.id, guw_attribute_id: guw_attribute.id, guw_type_id: guow.guw_type.id).first
        unless guowa.nil?
          worksheet.add_cell(ind, 16 + i, guowa.most_likely.nil? ? "N/A" : guowa.most_likely)
        end
      end

    end

    @guw_model.guw_attributes.each_with_index do |guw_attribute, i|
      worksheet.add_cell(0, 16 + i, guw_attribute.name)
    end

    send_data(workbook.stream.string, filename: "#{@current_organization.name[0..4]}-#{@project.title}-#{@project.version}-#{@guw_model.name}(#{("A".."Z").to_a[current_module_project.position_x.to_i]},#{current_module_project.position_y})-Export_UO-#{Time.now.strftime('%Y-%m-%d_%H-%M')}.est", type: "application/vnd.ms-excel")
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

  def import_myexport

    @guw_model = current_module_project.guw_model
    @component = current_component

    ind = 0
    ok = false
    already_exist = ["first"]
    first = false
    type_save = nil
    guw_uow_save = nil
    gac_save = nil
    tab_error = [[false], [false], [false], [false], [false]]
    indexing_field_error = [[false],[false],[false],[false]]

    if !params[:file].nil?# && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      worksheet =workbook[0]
      tab = worksheet.extract_data

      tab.each_with_index  do |row, index|
        if index > 0
          if row[4] && row[2] && row[6]  && !row[4].empty? &&  !row[2].empty? && !row[6].empty?
            guw_uow_group = Guw::GuwUnitOfWorkGroup.where(name: row[2],
                                                          module_project_id: current_module_project.id,
                                                          pbs_project_element_id: @component.id,).first_or_create
            my_order = Guw::GuwUnitOfWork.count('id' , :conditions => "module_project_id = #{current_module_project.id} AND pbs_project_element_id = #{@component.id} AND guw_unit_of_work_group_id = #{guw_uow_group.id}  AND guw_model_id = #{@guw_model.id}")
            if already_exist.join(",").include?(row[0..16].join(","))
              @guw_model.guw_attributes.all.each do |gac|
                if gac.name == row[16]
                  finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: type_save,
                                                             guw_unit_of_work_id: guw_uow_save,
                                                             guw_attribute_id: gac.id).first_or_create
                  finder.low = row[17] == "N/A" ? nil : row[17]
                  finder.most_likely = row[18] == "N/A" ? nil : row[18]
                  finder.high = row[19] == "N/A" ? nil : row[19]
                  finder.save
                  break
                end
              end
            else
              guw_uow = Guw::GuwUnitOfWork.create(selected: row[3].to_i == 1,
                                                   name: row[4],
                                                   comments: row[5],
                                                   guw_unit_of_work_group_id: guw_uow_group.id,
                                                   module_project_id: current_module_project.id,
                                                   pbs_project_element_id: @component.id,
                                                   guw_model_id: @guw_model.id,
                                                   display_order: my_order,
                                                   tracking: row[12],
                                                   quantity: row[11].nil? ? 1 : row[11],
                                                   size: row[14].nil? ? nil : row[14],
                                                   ajusted_size: row[15].nil? ? nil : row[15])
                if !row[7].nil?
                  @guw_model.guw_work_units.each do |wu|
                    if wu.name == row[7]
                      guw_uow.guw_work_unit_id = wu.id
                      ind += 1
                      indexing_field_error[1][0] = true
                      break
                    end
                    indexing_field_error[1][0] = false
                  end
                else
                  first_work_unit = @guw_model.guw_work_units.order("display_order ASC").first
                  unless first_work_unit.nil?
                    guw_uow.guw_work_unit_id = @guw_model.guw_work_units.order("display_order ASC").first.id
                  else
                    guw_uow.guw_work_unit_id = nil
                  end
                  # ind += 1
                  # indexing_field_error[1][0] = true
                end
                # unless indexing_field_error[1][0]
                #   indexing_field_error[1] << index
                # end

                if !row[8].nil?
                  @guw_model.guw_weightings.each do |wu|
                    if wu.name == row[8]
                      guw_uow.guw_weighting_id = wu.id
                      ind += 1
                      break
                    end
                  end
                else
                  first_weighting = @guw_model.guw_weightings.order("display_order ASC").first
                  unless first_weighting.nil?
                    guw_uow.guw_weighting_id = @guw_model.guw_weightings.order("display_order ASC").first.id
                  else
                    guw_uow.guw_weighting_id = nil
                  end
                  ind += 1
                end

                if !row[9].nil?
                  @guw_model.guw_factors.each do |wu|
                    if wu.name == row[9]
                      guw_uow.guw_factor_id = wu.id
                      ind += 1
                      break
                    end
                  end
                else
                  first_factor = @guw_model.guw_factors.order("display_order ASC").first
                  unless first_factor.nil?
                    guw_uow.guw_factor_id = @guw_model.guw_factors.order("display_order ASC").first.id
                  else
                    guw_uow.guw_factor_id = nil
                  end
                  ind += 1
                end

                @guw_model.guw_types.each do |type|
                  if row[6] == type.name
                    guw_uow.guw_type_id = type.id
                    indexing_field_error[0][0] = true
                    if !row[13].nil? && row[13] != "-"
                      type.guw_complexities.each do |complexity|
                        if row[13] == complexity.name
                          guw_uow.guw_complexity_id = complexity.id
                          indexing_field_error[3][0] = true
                          break
                        end
                        indexing_field_error[3][0] = false
                      end
                      unless indexing_field_error[3][0]
                        indexing_field_error[3] << index
                      end
                    end
                    if @guw_model.allow_technology == true
                      if !row[10].nil?
                        type.guw_complexity_technologies.each do |techno|
                          unless techno.organization_technology.nil?
                            if row[10] == techno.organization_technology.name
                              guw_uow.organization_technology_id = techno.organization_technology.id
                              ind += 1
                              indexing_field_error[2][0] = true
                              break
                            end
                          end
                          indexing_field_error[2][0] = false
                        end
                      else
                        guw_ct = type.guw_complexity_technologies.select{ |i| i.coefficient != nil }.first
                        unless guw_ct.nil?
                          guw_uow.organization_technology_id = guw_ct.organization_technology.id
                        else
                          guw_uow.organization_technology_id = nil
                        end

                        ind += 1
                        indexing_field_error[2][0] = true
                      end

                      unless indexing_field_error[2][0]
                        indexing_field_error[2] << index
                      end
                    end

                    @guw_model.guw_attributes.all.each do |gac|
                      guw_uow.save
                      finder = Guw::GuwUnitOfWorkAttribute.where(guw_type_id: type.id,
                                                                 guw_unit_of_work_id: guw_uow.id,
                                                                 guw_attribute_id: gac.id).first_or_create
                      # guw_uow_save = guw_uow.id
                      # finder.low = row[15] == "N/A" ? nil : row[15]
                      # finder.most_likely = row[16] == "N/A" ? nil : row[16]
                      # finder.high = row[17] == "N/A" ? nil : row[17]
                      finder.save
                    end

                    ind += 1
                    break
                  end
                  indexing_field_error[0][0] = false
                end
                unless indexing_field_error[0][0]
                  indexing_field_error[0] << index
                end
                guw_uow.save
                if ind == 3
                  guw_uow.save
                else
                  tab_error << index
                end
                ind = 0
                already_exist = row
            end
          else
            if row[4].nil? || row[4].empty?
              tab_error[0][0] = true
              tab_error[0] << index
            end
            if row[2].nil? || row[2].empty?
              tab_error[1][0] = true
              tab_error[1] << index
            end
            if row[6].nil? || row[6].empty?
              tab_error[2][0] = true
              tab_error[2] << index
            end
            if row[7].nil? || row[7].empty?
              tab_error[3][0] = true
              tab_error[3] << index
            end
            if row[8].nil? || row[8].empty?
              tab_error[4][0] = true
              tab_error[4] << index
            end
          end
        end
        ok = true
      end
    end

    my_verrif_tab_error(tab_error, indexing_field_error)
    if ok
      flash[:notice] = I18n.t(:importation_sucess_uo)
    else ok
      flash[:error] = I18n.t(:route_flag_error_4)
    end

    redirect_to :back
  end

  def all_guw_types
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_types = @guw_model.guw_types
    @organization = @current_organization
    set_page_title "Liste des unités d'oeuvres"
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:uo_model) => main_app.edit_organization_path(@guw_model.organization), @guw_model.organization => ""
  end

  def save_scale_module_attributes
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])

    Guw::GuwScaleModuleAttribute.destroy_all(guw_model_id: @guw_model)

    unless params['attributes_matrix'].nil?
      params['attributes_matrix'].each_with_index do |i, j|
        i[1].each do |k|
          Guw::GuwScaleModuleAttribute.create(guw_model_id: @guw_model.id,
                                             type_attribute: k[0],
                                             type_scale: i[0])
        end
      end
    end

    redirect_to :back
  end

end
