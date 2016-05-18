# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero Kbneral Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero Kbneral Public License for more details.
#
#    You should have received a copy of the GNU Affero Kbneral Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Kb::KbModelsController < ApplicationController

  require 'roo'
  require 'rubyXL'

  def data_export
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:kb_model_id])
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    kb_model_datas = @kb_model.kb_datas
    default_attributs = [I18n.t(:size), I18n.t(:effort_import), "Date", I18n.t(:project_area)]

    if !kb_model_datas.nil? && !kb_model_datas.empty?
      kb_model_datas.each_with_index do |kb_data, index|
        worksheet.add_cell(index + 1, 0, kb_data.size).change_horizontal_alignment('center')
        worksheet.add_cell(index + 1, 1, kb_data.effort).change_horizontal_alignment('center')
        worksheet.add_cell(index + 1, 2, kb_data.project_date).change_horizontal_alignment('center')
        kb_data.custom_attributes.each_with_index  do |(custom_attr_k, custom_attr_v),index_2|
          worksheet.add_cell(index + 1, index_2 + 3, custom_attr_v).change_horizontal_alignment('center')
          if index_2 + 3 > 2
            default_attributs.include?(custom_attr_k.to_s) ? default_attributs : default_attributs  << custom_attr_k.to_s
          end
        end
      end
    else
      default_attributs << [ "#{I18n.t(:custom_attribute)}_1", "#{I18n.t(:custom_attribute)}_2", "ect..."]
    end

    default_attributs.flatten.each_with_index do |w_header, index|
      worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
    end

    send_data(workbook.stream.string, filename: "#{@kb_model.organization.name[0..4]}-#{@kb_model.name.gsub(" ", "_")}_kb_data-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def show
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:kb_modules) => main_app.organization_module_estimation_path(@kb_model.organization, anchor: "effort"), @kb_model.organization => ""
  end

  def duplicate
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:kb_model_id])
    new_kb_model = @kb_model.amoeba_dup

    if @kb_model.copy_number.nil?
      @kb_model.copy_number = 0
    end

    new_copy_number =  @kb_model.copy_number.to_i + 1
    new_kb_model.name = "#{@kb_model.name}(#{new_copy_number})"
    new_kb_model.copy_number = 0
    @kb_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_kb_model.transaction do
      if new_kb_model.save
        @kb_model.save
        flash[:notice] = "Base copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie de la base"
      end
    end

    redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @kb_model = Kb::KbModel.new
    set_page_title I18n.t(:New_knowledge_base)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:kb_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    @organization = @kb_model.organization

    @current_organization
    set_page_title I18n.t(:Edit_knowledge_base)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:kb_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @kb_model.name => ""
  end

  def import
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:kb_model_id])

    unless params[:file].nil?
      begin
        begin
        file = Roo::Spreadsheet.open(params[:file].path, :extension => :xls)
        rescue
          file = Roo::Spreadsheet.open(params[:file].path, :extension => :xlsx)
        end
      rescue
        flash[:error] = "Une erreur est survenue durant l'import du modèle. Veuillez vérifier l'extension du fichier Excel."
        redirect_to kb.edit_kb_model_path(@kb_model) and return
      end

      Kb::KbData.delete_all("kb_model_id = #{@kb_model.id}")

      ((file.first_row + 1)..file.last_row).each do |line|
        size   = file.cell(line, 'A')
        effort   = file.cell(line, 'B')
        pd   = file.cell(line, 'C')

        h = Hash.new
        ('D'..'ZZ').each_with_index do |letter, i|
          if i < file.last_column
            begin
              h[file.cell(1, letter.to_s).to_sym] = file.cell(line, letter.to_s)
            rescue
            end
          end
        end

        Kb::KbData.create(size: size,
                          effort: effort,
                          project_date: pd,
                          unit: "UF",
                          custom_attributes: h,
                          kb_model_id: @kb_model.id)
      end
    end

    redirect_to kb.edit_kb_model_path(@kb_model)
  end

  def save_filters
    @kb_model = Kb::KbModel.find(params[:kb_model_id])
    @kb_model.filter_a = params["filter_a"]
    @kb_model.filter_b = params["filter_b"]
    @kb_model.filter_c = params["filter_c"]
    @kb_model.filter_d = params["filter_d"]
    @kb_model.save(validate: false)
    redirect_to kb.edit_kb_model_path(@kb_model)
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:kb_model][:organization_id])

    @kb_model = Kb::KbModel.new(params[:kb_model])
    @kb_model.organization_id = params[:kb_model][:organization_id].to_i
    if @kb_model.save
      redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])

    if params[:selected_attributes].nil?
      @kb_model.selected_attributes = []
      @kb_model.save
    else
      arr = []
      params[:selected_attributes].keys.each do |i|
        arr << i
      end
      @kb_model.selected_attributes = arr
      @kb_model.save
    end

    if @kb_model.update_attributes(params[:kb_model])
      redirect_to kb.edit_kb_model_path(@kb_model)
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @kb_model = Kb::KbModel.find(params[:id])
    organization_id = @kb_model.organization_id

    @kb_model.module_projects.each do |mp|
      mp.destroy
    end

    @kb_model.delete
    redirect_to main_app.organization_module_estimation_path(@kb_model.organization_id, anchor: "effort")
  end

  def save_efforts
    authorize! :execute_estimation_plan, @project

    @kb_model = Kb::KbModel.find(params[:kb_model_id])
    @kb_input = @kb_model.kb_inputs.where(module_project_id: current_module_project.id).first_or_create

    if @kb_model.date_min.nil? || @kb_model.date_max.nil?
      @kb_datas = @kb_model.kb_datas
    else
      if @kb_model.n_max.nil?
        @kb_datas = @kb_model.kb_datas.where("project_date >= ? AND project_date <= ?", @kb_model.date_min.to_s, @kb_model.date_max.to_s)
      else
        @kb_datas = @kb_model.kb_datas.where("project_date >= ? AND project_date <= ?", @kb_model.date_min.to_s, @kb_model.date_max.to_s).take(@kb_model.n_max.to_i)
      end
    end

    @project_list = Array.new
    e_array = Array.new
    e_array2 = Array.new
    s_array = Array.new
    s_array2 = Array.new
    es_array = Array.new

    @filters = params["filters"]

    @kb_input.filters = params["filters"]

    @kb_datas.each do |i|
      params["filters"].each do |f|
        if (params["filters"].values.reject { |c| c.empty? }.include?(i.custom_attributes[f.first.to_sym]))
          @project_list << i
        end
      end
    end

    if @project_list.blank?
      @project_list = @kb_datas
    end

    @project_list.each do |kb_data|
      unless kb_data.size.to_f == 0 || kb_data.size.to_f == 0
        s = Math.log10(kb_data.size.to_f)
        s2 = s * s

        e = Math.log10(kb_data.effort.to_f)
        e2 = e * e

        se = s * e

        s_array << s
        s_array2 << s2

        e_array << e
        e_array2 << e2

        es_array << se
      end
    end

    unless @project_list.empty?
      ms = s_array.sum / s_array.size
      ms2 = s_array2.sum / s_array2.size

      me = e_array.sum / e_array.size
      me2 = e_array2.sum / e_array2.size

      mes = es_array.sum / es_array.size

      pente = ((mes - ms * me) / (ms2 - ms * ms)).round(2)
      coef = (me - pente * ms).round(2)
      coef_10 = (10**coef).round(2)

      @values = Array.new
      @regression = Array.new
    end

    @project_list.map do |kb_data|
      @values << [kb_data.size.round(2), kb_data.effort.round(2)]
    end

    @project_list.map(&:size).each do |i|
      @regression << [i, (coef_10 * i ** pente).round(2)]
    end

    @formula = "#{coef_10.to_f} X ^ #{pente.to_f}"
    @kb_input.values = @values
    @kb_input.regression = @regression
    @kb_input.formula = @formula

    @kb_model.save
    @kb_input.save

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(module_project_id: current_module_project.id,
                                 pe_attribute_id: am.pe_attribute.id,
                                 in_out: "output").first

      ["low", "most_likely", "high"].each do |level|

        if @kb_model.three_points_estimation?
          size = params[:"retained_size_#{level}"].to_f
        else
          size = params[:"retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          effort = (coef_10.to_f * params[:size].to_f ** pente.to_f) * @kb_model.standard_unit_coefficient.to_i
          ev.send("string_data_#{level}")[current_component.id] = effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "retained_size"
          ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
          ev.send("string_data_#{level}")[current_component.id] = params[:size].to_f
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @kb_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      unless ev.nil?
        ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
      end
    end

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    current_module_project.views_widgets.each do |vw|
      ViewsWidget::update_field(vw, @current_organization, current_module_project.project, current_component)
    end

    size_attr = PeAttribute.find_by_alias("retained_size")
    size_previous_ev = EstimationValue.where(:pe_attribute_id => size_attr.id,
                                             :module_project_id => current_module_project.previous.first.id,
                                             :in_out => "output").first
    size_current_ev = EstimationValue.where(:pe_attribute_id => size_attr.id,
                                            :module_project_id => current_module_project.id,
                                            :in_out => "input").first
    effort_attr = PeAttribute.find_by_alias("effort")
    effort_current_ev = EstimationValue.where(:pe_attribute_id => effort_attr.id,
                                              :module_project_id => current_module_project.id,
                                              :in_out => "output").first

    @size = Kb::KbModel::display_size(size_previous_ev, size_current_ev, "most_likely", current_component.id)
    eff = effort_current_ev.send("string_data_probable")[current_component.id].to_f
    @effort = eff.to_f / @kb_model.standard_unit_coefficient.to_i

    redirect_to main_app.dashboard_path(@project, anchor: "effort")

  end

  def dot_export
    my_kb_model = Kb::KbModel.find(params[:kb_model_id]) #id
    kb_input = Kb::KbInput.where(kb_model_id: my_kb_model.id, module_project_id: current_module_project.id).first
    effort_attr = PeAttribute.find_by_alias("effort")
    effort_current_ev = EstimationValue.where(:pe_attribute_id => effort_attr.id, :module_project_id => current_module_project.id, :in_out => "output").first
    size_attr = PeAttribute.find_by_alias("retained_size")
    size_previous_ev = EstimationValue.where(:pe_attribute_id => size_attr.id, :module_project_id => current_module_project.previous.first.id, :in_out => "output").first
    size_current_ev = EstimationValue.where(:pe_attribute_id => size_attr.id, :module_project_id => current_module_project.id, :in_out => "input").first
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    my_helper = 0

    my_field = my_kb_model.selected_attributes
    worksheet.add_cell(0, 0, I18n.t(:project_number))
    worksheet.add_cell(0, 1, kb_input.values.size)
    worksheet.sheet_data[0][0].change_font_bold(true)
    worksheet.sheet_data[0][0].change_border(:left, 'thin')
    worksheet.sheet_data[0][0].change_border(:bottom, 'thin')
    worksheet.sheet_data[0][1].change_border(:left, 'thin')
    worksheet.sheet_data[0][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[0][1].change_border(:right, 'thin')

    my_field.each_with_index  do |field_name, index|
      worksheet.add_cell(index + 1, 0, field_name)
      worksheet.add_cell(index + 1, 1, kb_input.filters[field_name])
      worksheet.sheet_data[index + 1][0].change_font_bold(true)
      worksheet.sheet_data[my_helper + 1][0].change_border(:left, 'thin')
      worksheet.sheet_data[my_helper + 1][0].change_border(:bottom, 'thin')
      worksheet.sheet_data[my_helper + 1][1].change_border(:left, 'thin')
      worksheet.sheet_data[my_helper + 1][1].change_border(:bottom, 'thin')
      worksheet.sheet_data[my_helper + 1][1].change_border(:right, 'thin')
      my_helper = index
    end

    worksheet.add_cell(my_helper + 2, 0, I18n.t(:equation))
    worksheet.add_cell(my_helper + 2, 1, kb_input.formula)
    worksheet.sheet_data[my_helper + 2][0].change_font_bold(true)
    worksheet.sheet_data[my_helper + 2][0].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 2][0].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 2][1].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 2][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 2][1].change_border(:right, 'thin')

    worksheet.add_cell(my_helper + 3, 0, I18n.t(:size))
    worksheet.add_cell(my_helper + 3, 1, Kb::KbModel::display_size(size_previous_ev, size_current_ev, "most_likely", current_component.id))
    worksheet.sheet_data[my_helper + 3][0].change_font_bold(true)
    worksheet.sheet_data[my_helper + 3][0].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 3][0].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 3][1].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 3][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 3][1].change_border(:right, 'thin')

    worksheet.add_cell(my_helper + 4, 0, "#{I18n.t(:effort_import)} #{my_kb_model.effort_unit.blank? ? 'h.h' : my_kb_model.effort_unit}")
    worksheet.add_cell(my_helper + 4, 1, effort_current_ev.send("string_data_most_likely")[current_component.id].to_f / (my_kb_model.standard_unit_coefficient.nil? ? 1 : my_kb_model.standard_unit_coefficient))
    worksheet.sheet_data[my_helper + 4][0].change_font_bold(true)
    worksheet.sheet_data[my_helper + 4][0].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 4][0].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 4][1].change_border(:left, 'thin')
    worksheet.sheet_data[my_helper + 4][1].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper + 4][1].change_border(:right, 'thin')

    kb_input.values.each_with_index do |one_dot, index|
      if index == 0
        worksheet.add_cell(index, 4, I18n.t(:effort_import))
        worksheet.add_cell(index, 3, I18n.t(:size))
        worksheet.sheet_data[index][3].change_font_bold(true)
        worksheet.sheet_data[index][4].change_font_bold(true)
        worksheet.sheet_data[index][4].change_border(:left, 'thin')
        worksheet.sheet_data[index][3].change_border(:left, 'thin')
        worksheet.sheet_data[index][4].change_border(:right, 'thin')
        worksheet.sheet_data[index][4].change_border(:bottom, 'thin')
        worksheet.sheet_data[index][3].change_border(:bottom, 'thin')
        end
      worksheet.add_cell(index + 1, 3, one_dot[0])
      worksheet.add_cell(index + 1, 4, one_dot[1])
      worksheet.sheet_data[index + 1][4].change_border(:left, 'thin')
      worksheet.sheet_data[index + 1][3].change_border(:left, 'thin')
      worksheet.sheet_data[index + 1][4].change_border(:right, 'thin')
      my_helper = index + 1
    end
    worksheet.sheet_data[my_helper][4].change_border(:bottom, 'thin')
    worksheet.sheet_data[my_helper][3].change_border(:bottom, 'thin')
    send_data(workbook.stream.string, filename: "#{@project.organization.name[0..4]}-#{@project.title}-#{@project.version}-#{my_kb_model.name.gsub(" ", "_")}-(#{("A".."B").to_a[current_module_project.position_x - 1]},#{current_module_project.position_x})-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

end
