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
  load_resource
  require 'securerandom'
  require 'rubyXL'
  include ProjectsHelper
  include OrganizationsHelper
  include ActionView::Helpers::NumberHelper

  def import_project_areas
    @organization = Organization.find(params[:organization_id])
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0].extract_data

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].nil?
          new_app = ProjectArea.new(name: row[0], description: row[1],organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        elsif row[0].nil?
          tab_error << index + 1
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = I18n.t(:error_impor_groups, parameter: tab_error.join(", "))
    end
    flash[:notice] = I18n.t(:notice_wbs_activity_element_import_successful)
    redirect_to :back
  end

  def export_project_areas
    @organization = Organization.find(params[:organization_id])
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

  def polyval_export
    @organization = Organization.find(params[:organization_id])
=begin    polyval_var = (params[:MYonglet] == "ProjectCategory" ? ProjectCategory.where(organization_id: @organization.id) :
                  params[:MYonglet] == "WorkElementType" ? WorkElementType.where(organization_id: @organization.id) :
                  params[:MYonglet] == "OrganizationTechnology" ? OrganizationTechnology.where(organization_id: @organization.id) :
                  params[:MYonglet] == "OrganizationProfile" ? OrganizationProfile.where(organization_id: @organization.id) : PlatformCategory.where(organization_id: @organization.id))
=end
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
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0].extract_data

      tab.each_with_index do |row, index|
        if index > 0
          new_app = Application.new(name: row[0], organization_id: @organization.id)
          unless new_app.save
            tab_error << index + 1
          end
        end
      end
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    unless tab_error.empty?
      flash[:error] = I18n.t(:error_impor_groups, parameter: tab_error.join(", "))
    end
    flash[:notice] = I18n.t(:notice_wbs_activity_element_import_successful)
    redirect_to :back
  end

  def export_appli
    @organization = Organization.find(params[:organization_id])
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
    tab_error = []
    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
      workbook = RubyXL::Parser.parse(params[:file].path)
      tab = workbook[0].extract_data

      tab.each_with_index do |row, index|
        if index > 0 && !row[0].nil?
          new_group = Group.new(name: row[0], description: row[1], organization_id: @organization.id)
          unless new_group.save
            tab_error << index + 1
          end
        elsif row[0].nil?
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

  def generate_report_excel
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

    tmp1 = @organization.projects.where(creator_id: current_user.id,
                                        is_model: false,
                                        private: true).all

    if params[:report_date][:start_date].blank? || params[:report_date][:end_date].blank?
      tmp2 = @organization.projects.where(is_model: false, private: false).where(conditions).where("title like ?", "%#{params[:title]}%").all
    else
      tmp2 = @organization.projects.where(is_model: false, private: false).where(conditions).where(start_date: (Time.parse(start_date)..Time.parse(end_date))).where("title like ?", "%#{params[:title]}%").all
    end

    @projects = (tmp1 + tmp2).uniq

    workbook = RubyXL::Workbook.new
    worksheet = workbook.worksheets[0]
    worksheet.sheet_name = 'Data'

    tmp = Array.new

    if params[:with_header] == "checked"
      tmp << [
          I18n.t(:project),
          I18n.t(:label_project_version),
          I18n.t(:label_product_name),
          I18n.t(:description),
          I18n.t(:start_date),
          I18n.t(:applied_model),
          I18n.t(:project_area),
          I18n.t(:state),
          I18n.t(:creator),
      ] + @organization.fields.map(&:name)
    end

    @projects.each do |project|
      array_project = Array.new
      array_value = Array.new

      if can_show_estimation?(project) || can_see_estimation?(project)
          array_project << [
            project.title,
            project.version,
            (project.application.nil? ? project.application_name : project.application.name),
            "#{Nokogiri::HTML.parse(ActionView::Base.full_sanitizer.sanitize(project.description)).text}",
            I18n.l(project.start_date),
            project.original_model,
            project.project_area,
            project.estimation_status,
            project.creator
        ]

        @organization.fields.each do |field|
          pf = ProjectField.where(field_id: field.id, project_id: project.id).last
          if pf.nil?
            array_value << ''
          else
            array_value << (pf.value.to_f / field.coefficient.to_f)
          end
        end

      end

      tmp << (array_project + array_value).flatten(1)

    end

    tmp2 = []
    tmp.map do |i|
      if !i.empty?
        tmp2 << i
      end
    end

    tmp2.each_with_index do |r, i|
      tmp2[i].each_with_index do |r, j|
        if is_number?(tmp2[i][j])
          unless tmp2[i][j] == 0 || j == 1
            worksheet.add_cell(i, j, tmp2[i][j].to_f).set_number_format('.##')
          else
            worksheet.add_cell(i, j, tmp2[i][j])
          end
        else
          worksheet.add_cell(i, j, tmp2[i][j])
        end
      end
    end

    worksheet.change_row_bold(0 , true)

    send_data(workbook.stream.string, filename: "#{@organization.name[0..4]}-Data-#{Time.now.strftime("%m-%d-%Y_%H-%M")}.xlsx", type: "application/vnd.ms-excel")

    # workbook.write("#{Rails.root}/public/#{filename}.xlsx")
    # redirect_to "#{SETTINGS['HOST_URL']}/#{filename}.xlsx"
  end

  def report
    @organization = Organization.find(params[:organization_id])
    set_page_title I18n.t(:report, parameter: @organization)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => organization_estimations_path(@organization), I18n.t(:report) => ""
    check_if_organization_is_image(@organization)
  end

  def authorization
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""
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

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""
    set_page_title I18n.t(:Parameter, parameter: @organization)

    @technologies = @organization.organization_technologies
    @fields = @organization.fields
    @work_element_types = @organization.work_element_types

    @organization_profiles = @organization.organization_profiles

    @organization_group = @organization.groups
    @estimation_models = @organization.projects.where(:is_model => true)
  end

  def module_estimation
    @organization = Organization.find(params[:organization_id])

    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => organization_estimations_path(@organization), I18n.t(:label_estimation_modules) => ""
    set_page_title I18n.t(:module ,parameter: @organization)

    @guw_models = @organization.guw_models.order("name asc")
    @wbs_activities = @organization.wbs_activities.order("name asc")
    @technologies = @organization.organization_technologies.order("name asc")
  end

  def users
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""
    set_page_title I18n.t(:spec_users, parameter: @organization)
  end

  def estimations
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""
    set_page_title I18n.t(:spec_estimations, parameter: @organization.to_s)

    if current_user.super_admin == true
      @projects = @organization.projects.where(is_model: false).all
    else
      tmp1 = @organization.projects.where(is_model: false, private: false).all
      tmp2 = @organization.projects.where(creator_id: current_user.id, is_model: false, private: true).all
      @projects = (tmp1 + tmp2).uniq
    end
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
        creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
        unless creator_securities.nil?
          creator_securities.update_attribute(:user_id, user.id)
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

        # if the module_project view is nil
        #if new_mp.view.nil?
        #  default_view = new_organization.views.where('pemodule_id = ? AND is_default_view = ?', new_mp.pemodule_id, true).first
        #  if default_view.nil?
        #    default_view = View.create(name: "#{new_mp} view", description: "", pemodule_id: new_mp.pemodule_id, organization_id: new_organization_id)
        #  end
        #  new_mp.update_attribute(:view_id, default_view.id)
        #end

        #Recreate view for all moduleproject as the projects are not is the same organization
        #Copy the views and widgets for the new project
        #mp_default_view =
        #if old_mp.view.nil?
        #
        #else
        #
        #end

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
                widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id, name: view_widget.name, show_name: view_widget.show_name,
                                                 icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                 width: view_widget.width, height: view_widget.height, position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)

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

          guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id, organization_technology_id: new_technology_id)

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
                                      organization_technology_id: uow_new_technology_id)
          end
        end

        # UOW-INPUTS
        # new_mp.uow_inputs.each do |uo|
        #   new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
        #   new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
        #   uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
        # end

        #WBS-ACTIVITY-INPUTS
        new_mp.wbs_activity_inputs.each do |activity_input|
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: activity_input.wbs_activity_id).first
          unless new_wbs_activity.nil?
            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: activity_input.wbs_activity_ratio_id).first
            unless new_wbs_activity_ratio.nil?
              activity_input.update_attributes(wbs_activity_id: new_wbs_activity.id, wbs_activity_ratio_id: new_wbs_activity_ratio.id)
            end
          end
        end

        ["input", "output"].each do |io|
          new_mp.pemodule.pe_attributes.each do |attr|
            old_prj.pbs_project_elements.each do |old_component|
              new_prj_components.each do |new_component|
                ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                unless ev.nil?
                  ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
                  ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
                  ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
                  ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id
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
      new_organization = organization_image.amoeba_dup

      if params[:action_name] == "new_organization_from_image"
        new_organization.name = @organization_name
      elsif params[:action_name] == "copy_organization"
        new_organization.description << "\n \n Cette organisation est une copie de l'organisation #{organization_image.name}."
        new_organization.description << "\n #{I18n.l(Time.now)} : #{I18n.t(:organization_copied_by, username: current_user.name)}"
      end
      new_organization.is_image_organization = false

      new_organization.transaction do

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

          OrganizationsUsers.where(user_id: current_user.id, organization_id: new_organization.id).first_or_create!

          #Copy the organization referenced views and widgets
          #organization_image.views.referenced_views.each do |view|
          #  #=====
          #  new_copied_view = View.new(name: view.name, description: view.description, pemodule_id: view.pemodule_id, organization_id: new_organization.id, initial_view_id: view.id)
          #  if new_copied_view.save
          #    #Then copy the widgets
          #    view.views_widgets.each do |view_widget|
          #      widget_est_val = view_widget.estimation_value
          #      in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
          #      estimation_value = @module_project.estimation_values.where('pe_attribute_id = ? AND in_out=?', view_widget.estimation_value.pe_attribute_id, in_out).last
          #      estimation_value_id = estimation_value.nil? ? nil : estimation_value.id
          #      widget_copy = ViewsWidget.new(view_id: new_copied_view.id, module_project_id: @module_project.id, estimation_value_id: estimation_value_id, name: view_widget.name,
          #                                    show_name: view_widget.show_name, icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max,
          #                                    width: view_widget.width, height: view_widget.height, widget_type: view_widget.widget_type, position: view_widget.position,
          #                                    position_x: view_widget.position_x, position_y: view_widget.position_y)
          #      #Save and copy project_fields
          #      if widget_copy.save
          #        unless view_widget.project_fields.empty?
          #          project_field = view_widget.project_fields.last
          #
          #          #Get project_field value
          #          @value = 0
          #          if widget_copy.estimation_value.module_project.pemodule.alias == "effort_breakdown"
          #            begin
          #              @value = widget_copy.estimation_value.string_data_probable[current_component.id][widget_copy.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
          #            rescue
          #              begin
          #                @value = widget_copy.estimation_value.string_data_probable[current_component.id]
          #              rescue
          #                @value = 0
          #              end
          #            end
          #          else
          #            @value = widget_copy.estimation_value.string_data_probable[current_component.id]
          #          end
          #
          #          #create the new project_field
          #          ProjectField.create(project_id: @project.id, field_id: project_field.field_id, views_widget_id: widget_copy.id, value: @value)
          #        end
          #      end
          #    end
          #  end
          #
          #  #=====
          #end

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
                  new_wbs_profiles << new_organization_profile.id
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

                    corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
                      ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
                    end

                    new_elt.save(:validate => false)
                  end
                end
              else
                flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
              end
            end

            # Update all the new organization module_project's guw_model with the current guw_model
            wbs_activity_copy_id = old_wbs_activity.id
            new_organization.module_projects.where(wbs_activity_id: wbs_activity_copy_id).update_all(wbs_activity_id: new_wbs_activity.id)
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

          # Update the Expert Judgement modules's Models instances
          new_organization.expert_judgement_instances.each do |expert_judgment|
            # Update all the new organization module_project's guw_model with the current guw_model
            expert_judgment_copy_id = expert_judgment.copy_id
            new_organization.module_projects.where(expert_judgement_instance_id: expert_judgment_copy_id).update_all(expert_judgement_instance_id: expert_judgment.id)
          end

          # Update the modules's GE Models instances
          new_organization.ge_models.each do |ge_model|
            # Update all the new organization module_project's guw_model with the current guw_model
            ge_copy_id = ge_model.copy_id
            new_organization.module_projects.where(ge_model_id: ge_copy_id).update_all(ge_model_id: ge_model.id)
          end

          # Update the modules's GE Models instances
          new_organization.staffing_models.each do |staffing_model|
            # Update all the new organization module_project's guw_model with the current guw_model
            staffing_model_copy_id = staffing_model.copy_id
            new_organization.module_projects.where(staffing_model_id: staffing_model_copy_id).update_all(staffing_model_id: staffing_model.id)
          end

          # Update the modules's GE Models instances
          new_organization.kb_models.each do |kb_model|
            # Update all the new organization module_project's guw_model with the current guw_model
            kb_copy_id = kb_model.copy_id
            new_organization.module_projects.where(kb_model_id: kb_copy_id).update_all(kb_model_id: kb_model.id)
          end

          # Copy the modules's GUW Models instances
          new_organization.guw_models.each do |guw_model|

            # Update all the new organization module_project's guw_model with the current guw_model
            guw_model_copy_id = guw_model.copy_id
            new_organization.module_projects.where(guw_model_id: guw_model_copy_id).update_all(guw_model_id: guw_model.id)

            ###### Replace the code below

            guw_model.terminate_guw_model_duplication

          end

          flash[:notice] = I18n.t(:notice_organization_successful_created)
        else
          flash[:error] = I18n.t('errors.messages.not_saved.one', :resource => I18n.t(:organization))
        end
      end
    end

    #redirect_to :back

    respond_to do |format|
      format.html { redirect_to organizationals_params_path and return }
      format.js { render :js => "window.location.replace('/organizationals_params');"}
    end
  end

  def new
    authorize! :create_organizations, Organization

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:new_organization) => ""
    @organization = Organization.new
    @groups = @organization.groups
  end

  def edit
    #authorize! :edit_organizations, Organization
    authorize! :show_organizations, Organization

    set_page_title I18n.t(:organizations)
    @organization = Organization.find(params[:id])

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""

    @attributes = PeAttribute.all
    @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})

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

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:new_organization) => ""

    @organization = Organization.new(params[:organization])

    # Organization's projects selected columns
    @organization.project_selected_columns = Project.default_selected_columns

    # Add current_user to the organization
    @organization.users << current_user

    #A la sauvegarde, on crée des sous traitants
    if @organization.save

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

    set_page_title I18n.t(:organizations)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => ""

    if @organization.update_attributes(params[:organization])
      flash[:notice] = I18n.t (:notice_organization_successful_updated)
      redirect_to redirect_apply(edit_organization_path(@organization), nil, '/organizationals_params')
    else
      @attributes = PeAttribute.all
      @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})
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
    authorize! :manage, Organization
  end

  def destroy
    authorize! :manage, Organization

    @organization = Organization.find(params[:id])
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

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", "#{I18n.t(:organizations)}" => ""

    if current_user.super_admin?
      @organizations = Organization.all
    elsif can?(:manage, :all)
      @organizations = Organization.all.reject{|org| org.is_image_organization}
    else
      @organizations = current_user.organizations.all.reject{|org| org.is_image_organization}
    end

    if @organizations.size == 1
      redirect_to organization_estimations_path(@organizations.first)
    end
  end

  def export_user
    @organization = Organization.find(params[:organization_id])
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    first_line = [I18n.t(:first_name_attribute), I18n.t(:last_name_attribute), I18n.t(:initials_attribute),I18n.t(:email_attribute), I18n.t(:login_name_or_email), I18n.t(:authentication),I18n.t(:description), I18n.t(:label_language), I18n.t(:locked_at),I18n.t(:groups)]
    line = []

    first_line.each_with_index do |name, index|
      worksheet.add_cell(0, index, name)
    end

    @organization.users.each_with_index do |user, index_line|
      line =  [user.first_name, user.last_name, user.initials,user.email, user.login_name, user.auth_method ? user.auth_method.name : "Application" , user.description, user.language, user.locked_at.nil? ? 0 : 1] + user.groups.where(organization_id: @organization.id).map(&:name)
      line.each_with_index do |my_case, index|
        worksheet.add_cell(index_line + 1, index, my_case)
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

  def import_user
    users_existing = []
    user_with_no_name = []

    if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
        workbook = RubyXL::Parser.parse(params[:file].path)
        worksheet = workbook[0]
        tab = worksheet.extract_data

        tab.each_with_index do |line, index_line|
        if index_line > 0
          user = User.find_by_login_name(line[4])
          if  !line.empty? && !line.nil?
            if user.nil?
              password = SecureRandom.hex(8)
              if line[0] && line[1] && line[4] && line[3]
                if line[7]
                  langue = Language.find_by_name(line[7]) ? Language.find_by_name(line[7]).id : params[:language_id].to_i
                else
                  langue = params[:language_id].to_i
                end

                if line[5]
                  auth_method = AuthMethod.find_by_name(line[5]) ? AuthMethod.find_by_name(line[5]).id : AuthMethod.first.id
                else
                  auth_method = AuthMethod.first.id
                end

                user = User.new(first_name: line[0],
                                last_name: line[1],
                                initials: line[2].nil? ? "#{line[0][0]}#{line[1][0]}" : line[2],
                                email: line[3],
                                login_name: line[4],
                                id_connexion: line[4],
                                description: line[6],
                                super_admin: false,
                                password: password,
                                password_confirmation: password,
                                language_id: langue,
                                time_zone: "Paris",
                                object_per_page: 50,
                                auth_type: auth_method,
                                locked_at: line[8] ==  0 ? nil : Time.now,
                                number_precision: 2)
                if line[5].upcase == "SAML"
                  user.skip_confirmation_notification!
                  user.skip_confirmation!
                end
                user.save
                OrganizationsUsers.create(organization_id: @current_organization.id, user_id: user.id)
                group_index = 9
                 while line[group_index]
                    group = Group.where(name: line[group_index], organization_id: @current_organization.id).first
                    begin
                      GroupsUsers.create(group_id: group.id, user_id: user.id)
                    rescue
                      #rien
                    end
                   group_index += 1
                 end
              else
                user_with_no_name << index_line
              end
            else
              users_existing << line[4]
            end
          end
        end
      end
      final_error = []
      unless users_existing.empty?
        final_error <<  I18n.t(:user_exist, parameter: users_existing.join(", "))
      end
      unless user_with_no_name.empty?
        final_error << I18n.t(:user_with_no_name, parameter: user_with_no_name.join(", "))
      end
      unless final_error.empty?
        flash[:error] = final_error.join("<br/>").html_safe
      end
      flash[:notice] = I18n.t(:user_importation_success)
    else
      flash[:error] = I18n.t(:route_flag_error_4)
    end
    redirect_to organization_users_path(@current_organization)

=begin
    sep = "#{params[:separator].blank? ? I18n.t(:general_csv_separator) : params[:separator]}"
    error_count = 0
    file = params[:file]
    encoding = params[:encoding]

    #begin
      CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "ISO-8859-1:utf-8") do |csv|
        csv.each_with_index do |row, i|
          unless i == 0
            password = SecureRandom.hex(8)

            user = User.where(login_name: row[3]).first
            if user.nil?

              u = User.new(first_name: row[0],
                           last_name: row[1],
                           email: row[2],
                           login_name: row[3],
                           id_connexion: row[3],
                           super_admin: false,
                           password: password,
                           password_confirmation: password,
                           language_id: params[:language_id].to_i,
                           initials: "#{row[0].first}#{row[1].first}",
                           time_zone: "Paris",
                           object_per_page: 50,
                           auth_type: AuthMethod.first.id,
                           number_precision: 2)

              u.save(validate: false)

              OrganizationsUsers.create(organization_id: @current_organization.id,
                                        user_id: u.id)
              (row.size - 4).times do |i|
                group = Group.where(name: row[4 + i], organization_id: @current_organization.id).first
                begin
                  GroupsUsers.create(group_id: group.id,
                                     user_id: u.id)
                rescue
                  # nothing
                end
              end
            end
          end
        end
      end
    #rescue
    #  flash[:error] = "Une erreur est survenue durant l'import du fichier. Vérifier l'encodage du fichier (ISO-8859-1 pour Windows, utf-8 pour Mac) ou le caractère de séparateur du fichier"
    #end
=end
  end

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

  private
  def check_if_organization_is_image(organization)
    if organization.is_image_organization == true
      redirect_to("/organizationals_params",
                  flash: {
                      error: "Vous ne pouvez pas accéder aux estimations d'une organization image"
                  }) and return
    end
  end


end
