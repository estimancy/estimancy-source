# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero Skbneral Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero Skbneral Public License for more details.
#
#    You should have received a copy of the GNU Affero Skbneral Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Skb::SkbModelsController < ApplicationController

  def show
    authorize! :show_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:skb_modules) => main_app.organization_module_estimation_path(@skb_model.organization, anchor: "taille"), @skb_model.organization => ""
  end

  def duplicate
    authorize! :manage_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:skb_model_id])
    new_skb_model = @skb_model.amoeba_dup

    if @skb_model.copy_number.nil?
      @skb_model.copy_number = 0
    end

    new_copy_number =  @skb_model.copy_number.to_i + 1
    new_skb_model.name = "#{@skb_model.name}(#{new_copy_number})"
    new_skb_model.copy_number = 0
    @skb_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_skb_model.transaction do
      if new_skb_model.save
        @skb_model.save
        flash[:notice] = "Base copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie de la base"
      end
    end

    redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @skb_model = Skb::SkbModel.new
    set_page_title I18n.t(:New_knowledge_base)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:skb_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "taille"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    @organization = @skb_model.organization

    @current_organization
    set_page_title I18n.t(:Edit_knowledge_base)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:skb_modules) => main_app.organization_module_estimation_path(@organization, anchor: "taille"), @skb_model.name => ""
  end

  def data_export
    authorize! :show_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:skb_model_id])
    workbook = RubyXL::Workbook.new

    worksheet = workbook[0]
    worksheet.sheet_name = "Description du modèle"

    worksheet.add_cell(0, 0, "Nom")
    worksheet.add_cell(0, 1, @skb_model.name)

    worksheet.add_cell(1, 0, "Description")
    worksheet.add_cell(1, 1, @skb_model.description)

    worksheet.add_cell(2, 0, "Unité de taille")
    worksheet.add_cell(2, 1, @skb_model.size_unit)

    worksheet = workbook.add_worksheet("Données")
    kb_model_datas = @skb_model.skb_datas
    default_attributs = ["Nom", "Dscription", "Données", "Traitements"]

    if !kb_model_datas.nil? && !kb_model_datas.empty?
      kb_model_datas.each_with_index do |kb_data, index|
        worksheet.add_cell(index + 1, 0, kb_data.name).change_horizontal_alignment('center')
        worksheet.add_cell(index + 1, 1, kb_data.description).change_horizontal_alignment('center')
        worksheet.add_cell(index + 1, 2, kb_data.data).change_horizontal_alignment('center')
        worksheet.add_cell(index + 1, 3, kb_data.processing).change_horizontal_alignment('center')
      end
    end

    send_data(workbook.stream.string, filename: "#{@skb_model.organization.name[0..4]}-#{@skb_model.name.gsub(" ", "_")}_skb_data-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end

  def import
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])

    unless params[:file].nil?
      begin
        begin
        file = Roo::Spreadsheet.open(params[:file].path, :extension => :xls)
        rescue
          file = Roo::Spreadsheet.open(params[:file].path, :extension => :xlsx)
        end
      rescue
        flash[:error] = "Une erreur est survenue durant l'import du modèle. Veuillez vérifier l'extension du fichier Excel."
        redirect_to skb.edit_skb_model_path(@skb_model, organization_id: @organization.id) and return
      end

      file.default_sheet = file.sheets[0]
      @skb_model = Skb::SkbModel.where(params[:skb_model_id]).first_or_create(name: file.cell(1,2),
                                                                              description: file.cell(2,2),
                                                                              size_unit: file.cell(3,2),
                                                                              organization_id: @organization.id)

      unless @skb_model.nil?
        Skb::SkbData.delete_all("skb_model_id = #{@skb_model.id}")
      end

      file.default_sheet = file.sheets[1]
      ((file.first_row + 1)..file.last_row).each do |line|
        name = file.cell(line, 'A')
        description = file.cell(line, 'B')
        data = file.cell(line, 'C')
        traitement   = file.cell(line, 'D')

        Skb::SkbData.create(name: name,
                            description: description,
                            data: data,
                            processing: traitement,
                            skb_model_id: @skb_model.id)
      end
    end

    redirect_to skb.edit_skb_model_path(@skb_model, organization_id: @organization.id)
  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])

    @skb_model = Skb::SkbModel.new(params[:skb_model])
    @skb_model.organization_id = @organization.id.to_i
    if @skb_model.save
      redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])

    if @skb_model.update_attributes(params[:skb_model])
      redirect_to skb.edit_skb_model_path(@skb_model)
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @skb_model = Skb::SkbModel.find(params[:id])
    organization_id = @skb_model.organization_id

    @skb_model.module_projects.each do |mp|
      mp.destroy
    end

    @skb_model.delete
    redirect_to main_app.organization_module_estimation_path(@skb_model.organization_id, anchor: "taille")
  end

  def save_size
    authorize! :execute_estimation_plan, @project

    @skb_model = Skb::SkbModel.find(params[:skb_model_id])
    @skb_input = @skb_model.skb_inputs.where(module_project_id: current_module_project.id).first_or_create

    @skb_input.data = params[:data].to_i
    @skb_input.processing = params[:processing].to_i
    @skb_input.retained_size = (params[:data].to_i + params[:processing].to_i)

    @skb_input.save

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(module_project_id: current_module_project.id,
                                 pe_attribute_id: am.pe_attribute.id,
                                 in_out: "output").first

      ["low", "most_likely", "high"].each do |level|

        if @skb_model.three_points_estimation?
          size = params[:"retained_size_#{level}"].to_f
        else
          size = params[:"retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "retained_size"
          ev.send("string_data_#{level}")[current_component.id] = (@skb_input.data + @skb_input.processing).round(0)
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @skb_model.three_points_estimation?
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

    @size = Skb::SkbModel::display_size(size_previous_ev, size_current_ev, "most_likely", current_component.id)

  end

end
