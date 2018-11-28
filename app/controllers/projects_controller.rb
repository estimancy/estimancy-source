#encoding: utf-8
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

class ProjectsController < ApplicationController

  require 'rubyXL'

  include WbsActivityElementsHelper
  include ModuleProjectsHelper
  include ProjectsHelper
  include PemoduleEstimationMethods

  load_resource

  helper_method :sort_direction, :is_collapsible?, :set_attribute_unit
  helper_method :show_status_change_comments
  helper_method :dashboard_none_displayed

  before_filter :load_data, :only => [:update, :edit, :new, :create, :show]
  before_filter :check_estimations_counter, :only => [:new, :duplicate, :change_new_estimation_data, :set_checkout_version]   # create, duplicate, checkout

  private def check_estimations_counter
    @organization = @current_organization
    estimations_counter = @organization.estimations_counter
    unless estimations_counter.nil?
      if estimations_counter == 0 && @current_user.super_admin != true
        #redirect_to(organization_estimations_path(@organization), flash:{ warning: I18n.t(:warning_zero_estimations_counter) } ) and return
        flash[:warning] = I18n.t(:warning_zero_estimations_counter)
        #redirect_to(:back) and return
        respond_to do |format|
          format.html { redirect_to(:back) and return }
          format.js { render :js => "window.location = '#{request.env['HTTP_REFERER']}'" }
        end
      elsif estimations_counter < 10
        flash.now[:warning] = I18n.t(:warning_minimum_estimations_counter, counter: estimations_counter)
      end
    end
  end


  def load_data
    #No authorize required since this method protected and is used to load data and shared by the other one.
    if params[:id]
      begin
        @project = Project.find(params[:id])
      rescue
        redirect_to root_url and return
      end
    else
      @project = Project.new :state => 'preliminary'
    end

    @pemodules ||= Pemodule.all
    @project_modules = @project.pemodules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    if current_user.super_admin == true
      @organizations = Organization.all
    else
      @organizations = current_user.organizations
    end

    @project_modules = @project.pemodules
    @project_security_levels = ProjectSecurityLevel.all
    @module_project = ModuleProject.find_by_project_id(@project.id)
  end

  def rapport
    @project
    @current_organization = @project.organization
    render :layout => false
  end

  def raw_data_extraction
    workbook = RubyXL::Workbook.new

    @organization = Organization.where(id: params[:organization_id]).first

    worksheet_cf = workbook.worksheets[0]
    worksheet_cf.sheet_name = 'Composants Fonctionnels'

    worksheet_wbs = workbook.add_worksheet('Activités')
    worksheet_synt = workbook.add_worksheet('Synthèse')

    str = ""

    worksheet_cf.add_cell(0, 0, "Devis")
    worksheet_cf.add_cell(0, 1, "Application")
    worksheet_cf.add_cell(0, 2, "Besoin Métier")
    worksheet_cf.add_cell(0, 3, "Numero de demande")
    worksheet_cf.add_cell(0, 4, "Domaine")
    worksheet_cf.add_cell(0, 5, "Service")
    worksheet_cf.add_cell(0, 6, "Localisation")
    worksheet_cf.add_cell(0, 7, "Catégorie")
    worksheet_cf.add_cell(0, 8, "Fournisseur")
    worksheet_cf.add_cell(0, 9, "Date")
    worksheet_cf.add_cell(0, 10, "Statut")
    worksheet_cf.add_cell(0, 11, "Composant fonctionnel")
    worksheet_cf.add_cell(0, 12, "Type de composant")
    worksheet_cf.add_cell(0, 13, "Complexité théorique")
    worksheet_cf.add_cell(0, 14, "Complexité calculée")
    worksheet_cf.add_cell(0, 15, "% DEV théorique")
    worksheet_cf.add_cell(0, 16, "% DEV calculé")
    worksheet_cf.add_cell(0, 17, "% TEST théorique")
    worksheet_cf.add_cell(0, 18, "% TEST calculé")

    i = 1

    @total_cost = Hash.new {|h,k| h[k] = [] }
    @total_effort = Hash.new {|h,k| h[k] = [] }

    @organization.projects.each do |project|
      project.guw_unit_of_works.each do |guow|
        worksheet_cf.add_cell(i, 0, project.title)
        worksheet_cf.add_cell(i, 1, project.application_name)
        worksheet_cf.add_cell(i, 2, project.business_need)
        worksheet_cf.add_cell(i, 3, project.request_number)
        worksheet_cf.add_cell(i, 4, project.project_area.nil? ? '' : project.project_area.name)
        worksheet_cf.add_cell(i, 5, project.acquisition_category.nil? ? '' : project.acquisition_category.name)
        worksheet_cf.add_cell(i, 6, project.project_category.nil? ? '' : project.project_category.name)
        worksheet_cf.add_cell(i, 7, project.platform_category.nil? ? '' : project.platform_category.name)
        worksheet_cf.add_cell(i, 8, project.provider.nil? ? '' : project.provider.name)
        worksheet_cf.add_cell(i, 9, project.start_date.to_s)
        worksheet_cf.add_cell(i, 10, project.estimation_status.to_s)
        worksheet_cf.add_cell(i, 11, guow.name)
        worksheet_cf.add_cell(i, 12, guow.guw_type.nil? ? '-' : guow.guw_type.name)
        worksheet_cf.add_cell(i, 13, guow.intermediate_percent)
        worksheet_cf.add_cell(i, 14, guow.intermediate_weight)

        @guw_model = guow.guw_model
        @guw_coefficients = @guw_model.guw_coefficients

        j = 0
        @guw_coefficients.each do |gc|
          if gc.coefficient_type == "Pourcentage"

            @guw_coefficient_guw_coefficient_elements = gc.guw_coefficient_elements
            default = @guw_coefficient_guw_coefficient_elements.where(default: true).first

            ceuw = Guw::GuwCoefficientElementUnitOfWork.where(guw_unit_of_work_id: guow.id,
                                                              guw_coefficient_id: gc.id,
                                                              module_project_id: guow.module_project_id).order("updated_at ASC").last

            worksheet_cf.add_cell(i, 15 + j, default.nil? ? 100 : default.value.to_f)
            worksheet_cf.add_cell(i, 15 + j + 1, ceuw.nil? ? nil : ceuw.percent.to_f)
            j = j + 2
          end
        end


        guow.guw_unit_of_work_attributes.where(guw_type_id: guow.guw_type.id).includes(:guw_attribute).order('guw_guw_attributes.name asc').each_with_index do |uowa, j|
          worksheet_cf.add_cell(i, 19 + j, uowa.nil? ? nil : uowa.most_likely)
        end

        # if j == 0
        @guw_model.guw_attributes.each_with_index do |guw_attribute, ii|
          worksheet_cf.add_cell(0, 19+ii, guw_attribute.name)
        end
        # end

        i = i + 1
        guw_output_effort = Guw::GuwOutput.where(name: ["Charges T (jh)"], guw_model_id: @guw_model.id).first
        guw_output_cost = Guw::GuwOutput.where(name: ["Coût Services (€)"], guw_model_id: @guw_model.id).first

        unless guw_output_effort.nil?
          guw_output_effort_value = guow.ajusted_size.nil? ? 0 : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"].to_f.round(2))
        end

        unless guw_output_cost.nil?
          guw_output_cost_value = guow.ajusted_size.nil? ? 0 : guow.ajusted_size["#{guw_output_cost.id}"].to_f.round(2)
        end

        @total_effort[project.id] << guw_output_effort_value.to_f
        @total_cost[project.id] << guw_output_cost_value.to_f
      end
    end

    worksheet_wbs.add_cell(0, 0, "Devis")
    worksheet_wbs.add_cell(0, 1, "Application")
    worksheet_wbs.add_cell(0, 2, "Besoin Métier")
    worksheet_wbs.add_cell(0, 3, "Numero de demande")
    worksheet_wbs.add_cell(0, 4, "Domaine")
    worksheet_wbs.add_cell(0, 5, "Service")
    worksheet_wbs.add_cell(0, 6, "Localisation")
    worksheet_wbs.add_cell(0, 7, "Catégorie")
    worksheet_wbs.add_cell(0, 8, "Fournisseur")
    worksheet_wbs.add_cell(0, 9, "Date")
    worksheet_wbs.add_cell(0, 10, "Statut")
    worksheet_wbs.add_cell(0, 11, "Ratio")
    worksheet_wbs.add_cell(0, 12, "Phase")
    worksheet_wbs.add_cell(0, 11, "TJM")
    worksheet_wbs.add_cell(0, 12, "Charge calculée")
    worksheet_wbs.add_cell(0, 13, "Charge retenue")
    worksheet_wbs.add_cell(0, 14, "Coût calculé")
    worksheet_wbs.add_cell(0, 15, "Coût retenu")

    ModuleProjectRatioElement.where(organization_id: @organization.id).where("theoretical_effort_most_likely IS NOT NULL").each_with_index do |mpre, iii|
      mpre_project = mpre.module_project.project
      worksheet_wbs.add_cell(iii+1, 0, mpre_project.title)
      worksheet_wbs.add_cell(iii+1, 1, mpre_project.application_name)
      worksheet_wbs.add_cell(iii+1, 2, mpre_project.business_need)
      worksheet_wbs.add_cell(iii+1, 3, mpre_project.request_number)
      worksheet_wbs.add_cell(iii+1, 4, mpre_project.project_area.nil? ? '' : mpre_project.project_area.name)
      worksheet_wbs.add_cell(iii+1, 5, mpre_project.acquisition_category.nil? ? '' : mpre_project.acquisition_category.name)
      worksheet_wbs.add_cell(iii+1, 6, mpre_project.project_category.nil? ? '' : mpre_project.project_category.name)
      worksheet_wbs.add_cell(iii+1, 7, mpre_project.platform_category.nil? ? '' : mpre_project.platform_category.name)
      worksheet_wbs.add_cell(iii+1, 8, mpre_project.provider.nil? ? '' : mpre_project.provider.name)
      worksheet_wbs.add_cell(iii+1, 9, mpre_project.start_date.to_s)
      worksheet_wbs.add_cell(iii+1, 10, mpre_project.estimation_status.to_s)
      worksheet_wbs.add_cell(iii+1, 11, mpre.wbs_activity_ratio.name)
      worksheet_wbs.add_cell(iii+1, 12, mpre.name)
      worksheet_wbs.add_cell(iii+1, 13, mpre.tjm)
      worksheet_wbs.add_cell(iii+1, 14, mpre.theoretical_effort_most_likely.blank? ? 0 : mpre.theoretical_effort_most_likely.round(user_number_precision))
      worksheet_wbs.add_cell(iii+1, 15, mpre.retained_effort_most_likely.blank? ? 0 : mpre.retained_effort_most_likely.round(user_number_precision))
      worksheet_wbs.add_cell(iii+1, 16, mpre.theoretical_cost_most_likely.blank? ? 0 : mpre.theoretical_cost_most_likely.round(user_number_precision))
      worksheet_wbs.add_cell(iii+1, 17, mpre.retained_cost_most_likely.blank? ? 0 : mpre.retained_cost_most_likely.round(user_number_precision))
    end

    pemodule_wbs = Pemodule.where(alias: "effort_breakdown").first
    @organization.projects.each do |project|
      module_project = project.module_projects.where(pemodule_id: pemodule_wbs.id).first
      unless module_project.nil?
        ModuleProjectRatioElement.where(organization_id: @organization.id,
                                        wbs_activity_ratio_id: module_project.wbs_activity_ratio_id).where("theoretical_effort_most_likely IS NOT NULL").each_with_index do |mpre, iii|

          if mpre.module_project_id.in?(project.module_projects.map(&:id))
            if mpre.wbs_activity_element.is_root?
              @total_effort[project.id] << mpre.retained_effort_most_likely.to_f
              @total_cost[project.id] << mpre.retained_cost_most_likely.to_f
            end
          end
        end
      end
    end


    # SI on trouve 0 dan effrto ou cost, faire comme ça,
    # sinon faire comme c'est fait en haut...
    @organization.projects.where(is_model: false).each do |project|

      fe = Field.where(organization_id: project.organization_id, name: ["Charge Totale (jh)", "Effort Total (UC)"]).first
      fc = Field.where(organization_id: project.organization_id, name: "Coût (k€)").first

      project.module_projects.each do |mp|
        ViewsWidget.where(module_project_id: mp.id).each do |vw|
          vw_project_fields = vw.project_fields
          unless vw_project_fields.empty?

            unless fe.nil?
              vw_project_fields.where(project_id: project.id, field_id: fe.id).each do |pf|
                @total_effort[project.id] << pf.value.to_f
              end
            end

            unless fc.nil?
              vw_project_fields.where(project_id: project.id, field_id: fc.id).each do |pf|
                @total_cost[project.id] << pf.value.to_f
              end
            end
          end
        end
      end
    end

    worksheet_synt.add_cell(0, 0, "Devis")
    worksheet_synt.add_cell(0, 1, "Application")
    worksheet_synt.add_cell(0, 2, "Besoin Métier")
    worksheet_synt.add_cell(0, 3, "Numero de demande")
    worksheet_synt.add_cell(0, 4, "Domaine")
    worksheet_synt.add_cell(0, 5, "Service")
    worksheet_synt.add_cell(0, 6, "Localisation")
    worksheet_synt.add_cell(0, 7, "Catégorie")
    worksheet_synt.add_cell(0, 8, "Fournisseur")
    worksheet_synt.add_cell(0, 9, "Date")
    worksheet_synt.add_cell(0, 10, "Statut")
    worksheet_synt.add_cell(0, 11, "Charge totale")
    worksheet_synt.add_cell(0, 12, "Coût total")
    worksheet_synt.add_cell(0, 13, "Prix moyen pondéré")

    pi = 1
    @total_effort.each do |k, value|
      project = Project.find(k)

      worksheet_synt.add_cell(pi, 0, project.title)
      worksheet_synt.add_cell(pi, 1, project.application_name)
      worksheet_synt.add_cell(pi, 2, project.business_need)
      worksheet_synt.add_cell(pi, 3, project.request_number)
      worksheet_synt.add_cell(pi, 4, project.project_area.nil? ? '' : project.project_area.name)
      worksheet_synt.add_cell(pi, 5, project.acquisition_category.nil? ? '' : project.acquisition_category.name)
      worksheet_synt.add_cell(pi, 6, project.project_category.nil? ? '' : project.project_category.name)
      worksheet_synt.add_cell(pi, 7, project.platform_category.nil? ? '' : project.platform_category.name)
      worksheet_synt.add_cell(pi, 8, project.provider.nil? ? '' : project.provider.name)
      worksheet_synt.add_cell(pi, 9, project.start_date.to_s)
      worksheet_synt.add_cell(pi, 10, project.estimation_status.to_s)

      worksheet_synt.add_cell(pi, 11, @total_effort[k].sum.to_f.round(2))
      worksheet_synt.add_cell(pi, 12, @total_cost[k].sum.to_f.round(2))

      unless @total_effort[k].sum == 0
        worksheet_synt.add_cell(pi, 13, (@total_cost[k].sum.to_f / @total_effort[k].sum.to_f).round(2) )
      end

      pi = pi + 1
    end

    send_data(workbook.stream.string, filename: "RAW_DATA.xlsx", type: "application/vnd.ms-excel")

  end

  def build_rapport
    pdf = WickedPdf.new.pdf_from_url(rapport_url)
    save_path = Rails.root.join('pdfs','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    redirect_to organization_estimations_path(@current_organization) and return
  end

  def dashboard
    if @project.nil?
      flash[:error] = I18n.t(:project_not_found)
      redirect_to organization_estimations_path(@current_organization) and return
    else
      if (params[:from_current_dashboard] && params[:organization_id]) && (@project.organization_id != params[:organization_id].to_i)
        flash[:warning] = I18n.t(:current_estimation_does_not_exists)
        redirect_to organization_estimations_path(organization_id: params[:organization_id]) and return
      end
    end

    @current_organization = @project.organization
    @pbs_project_element = current_component

    # return if user doesn't have the rigth to consult the estimation
    if !can_show_estimation?(@project)
      redirect_to(organization_estimations_path(@current_organization), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
    end

    if @current_organization.is_image_organization == true
      redirect_to(root_url, flash: { error: "Vous ne pouvez pas accéder à une organization image"}) and return
    end

    set_page_title I18n.t(:spec_estimations, parameter: @current_organization)

    @user = current_user
    @pemodules ||= Pemodule.all
    @module_project = current_module_project
    @show_hidden = 'true'

    status_comment_link = ""
    if can_alter_estimation?(@project) && ( can?(:alter_estimation_status, @project) || can?(:alter_project_status_comment, @project))
      status_comment_link = "#{main_app.add_comment_on_status_change_path(:project_id => @project.id)}"
    end
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@current_organization.id}", @current_organization.to_s => organization_estimations_path(@current_organization), "#{@project}" => "#{main_app.edit_project_path(@project)}", "<span class='badge' style='background-color: #{@project.status_background_color}'> #{@project.status_name}" => status_comment_link

    @project_organization = @project.organization
    @module_projects = @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?

    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    check_module_project
  end

  # Function to activate the current/selected module_project
  def activate_module_project
    session[:module_project_id] = params[:module_project_id]
    @module_project = ModuleProject.find(params[:module_project_id])
    @project = @module_project.project
    @project_organization = @project.organization

    authorize! :show_project, @project

    @module_projects ||= @project.module_projects
    @pbs_project_element = current_component

    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @results = nil

    check_module_project
  end

  def check_module_project
    if @module_project.pemodule.alias == "expert_judgement"
      if @module_project.expert_judgement_instance.nil?
        @expert_judgement_instance = ExpertJudgement::Instance.first
      else
        @expert_judgement_instance = @module_project.expert_judgement_instance
      end

      array_attributes = Array.new

      if @expert_judgement_instance.enabled_size?
        array_attributes << "retained_size"
      end

      if @expert_judgement_instance.enabled_effort?
        array_attributes << "effort"
      end

      if @expert_judgement_instance.enabled_cost?
        array_attributes << "cost"
      end

      #@expert_judgement_attributes = PeAttribute.where(alias: array_attributes)
      expert_judgment_module = Pemodule.where(alias: "expert_judgement").first
      if expert_judgment_module
        @expert_judgement_attributes = expert_judgment_module.pe_attributes.where(alias: array_attributes)
      else
        @expert_judgement_attributes = PeAttribute.where(alias: array_attributes)
      end

      array_attributes.each do |a|
        ExpertJudgement::InstanceEstimate.where( pe_attribute_id: PeAttribute.find_by_alias(a).id,
                                                 expert_judgement_instance_id: @expert_judgement_instance.id.to_i,
                                                 module_project_id: @module_project.id,
                                                 pbs_project_element_id: @pbs_project_element.id).first_or_create!
      end

    elsif @module_project.pemodule.alias == "kb"
      @kb_model = @module_project.kb_model
      @kb_input = Kb::KbInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    kb_model_id: @kb_model.id).first_or_create
      @project_list = []

    elsif @module_project.pemodule.alias == "skb"
      @skb_model = @module_project.skb_model
      @skb_input = Skb::SkbInput.where(module_project_id: @module_project.id,
                                       organization_id: @project_organization.id,
                                       skb_model_id: @skb_model.id).first_or_create
      @project_list = []

    elsif @module_project.pemodule.alias == "ge"
      @ge_model = @module_project.ge_model
      @ge_input = Ge::GeInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    ge_model_id: @ge_model.id).first_or_create
      @ge_input_values = @ge_input.values
      @ge_factors = @ge_model.ge_factors
      @all_factors_values_hash = Hash.new #hash that contained factor values

      @ge_factors_values = @ge_model.ge_factor_values
      if @ge_factors_values.length > 0
        @ge_factors_groups = @ge_factors_values.group_by(&:factor_scale_prod) #@ge_factors_values.group_by { |f| f.factor_scale_prod }
        @ge_scale_factors = @ge_factors_groups['S']
        @ge_prod_factors = @ge_factors_groups['P']
        @ge_conversion_factors = @ge_factors_groups['C']

        #@ge_factor_values_per_type = @ge_factors_values.group_by(&:factor_type)

        @ge_scale_factors_per_type =  @ge_scale_factors.nil? ? {} : @ge_scale_factors.group_by(&:factor_type)
        @ge_prod_factors_per_type = @ge_prod_factors.nil? ? {} : @ge_prod_factors.group_by(&:factor_type)
        @ge_conversion_factors_per_type = @ge_conversion_factors.nil? ? {} : @ge_conversion_factors.group_by(&:factor_type)

        @all_factors_values_hash["S"] = Hash.new
        @all_factors_values_hash["P"] = Hash.new
        @all_factors_values_hash["C"] = Hash.new

        @ge_type_factors_per_scale_prod = Hash.new
        @ge_type_factors_per_scale_prod["S"] = @ge_scale_factors_per_type
        @ge_type_factors_per_scale_prod["P"] = @ge_prod_factors_per_type
        @ge_type_factors_per_scale_prod["C"] = @ge_conversion_factors_per_type

        @ge_type_factors_per_scale_prod.each do |scale_prod, factors_per_type|
          factors_per_type.each do |type, factor_values_array|
            @type_factors_values_hash = Hash.new
            @ge_model.ge_factors.where(scale_prod: "#{scale_prod}").each do |f|
              if f.factor_type == type
                factors_array = Array.new
                factor_values_array.each do |factor_value|
                  if factor_value.factor_alias == f.alias
                    factors_array << factor_value  #[factor_value.value_text, factor_value.id]
                  end
                end
                @type_factors_values_hash["#{f.alias}"] = factors_array
              end
            end
            @all_factors_values_hash["#{scale_prod}"]["#{type}"] = @type_factors_values_hash
          end
        end
      end

    elsif @module_project.pemodule.alias == "operation"
      @operation_model = @module_project.operation_model
    elsif @module_project.pemodule.alias == "guw"

      #if @module_project.guw_model.nil?
      #  @guw_model = Guw::GuwModel.first
      #else
      @guw_model = @module_project.guw_model
      # @guw_model = GuwModel.includes(:guw_unit_of_works, :organization_technology, :guw_type, :guw_complexity).find(@module_project)
      #end
      # Uitilisation de la vue ModuleProjectGuwUnitOfWorkGroup
      @unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(organization_id: @current_organization.id,
                                                           project_id: @project.id,
                                                           module_project_id: @module_project.id,
                                                           pbs_project_element_id: @pbs_project_element.id).all

      # @unit_of_work_groups = ModuleProjectGuwUnitOfWorkGroup.where(organization_id: @current_organization.id, project_id: @project.id,
      #                                                              module_project_id: @module_project.id, pbs_project_element_id: @pbs_project_element.id).all

    elsif @module_project.pemodule.alias == "staffing"
      @staffing_model = @module_project.staffing_model
      trapeze_default_values = @staffing_model.trapeze_default_values
      @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @pbs_project_element.id).first
      if @staffing_custom_data.nil?
        @staffing_custom_data = Staffing::StaffingCustomDatum.create(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @pbs_project_element.id,
                                                                     staffing_method: 'trapeze',
                                                                     period_unit: 'week', global_effort_type: 'probable', mc_donell_coef: 6, puissance_n: 0.33,
                                                                     trapeze_default_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] },
                                                                     trapeze_parameter_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] } )
      end

    elsif @module_project.pemodule.alias == "effort_breakdown"
      @wbs_activity = @module_project.wbs_activity
      @project_wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity.wbs_activity_elements.arrange(:order => :position))

      @wbs_activity_ratio = @module_project.get_wbs_activity_ratio(@pbs_project_element.id)
      if @wbs_activity_ratio.nil?
        unless params[:ratio].nil?
          @wbs_activity_ratio = WbsActivityRatio.find(params[:ratio])
        end
      end

      unless @wbs_activity_ratio.nil?
        ratio_elements = @wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
        @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

        # Module_project Ratio elements
        @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@wbs_activity_ratio, @pbs_project_element)

        # Module Project Ratio Variables
        @module_project_ratio_variables = @module_project.get_module_project_ratio_variables(@wbs_activity_ratio, @pbs_project_element)
      end
    else
      # other
    end
  end


  def dashboard_none_displayed(none_displayed_module_project)

    @project_organization = @project.organization
    @current_organization = @project_organization

    if @project.nil?
      flash[:error] = I18n.t(:project_not_found)
      redirect_to organization_estimations_path(@project_organization) and return
    end

    # return if user doesn't have the rigth to consult the estimation
    if !can_show_estimation?(@project)
      redirect_to(organization_estimations_path(@current_organization), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
    end

    if @current_organization.is_image_organization == true
      redirect_to(root_url, flash: { error: "Vous ne pouvez pas accéder à une organization image"}) and return
    end

    set_page_title I18n.t(:spec_estimations, parameter: @project_organization)

    @user = current_user
    @pemodules ||= Pemodule.all
    @module_project = none_displayed_module_project #current_module_project
    @show_hidden = 'true'

    status_comment_link = ""
    if can_alter_estimation?(@project) && ( can?(:alter_estimation_status, @project) || can?(:alter_project_status_comment, @project))
      status_comment_link = "#{main_app.add_comment_on_status_change_path(:project_id => @project.id)}"
    end
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@project_organization.id}", @project_organization.to_s => organization_estimations_path(@project_organization), "#{@project}" => "#{main_app.edit_project_path(@project)}", "<span class='badge' style='background-color: #{@project.status_background_color}'> #{@project.status_name}" => status_comment_link

    @module_projects = @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?

    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    if @module_project.pemodule.alias == "expert_judgement"
      if none_displayed_module_project.expert_judgement_instance.nil?
        @expert_judgement_instance = ExpertJudgement::Instance.first
      else
        @expert_judgement_instance = none_displayed_module_project.expert_judgement_instance
      end

      array_attributes = Array.new

      if @expert_judgement_instance.enabled_size?
        array_attributes << "retained_size"
      end

      if @expert_judgement_instance.enabled_effort?
        array_attributes << "effort"
      end

      if @expert_judgement_instance.enabled_cost?
        array_attributes << "cost"
      end

      #@expert_judgement_attributes = PeAttribute.where(alias: array_attributes)
      expert_judgment_module = Pemodule.where(alias: "expert_judgement").first
      if expert_judgment_module
        @expert_judgement_attributes = expert_judgment_module.pe_attributes.where(alias: array_attributes)
      else
        @expert_judgement_attributes = PeAttribute.where(alias: array_attributes)
      end

      array_attributes.each do |a|
        ExpertJudgement::InstanceEstimate.where( pe_attribute_id: PeAttribute.find_by_alias(a).id,
                                                 expert_judgement_instance_id: @expert_judgement_instance.id.to_i,
                                                 module_project_id: none_displayed_module_project.id,
                                                 pbs_project_element_id: current_component.id).first_or_create!
      end

    elsif @module_project.pemodule.alias == "kb"
      @kb_model = none_displayed_module_project.kb_model
      @kb_input = Kb::KbInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    kb_model_id: @kb_model.id).first_or_create
      @project_list = []

    elsif @module_project.pemodule.alias == "skb"
      @skb_model = none_displayed_module_project.skb_model
      @skb_input = Skb::SkbInput.where(module_project_id: @module_project.id,
                                       organization_id: @project_organization.id,
                                       skb_model_id: @skb_model.id).first_or_create
      @project_list = []

    elsif @module_project.pemodule.alias == "ge"
      @ge_model = none_displayed_module_project.ge_model
      @ge_input = Ge::GeInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    ge_model_id: @ge_model.id).first_or_create
      @ge_input_values = @ge_input.values
      @ge_factors = @ge_model.ge_factors
      @all_factors_values_hash = Hash.new #hash that contained factor values

      @ge_factors_values = @ge_model.ge_factor_values
      if @ge_factors_values.length > 0
        @ge_factors_groups = @ge_factors_values.group_by(&:factor_scale_prod) #@ge_factors_values.group_by { |f| f.factor_scale_prod }
        @ge_scale_factors = @ge_factors_groups['S']
        @ge_prod_factors = @ge_factors_groups['P']
        @ge_conversion_factors = @ge_factors_groups['C']

        #@ge_factor_values_per_type = @ge_factors_values.group_by(&:factor_type)

        @ge_scale_factors_per_type =  @ge_scale_factors.nil? ? {} : @ge_scale_factors.group_by(&:factor_type)
        @ge_prod_factors_per_type = @ge_prod_factors.nil? ? {} : @ge_prod_factors.group_by(&:factor_type)
        @ge_conversion_factors_per_type = @ge_conversion_factors.nil? ? {} : @ge_conversion_factors.group_by(&:factor_type)

        @all_factors_values_hash["S"] = Hash.new
        @all_factors_values_hash["P"] = Hash.new
        @all_factors_values_hash["C"] = Hash.new

        @ge_type_factors_per_scale_prod = Hash.new
        @ge_type_factors_per_scale_prod["S"] = @ge_scale_factors_per_type
        @ge_type_factors_per_scale_prod["P"] = @ge_prod_factors_per_type
        @ge_type_factors_per_scale_prod["C"] = @ge_conversion_factors_per_type

        @ge_type_factors_per_scale_prod.each do |scale_prod, factors_per_type|
          factors_per_type.each do |type, factor_values_array|
            @type_factors_values_hash = Hash.new
            @ge_model.ge_factors.where(scale_prod: "#{scale_prod}").each do |f|
              if f.factor_type == type
                factors_array = Array.new
                factor_values_array.each do |factor_value|
                  if factor_value.factor_alias == f.alias
                    factors_array << factor_value  #[factor_value.value_text, factor_value.id]
                  end
                end
                @type_factors_values_hash["#{f.alias}"] = factors_array
              end
            end
            @all_factors_values_hash["#{scale_prod}"]["#{type}"] = @type_factors_values_hash
          end
        end
      end

    elsif @module_project.pemodule.alias == "operation"
      @operation_model = none_displayed_module_project.operation_model
    elsif @module_project.pemodule.alias == "guw"
      @guw_model = none_displayed_module_project.guw_model
      @unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id, module_project_id: none_displayed_module_project.id).all

    elsif @module_project.pemodule.alias == "staffing"
      @staffing_model = none_displayed_module_project.staffing_model
      trapeze_default_values = @staffing_model.trapeze_default_values
      @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: current_component.id).first
      if @staffing_custom_data.nil?
        @staffing_custom_data = Staffing::StaffingCustomDatum.create(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: current_component.id,
                                                                     staffing_method: 'trapeze',
                                                                     period_unit: 'week', global_effort_type: 'probable', mc_donell_coef: 6, puissance_n: 0.33,
                                                                     trapeze_default_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] },
                                                                     trapeze_parameter_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] } )
      end

    elsif @module_project.pemodule.alias == "effort_breakdown"
      @pbs_project_element = current_component
      @wbs_activity = none_displayed_module_project.wbs_activity
      @project_wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity.wbs_activity_elements.arrange(:order => :position))

      @wbs_activity_ratio = none_displayed_module_project.get_wbs_activity_ratio(current_component.id)
      if @wbs_activity_ratio.nil?
        unless params[:ratio].nil?
          @wbs_activity_ratio = WbsActivityRatio.find(params[:ratio])
        end
      end

      unless @wbs_activity_ratio.nil?
        ratio_elements = @wbs_activity_ratio.wbs_activity_ratio_elements.joins(:wbs_activity_element).arrange(order: 'position')
        @wbs_activity_ratio_elements = WbsActivityRatioElement.sort_by_ancestry(ratio_elements)

        # Module_project Ratio elements
        @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@wbs_activity_ratio, @pbs_project_element)

        # Module Project Ratio Variables
        @module_project_ratio_variables = @module_project.get_module_project_ratio_variables(@wbs_activity_ratio, @pbs_project_element)
      end

      { wbs_activity_ratio_elements: @wbs_activity_ratio_elements,
        module_project_ratio_elements: @module_project_ratio_elements,
        module_project_ratio_variables: @module_project_ratio_variables,
        project_wbs_activity_elements: @project_wbs_activity_elements
      }
    else
      # others
    end
  end


  def index
    #No authorize required since everyone can access the list (permission will be managed project per project)
    set_page_title I18n.t(:estimation_setting)

    # The current user can only see projects of its organizations
    @projects = current_user.organizations.map{|i| i.projects }.flatten.reject { |j| !j.is_childless? }  #Then only projects on which the current is authorise to see will be displayed
  end

  #Allow to user to change the estimation data when creating from template
  def change_new_estimation_data
    @project_template = Project.find(params[:template_id])
    @new_project = Project.new

    @project_areas = @current_organization.project_areas
    @platform_categories = @current_organization.platform_categories
    @acquisition_categories = @current_organization.acquisition_categories
    @project_categories = @current_organization.project_categories
    @providers = @current_organization.providers
  end

  def new
    # To create an estimation model, use should have a :manage_estimation_models authorization
    @is_model = params[:is_model]
    if @is_model
      authorize! :manage_estimation_models, Project
      #set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@current_organization, anchor: "tabs-estimation-models"), I18n.t('new_project_from') => ""
      set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@current_organization, anchor: "tabs-estimation-models"), I18n.t('create_new_estimation_model') => ""
      set_page_title I18n.t(:new_estimation_model)
    else
      authorize! :create_project_from_scratch, Project
      set_breadcrumbs I18n.t(:estimate) => organization_estimations_path(@current_organization), I18n.t('new_project') => ""
      set_page_title I18n.t(:new_estimation_model)
    end

    @organization = Organization.find(params[:organization_id])
    @project_areas = @organization.project_areas
    @platform_categories = @organization.platform_categories
    @acquisition_categories = @organization.acquisition_categories
    @project_categories = @organization.project_categories
    @providers = @organization.providers
  end

  #Create a new project
  def create
    @is_model = params[:project][:is_model]
    if @is_model == "true"
      authorize! :manage_estimation_models, Project
      set_page_title I18n.t(:new_estimation_model)
      set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@current_organization, anchor: "tabs-estimation-models")
    else
      authorize! :create_project_from_scratch, Project
      set_page_title I18n.t(:new_project)
      set_breadcrumbs I18n.t(:estimate) => organization_estimations_path(@current_organization)
    end

    @project_title = params[:project][:title]
    @project = Project.new(params[:project])

    if @project.new_record?
      @project.is_model = @is_model

      # On met à jour ce champs pour la gestion des Trigger
      @project.is_new_created_record = true
    end

    if @is_model == true
      if params[:project][:application_ids].present?
        @project.application_ids = params[:project][:application_ids]
      else
        @project.application_name = params[:project][:application_name]
      end
    else
      if params[:project][:application_id].present?
        @project.application_id = params[:project][:application_id]
      else
        @project.application_name = params[:project][:application_name]
      end
    end

    @project.creator_id = current_user.id
    @project.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:estimation_created_by, username: current_user.name)} \r\n"
    @organization = Organization.find(params[:project][:organization_id])

    @project_areas = @organization.project_areas
    @platform_categories = @organization.platform_categories
    @acquisition_categories = @organization.platform_categories
    @project_categories = @organization.project_categories
    @providers = @organization.providers

    estimation_owner = User.find_by_initials(AdminSetting.find_by_key("Estimation Owner").value)

    #Give full control to project creator
    defaut_psl = AdminSetting.where(key: "Secure Level Creator").first_or_create!(key: "Secure Level Creator", value: "*ALL")
    full_control_security_level = ProjectSecurityLevel.where(name: defaut_psl.value, organization_id: @organization.id).first_or_create(name: defaut_psl.value,
                                                                                                                                        organization_id: @organization.id,
                                                                                                                                        description: "Authorization to Read + Comment + Modify + Define + can change users's permissions on the project")

    manage_project_permission = Permission.where(alias: "manage", object_associated: "Project").first_or_create(alias: "manage",
                                                                                                                object_associated: "Project",
                                                                                                                name: "Manage Projet",
                                                                                                                uuid: UUIDTools::UUID.random_create.to_s)
    # Add the "manage project" authorization to the "FullControl" security level
    if manage_project_permission
      if !manage_project_permission.in?(full_control_security_level.permission_ids)
        full_control_security_level.update_attribute('permission_ids', manage_project_permission.id)
      end
    end

    #For user
    current_user_ps = @project.project_securities.build
    # if params[:project][:creator_id].blank?
      current_user_ps.user_id = estimation_owner.id
    # else
      # current_user_ps.user_id = params[:project][:creator_id].to_i
    # end
    current_user_ps.project_security_level = full_control_security_level
    current_user_ps.is_model_permission = false
    current_user_ps.is_estimation_permission = true
    current_user_ps.save

    #For group
    defaut_group = AdminSetting.where(key: "Groupe using estimation").first_or_create!(value: "*USER")
    defaut_group_ps = @project.project_securities.build
    defaut_group_ps.group_id = Group.where(name: defaut_group.value,
                                           organization_id: @organization.id).first_or_create(description: "Groupe créé par défaut dans l'organisation pour la gestion des administrateurs").id
    defaut_group_ps.project_security_level = full_control_security_level
    defaut_group_ps.is_model_permission = false
    defaut_group_ps.is_estimation_permission = true
    defaut_group_ps.save

    if @is_model == "true"
      new_current_user_ps = @project.project_securities.build
      # if params[:project][:creator_id].blank?
        new_current_user_ps.user_id = estimation_owner.id
      # else
      #   new_current_user_ps.user_id = params[:project][:creator_id].to_i
      # end
      new_current_user_ps.project_security_level = full_control_security_level
      new_current_user_ps.is_model_permission = true
      new_current_user_ps.is_estimation_permission = false
      new_current_user_ps.save

      new_defaut_group_ps = @project.project_securities.build
      new_defaut_group_ps.group_id = Group.where(name: defaut_group.value, organization_id: @organization.id).first_or_create(description: "Groupe créé par défaut dans l'organisation pour la gestion des administrateurs").id
      new_defaut_group_ps.project_security_level = full_control_security_level
      new_defaut_group_ps.is_model_permission = true
      new_defaut_group_ps.is_estimation_permission = false
      new_defaut_group_ps.save
    end

    @project.is_historicized = false

    if @project.start_date.nil? or @project.start_date.blank?
      @project.start_date = Time.now.to_date
    end

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
          pbs_project_element = pe_wbs_project_product.pbs_project_elements.build(organization_id: @organization.id,
                                                                                  :name => "#{@product_name.blank? ? @project_title : @product_name}",
                                                                                  :is_root => true, :start_date => Time.now, :position => 0,
                                                                                  :work_element_type_id => default_work_element_type.id,
                                                                                  :organization_technology_id => @organization.organization_technologies.first_or_create(name: "Java", alias: "Java", organization_id: @organization.id, productivity_ratio: 1, state: "draft").id)
          pbs_project_element.add_to_transaction
          pbs_project_element.save!
          pe_wbs_project_product.save!

          #Get the initialization module from ApplicationController
          #When creating project, we need to create module_projects for created initialization
          unless @initialization_module.nil?
            # Create the project's Initialization module
            cap_module_project = ModuleProject.new(:project_id => @project.id, :organization_id => @organization.id, :pemodule_id => @initialization_module.id, :position_x => 0, :position_y => 0, show_results_view: true)
            # Create the Initialization module view
            ###cap_module_project.build_view(name: "#{cap_module_project.to_s} - Module project View", pemodule_id: cap_module_project.pemodule_id, organization_id: @project.organization_id)

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
            end
          end

          # On remet à jour ce champs pour la gestion des Trigger
          @project.update_attribute(:is_new_created_record, false)

          # Update project's organization estimations counter
          unless @is_model == "true" || @current_user.super_admin == true
            unless @organization.estimations_counter.nil? || @organization.estimations_counter == 0
              @organization.estimations_counter -= 1
              @organization.save
            end
          end

          redirect_to redirect_apply(edit_project_path(@project)), notice: "#{I18n.t(:notice_project_successful_created)}"
        else
          flash[:error] = "#{I18n.t(:error_project_creation_failed)}"
          params[:is_model] ||= params[:project][:is_model]
          render(action: :new, is_model: params[:project][:is_model])
        end

        #raise ActiveRecord::Rollback
      rescue ActiveRecord::UnknownAttributeError, ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid => error
        p error
        flash[:error] = "#{I18n.t (:error_project_creation_failed)} #{@project.errors.full_messages.to_sentence}"
        redirect_to (@project.is_model ? organization_setting_path(@organization, anchor: "tabs-estimation-models") : organization_estimations_path(@organization))
      end
    end
  end


  #Edit a selected project
  def edit
    set_page_title I18n.t(:edit_estimation)

    @project = Project.find(params[:id])
    @organization = @project.organization

    @project_areas = @organization.project_areas
    @platform_categories = @organization.platform_categories
    @acquisition_categories = @organization.acquisition_categories
    @project_categories = @organization.project_categories
    @providers = @organization.providers

    #generate_dashboard

    #set_breadcrumbs  I18n.t(:estimate) => projects_path, @project => edit_project_path(@project)
    if @project.is_model
      set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@organization, anchor: "tabs-estimation-models"), @project => edit_project_path(@project), "<span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)

      if cannot?(:manage_estimation_models, Project)    # No write access to project
        unless can_show_estimation?(@project)
        #   redirect_to(:action => 'show') and return
        # else
          #redirect_to(organization_setting_path(@organization, anchor: "tabs-estimation-models"), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
          redirect_to :back, flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)} and return
        end
      end

    else

      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)

      # if cannot?(:edit_project, @project)    # No write access to project
      #   redirect_to(:action => 'show') and return
      # end

      # We need to verify user's groups rights on estimation according to the current estimation status
      if !can_modify_estimation?(@project)
        unless can_show_estimation?(@project)
          redirect_to(organization_estimations_path(@organization), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
        end
      end
    end

    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
    #@pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @guw_module = Pemodule.where(alias: "guw").first
    @kb_module = Pemodule.where(alias: "kb").first
    @skb_module = Pemodule.where(alias: "skb").first
    @ge_module = Pemodule.where(alias: "ge").first
    @operation_module = Pemodule.where(alias: "operation").first
    @staffing_module = Pemodule.where(alias: "staffing").first
    @ej_module = Pemodule.where(alias: "expert_judgement").first
    @ebd_module = Pemodule.where(alias: "effort_breakdown").first

    @guw_modules = @guw_module.nil? ? [] : @project.organization.guw_models.map{|i| [i, "#{i.id},#{@guw_module.id}"] }
    @ge_models = @ge_module.nil? ? [] : @project.organization.ge_models.map{|i| [i, "#{i.id},#{@ge_module.id}"] }
    @operation_models = @operation_module.nil? ? [] : @project.organization.operation_models.map{|i| [i, "#{i.id},#{@operation_module.id}"] }
    @kb_models = @kb_module.nil? ? [] : @project.organization.kb_models.map{|i| [i, "#{i.id},#{@kb_module.id}"] }
    @skb_models = @skb_module.nil? ? [] : @project.organization.skb_models.map{|i| [i, "#{i.id},#{@skb_module.id}"] }
    @staffing_modules = @staffing_module.nil? ? [] : @project.organization.staffing_models.map{|i| [i, "#{i.id},#{@staffing_module.id}"] }
    @ej_modules = @ej_module.nil? ? [] : @project.organization.expert_judgement_instances.map{|i| [i, "#{i.id},#{@ej_module.id}"] }
    @wbs_instances = @ebd_module.nil? ? [] : @project.organization.wbs_activities.map{|i| [i, "#{i.id},#{@ebd_module.id}"] }

    @modules_selected = ([@guw_module, @ge_module, @staffing_module, @ej_module, @ebd_module, @kb_module, @skb_module]).map do |i|
      unless i.nil?
        [i.title, i.id]
      end
    end

    project_root = @project.root
    project_tree = project_root.subtree
    arranged_projects = project_tree.arrange
    array_json_tree = Project.json_tree(arranged_projects)
    @projects_json_tree = Hash[*array_json_tree.flatten]
    @projects_json_tree = @projects_json_tree.to_json
  end

  def update
    set_page_title I18n.t(:edit_estimation)
    @project = Project.find(params[:id])
    @organization = @project.organization
    @project.transaction_id = @project.transaction_id.nil? ? "#{@project.id}_1" : @project.transaction_id.next rescue "#{@project.id}_1"
    estimation_status_has_changed = false
    project_old_estimation_status = @project.estimation_status

    @project_areas = @organization.project_areas
    @platform_categories = @organization.platform_categories
    @acquisition_categories = @organization.platform_categories
    @project_categories = @organization.project_categories
    @providers = @organization.providers

    if @project.is_model
      set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@organization, anchor: "tabs-estimation-models"), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)

      if cannot?(:manage_estimation_models, Project)    # No write access to project
        flash[:warning] = I18n.t(:warning_no_modify_permission_on_project_status)
        if can_show_estimation?(@project)
          redirect_to(:action => 'edit') and return
        else
          redirect_to(organization_setting_path(@organization)) and return
        end
      end

    else
      set_breadcrumbs I18n.t(:estimate) => organization_estimations_path(@organization), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)

      # We need to verify user's groups rights on estimation according to the current estimation status
      if !can_modify_estimation?(@project) && !can_alter_estimation?(@project)
        flash[:warning] = I18n.t(:warning_no_modify_permission_on_project_status)
        if can_show_estimation?(@project)
          redirect_to(:action => 'edit') and return
        else
          redirect_to(organization_estimations_path(@organization)) and return
        end
      end
    end

    if (@project.is_model && can?(:manage_estimation_models, Project)) || (!@project.is_model && (can?(:edit_project, @project) || can_alter_estimation?(@project))) # Have the write access to project

      if @project.is_model == true
        if params[:project][:application_ids].present?
          @project.applications.delete_all
          @project.application_ids = params[:project][:application_ids]
        else
          @project.application_name = params[:project][:application_name]
        end
      else
        begin
          if params[:project][:application_id].present?
            @project.application_id = params[:project][:application_id]
          else
            @project.application_name = params[:project][:application_name]
          end
        rescue
          # ignored
        end
      end

      # remplir le champs allow_export_pdf
      @project.allow_export_pdf = params['allow_export_pdf']
      @project.save

      project_root = @project.root_component
      #if @project.is_model == true
      #  project_root_name = @project.title
      #else
      if @project.application.nil?
        project_root_name = "#{@project.application_name.blank? ? @project.title : @project.application_name}"
      else
        project_root_name = "#{@project.application.name.blank? ? @project.title : @project.application.name}"
      end
      #end
      project_root.update_attribute(:name, project_root_name)

      @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
      @wbs_activity_elements = []
      @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

      # Before modifications for trigger
      # we can update group securities levels on edit or on show with some restrictions
      # if params['is_project_show_view'].nil? || (params['is_project_show_view'] == "true" && !params['group_security_levels'].nil?)
      #   @project.project_securities.delete_all

      #   unless params["group_securities"].nil?
      #     params["group_securities"].each do |psl|
      #       params["group_securities"][psl.first].each do |group|
      #         ProjectSecurity.create(group_id: group.first.to_i,
      #                                project_id: @project.id,
      #                                project_security_level_id: psl.first,
      #                                is_model_permission: false,
      #                                is_estimation_permission: true)
      #       end
      #     end
      #   end
      #
      #   unless params["group_securities_from_model"].nil?
      #     params["group_securities_from_model"].each do |psl|
      #       params["group_securities_from_model"][psl.first].each do |group|
      #         ProjectSecurity.create(group_id: group.first.to_i,
      #                                project_id: @project.id,
      #                                project_security_level_id: psl.first,
      #                                is_model_permission: true,
      #                                is_estimation_permission: false)
      #       end
      #     end
      #   end
      #
      #   unless params["user_securities"].nil?
      #     params["user_securities"].each do |psl|
      #       params["user_securities"][psl.first].each do |user|
      #         ProjectSecurity.create(user_id: user.first.to_i,
      #                                project_id: @project.id,
      #                                project_security_level_id: psl.first,
      #                                is_model_permission: @project.is_model,
      #                                is_estimation_permission: true)
      #       end
      #     end
      #   end
      #
      #   unless params["user_securities_from_model"].nil?
      #     params["user_securities_from_model"].each do |psl|
      #       params["user_securities_from_model"][psl.first].each do |user|
      #         # TODO : vérifier cette boucle
      #         owner_key = AdminSetting.find_by_key("Estimation Owner")
      #         owner = User.where(initials: owner_key.value).first
      #         ProjectSecurity.create(user_id: owner.id.to_i,
      #                                project_id: @project.id,
      #                                project_security_level_id: psl.first,
      #                                is_model_permission: @project.is_model,
      #                                is_estimation_permission: false)
      #       end
      #     end
      #   end
      # end
      # END Before modifications for trigger


      # Après les modifications pour les Trigger
      if params['is_project_show_view'].nil? || (params['is_project_show_view'] == "true" && !params['group_security_levels'].nil?)
        new_project_securities = []
        all_project_securities = @project.project_securities

        # GROUP
        unless params["group_securities"].nil?
          group_securities_a_garder = []
          group_securities_to_add = []
          group_securities_to_destroy = []

          params["group_securities"].each do |psl|
            params["group_securities"][psl.first].each do |group|
              ps = @project.project_securities.where(group_id: group.first.to_i, project_security_level_id: psl.first,
                                                     is_model_permission: false, is_estimation_permission: true).first
              if ps
                group_securities_a_garder << ps
              else
                group_securities_to_add << @project.project_securities.create(group_id: group.first.to_i, project_security_level_id: psl.first,
                                                                              is_model_permission: false, is_estimation_permission: true,
                                                                              originator_id: @current_user.id, event_organization_id: @organization.id)
              end
            end
          end
          # on met à jour les securite des groupes du projet
          new_project_securities << group_securities_a_garder.map(&:id) + group_securities_to_add.map(&:id)
        end

        # GROUP FROM MODEL
        unless params["group_securities_from_model"].nil?
          group_from_model_securities_a_garder = []
          group_from_model_securities_to_add = []

          params["group_securities_from_model"].each do |psl|
            params["group_securities_from_model"][psl.first].each do |group|

              ps = @project.project_securities.where(group_id: group.first.to_i, project_security_level_id: psl.first,
                                                     is_model_permission: true, is_estimation_permission: false).first
              if ps
                group_from_model_securities_a_garder << ps
              else
                group_from_model_securities_to_add << @project.project_securities.create(group_id: group.first.to_i, project_security_level_id: psl.first,
                                                                                        is_model_permission: true, is_estimation_permission: false,
                                                                                        originator_id: @current_user.id, event_organization_id: @organization.id)
              end
            end
          end
          # on met à jour les securite des groupes du projet
          new_project_securities << group_from_model_securities_a_garder.map(&:id) + group_from_model_securities_to_add.map(&:id)
        end


        # USER
        unless params["user_securities"].nil?
          user_securities_a_garder = []
          user_securities_to_add = []
          params["user_securities"].each do |psl|
            params["user_securities"][psl.first].each do |user|
              ps = @project.project_securities.where(user_id: user.first.to_i, project_security_level_id: psl.first,
                                                     is_model_permission: @project.is_model.nil? ? false : @project.is_model, is_estimation_permission: true).first
              if ps
                user_securities_a_garder << ps
              else
                user_securities_to_add << @project.project_securities.create(user_id: user.first.to_i, project_security_level_id: psl.first, is_model_permission: @project.is_model.nil? ? false : @project.is_model, is_estimation_permission: true,
                                                                             originator_id: @current_user.id, event_organization_id: @organization.id)
              end
            end
          end
          # on met à jour les securite des users du project
          new_project_securities << user_securities_a_garder.map(&:id) + user_securities_to_add.map(&:id)
        end

        # USER FROM MODEL
        unless params["user_securities_from_model"].nil?
          user_from_model_securities_a_garder = []
          user_from_model_securities_to_add = []

          params["user_securities_from_model"].each do |psl|
            params["user_securities_from_model"][psl.first].each do |user|
              # TODO : vérifier cette boucle
              owner_key = AdminSetting.find_by_key("Estimation Owner")
              owner = User.where(initials: owner_key.value).first

              ps = @project.project_securities.where(user_id: owner.id.to_i, project_security_level_id: psl.first,
                                                      is_model_permission: @project.is_model.nil? ? false : @project.is_model, is_estimation_permission: false).first
              if ps
                user_from_model_securities_a_garder << ps
              else
                user_from_model_securities_to_add << @project.project_securities.create(user_id: owner.id.to_i, project_security_level_id: psl.first,
                                                                                         is_model_permission: @project.is_model.nil? ? false : @project.is_model, is_estimation_permission: false,
                                                                                         originator_id: @current_user.id, event_organization_id: @organization.id)
              end
            end
          end
          # on met à jour les securite des users du projet cree à partir du model
          new_project_securities << user_from_model_securities_a_garder.map(&:id) + user_from_model_securities_to_add.map(&:id)
        end

        @project.project_security_ids = new_project_securities.flatten.reject{ |e| e.blank? }
        @project.save
      end

      # Get the max X and Y positions of modules
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

      #Get the project Organization before update
      project_organization = @project.organization


      if params[:project].present?
        # Before saving project, update the project comment when the status has changed
        if params[:project][:estimation_status_id]
          new_status_id = params[:project][:estimation_status_id].to_i
          if @project.estimation_status_id != new_status_id
            new_comments = auto_update_status_comment(params[:id], new_status_id)
            new_comments << "#{@project.status_comment} \r\n"
            @project.status_comment = new_comments
            estimation_status_has_changed = true
          end
        end
      end

      if @project.update_attributes(params[:project])
        begin
          #start_date = Date.strptime(params[:project][:start_date], I18n.t('%m/%d/%Y'))
          start_date = Date.strptime(params[:project][:start_date], I18n.t('date.formats.default'))
          @project.start_date = start_date
        rescue
          @project.start_date = Time.now.to_date
        end

        # Initialization Module
        unless @initialization_module.nil?
          # Get the project initialization module_project or create if it doesn't exist
          cap_module_project = @project.module_projects.find_by_pemodule_id(@initialization_module.id)
          if cap_module_project.nil?
            cap_module_project = @project.module_projects.create(:pemodule_id => @initialization_module.id, :position_x => 0, :position_y => 0)
          end

          # Create the project initialization module estimation_values if project organization has changed and not nil
          if project_organization.nil? && !@project.organization.nil?

            #Create the corresponding EstimationValues
            unless @project.organization.attribute_organizations.nil?
              @project.organization.attribute_organizations.each do |am|
                ['input', 'output'].each do |in_out|
                  EstimationValue.create(:pe_attribute_id => am.pe_attribute.id, :organization_id => @organization.id, :module_project_id => cap_module_project.id, :in_out => in_out,
                                         :is_mandatory => am.is_mandatory, :description => am.pe_attribute.description, :display_order => nil,
                                         :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                         :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                         :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                end
              end
            end
            # When project organization exists
          elsif !project_organization.nil?

            # project's organization is deleted and none one is selected
            if @project.organization.nil?
              cap_module_project.estimation_values.delete_all
            end

            # Project's organization has changed
            if !@project.organization.nil? && project_organization != @project.organization
              # Delete all last estimation values for this organization on this project
              cap_module_project.estimation_values.delete_all

              # Create estimation_values for the new selected organization
              @project.organization.attribute_organizations.each do |am|
                ['input', 'output'].each do |in_out|
                  EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                         :organization_id => @organization.id,
                                         :module_project_id => cap_module_project.id,
                                         :in_out => in_out, :is_mandatory => am.is_mandatory,
                                         :description => am.pe_attribute.description, :display_order => nil,
                                         :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                         :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                         :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
                end
              end
            end
          end
        end

        if @project.save
          #Verifier s'il faut creer une nouvelle version lors du changement de statut
          if estimation_status_has_changed == true
            next_status = @project.estimation_status
            if next_status && next_status.create_new_version_when_changing_status == true
              @project.update_attribute(:estimation_status_id, project_old_estimation_status.id)

              # On cree une nouvelle version de l'estimation
              @project.create_new_version_when_changing_status(next_status)
            end
          end
        end

        flash[:notice] = I18n.t(:notice_project_successful_updated)
        if @project.is_model
          redirect_to redirect_apply(edit_project_path(@project, :anchor => session[:anchor]), nil, organization_setting_path(@project.organization, anchor: "tabs-estimation-models")) and return
        else
          redirect_to redirect_apply(edit_project_path(@project, :anchor => session[:anchor]), nil, organization_estimations_path(@project.organization, :anchor => 'tabs-5')) and return
        end
      else
        @guw_module = Pemodule.where(alias: "guw").first
        @kb_module = Pemodule.where(alias: "kb").first
        @skb_module = Pemodule.where(alias: "skb").first
        @ge_module = Pemodule.where(alias: "ge").first
        @operation_module = Pemodule.where(alias: "operation").first
        @staffing_module = Pemodule.where(alias: "staffing").first
        @ej_module = Pemodule.where(alias: "expert_judgement").first
        @ebd_module = Pemodule.where(alias: "effort_breakdown").first

        @guw_modules = @guw_module.nil? ? [] : @project.organization.guw_models.map{|i| [i, "#{i.id},#{@guw_module.id}"] }
        @ge_models = @ge_module.nil? ? [] : @project.organization.ge_models.map{|i| [i, "#{i.id},#{@ge_module.id}"] }
        @operation_models = @operation_module.nil? ? [] : @project.organization.operation_models.map{|i| [i, "#{i.id},#{@operation_module.id}"] }
        @kb_models = @kb_module.nil? ? [] : @project.organization.kb_models.map{|i| [i, "#{i.id},#{@kb_module.id}"] }
        @skb_models = @skb_module.nil? ? [] : @project.organization.skb_models.map{|i| [i, "#{i.id},#{@skb_module.id}"] }
        @staffing_modules = @staffing_module.nil? ? [] : @project.organization.staffing_models.map{|i| [i, "#{i.id},#{@staffing_module.id}"] }
        @ej_modules = @ej_module.nil? ? [] : @project.organization.expert_judgement_instances.map{|i| [i, "#{i.id},#{@ej_module.id}"] }
        @wbs_instances = @ebd_module.nil? ? [] : @project.organization.wbs_activities.map{|i| [i, "#{i.id},#{@ebd_module.id}"] }

        @modules_selected = ([@guw_module, @ge_module, @staffing_module, @ej_module, @ebd_module, @kb_module]).map{|i| [i.title, i.id]}

        render :action => 'edit'
      end
    end
  end

  #copy model project security to all projects based on this model
  def copy_security
    model_project = Project.find(params[:project_id])
    model_project.projects_from_model.each do |project|

      # ProjectSecurity.delete_all("project = ?", project.id)
      project.project_securities.delete_all

      model_project.project_securities.where(is_model_permission: true, is_estimation_permission: false).all.each do |ps|
        ProjectSecurity.create(project_id: project.id,
                               user_id: nil,
                               project_security_level_id: ps.project_security_level_id,
                               group_id: ps.group_id,
                               is_model_permission: false,
                               is_estimation_permission: true)
      end

      model_project.project_securities.where(is_model_permission: true, is_estimation_permission: false, user_id: model_project.creator_id).all.each do |ps|
        owner_user = User.find_by_initials(AdminSetting.find_by_key("Estimation Owner").value.to_s)

        ProjectSecurity.create(project_id: project.id,
                               user_id: owner_user.id,
                               project_security_level_id: ps.project_security_level_id,
                               group_id: ps.group_id,
                               is_model_permission: false,
                               is_estimation_permission: true)
      end

    end

    redirect_to :back
  end

  def show
    @project = Project.find(params[:id])
    @organization = @project.organization

    authorize! :show_project, @project
    set_page_title I18n.t(:estimation)

    #set_breadcrumbs  I18n.t(:estimate) => organization_estimations_path(@organization), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)
    if @project.is_model
      set_breadcrumbs I18n.t(:estimation_models) => organization_setting_path(@organization, anchor: "tabs-estimation-models"), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)
    else
      set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => organization_estimations_path(@organization), "#{@project} <span class='badge' style='background-color: #{@project.status_background_color}'>#{@project.status_name}</span>" => edit_project_path(@project)
    end

    @project_areas = @organization.project_areas
    @platform_categories = @organization.platform_categories
    @acquisition_categories = @organization.acquisition_categories
    @project_categories = @organization.project_categories
    @providers = @organization.providers

    # We need to verify user's groups rights on estimation according to the current estimation status
    if !can_show_estimation?(@project)
      redirect_to(organization_estimations_path(@organization), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
    end

    @pe_wbs_project_product = @project.pe_wbs_projects.products_wbs.first
    #@pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max


    @guw_module = Pemodule.where(alias: "guw").first
    @kb_module = Pemodule.where(alias: "kb").first
    @skb_module = Pemodule.where(alias: "skb").first
    @ge_module = Pemodule.where(alias: "ge").first
    @operation_module = Pemodule.where(alias: "operation").first
    @staffing_module = Pemodule.where(alias: "staffing").first
    @ej_module = Pemodule.where(alias: "expert_judgement").first
    @ebd_module = Pemodule.where(alias: "effort_breakdown").first

    @guw_modules = @guw_module.nil? ? [] : @project.organization.guw_models.map{|i| [i, "#{i.id},#{@guw_module.id}"] }
    @ge_models = @ge_module.nil? ? [] : @project.organization.ge_models.map{|i| [i, "#{i.id},#{@ge_module.id}"] }
    @operation_models = @operation_module.nil? ? [] : @project.organization.operation_models.map{|i| [i, "#{i.id},#{@operation_module.id}"] }
    @kb_models = @project.organization.kb_models.map{|i| [i, "#{i.id},#{@kb_module.id}"] }
    @skb_models = @project.organization.skb_models.map{|i| [i, "#{i.id},#{@skb_module.id}"] }
    @staffing_modules = @staffing_module.nil? ? [] : @project.organization.ge_models.map{|i| [i, "#{i.id},#{@staffing_module.id}"] }
    @ej_modules = @ej_module.nil? ? [] : @project.organization.expert_judgement_instances.map{|i| [i, "#{i.id},#{@ej_module.id}"] }
    @wbs_instances = @ebd_module.nil? ? [] : @project.organization.wbs_activities.map{|i| [i, "#{i.id},#{@ebd_module.id}"] }

    @modules_selected = (Pemodule.all - [@guw_module, @kb_module, @ge_module, @staffing_module, @ej_module, @ebd_module]).map{|i| [i.title,i.id]}

    project_root = @project.root
    project_tree = project_root.subtree
    arranged_projects = project_tree.arrange
    array_json_tree = Project.json_tree(arranged_projects)
    @projects_json_tree = Hash[*array_json_tree.flatten]
    @projects_json_tree = @projects_json_tree.to_json
  end

  def destroy
    @project = Project.find(params[:id])
    authorize! :delete_project, @project

    is_model = @project.is_model

    case params[:commit]
      when I18n.t('delete')
        if params[:yes_confirmation] == 'selected'
          if ((can? :delete_project, @project) || (can? :manage, @project)) && @project.is_childless?
            @project.destroy
            ###current_user.delete_recent_project(@project.id)
            session[:project_id] = current_user.projects.first
            flash[:notice] = I18n.t(:notice_project_successful_deleted, :value => 'Project')
            if !params[:from_tree_history_view].blank? && params['current_showed_project_id'] != params[:id]
              redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history')
            else
              redirect_to (is_model ? organization_setting_path(@current_organization, anchor: "tabs-estimation-models") : organization_estimations_path(@current_organization))
            end
          else
            flash[:warning] = I18n.t(:error_access_denied)
            redirect_to (params[:from_tree_history_view].nil? ?  organization_estimations_path(@organization) : edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'))
          end
        else
          flash[:warning] = I18n.t('warning_need_check_box_confirmation')
          render :template => 'projects/confirm_deletion'
        end
      when I18n.t('cancel')
        redirect_to (is_model ? organization_setting_path(@current_organization, anchor: "tabs-estimation-models") : organization_estimations_path(@current_organization))
      else
          render :template => 'projects/confirm_deletion'
    end
  end


  # Multiple deletion
  def destroy_multiple_project
    if params['project_ids_to_delete']
      puts params['project_ids_to_delete']
      project_ids = params['project_ids_to_delete']
      project_ids.each do |project_id|
        project = Project.find(project_id)
        if project
          if ((can? :delete_project, project) || (can? :manage, project)) && project.is_childless?
            project.destroy
          else
            flash[:warning] = I18n.t(:error_access_denied)
          end
        end
      end

      flash[:notice] = I18n.t(:notice_multiple_project_successful_deleted)
    end
    redirect_to (params[:from_tree_history_view].nil? ?  organization_estimations_path(@current_organization) : edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'))
  end



  #Update the project's organization estimation statuses
  def update_organization_estimation_statuses
    @estimation_statuses = []

    unless params[:project_organization_id].nil? || params[:project_organization_id].blank?
      @organization = Organization.find(params[:project_organization_id])

      if params[:project_id].present?
        @project = Project.find(params[:project_id])
        # Editing project that does not have estimation status
        if @project.estimation_status.nil? || !@organization.estimation_statuses.include?(@project.estimation_status)
          # Note: When estimation's organization changed, the status id won't be valid for the new selected organization
          initial_status = @organization.estimation_statuses.order(:status_number).first_or_create(organization_id: @project.organization_id, status_number: 0, status_alias: 'preliminary', name: 'Préliminaire', status_color: 'F5FFFD')
          @estimation_statuses = [[initial_status.name, initial_status.id]]
        else
          estimation_statuses = @project.estimation_status.to_transition_statuses.map{ |i| [i.name, i.id]}
          estimation_statuses << [@project.estimation_status.name, @project.estimation_status.id]
          @estimation_statuses = estimation_statuses.uniq
        end
      else
        initial_status = @organization.estimation_statuses.order(:status_number)
        @estimation_statuses = [[initial_status.first.name, initial_status.first.id]]
      end
    end
    @estimation_statuses
  end

  def confirm_deletion
    set_page_title I18n.t(:confirm_deletion)

    @project = Project.find(params[:project_id])
    if @project.is_childless?
      authorize! :delete_project, @project

      @from_tree_history_view = params[:from_tree_history_view]
      @current_showed_project_id = params['current_showed_project_id']

      #if @project.has_children? || @project.rejected? || @project.released? || @project.checkpoint?
      if @project.has_children?
        if @from_tree_history_view
          redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'), :flash => {:warning => I18n.t(:warning_project_cannot_be_deleted)}
        else
          flash[:warning] = I18n.t(:warning_project_cannot_be_deleted)
          redirect_to (@project.is_model ? organization_setting_path(@current_organization, anchor: "tabs-estimation-models") : organization_estimations_path(@current_organization))
        end
      end
    else
      redirect_to :back
    end
  end

  # def confirm_deletion_multiple
  #   set_page_title I18n.t(:confirm_deletion)
  #
  #   @projects = Project.where(id: params[:deleted_projects]).all
  #
  #   puts(" ids = #{params[:deleted_projects]}")
  #   @projects = Project.find(params[:project_id])
  #
  # end

  def select_categories
    #No authorize required
    if params[:project_area_selected].is_numeric?
      @project_area = ProjectArea.find(params[:project_area_selected])
    else
      @project_area = ProjectArea.find_by_name(params[:project_area_selected])
    end

    @project_areas = ProjectArea.all
    @platform_categories = PlatformCategory.all
    @acquisition_categories = AcquisitionCategory.all
    @project_categories = ProjectCategory.all
    @providers = Provider.all
  end

  #Load specific security depending of user selected (last tabs on project editing page)
  def load_security_for_selected_user
    #No authorize required
    set_page_title I18n.t(:project_security)
    @user = User.find(params[:user_id])
    @project = Project.find(params[:project_id])
    @prj_scrt = ProjectSecurity.find_by_user_id_and_project_id(@user.id, @project.id)
    if @prj_scrt.nil?
      @prj_scrt = ProjectSecurity.create(:user_id => @user.id, :project_id => @project.id)
    end

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end

  end

  #Load specific security depending of user selected (last tabs on project editing page)
  def load_security_for_selected_group
    #No authorize required
    set_page_title I18n.t(:project_security)
    @group = Group.find(params[:group_id])
    @project = Project.find(params[:project_id])
    @prj_scrt = ProjectSecurity.find_by_group_id_and_project_id(@group.id, @project.id)
    if @prj_scrt.nil?
      @prj_scrt = ProjectSecurity.create(:group_id => @user.id, :project_id => @project.id)
    end

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end

  end

  #Updates the security according to the previous users
  def update_project_security_level
    #TODO check if No authorize is required
    set_page_title I18n.t(:project_security)
    @user = User.find(params[:user_id].to_i)
    @prj_scrt = ProjectSecurity.find_by_user_id_and_project_id(@user.id, @project.id)
    @prj_scrt.update_attribute('project_security_level_id', params[:project_security_level])

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end
  end

  #Updates the security according to the previous users
  def update_project_security_level_group
    #TODO check if No authorize is required
    set_page_title I18n.t(:project_security)
    @group = Group.find(params[:group_id].to_i)
    @prj_scrt = ProjectSecurity.find_by_group_id_and_project_id(@group.id, @project.id)
    @prj_scrt.update_attribute('project_security_level_id', params[:project_security_level])

    respond_to do |format|
      format.js { render :partial => 'projects/run_estimation' }
    end
  end

  #Allow o add or append a pemodule to a estimation process
  def append_pemodule
    @project = Project.find(params[:project_id])
    @organization = @project.organization
    @pemodule = Pemodule.find(params[:module_selected].split(',').last.to_i)

    if @project.is_model
      authorize! :manage_estimation_models, Project
    else
      authorize! :alter_estimation_plan, @project
    end

    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    if params[:pbs_project_element_id] && params[:pbs_project_element_id] != ''
      @pbs_project_element = PbsProjectElement.find(params[:pbs_project_element_id])
    else
      @pbs_project_element = @project.root_component
    end

    unless @pemodule.nil? || @project.nil?
      @array_modules = Pemodule.all
      @pemodules ||= Pemodule.all

      #Max pos or 1
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max

      # Get the module_project creation order : for this, we have to count the number of MP with same pemodule in this project
      mp_creation_order = @project.module_projects.where(pemodule_id: @pemodule.id).all.map(&:creation_order).max

      #When adding a module in the "timeline", it creates an entry in the table ModuleProject for the current project, at position 2 (the one being reserved for the input module).
      my_module_project = ModuleProject.new(:project_id => @project.id, :organization_id => @organization.id, :pemodule_id => @pemodule.id,
                                            :position_y => 1, :position_x => @module_positions_x.to_i + 1,
                                            :top_position => 100, :left_position => 600, :creation_order => mp_creation_order.to_i+1)
      my_module_project.save

      #si le module est un module generic on l'associe le module project
      if @pemodule.alias == "guw"
        my_module_project.guw_model_id = params[:module_selected].split(',').first
      elsif @pemodule.alias == "kb"
        kb_model_id = params[:module_selected].split(',').first.to_i
        my_module_project.kb_model_id = kb_model_id
        Kb::KbInput.create( organization_id: @current_organization.id,
                            module_project_id: my_module_project.id,
                            kb_model_id: kb_model_id)
      elsif @pemodule.alias == "skb"
        skb_model_id = params[:module_selected].split(',').first.to_i
        my_module_project.skb_model_id = skb_model_id
        Skb::SkbInput.create( organization_id: @current_organization.id,
                              module_project_id: my_module_project.id,
                              skb_model_id: skb_model_id)
      elsif @pemodule.alias == "ge"
        my_module_project.ge_model_id = params[:module_selected].split(',').first

      elsif @pemodule.alias == "operation"
        my_module_project.operation_model_id = params[:module_selected].split(',').first

      elsif @pemodule.alias == "staffing"
        staffing_model_id = params[:module_selected].split(',').first.to_i
        my_module_project.staffing_model_id = staffing_model_id
        staffing_model = Staffing::StaffingModel.find(staffing_model_id)
        #Then create an staffing_custom_data object for current module_project
        Staffing::StaffingCustomDatum.create( staffing_model_id: staffing_model_id,
                                              module_project_id: my_module_project.id,
                                              pbs_project_element_id: @pbs_project_element.id,
                                              staffing_method: 'trapeze',
                                              period_unit: 'week',
                                              global_effort_type: 'probable',
                                              mc_donell_coef: 6,
                                              puissance_n: 0.33,
                                              trapeze_parameter_values: staffing_model.trapeze_default_values)

      elsif @pemodule.alias == "effort_breakdown"
        wbs_id = params[:module_selected].split(',').first.to_i
        my_module_project.wbs_activity_id = wbs_id

        my_module_project.wbs_activity.wbs_activity_ratios.each do |ratio|
          ratio_wai = WbsActivityInput.new(module_project_id: my_module_project.id,
                                     wbs_activity_id: wbs_id, wbs_activity_ratio_id: ratio.id,
                                     pbs_project_element_id: @pbs_project_element.id)
          ratio_wai.save
        end


        my_module_project.wbs_activity_inputs.first

        #create module_project ratio elements
        my_module_project.wbs_activity.wbs_activity_ratios.each do |ratio|

          # create the module_project_ratio_variable
          ratio.wbs_activity_ratio_variables.each do |ratio_variable|
            mp_ratio_variable = ModuleProjectRatioVariable.new(pbs_project_element_id: @pbs_project_element.id, module_project_id: my_module_project.id,
                                                               organization_id: @organization.id, wbs_activity_id: my_module_project.wbs_activity_id,
                                                               wbs_activity_ratio_id: ratio.id, wbs_activity_ratio_variable_id: ratio_variable.id,
                                                               name: ratio_variable.name, description: ratio_variable.description,
                                                               percentage_of_input: ratio_variable.percentage_of_input, is_modifiable: ratio_variable.is_modifiable,
                                                               is_used_in_ratio_calculation: ratio_variable.is_used_in_ratio_calculation)
            mp_ratio_variable.save
          end


          # create the module_project_ratio_elements
          ratio.wbs_activity_ratio_elements.each do |ratio_element|
            mp_ratio_element = ModuleProjectRatioElement.new(organization_id: @organization.id,
                                                             wbs_activity_id: my_module_project.wbs_activity_id,
                                                             pbs_project_element_id: @pbs_project_element.id,
                                                             module_project_id: my_module_project.id,
                                                             wbs_activity_ratio_id: ratio.id,
                                                             wbs_activity_ratio_element_id: ratio_element.id,
                                                             wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                                             multiple_references: ratio_element.multiple_references, name: ratio_element.wbs_activity_element.name,
                                                             description: ratio_element.wbs_activity_element.description, selected: true, is_optional: ratio_element.is_optional,
                                                             ratio_value: ratio_element.ratio_value, position: ratio_element.wbs_activity_element.position)
            mp_ratio_element.save
          end
          #Update module_project_ratio_element ancestry
          #current_ratio_mp_ratio_elements = my_module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio.id, pbs_project_element_id: @pbs_project_element.id)
          current_ratio_mp_ratio_elements = my_module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio.id)
          my_module_project.wbs_activity.wbs_activity_elements.each do |activity_elt|
            activity_elt_ancestor_ids = activity_elt.ancestor_ids
            unless activity_elt.is_root?
              new_ancestor_ids_list = []
              activity_elt_ancestor_ids.each do |ancestor_id|
                ancestor = current_ratio_mp_ratio_elements.where(wbs_activity_element_id: ancestor_id).first
                unless ancestor.nil?
                  new_ancestor_ids_list.push(ancestor.id)
                end
              end
              new_ancestry = new_ancestor_ids_list.join('/')
              mp_ratio_elements = current_ratio_mp_ratio_elements.where(wbs_activity_element_id: activity_elt.id)
              unless mp_ratio_elements.nil?
                mp_ratio_elements.update_all(ancestry: new_ancestry)
              end
            end
          end
        end

      elsif @pemodule.alias == "expert_judgement"
        eji_id = params[:module_selected].split(',').first
        my_module_project.expert_judgement_instance_id = eji_id.to_i
      end

      my_module_project.save


      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max

      if @pemodule.alias.in?(["guw", "operation"])
        #guw_model = Guw::GuwModel.find(my_module_project.guw_model_id)
        #guw_outputs = guw_model.guw_outputs

        all_attribute_modules = my_module_project.pemodule.attribute_modules

        case @pemodule.alias
          when "guw"
            attribute_modules = all_attribute_modules.where(guw_model_id: my_module_project.guw_model_id)
          when "operation"
            attribute_modules = all_attribute_modules.where(operation_model_id: my_module_project.operation_model_id)
          else
            attribute_modules = all_attribute_modules
        end

        #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
        attribute_modules.each do |am|

          unless am.pe_attribute.nil?
            if am.in_out == 'both'
              ['input', 'output'].each do |in_out|
                EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                       :organization_id => @organization.id,
                                       :module_project_id => my_module_project.id,
                                       :in_out => in_out,
                                       :is_mandatory => am.is_mandatory,
                                       :description => am.description,
                                       :display_order => am.display_order,
                                       :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                       :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                       :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                       :custom_attribute => am.custom_attribute,
                                       :project_value => am.project_value)

              end
            elsif am.in_out != nil
              EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                     :organization_id => @organization.id,
                                     :module_project_id => my_module_project.id,
                                     :in_out => am.in_out,
                                     :is_mandatory => am.is_mandatory,
                                     :display_order => am.display_order,
                                     :description => am.description,
                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                     :custom_attribute => am.custom_attribute,
                                     :project_value => am.project_value)
            end
          end
        end

      else
        #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
        my_module_project.pemodule.attribute_modules.each do |am|
          unless am.pe_attribute.nil?

            if am.in_out == 'both'
              ['input', 'output'].each do |in_out|
                EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                       :organization_id => @organization.id,
                                       :module_project_id => my_module_project.id,
                                       :in_out => in_out,
                                       :is_mandatory => am.is_mandatory,
                                       :description => am.description,
                                       :display_order => am.display_order,
                                       :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                       :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                       :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                       :custom_attribute => am.custom_attribute,
                                       :project_value => am.project_value)
              end
            else
              EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                     :organization_id => @organization.id,
                                     :module_project_id => my_module_project.id,
                                     :in_out => am.in_out,
                                     :is_mandatory => am.is_mandatory,
                                     :display_order => am.display_order,
                                     :description => am.description,
                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                     :custom_attribute => am.custom_attribute,
                                     :project_value => am.project_value)
            end
          end
        end
      end

      #Link initialization module to other modules
      unless @initialization_module.nil?
        my_module_project.update_attribute('associated_module_project_ids', @initialization_module_project.id) unless @initialization_module_project.nil?
      end

      #======
      #Select the default view for module_project
      default_view = View.where("organization_id = ? AND pemodule_id = ? AND is_default_view = ?",  @project.organization_id, @pemodule.id, true).first
      #Then copy the default view widgets in the new created view
      unless default_view.nil?
        new_copied_view = View.new(name: "#{@project} - #{my_module_project} view", description: "", pemodule_id: my_module_project.pemodule_id, organization_id: @project.organization_id, initial_view_id: default_view.id)
        if new_copied_view.save
          #Then copy the widgets of the dafult view
          default_view.views_widgets.each do |view_widget|
            widget_est_val = view_widget.estimation_value
            in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
            estimation_value = my_module_project.estimation_values.where('pe_attribute_id = ? AND in_out=?', view_widget.estimation_value.pe_attribute_id, in_out).last
            estimation_value_id = estimation_value.nil? ? nil : estimation_value.id
            widget_copy = ViewsWidget.new(view_id: new_copied_view.id, module_project_id: my_module_project.id,
                                          estimation_value_id: estimation_value_id,
                                          name: view_widget.name, show_name: view_widget.show_name,
                                          show_tjm: view_widget.show_tjm,
                                          equation: view_widget.equation,
                                          comment: view_widget.comment,
                                          is_kpi_widget: view_widget.is_kpi_widget,
                                          kpi_unit: view_widget.kpi_unit,
                                          icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max,
                                          width: view_widget.width, height: view_widget.height, widget_type: view_widget.widget_type,
                                          position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)
            #Save and copy project_fields
            if widget_copy.save
              unless view_widget.project_fields.empty?
                project_field = view_widget.project_fields.last

                #Get project_field value
                @value = 0
                if widget_copy.estimation_value.module_project.pemodule.alias == "effort_breakdown"
                  begin
                    @value = widget_copy.estimation_value.string_data_probable[current_component.id][widget_copy.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                  rescue
                    begin
                      @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                    rescue
                      @value = 0
                    end
                  end
                else
                  @value = widget_copy.estimation_value.string_data_probable[current_component.id]
                end

                #create the new project_field
                ProjectField.create(project_id: @project.id, field_id: project_field.field_id, views_widget_id: widget_copy.id, value: @value)
              end
            end
          end

          my_module_project.view_id = new_copied_view.id
          my_module_project.save
        end
      end
      #======
    end
  end

  # Select component on project/estimation dashboard
  def select_pbs_project_elements
    #No authorize required
    @project = Project.find(params[:project_id])
    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @module_projects.find_by_pemodule_id(@initialization_module.id)

    if params[:pbs_project_element_id] && params[:pbs_project_element_id] != ''
      @pbs_project_element = PbsProjectElement.find(params[:pbs_project_element_id])
    else
      @pbs_project_element = @project.root_component
    end
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = ModuleProject.where(:project_id => @project.id).all.map(&:position_x).uniq.max
  end


  def read_tree_nodes(current_node)
    #No authorize required
    ordered_list_of_nodes = Array.new
    next_nodes = current_node.next.sort { |node1, node2| (node1.position_y <=> node2.position_y) && (node1.position_x <=> node2.position_x) }.uniq
    ordered_list_of_nodes = ordered_list_of_nodes + next_nodes
    ordered_list_of_nodes.uniq

    next_nodes.each do |n|
      read_tree_nodes(n)
    end
  end

  def execute_estimation

    #pour chaque module
      #recupérer les attribut d'entrée
        #appeller set_attribut
      #end
    #end

    #current_module_project.nexts.each do |mp|
    #  mp.pemodule.pe_attributes.each do |attr|
    #
    #    mp_klass = "#{mp.pemodule.alias.camelcase.constantize}::#{mp.pemodule.alias.camelcase.constantize}".gsub(' ', '').constantize
    #
    #    if ""
    #
    #    end
    #    case mp.pemodule.alias
    #      when "guw"
    #        obj = mp_klass.send(:new, @project, current_module_project)
    #        obj.send("get_#{attr.alias}")
    #      when "operation"
    #        obj = mp_klass.send(:new, @project, current_module_project)
    #        obj.send("get_#{attr.alias}")
    #
    #        p "GE : #{attr.alias}"
    #        p obj.send("get_#{attr.alias}")
    #      when "effort_breakdown"
    #        obj = mp_klass.send(:new, current_component, mp, nil, WbsActivityRatio.first)
    #        obj.send("get_#{attr.alias}")
    #
    #        p "EB : #{attr.alias}"
    #        p obj.send("get_#{attr.alias}")
    #      when "expert_judgement"
    #        obj = mp_klass.send(:new)
    #      else
    #        obj = mp_klass.send(:new)
    #    end

        #ev = EstimationValue.where(module_project_id: mp.id,
        #                           pe_attribute_id: attr.id,
        #                           in_out: "input").first.string_data_low[current_component.id]

        #p mp.input_attributes.map(&:name)
        #p mp.output_attributes.map(&:name)
        #p "==="
    #  end
    #end
    #redirect_to dashboard_path(@project)
  end

  #Run estimation process
  def run_estimation(start_module_project = nil, pbs_project_element_id = nil, rest_of_module_projects = nil, set_attributes = nil)
    #@project = current_project
    authorize! :execute_estimation_plan, @project

    @my_results = Hash.new
    @last_estimation_results = Hash.new
    # set_attributes_name_list = {'low' => [], 'high' => [], 'most_likely' => []}

    if start_module_project.nil?
      pbs_project_element = current_component
      pbs_project_element_id = pbs_project_element.id
      start_module_project = current_module_project
      # rest_of_module_projects = crawl_module_project(current_module_project, pbs_project_element)
      set_attributes = {:low => {}, :most_likely => {}, :high => {}}


      ['low', 'most_likely', 'high'].each do |level|
        params[level].each do |key, hash|
          set_attributes[level][key] = hash[current_module_project.id.to_s]
        end
      end
    end

    # if the EffortBreakdown module is called, we need to have at least one Wbs-activity/Ratio defined in the PBS or in project level
    #if start_module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
    #  pe_wbs_activity = start_module_project.project.pe_wbs_projects.activities_wbs.first
    #  project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
    #  wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first
    #  #If the PBS has ratio this will be used, otherwise the general Ratio (in project's side) will be used
    #  if current_component.wbs_activity_ratio.nil? && wbs_project_elt_with_ratio.nil?
    #    flash[:notice] = "Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet"
    #    #return redirect_to(:back, :alert =>"Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet" )
    #    redirect_to(root_path(flash: { error: "Wbs-Activity est non existant, veuillez choisir un Wbs-activity au projet"})) and return
    #  end
    #end

    # Execution of the first/current module-project
    ['low', 'most_likely', 'high'].each do |level|
      @my_results[level.to_sym] = run_estimation_plan(set_attributes[level], pbs_project_element_id, level, @project, start_module_project)
    end

    # Save output values: only for current pbs_project_element and for current module-project
    # Component parent estimation results is computed again in a asynchronous jobs processing in the "save_estimation_results" method
    save_estimation_results(start_module_project, set_attributes, @my_results)

    redirect_to dashboard_path(@project)
  end


  # Function that save current module_project estimation result in DB
  #Save output values: only for current pbs_project_element
  def save_estimation_results(start_module_project, input_attributes, output_data)
    #@project = current_project
    authorize! :execute_estimation_plan, @project

    @pbs_project_element = current_component

    # get the estimation_value for the current_pbs_project_element
    current_pbs_estimations = start_module_project.estimation_values
    current_pbs_estimations.each do |est_val|
      est_val_attribute_alias = est_val.pe_attribute.alias
      est_val_attribute_type = est_val.pe_attribute.attribute_type

      if est_val.in_out == 'output'
        out_result = Hash.new
        @my_results.each do |res|
          ['low', 'most_likely', 'high'].each do |level|
            # We don't have to replace the value, but we need to update them
            level_estimation_value = est_val.send("string_data_#{level}")
            level_estimation_value_without_consistency = @my_results[level.to_sym]["#{est_val_attribute_alias}_#{start_module_project.id.to_s}".to_sym]

            # In case when module use the wbs_project_element, the is_consistent need to be set
            if start_module_project.pemodule.yes_for_output_with_ratio? || start_module_project.pemodule.yes_for_output_without_ratio? || start_module_project.pemodule.yes_for_input_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_without_ratio?
              level_estimation_value[@pbs_project_element.id] = set_element_value_with_activities(level_estimation_value_without_consistency, start_module_project)
            else
              level_estimation_value[@pbs_project_element.id] = level_estimation_value_without_consistency
            end

            out_result["string_data_#{level}"] = level_estimation_value
          end

          # compute the probable value for each node
          probable_estimation_value = est_val.send('string_data_probable')
          if est_val_attribute_type == 'numeric'
            probable_estimation_value[@pbs_project_element.id] = probable_value(@my_results, est_val)

            ######### if module_project use Ratio for output (like the Effort breakdown estimation module) ###############
            # Get the effort per Activity by profile
            #if start_module_project.pemodule.yes_for_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_with_ratio?
              #copy paste
            #end
          #  We remove the code

          else
            probable_estimation_value[@pbs_project_element.id] = @my_results[:most_likely]["#{est_val_attribute_alias}_#{est_val.module_project_id.to_s}".to_sym]
          end

          # Update the pbs probable value
          out_result['string_data_probable'] = probable_estimation_value
        end

        #Update current pbs estimation values
        est_val.update_attributes(out_result)

      elsif est_val.in_out == 'input'
        in_result = Hash.new

        ['low', 'most_likely', 'high'].each do |level|
          level_estimation_value = est_val.send("string_data_#{level}")
          begin
            pbs_level_form_input = input_attributes[level][est_val_attribute_alias]
          rescue
            pbs_level_form_input = input_attributes[est_val_attribute_alias.to_sym]
          end

          wbs_root = start_module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.where('is_root = ?', true).first
          if start_module_project.pemodule.yes_for_input? || start_module_project.pemodule.yes_for_input_output_with_ratio? || start_module_project.pemodule.yes_for_input_output_without_ratio?
            unless start_module_project.pemodule.alias == 'effort_balancing'
              level_estimation_value[@pbs_project_element.id] = compute_tree_node_estimation_value(wbs_root, pbs_level_form_input)
            end
          else
            level_estimation_value[@pbs_project_element.id] = pbs_level_form_input
          end

          in_result["string_data_#{level}"] = level_estimation_value
        end

        #calulate the Probable value for the input data
        input_probable_estimation_value = est_val.send('string_data_probable')
        minimum = in_result["string_data_low"][@pbs_project_element.id].to_f
        most_likely = in_result["string_data_most_likely"][@pbs_project_element.id].to_f
        maximum = in_result["string_data_high"][@pbs_project_element.id].to_f

        # The module is not using Ratio and Activities
        if !start_module_project.pemodule.yes_for_input? && !start_module_project.pemodule.yes_for_input_output_with_ratio?
          if est_val_attribute_type == 'numeric'
            input_probable_estimation_value[@pbs_project_element.id] = compute_probable_value(minimum, most_likely, maximum, est_val)[:value]  #probable_value(in_result, est_val)
          else
            input_probable_estimation_value[@pbs_project_element.id] = in_result["string_data_most_likely"][@pbs_project_element.id]
          end
          #update the iput result with probable value
          in_result["string_data_probable"] = input_probable_estimation_value
        end

        #Update the Input data estimation values
        est_val.update_attributes(in_result)
      end

      # Save estimation for the current component parent
      if est_val.save
        ###EstimationsWorker.perform_async(@pbs_project_element.id, est_val.id)
      end
    end
  end


private

  # Breadth-First Traversal of a Tree
  # This function list the next module_projects according to the given (starting_node) module_project
  # compatibility between the module_projects with the current_component is verified
  # Then return the module_projects like Tree Breadth
  def crawl_module_project(starting_node, pbs_project_element)
    #No authorize required since this method is private and won't be call from any route
    list = []
    items=[starting_node]
    until items.empty?
      # Returns the first element of items and removes it (shifting all other elements down by one).
      item = items.shift

      # Get all next module_projects that are linked to the current item
      list << item unless list.include?(item)
      kids = item.next.select { |i| i.pbs_project_elements.map(&:id).include?(pbs_project_element.id) }
      kids = kids.sort { |mp1, mp2| (mp1.position_y <=> mp2.position_y) && (mp1.position_x <=> mp2.position_x) } #Get next module_project

      kids.each { |kid| items << kid }
    end
    list - [starting_node]
  end

  # Compute the input element value
  ## values_to_set : Hash
  def compute_tree_node_estimation_value(tree_root, values_to_set)
    #No authorize required since this method is private and won't be call from any route
    WbsActivityElement.rebuild_depth_cache!
    new_effort_person_hour = Hash.new

    tree_root.children.each do |node|
      # Sort node subtree by ancestry_depth
      sorted_node_elements = node.subtree.order('ancestry_depth desc')
      sorted_node_elements.each do |wbs_project_element|
        if wbs_project_element.is_childless?
          new_effort_person_hour[wbs_project_element.id] = values_to_set[wbs_project_element.id.to_s]
        else
          new_effort_person_hour[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, new_effort_person_hour)
        end
      end
    end

    new_effort_person_hour[tree_root.id] = compact_array_and_compute_node_value(tree_root, new_effort_person_hour) ###root_element_effort_person_hour
    new_effort_person_hour
  end


  #This method set result in DB with the :value key for node estimation value
  def set_element_value_with_activities(estimation_result, module_project)
    authorize! :execute_estimation_plan, @project

    result_with_consistency = Hash.new
    consistency = true
    if !estimation_result.nil? && !estimation_result.eql?('-')
      estimation_result.each do |wbs_project_elt_id, est_value|
        if module_project.pemodule.alias == 'wbs_activity_completion'
          wbs_project_elt = WbsActivityElement.find(wbs_project_elt_id)
          if wbs_project_elt.has_new_complement_child?
            consistency = set_wbs_completion_node_consistency(estimation_result, wbs_project_elt)
          end
          result_with_consistency[wbs_project_elt_id] = {:value => est_value, :is_consistent => consistency}
        elsif module_project.pemodule.alias == 'effort_balancing'
          result_with_consistency[wbs_project_elt_id] = {:value => est_value}
        else
          result_with_consistency[wbs_project_elt_id] = {:value => est_value}
        end

      end
    else
      result_with_consistency = nil
    end

    result_with_consistency
  end


  # After estimation, need to know if node value are consistent or not for WBS-Completion modules
  def set_wbs_completion_node_consistency(estimation_result, wbs_project_element)
    #@project = current_project
    authorize! :alter_project_pbs_products, @project

    consistency = true
    estimation_result_without_null_value = []

    wbs_project_element.child_ids.each do |child_id|
      value = estimation_result[child_id]
      if value.is_a?(Float) or value.is_a?(Integer)
        estimation_result_without_null_value << value
      end
    end
    if estimation_result[wbs_project_element.id].to_f != estimation_result_without_null_value.sum.to_f
      consistency = false
    end
    consistency
  end


public

  # This estimation plan method is called for each component
  def run_estimation_plan(input_data, pbs_project_element_id, level, project, current_mp_to_execute)
    @project = project #current_project
    authorize! :execute_estimation_plan, @project

    @result_hash = Hash.new
    # Add the current project id in input data parameters
    input_data['current_project_id'.to_sym] = @project.id

    #Need to add input for pbs_project_element and module_project
    input_data['pbs_project_element_id'.to_sym] = pbs_project_element_id
    input_data['module_project_id'.to_sym] = current_mp_to_execute.id

    # For Balancing-Module : Estimation will be calculated only for the current selected balancing attribute
    if current_mp_to_execute.pemodule.alias.to_s == Projestimate::Application::BALANCING_MODULE
      balancing_attr_est_values = current_mp_to_execute.estimation_values.where('in_out = ? AND pe_attribute_id = ?', "output", current_balancing_attribute).last
      current_module = "#{current_mp_to_execute.pemodule.alias.camelcase.constantize}::#{current_mp_to_execute.pemodule.alias.camelcase.constantize}".gsub(' ', '').constantize
      input_data['pe_attribute_alias'.to_sym] = balancing_attr_est_values.pe_attribute.alias

      # Normally, the input data is commonly from the Expert Judgment Module on PBS (when running estimation on its product)
      cm = current_module.send(:new, input_data)
      @result_hash["#{balancing_attr_est_values.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = cm.send("get_#{balancing_attr_est_values.pe_attribute.alias}", project.id, current_mp_to_execute.id, pbs_project_element_id, level)

    # For others modules
    else
      #current_mp_to_execute.estimation_values.sort! { |a, b| a.in_out <=> b.in_out }.each do |est_val|
      current_mp_to_execute.estimation_values.each do |est_val|

        current_module = "#{current_mp_to_execute.pemodule.alias.camelcase.constantize}::#{current_mp_to_execute.pemodule.alias.camelcase.constantize}".gsub(' ', '').constantize

        input_data['pe_attribute_alias'.to_sym] = est_val.pe_attribute.alias

        # Normally, the input data is commonly from the Expert Judgment Module on PBS (when running estimation on its product)
        cm = current_module.send(:new, input_data)

        if est_val.in_out == 'output' or est_val.in_out=='both'
          @result_hash["#{est_val.pe_attribute.alias}_#{current_mp_to_execute.id}".to_sym] = cm.send("get_#{est_val.pe_attribute.alias}", project.id, current_mp_to_execute.id, pbs_project_element_id, level)
        end
      end
    end

    @result_hash
  end

  #Update new project/estimation views and widgets
  def update_views_and_widgets(new_prj, old_mp, new_mp)
    new_prj.update_project_views_and_widgets(old_mp, new_mp)

    # #For initialization module level
    # ###if old_mp.pemodule.alias == Projestimate::Application::INITIALIZATION
    #   #We have to copy all the selected view's widgets in a new view for the current module_project
    #   if old_mp.view
    #     #Copy the views and widgets for the new project
    #     new_view = View.new(organization_id: new_prj.organization_id, pemodule_id: new_mp.pemodule_id , name: "#{new_prj} :  #{new_mp}", description: "")
    #
    #     if new_view.save
    #       old_mp_view_widgets = old_mp.view.views_widgets.all
    #       old_mp_view_widgets.each do |old_view_widget|
    #         new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_view_widget.module_project_id)
    #         new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
    #         widget_est_val = old_view_widget.estimation_value
    #         if old_view_widget.is_kpi_widget || widget_est_val.nil?
    #           # Vignette Commentaires et Vignette KPI
    #           new_view_widget = ViewsWidget.new(view_id: new_view.id,
    #                                             module_project_id: new_view_widget_mp_id,
    #                                             name: old_view_widget.name,
    #                                             show_name: old_view_widget.show_name,
    #                                             show_tjm: old_view_widget.show_tjm,
    #                                             is_label_widget: old_view_widget.is_label_widget,
    #                                             comment: old_view_widget.comment,
    #                                             is_kpi_widget: old_view_widget.is_kpi_widget,
    #                                             kpi_unit: old_view_widget.kpi_unit,
    #                                             equation: old_view_widget.equation,
    #                                             icon_class: old_view_widget.icon_class,
    #                                             color: old_view_widget.color,
    #                                             show_min_max: old_view_widget.show_min_max,
    #                                             widget_type: old_view_widget.widget_type,
    #                                             width: old_view_widget.width,
    #                                             height: old_view_widget.height,
    #                                             position: old_view_widget.position,
    #                                             position_x: old_view_widget.position_x,
    #                                             position_y: old_view_widget.position_y)
    #
    #             #Update KPI Widget aquation
    #             ["A", "B", "C", "D", "E"].each do |letter|
    #               unless old_view_widget.equation[letter].nil?
    #
    #                 new_array = []
    #                 est_val_id = old_view_widget.equation[letter].first
    #                 mp_id = old_view_widget.equation[letter].last
    #
    #                 begin
    #                   new_mpr = new_prj.module_projects.where(copy_id: mp_id).first
    #                   new_mpr_id = new_mpr.id
    #                   begin
    #                     new_est_val_id = new_mpr.estimation_values.where(copy_id: est_val_id).first.id
    #                   rescue
    #                     new_est_val_id = nil
    #                   end
    #                 rescue
    #                   new_mpr_id = nil
    #                 end
    #
    #                 new_array << new_est_val_id
    #                 new_array << new_mpr_id
    #
    #                 new_view_widget.equation[letter] = new_array
    #               end
    #             end
    #
    #             new_view_widget.save
    #         else
    #           in_out = widget_est_val.in_out
    #           widget_pe_attribute_id = widget_est_val.pe_attribute_id
    #           unless new_view_widget_mp.nil?
    #             new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
    #             estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
    #
    #             new_view_widget = ViewsWidget.new(view_id: new_view.id,
    #                                               module_project_id: new_view_widget_mp_id,
    #                                               estimation_value_id: estimation_value_id,
    #                                               name: old_view_widget.name,
    #                                               show_name: old_view_widget.show_name,
    #                                               show_tjm: old_view_widget.show_tjm,
    #                                               show_wbs_activity_ratio: old_view_widget.show_wbs_activity_ratio,
    #                                               is_label_widget: old_view_widget.is_label_widget,
    #                                               comment: old_view_widget.comment,
    #                                               is_kpi_widget: old_view_widget.is_kpi_widget,
    #                                               kpi_unit: old_view_widget.kpi_unit,
    #                                               equation: old_view_widget.equation,
    #                                               icon_class: old_view_widget.icon_class,
    #                                               color: old_view_widget.color,
    #                                               show_min_max: old_view_widget.show_min_max,
    #                                               widget_type: old_view_widget.widget_type,
    #                                               use_organization_effort_unit: old_view_widget.use_organization_effort_unit,
    #                                               width: old_view_widget.width,
    #                                               height: old_view_widget.height,
    #                                               position: old_view_widget.position,
    #                                               position_x: old_view_widget.position_x,
    #                                               position_y: old_view_widget.position_y)
    #             if new_view_widget.save
    #               #Update the copied project_fields
    #               pf = ProjectField.where(project_id: new_prj.id, views_widget_id: old_view_widget.id).first
    #               unless pf.nil?
    #                 pf.views_widget_id = new_view_widget.id
    #                 pf.save
    #               end
    #             end
    #           end
    #         end
    #
    #       end
    #       #update the new module_project view
    #       new_mp.update_attribute(:view_id, new_view.id)
    #     end
    #   end
    # ###end
  end

  #Duplicate an estimation/project
  def duplicate
    # To duplicate a project user need to have the "show_project" and "create_project_from_scratch" authorizations
    if params[:action_name] == "duplication"
      authorize! :copy_project, @project
      # To Create a project from a template user need to have "create_project_from_template" authorization
      #elsif params[:action_name] == "create_project_from_template"
    elsif !params[:create_project_from_template].nil?
      authorize! :create_project_from_template, Project
    end

    @organization = Organization.find(params[:organization_id])
    old_prj = Project.find(params[:project_id])
    generate_automatique_title = false
    @user = current_user

    new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
    new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:estimation_created_from_estimation_by, estimation_name: old_prj, username: @user.name)} \r\n"
    new_prj.ancestry = nil
    new_prj.creator_id = @user.id
    if params[:action_name] == "duplication_model"
      new_prj.is_model = true
    else
      new_prj.is_model = false
      new_prj.use_automatic_quotation_number = false
    end

    # On met à jour ce champs pour la gestion des Trigger
    new_prj.is_new_created_record = true

    # new_prj.is_private = old_prj.is_private

    #=======
    #if creation from template
    if !params[:create_project_from_template].nil?
      new_prj.original_model_id = old_prj.id
      new_prj.use_automatic_quotation_number = false

      #Update some params with the form input data
      new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:estimation_created_from_model_by, model_name: old_prj, username: @user.name)} \r\n"

      # time_now = Time.now
      # StatusHistory.create(organization: new_prj.organization.name,
      #                      project_id: new_prj.id,
      #                      project: new_prj.title,
      #                      version_number: old_prj.version_number,
      #                      change_date: time_now,
      #                      action: "Création",
      #                      comments: nil,
      #                      origin: nil,
      #                      target: new_prj.estimation_status.name,
      #                      user: current_user.name,
      #                      gap: nil)

      if params['project']['application_id'].present?
        new_prj.application_id = params['project']['application_id']
      else
        new_prj.application_name = params['project']['application_name']
      end

      new_prj.title = params['project']['title']
      new_prj.version_number = params['project']['version_number']
      new_prj.description = params['project']['description']
      new_prj.start_date = Time.now

      # si generation d'un nouveau n° de devis, il faut MAJ la valeur au niveau de l'organisation
      if old_prj.use_automatic_quotation_number
        generate_automatique_title = true
      end
    else
      # simple copy
      if old_prj.original_model
        if old_prj.original_model.use_automatic_quotation_number
          generate_automatique_title = true
        end
      end
    end
    #=======

    # Locking organization instead project is created/save
    Organization.transaction do
      begin
        # get et lock the organization
        @organization.lock!

        new_automatic_number = @organization.automatic_quotation_number.next
        @organization.automatic_quotation_number = new_automatic_number

        # si generation d'un nouveau n° de devis, il faut MAJ la valeur au niveau de l'organisation
        if generate_automatique_title == true
          #new_prj.title = "#{@organization.prefix_quotation_number} #{new_automatic_number}"
          new_prj.title = new_automatic_number
          new_prj.save
          @organization.save!
        end

      rescue
        flash[:error] = "Erreur lors de la génération du numéro de devis automatique"
        #redirect_to request.referer #and return

        raise ActiveRecord::Rollback #and return
        redirect_to request.referer and return
      end
    end
    # end locking


    # Debut transaction
    ActiveRecord::Base.transaction do

      if new_prj.save
        old_prj.save #Original project copy number will be incremented to 1

        #Update the project securities for the current user who create the estimation from model
        #if params[:action_name] == "create_project_from_template"
        owner = User.find_by_initials(AdminSetting.find_by_key("Estimation Owner").value)
        if !params[:create_project_from_template].nil?
          creator_securities = new_prj.project_securities
          creator_securities.each do |ps|
            if ps.is_model_permission == true
              # Amelioration Creer à partir d'un modele
              # ps.update_attribute(:is_model_permission, false)
              # ps.update_attribute(:is_estimation_permission, true)
              ps.is_model_permission = false
              ps.is_estimation_permission = true

              if ps.user_id == owner.id
                #ps.update_attribute(:user_id, owner.id)
                ps.user_id = owner.id
              end
              ps.save
            else
              ps.destroy
            end
          end
        end

        #Managing the component tree : PBS
        pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

        # For PBS
        new_prj_components = pe_wbs_product.pbs_project_elements
        new_prj_application = new_prj.application
        new_prj_components.each do |new_c|
          if new_c.is_root == true
            if !params[:create_project_from_template].nil?
              if new_prj_application.nil?
                new_c.name = new_prj.application_name
              else
                new_c.name = new_prj_application.name
              end
              new_c.save
            end
          end

          new_ancestor_ids_list = []
          new_c.ancestor_ids.each do |ancestor_id|
            ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
            new_ancestor_ids_list.push(ancestor_id)
          end
          new_c.ancestry = new_ancestor_ids_list.join('/')
          new_c.save
        end

        hash_apps = {}
        @organization.applications.each do |app|
          hash_apps[app.name] = app
        end

        #For applications
        old_prj.applications.each do |application|
          # Application.where(name: application.name, organization_id: @organization.id).first
          app = hash_apps[application.name]
          ApplicationsProjects.create(application_id: app.id, project_id: new_prj.id)
        end

        # For ModuleProject associations
        old_prj.module_projects.group(:id).each do |old_mp|

          old_mp_associated_module_projects = old_mp.associated_module_projects
          old_mp_module_project_ratio_elements = old_mp.module_project_ratio_elements


          new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

          # ModuleProject Associations for the new project
          old_mp_associated_module_projects.each do |associated_mp|
            new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
            new_mp.associated_module_projects << new_associated_mp
          end

          ### Wbs activity
          #create module_project ratio elements
          old_mp_module_project_ratio_elements.each do |old_mp_ratio_elt|
            mp_ratio_element = old_mp_ratio_elt.dup
            mp_ratio_element.module_project_id = new_mp.id
            mp_ratio_element.copy_id = old_mp_ratio_elt.id

            pbs = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first
            unless pbs.nil?
              mp_ratio_element.pbs_project_element_id = pbs.id
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
            Skb::SkbInput.create(data: skbi.data, processing: skbi.processing, retained_size: skbi.retained_size,
                                 organization_id: @organization.id, module_project_id: new_mp.id)
          end

          #For ge_model_factor_descriptions
          old_mp.ge_model_factor_descriptions.each do |factor_description|
            Ge::GeModelFactorDescription.create(ge_model_id: factor_description.ge_model_id, ge_factor_id: factor_description.ge_factor_id,
                                                factor_alias: factor_description.factor_alias, description: factor_description.description,
                                                module_project_id: new_mp.id, project_id: new_prj.id, organization_id: @organization.id)
          end

          # if the module_project is nil
          unless old_mp.view.nil?
            #Update the new project/estimation views and widgets
            update_views_and_widgets(new_prj, old_mp, new_mp)
          end

          #Update the Unit of works's groups
          new_mp.guw_unit_of_work_groups.each do |guw_group|
            new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
            new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
            guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id,
                                        project_id: new_prj.id,
                                        organization_id: new_prj.organization_id)

            # Update the group unit of works and attributes
            guw_group.guw_unit_of_works.each do |guw_uow|
              new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
              new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

              new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
              new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
              guw_uow.update_attributes(module_project_id: new_uow_mp_id,
                                        pbs_project_element_id: new_pbs_id,
                                        organization_id: new_prj.organization_id,
                                        project_id: new_prj.id)

              # copy des coefficient-elements-unit-of-works
              guw_uow.guw_coefficient_element_unit_of_works.each do |new_guw_coeff_elt_uow|
                unless new_guw_coeff_elt_uow.nil?
                  new_guw_coeff_elt_uow.guw_unit_of_work_id = guw_uow.id
                  new_guw_coeff_elt_uow.module_project_id = new_mp.id
                  new_guw_coeff_elt_uow.save
                end
              end
              #====
            end
          end

          new_mp_pemodule_pe_attributes = new_mp.pemodule.pe_attributes
          old_prj_pbs_project_elements = old_prj.pbs_project_elements
          new_mp_estimation_values = new_mp.estimation_values
          hash_nmpevs = {}

          new_mp_estimation_values.where(pe_attribute_id: new_mp_pemodule_pe_attributes.map(&:id), in_out: ["input", "output"]).each do |nmpev|
            hash_nmpevs["#{nmpev.pe_attribute_id}_#{nmpev.in_out}"] = nmpev
          end

          ["input", "output"].each do |io|

            new_mp_pemodule_pe_attributes.each do |attr|

                ev = hash_nmpevs["#{attr.id}_#{io}"]

              unless ev.nil?
                new_evs = EstimationValue.where(copy_id: ev.estimation_value_id).all
                old_prj_pbs_project_elements.each do |old_component|
                  new_prj_components.each do |new_component|
                    # unless ev.nil?

                    ev_low = ev.string_data_low.delete(old_component.id)
                    ev_most_likely = ev.string_data_most_likely.delete(old_component.id)
                    ev_high = ev.string_data_high.delete(old_component.id)
                    ev_probable = ev.string_data_probable.delete(old_component.id)

                    ev.string_data_low[new_component.id.to_i] = ev_low
                    ev.string_data_most_likely[new_component.id.to_i] = ev_most_likely
                    ev.string_data_high[new_component.id.to_i] = ev_high
                    ev.string_data_probable[new_component.id.to_i] = ev_probable

                    # update ev attribute links
                    unless ev.estimation_value_id.nil?
                      project_id = new_prj.id
                      new_ev = new_evs.select { |est_v| est_v.module_project.project_id == project_id}.first
                      if new_ev
                        ev.estimation_value_id = new_ev.id
                      end
                    end

                    ev.save
                    # end
                  end
                end
              end
            end
          end
        end

        # On remet à jour ce champs pour la gestion des Trigger
        new_prj.update_attribute(:is_new_created_record, false)

        # Update project's organization estimations counter
        unless new_prj.is_model == true || @current_user.super_admin == true
          unless @organization.estimations_counter.nil? || @organization.estimations_counter == 0
            @organization.estimations_counter -= 1
            @organization.save
          end
        end


        flash[:success] = I18n.t(:notice_project_successful_duplicated)
        redirect_to edit_project_path(new_prj) and return
      else
        #if params[:action_name] == "create_project_from_template"
        if !params[:create_project_from_template].nil?
          flash[:error] = I18n.t(:project_already_exist, value: old_prj.title)
          redirect_to projects_from_path(organization_id: @organization.id) and return
        else
          flash[:error] = I18n.t(:error_project_failed_duplicate)
          redirect_to organization_estimations_path(@current_organization)
        end
      end
    end   # Fin transaction
  end

  def commit
    project = Project.find(params[:project_id])
    authorize! :commit_project, project

    if !can_modify_estimation?(project)
      redirect_to(organization_estimations_path(@current_organization), flash: {warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
    end

    #change project's status
    project.commit_status

    if params[:from_tree_history_view]
      redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history') and return
    else
      redirect_to organization_estimations_path(@current_organization) and return
    end
  end

  #Find which projects/estimations are created from this model
  def find_use_estimation_model
    @project = Project.find(params[:project_id])
    authorize! :show_project, @project

    @related_projects = Project.where(original_model_id: @project.id).all
  end

  #Find where is used the project
  def find_use_project
    @project = Project.find(params[:project_id])
    authorize! :show_project, @project

    @related_projects = Array.new
    @related_projects_inverse = Array.new

    unless @project.nil?
      related_pe_wbs_project = @project.pe_wbs_projects.products_wbs
      related_pbs_projects = PbsProjectElement.where(:pe_wbs_project_id => related_pe_wbs_project)
      unless related_pe_wbs_project.empty?
        related_pbs_projects.each do |pbs|
          unless pbs.project_link.nil? or pbs.project_link.blank?
            p = Project.find_by_id(pbs.project_link)
            @related_projects << p
          end
        end
      end
    end

    related_pbs_project_elements = PbsProjectElement.where('project_link IN (?)', [params[:project_id]]).all
    related_pbs_project_elements.each do |i|
      @related_projects_inverse << i.pe_wbs_project.project
    end

    @related_users = @project.organization.users
    @related_groups = @project.organization.groups
  end

  def projects_global_params
    set_page_title I18n.t(:project_global_parameters)
  end

  def default_work_element_type
    @current_organization.work_element_types.first_or_create(name: "Default", alias: "default")
  end

  #Add/Import a WBS-Activity template from Library to Project
  def add_wbs_activity_to_project
    @project = Project.find(params[:project_id])

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @wbs_project_elements_root = @project.wbs_project_element_root

    selected_wbs_activity_elt = WbsActivityElement.find(params[:wbs_activity_element])

    # Delete all other wbs_project_elements when the wbs_project_element is valide
    #wbs_project_elements_to_delete = @project.wbs_project_elements.where('id != ?', @wbs_project_elements_root.id)
    #@project.wbs_project_elements.where('is_root != ?', true).destroy_all
    @project.wbs_project_elements.where(:is_root => [nil, false]).destroy_all

    wbs_project_element = WbsProjectElement.new(:pe_wbs_project_id => @pe_wbs_project_activity.id, :wbs_activity_element_id => selected_wbs_activity_elt.id,
                                                :wbs_activity_id => selected_wbs_activity_elt.wbs_activity_id, :name => selected_wbs_activity_elt.name,
                                                :description => selected_wbs_activity_elt.description, :ancestry => @wbs_project_elements_root.id,
                                                :author_id => current_user.id, :copy_number => 0,
                                                :wbs_activity_ratio_id => params[:project_default_wbs_activity_ratio], # Update Project default Wbs-Activity-Ratio
                                                :is_added_wbs_root => true)

    selected_wbs_activity_children = selected_wbs_activity_elt.children

    respond_to do |format|
      #wbs_project_element.transaction do
      if wbs_project_element.save
        selected_wbs_activity_children.each do |child|
          create_wbs_activity_from_child(child, @pe_wbs_project_activity, @wbs_project_elements_root)
        end

        #add some additional information for leaf element customization
        added_wbs_project_elements = WbsProjectElement.find_all_by_wbs_activity_id_and_pe_wbs_project_id(wbs_project_element.wbs_activity_id, @pe_wbs_project_activity.id)
        added_wbs_project_elements.each do |project_elt|
          if project_elt.has_children?
            project_elt.can_get_new_child = false
          else
            project_elt.can_get_new_child = true
          end
          project_elt.save
        end

        @project.included_wbs_activities.push(wbs_project_element.wbs_activity_id)
        if @project.save
          flash[:notice] = I18n.t(:notice_wbs_activity_successful_added)
        else
          flash[:error] = "#{@project.errors.full_messages.to_sentence}"
        end
      else
        flash[:error] = "#{wbs_project_element.errors.full_messages.to_sentence}"
      end
      #end
      format.html { redirect_to edit_project_path(@project, :anchor => 'tabs-3') }
      format.js { redirect_to edit_project_path(@project, :anchor => 'tabs-3') }
    end
  end


private

  def get_new_ancestors(node, pe_wbs_activity, wbs_elt_root)
    #No authorize required since this method is private and won't be call from any route
    node_ancestors = node.ancestry.split('/')
    new_ancestors = []
    new_ancestors << wbs_elt_root.id
    node_ancestors.each do |ancestor|
      corresponding_wbs_project = WbsProjectElement.where('wbs_activity_element_id = ? and pe_wbs_project_id = ?', ancestor, pe_wbs_activity.id).first
      new_ancestors << corresponding_wbs_project.id
    end
    new_ancestors.join('/')
  end

  def create_wbs_activity_from_child(node, pe_wbs_activity, wbs_elt_root)
    authorize! :alter_wbsactivities, @project

    wbs_project_element = WbsProjectElement.new(:pe_wbs_project_id => pe_wbs_activity.id, :wbs_activity_element_id => node.id, :wbs_activity_id => node.wbs_activity_id, :name => node.name,
                                                :description => node.description, :ancestry => get_new_ancestors(node, pe_wbs_activity, wbs_elt_root), :author_id => current_user.id, :copy_number => 0)
    wbs_project_element.transaction do
      wbs_project_element.save

      if node.has_children?
        node_children = node.children
        node_children.each do |node_child|
          ActiveRecord::Base.transaction do
            create_wbs_activity_from_child(node_child, pe_wbs_activity, wbs_elt_root)
          end
        end
      end
    end
  end


public

  def refresh_wbs_project_elements
    @project = Project.find(params[:project_id])
    authorize! :edit_project, @project

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @show_hidden = params[:show_hidden]
    @is_project_show_view = params[:is_project_show_view]
  end

  #On edit page, select ratios according to the selected wbs_activity
  def refresh_wbs_activity_ratios
    if params[:wbs_activity_element_id].empty? || params[:wbs_activity_element_id].nil?
      @wbs_activity_ratios = []
    else
      selected_wbs_activity_elt = WbsActivityElement.find(params[:wbs_activity_element_id])
      @wbs_activity = selected_wbs_activity_elt.wbs_activity
      @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    end
  end

  # On the project edit view, we are going to show to user the current selected WBS-Activity elements
  # without adding it to the project until it saves it with the "Add" button
  def render_selected_wbs_activity_elements
    @project = Project.find(params[:project_id])
    authorize! :edit_project, @project

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @show_hidden = params[:show_hidden]
    @is_project_show_view = params[:is_project_show_view]

    @wbs_activity_element = WbsActivityElement.find(params[:wbs_activity_elt_id])
    @wbs_activity = @wbs_activity_element.wbs_activity

    @wbs_activity_elements_list = @wbs_activity.wbs_activity_elements
    @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity_elements_list)
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    @wbs_activity_organization = @wbs_activity.organization
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity_organization.organization_profiles

    @wbs_activity_ratio_elements = []
    @total = 0
    if params[:Ratio]
      @wbs_activity_elements.each do |wbs|
        @wbs_activity_ratio_elements += wbs.wbs_activity_ratio_elements.where(:wbs_activity_ratio_id => params[:Ratio])
        @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
      end
    else
      unless @wbs_activity.wbs_activity_ratios.empty?
        @wbs_activity_elements.each do |wbs|
          @wbs_activity_ratio_elements += wbs.wbs_activity_ratio_elements.where(:wbs_activity_ratio_id => @wbs_activity.wbs_activity_ratios.first.id)
        end
        @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
      end
    end

  end

  def projects_from
    @organization = Organization.find(params[:organization_id])
    set_page_title I18n.t(:text_create_from_model_2)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization), I18n.t('new_project_from') => ""

    #authorize! :create_project_from_template, Project
    if cannot?(:create_project_from_template, Project)
      redirect_to :back, flash: {warning: I18n.t(:error_access_denied)}
    end

    #@estimation_models = @organization.projects.includes(:estimation_status, :project_area, :project_category, :platform_category, :acquisition_category).where(:is_model => true)
    @estimation_models = Project.includes(:estimation_status, :project_area, :project_category, :platform_category, :acquisition_category).where(organization_id: @organization.id, :is_model => true)

    fields = @organization.fields
    ProjectField.where(project_id: @estimation_models.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(fields.map(&:id))
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

    ###@current_ability = Ability.new(current_user, @organization, @estimation_models, 1, false)
  end

  #Set the checkout version
  def set_checkout_version
    @project = Project.find(params[:project_id])
    @archive_status = @project.organization.estimation_statuses.where(is_archive_status: true).first
    @new_status = @project.organization.estimation_statuses.where(is_new_status: true).first
  end


  def sort
    @organization = @current_organization
    # @projects = @organization.organization_estimations
    @projects = @organization.projects.where(:is_model => [nil, false])

    k = params[:f]
    s = params[:s]

    @sort_column = k
    @sort_order = s

    @search_column = session[:search_column]
    @search_value = session[:search_value]
    @search_hash = session[:search_hash]

    organization_projects = get_sorted_estimations(@organization.id, @projects, @sort_column, @sort_order, @search_hash)
    @search_string = session[:search_string] || ""

    res = []
    organization_projects.each do |p|
      if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
        res << p
      end
    end

    # Filtre sur les versions des estimations
    if !params[:filter_version].in?(['4', ''])
      res = filter_estimation_versions(res, params[:filter_version])
    end

    @object_per_page = (current_user.object_per_page || 10)
    if params['previous_next_action'] == "true"
      @min = params['min'].to_i
      @max = params['max'].to_i
    else
      @min = 0
      @max = @object_per_page
    end

    @projects = res[@min..@max-1].nil? ? [] : res[@min..@max-1]

    last_page = res.paginate(:page => 1, :per_page => @object_per_page).total_pages
    @last_page_min = (last_page.to_i-1) * @object_per_page
    @last_page_max = @last_page_min + @object_per_page


    if params[:is_last_page] == "true" || (@min == @last_page_min)
      @projects = res.paginate(:page => last_page, :per_page => @object_per_page)

      @min = (last_page.to_i-1) * @object_per_page
      @max = @min + @object_per_page
      @is_last_page = "true"
    else
      @is_last_page = "false"
    end

    session[:object_per_page] = @object_per_page
    session[:last_page_min] = @last_page_min
    session[:last_page_max] = @last_page_max

    session[:sort_column] = @sort_column
    session[:sort_order] = @sort_order
    session[:sort_action] = true
    session[:is_last_page] = @is_last_page
    session[:search_column] = @search_column
    session[:search_value] = @search_value

    build_footer
  end

  def search
    @organization = @current_organization

    @object_per_page = (current_user.object_per_page || 10)
    @min = 0
    @max = @object_per_page
    @sort_column = (params[:sort_column].blank? ? session[:sort_column] : params[:sort_column])
    @sort_order = (params[:sort_order].blank? ? session[:sort_order] : params[:sort_order])
    @sort_action = (params[:sort_action].blank? ? session[:sort_action] : params[:sort_action])
    @search_hash = {}
    @search_string = ""
    @search_column = ""
    @search_value = ""

    # filtre sur les versions
    @filter_version = params[:filter_organization_projects_version]

    params.delete("utf8")
    params.delete("commit")
    params.delete("action")
    params.delete("controller")
    params.delete("filter_organization_projects_version")
    params.delete("sort_action")
    params.delete("sort_column")
    params.delete("sort_order")
    params.delete("min")
    params.delete("max")
    params.delete_if { |k, v| v.nil? || v.blank? }

    @search_hash = params
    unless @search_hash.blank?
      @search_hash.each do |k, v|
        @search_string << "&search[#{k}]=#{v}"
      end
    end

    session[:search_string] = @search_string
    session[:search_hash] = @search_hash

    # @organization_estimations = @organization.organization_estimations.order("created_at ASC")
    @projects = @organization.projects.where(:is_model => [nil, false]).order("start_date desc")

    if @sort_action.to_s == "true" && @sort_column != "" && @sort_order != ""
      #@projects = get_sorted_estimations(@organization.id, @projects, params[:sort_column], params[:sort_order])
      @organization_estimations = get_sorted_estimations(@organization.id, @projects, @sort_column, @sort_order, @search_hash)
    else
      @organization_estimations = get_multiple_search_results(@organization.id, @projects, @search_hash)
    end

    if @organization_estimations.nil? || @organization_estimations.blank?
      @organization_estimations = @organization.organization_estimations.where(project_id: @projects.all.map(&:id)).all  ##@organization.organization_estimations #@organization.projects.order("created_at ASC")
    end

    # filtre sur la version des estimations
    if !@filter_version.to_s.in?(['4', ''])
      @organization_estimations = filter_estimation_versions(@organization_estimations, @filter_version)
    end

    res = []
    @organization_estimations.each do |p|
      if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
        res << p
      end
    end

    @projects = res[@min..@max].nil? ? [] : res[@min..@max-1]

    if @projects.length <= @object_per_page
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


    build_footer
  end

  private def check_for_projects(start_number, desired_size, organization_estimations)

     if start_number == 0
       projects = organization_estimations.take(desired_size)
     else
       project = organization_estimations[start_number-1] #|| organization_estimations.last
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
             last_project = project
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
           estimations_abilities.call(next_projects)
         end
       end
     end

     estimations_abilities.call(projects)

     result
   end

  private def build_footer
    @object_per_page = (current_user.object_per_page || 10)

    if params[:min].present? && params[:max].present?
      @min = params[:min].to_i
      @max = params[:max].to_i
    else
      @min = 0
      @max = (current_user.object_per_page || @object_per_page)
    end

    @fields_coefficients = {}
    @pfs = {}

    fields = @organization.fields

    # ProjectField.where(project_id: @projects.map(&:id).uniq, field_id: fields.map(&:id).uniq).each do |pf|
    #   @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
    # end

    # Correction concernant les valeurs des champs personnalisés qui ne remontent pas
    #ProjectField.where(project_id: @projects.map(&:id).uniq, field_id: fields.map(&:id).uniq).each do |pf|
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

  #Checkout the project : create a new version of the project
  def checkout
    old_prj = Project.find(params[:project_id])
    @organization = @current_organization

    authorize! :commit_project, old_prj

    #if !can_modify_estimation?(project)
    if !(can_alter_estimation?(old_prj) && can?(:commit_project, old_prj))
      redirect_to(organization_estimations_path(@current_organization), flash: {warning: I18n.t(:warning_checkout_unauthorized_action)}) and return
    end

    # If project is not childless, a new branch need to be created
    # And user need have the "allow_to_create_branch" permission to create new branch
    if old_prj.has_children? && (cannot? :allow_to_create_branch, old_prj)
      redirect_to organization_estimations_path(@current_organization), :flash => {:warning => I18n.t('warning_not_allow_to_create_new_branch_of_project')} and return
    end

    description = params[:description]
    version_number = params[:new_version]
    if version_number.blank?
      version_number = set_project_version(old_prj)
    end

    archive_last_project_version = params['archive_last_project_version']
    new_project_version = params['new_project_version']

    new_prj = old_prj.checkout_project_base(current_user, description, version_number, archive_last_project_version, new_project_version)

    # On remet à jour ce champs pour la gestion des Trigger
    new_prj.is_new_created_record = false

    #begin
      #new_prj.transaction do
        if new_prj.save
          flash[:success] = I18n.t(:notice_project_successful_checkout)
          redirect_to (edit_project_path(new_prj, :anchor => "tabs-history")), :notice => I18n.t(:notice_project_successful_checkout) and return

        else
          flash[:error] = I18n.t(:error_project_checkout_failed)
          redirect_to organization_estimations_path(@current_organization), :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
        end
      #end
    # rescue
    #   flash[:error] = I18n.t(:error_project_checkout_failed)
    #   redirect_to organization_estimations_path(@current_organization), :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
    #   ##redirect_to(edit_project_path(old_prj, :anchor => 'tabs-history'), :flash => {:error => I18n.t(:error_project_checkout_failed)} ) and return
    # end

    #else
    #redirect_to "#{session[:return_to]}", :flash => {:warning => I18n.t('warning_project_cannot_be_checkout')}
    #end  # END commit permission
  end

  #
  #
  # def checkout_SAVE_13_02_2018_pour_tache_1830
  #   old_prj = Project.find(params[:project_id])
  #   @organization = @current_organization
  #
  #   authorize! :commit_project, old_prj
  #
  #   #if !can_modify_estimation?(project)
  #   if !(can_alter_estimation?(old_prj) && can?(:commit_project, old_prj))
  #     redirect_to(organization_estimations_path(@current_organization), flash: {warning: I18n.t(:warning_checkout_unauthorized_action)}) and return
  #   end
  #
  #   # If project is not childless, a new branch need to be created
  #   # And user need have the "allow_to_create_branch" permission to create new branch
  #   if old_prj.has_children? && (cannot? :allow_to_create_branch, old_prj)
  #     redirect_to organization_estimations_path(@current_organization), :flash => {:warning => I18n.t('warning_not_allow_to_create_new_branch_of_project')} and return
  #   end
  #
  #   #begin
  #   old_prj_copy_number = old_prj.copy_number
  #
  #   #old_prj_pe_wbs_product_name = old_prj.pe_wbs_projects.products_wbs.first.name
  #   #old_prj_pe_wbs_activity_name = old_prj.pe_wbs_projects.activities_wbs.first.name
  #
  #   new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
  #   old_prj.copy_number = old_prj_copy_number
  #
  #   new_prj.title = old_prj.title
  #   new_prj.alias = old_prj.alias
  #   new_prj.description = params[:description]
  #   new_prj.parent_id = old_prj.id
  #   new_prj.creator_id = current_user.id
  #
  #   new_prj.version_number = params[:new_version]  #set_project_version(old_prj)
  #   if params[:new_version].nil? || params[:new_version].empty?
  #     new_prj.version_number = set_project_version(old_prj)
  #   end
  #
  #   new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_version_from_to, from_version: old_prj.version_number, to_version: new_prj.version_number, current_user_name: current_user.name)}. \r\n"
  #
  #   # new_prj.transaction do
  #     if new_prj.save
  #       old_prj.save #Original project copy number will be incremented to 1
  #
  #       #Managing the component tree : PBS
  #       pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first
  #       #pe_wbs_activity = new_prj.pe_wbs_projects.activities_wbs.first
  #
  #       #pe_wbs_product.name = old_prj_pe_wbs_product_name
  #       #pe_wbs_activity.name = old_prj_pe_wbs_activity_name
  #
  #       pe_wbs_product.save(validate: false)
  #       #pe_wbs_activity.save
  #
  #       # For PBS
  #       new_prj_components = pe_wbs_product.pbs_project_elements
  #       new_prj_components.each do |new_c|
  #         unless new_c.is_root?
  #           new_ancestor_ids_list = []
  #           new_c.ancestor_ids.each do |ancestor_id|
  #             ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
  #             new_ancestor_ids_list.push(ancestor_id)
  #           end
  #           new_c.ancestry = new_ancestor_ids_list.join('/')
  #           # For PBS-Project-Element Links with modules
  #           #old_pbs = PbsProjectElement.find(new_c.copy_id)
  #           #new_c.module_projects = old_pbs.module_projects
  #           new_c.save(validate: false)
  #         end
  #       end
  #
  #       #For applications
  #       old_prj.applications.each do |application|
  #         app = Application.where(name: application.name, organization_id: @organization.id).first
  #         ap = ApplicationsProjects.create(application_id: app.id,
  #                                          project_id: new_prj.id)
  #         ap.save
  #       end
  #
  #       # For ModuleProject associations
  #       old_prj.module_projects.group(:id).each do |old_mp|
  #         new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)
  #
  #         # ModuleProject Associations for the new project
  #         old_mp.associated_module_projects.each do |associated_mp|
  #           new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
  #           new_mp.associated_module_projects << new_associated_mp
  #         end
  #
  #         ### Wbs activity
  #         #create module_project ratio elements
  #         old_mp.module_project_ratio_elements.each do |old_mp_ratio_elt|
  #
  #           mp_ratio_element = old_mp_ratio_elt.dup
  #           mp_ratio_element.module_project_id = new_mp.id
  #           mp_ratio_element.copy_id = old_mp_ratio_elt.id
  #
  #             pbs = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first
  #             mp_ratio_element.pbs_project_element_id = pbs.nil? ? nil : pbs.id
  #             mp_ratio_element.save
  #           end
  #           pbs_id = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first.id
  #           mp_ratio_element.pbs_project_element_id = pbs_id
  #           mp_ratio_element.save
  #         end
  #
  #         new_mp_ratio_elements = new_mp.module_project_ratio_elements
  #         new_mp_ratio_elements.each do |mp_ratio_element|
  #
  #           #unless mp_ratio_element.is_root?
  #           new_ancestor_ids_list = []
  #           mp_ratio_element.ancestor_ids.each do |ancestor_id|
  #             ancestor = new_mp_ratio_elements.where(copy_id: ancestor_id).first
  #             if ancestor
  #               ancestor_id = ancestor.id
  #               new_ancestor_ids_list.push(ancestor_id)
  #             end
  #           end
  #           mp_ratio_element.ancestry = new_ancestor_ids_list.join('/')
  #           #end
  #           mp_ratio_element.save
  #         end
  #         ### End wbs_activity
  #
  #         # For SKB-Input
  #         old_mp.skb_inputs.each do |skbi|
  #           Skb::SkbInput.create(data: skbi.data, processing: skbi.processing, retained_size: skbi.retained_size,
  #                                organization_id: @organization.id, module_project_id: new_mp.id)
  #         end
  #
  #         #For ge_model_factor_descriptions
  #         old_mp.ge_model_factor_descriptions.each do |factor_description|
  #           Ge::GeModelFactorDescription.create(ge_model_id: factor_description.ge_model_id, ge_factor_id: factor_description.ge_factor_id,
  #                                               factor_alias: factor_description.factor_alias, description: factor_description.description,
  #                                               module_project_id: new_mp.id, project_id: new_prj.id, organization_id: @organization.id)
  #         end
  #
  #         # if the module_project is nil
  #         unless old_mp.view.nil?
  #           #Update the new project/estimation views and widgets
  #           update_views_and_widgets(new_prj, old_mp, new_mp)
  #         end
  #
  #
  #         #Update the Unit of works's groups
  #         new_mp.guw_unit_of_work_groups.each do |guw_group|
  #           new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
  #           new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
  #           guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id,
  #                                       project_id: new_prj.id)
  #
  #           # Update the group unit of works and attributes
  #           guw_group.guw_unit_of_works.each do |guw_uow|
  #             new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
  #             new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id
  #
  #             new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
  #             new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
  #             guw_uow.update_attributes(module_project_id: new_uow_mp_id,
  #                                       pbs_project_element_id: new_pbs_id,
  #                                       project_id: new_prj.id)
  #           end
  #         end
  #
  #           new_mp_pemodule_pe_attributes = new_mp.pemodule.pe_attributes
  #           old_prj_pbs_project_elements = old_prj.pbs_project_elements
  #           new_mp_estimation_values = new_mp.estimation_values
  #           hash_nmpevs = {}
  #
  #           new_mp_estimation_values.where(pe_attribute_id: new_mp_pemodule_pe_attributes.map(&:id), in_out: ["input", "output"]).each do |nmpev|
  #             hash_nmpevs["#{nmpev.pe_attribute_id}_#{nmpev.in_out}"] = nmpev
  #           end
  #
  #           ["input", "output"].each do |io|
  #
  #             new_mp_pemodule_pe_attributes.each do |attr|
  #
  #               ev = hash_nmpevs["#{attr.id}_#{io}"]
  #
  #               unless ev.nil?
  #                 new_evs = EstimationValue.where(copy_id: ev.estimation_value_id).all
  #                 old_prj_pbs_project_elements.each do |old_component|
  #                   new_prj_components.each do |new_component|
  #
  #                     ev_low = ev.string_data_low.delete(old_component.id)
  #                     ev_most_likely = ev.string_data_most_likely.delete(old_component.id)
  #                     ev_high = ev.string_data_high.delete(old_component.id)
  #                     ev_probable = ev.string_data_probable.delete(old_component.id)
  #
  #                   ev.string_data_low[new_component.id.to_i] = ev_low
  #                   ev.string_data_most_likely[new_component.id.to_i] = ev_most_likely
  #                   ev.string_data_high[new_component.id.to_i] = ev_high
  #                   ev.string_data_probable[new_component.id.to_i] = ev_probable
  #
  #                       # update ev attribute links
  #                       unless ev.estimation_value_id.nil?
  #                         project_id = new_prj.id
  #                         new_ev = new_evs.select { |est_v| est_v.module_project.project_id == project_id}.first
  #                         if new_ev
  #                           ev.estimation_value_id = new_ev.id
  #                         end
  #                       end
  #
  #                       ev.save
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #         # end
  #       # end
  #
  #       #Archive project last versions
  #       if params['archive_last_project_version'] == "yes"
  #         #get last versions of the projects
  #         project_ancestors = new_prj.ancestors
  #         unless project_ancestors.empty? || project_ancestors.nil?
  #           #Get the archive status of the project's organization
  #           archive_status = new_prj.organization.estimation_statuses.where(is_archive_status: true).first
  #           if archive_status
  #             old_version = old_prj.version_number
  #             project_ancestors.each do |ancestor|
  #               ancestor.update_attribute(:estimation_status_id, archive_status.id)
  #               ancestor.status_comment = "#{I18n.l(Time.now)} - Changement automatique de statut des anciennes versions lors du passage de la version #{old_version} à #{new_prj.version_number} par #{current_user.name}. Nouveau statut : #{archive_status.name} \r ___________________________________________________________________________\r\n" + ancestor.status_comment
  #               ancestor.save
  #             end
  #           end
  #         end
  #       end
  #
  #       #New project last versions
  #       if params['new_project_version'] == "yes"
  #         #get last versions of the projects
  #         #Get the archive status of the project's organization
  #         new_status = new_prj.organization.estimation_statuses.where(is_new_status: true).first
  #         if new_status
  #           old_version = old_prj.version_number
  #           new_prj.update_attribute(:estimation_status_id, new_status.id)
  #           new_prj.status_comment = "#{I18n.l(Time.now)} - Changement automatique de statut des anciennes versions lors du passage de la version #{old_version} à #{new_prj.version_number} par #{current_user.name}. Nouveau statut : #{new_status.name}\r ___________________________________________________________________________\r\n" + new_prj.status_comment
  #           new_prj.save
  #         end
  #       end
  #
  #       unless new_prj.is_model == true || @current_user.super_admin == true
  #         unless @organization.estimations_counter.nil? || @organization.estimations_counter == 0
  #           @organization.estimations_counter -= 1
  #           @organization.save
  #         end
  #       end
  #
  #       flash[:success] = I18n.t(:notice_project_successful_checkout)
  #       redirect_to (edit_project_path(new_prj, :anchor => "tabs-history")), :notice => I18n.t(:notice_project_successful_checkout) and return
  #
  #     else
  #       flash[:error] = I18n.t(:error_project_checkout_failed)
  #       redirect_to organization_estimations_path(@current_organization), :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
  #     end
  #   # end
  #   # rescue
  #   #   flash[:error] = I18n.t(:error_project_checkout_failed)
  #   #   redirect_to organization_estimations_path(@current_organization), :flash => {:error => I18n.t(:error_project_checkout_failed)} and return
  #   #   ##redirect_to(edit_project_path(old_prj, :anchor => 'tabs-history'), :flash => {:error => I18n.t(:error_project_checkout_failed)} ) and return
  #   # end
  #
  #   #else
  #   #redirect_to "#{session[:return_to]}", :flash => {:warning => I18n.t('warning_project_cannot_be_checkout')}
  #   #end  # END commit permission
  # end


private

  # Set the new checked-outed project version_number
  def set_project_version(project_to_checkout)
    #No authorize is required as method is private and could not be accessed by any route

    new_version = project_to_checkout.set_next_project_version

    # parent_version = project_to_checkout.version_number
    #
    # # The new version_number number is calculated according to the parent project position (if parent project has children or not)
    # if project_to_checkout.is_childless?
    #   # get the version_number last numerical value
    #   version_ended = parent_version.split(/(\d\d*)$/).last
    #
    #   #Test if ended version_number value is a Integer
    #   if version_ended.valid_integer?
    #     new_version_ended = "#{ version_ended.to_i + 1 }"
    #     new_version = parent_version.gsub(/(\d\d*)$/, new_version_ended)
    #   else
    #     new_version = "#{ version_ended }.1"
    #   end
    # else
    #   #That means project has successor(s)/children, and a new branch need to be created
    #   branch_version = 1
    #   parent_version_ended_end = 0
    #   if parent_version.include?('-')
    #     split_parent_version = parent_version.split('-')
    #     branch_name = split_parent_version.first
    #     parent_version_ended = split_parent_version.last
    #
    #     split_parent_version_ended = parent_version_ended.split('.')
    #
    #     parent_version_ended_begin = split_parent_version_ended.first
    #     parent_version_ended_end = split_parent_version_ended.last
    #
    #     branch_version = parent_version_ended_begin.to_i + 1
    #
    #     #new_version = parent_version.gsub(/(-.*)/, "-#{branch_version}")
    #
    #     new_version = "#{branch_name}-#{branch_version}.#{parent_version_ended_end}"
    #   else
    #     branch_name = parent_version
    #     new_version = "#{branch_name}-#{branch_version}.0"
    #   end
    #
    #   # If new_version is not available, then check for new available version_number
    #   until is_project_version_available?(project_to_checkout.title, project_to_checkout.alias, new_version)
    #     branch_version = branch_version+1
    #     new_version = "#{branch_name}-#{branch_version}.#{parent_version_ended_end}"
    #   end
    # end
    # new_version
  end

  #Function that check the couples (title,version_number) and (alias, version_number) availability
  def is_project_version_available?(parent_title, parent_alias, new_version)
    begin
      #No authorize required
      project = Project.where('(title=? AND version_number=?) OR (alias=? AND version_number=?)', parent_title, new_version, parent_alias, new_version).first
      if project
        false
      else
        true
      end
    rescue
      false
    end
  end


public

  #Filter the projects list according to version_number
  def add_filter_on_project_version
    @organization = Organization.find(params[:organization_id])
    #No authorize required
    #@projects = Project.find(params[:project_ids])  #@organization.projects
    #@projects = @projects.reject{|i| i.is_model ==  true}
    if params['project_list_name'] == 'filter_organization_projects_version'
      #projects_list = @organization.organization_estimations.where(id: params[:project_ids])

      organization_estimations = @organization.organization_estimations
      projects_list = []
      organization_estimations.each do |p|
        if can?(:see_project, p.project, estimation_status_id: p.project.estimation_status_id)
          projects_list << p.project
        end
      end
    end


    selected_filter_version = params[:filter_selected]
    res = filter_estimation_versions(projects_list, selected_filter_version)
    @filter_version = selected_filter_version

    @object_per_page = (current_user.object_per_page || 10)
    @min = 0
    @max = @object_per_page

    @projects = res[@min..@max].nil? ? [] : res[@min..@max-1]

    last_page = res.paginate(:page => 1, :per_page => @object_per_page).total_pages
    @last_page_min = (last_page.to_i-1) * @object_per_page
    @last_page_max = @last_page_min + @object_per_page

    if params[:is_last_page] == "true" || (@min == @last_page_min) || (@projects.size <= @last_page_max)
      @is_last_page = "true"
    else
      @is_last_page = "false"
    end

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

  #Function that manage link_to from project history graphical view
  def show_project_history
    #No authorize required as authorizations are manage  in each called function...
    @counter = params['counter']
    checked_node_ids = params['checked_node_ids']
    action_id = params['action_id']
    @string_url = ""
    if @counter.to_i > 0
      begin
        project_id = checked_node_ids.first
        organization = Project.find(project_id).organization
        case action_id
          when "edit_node_path"
            @string_url = edit_project_path(:id => project_id)
          when "delete_node_path"
            @string_url = confirm_deletion_path(:project_id => project_id, :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "activate_node_path"
            @string_url = dashboard_path(:project_id => project_id)
          when "find_use_projects" #when "find_use_node_path"
            @string_url = find_use_project_path(:project_id => project_id)
          when "promote_node_path"
            @string_url = commit_path(:project_id => project_id, :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "duplicate_node_path"
            @string_url = "/projects/#{project_id}/duplicate?organization_id=#{organization.id}"
          when "checkout_node_path"
            @string_url = checkout_path(:project_id => project_id)
          #when "collapse_node_path"
            #@string_url = collapse_project_version_path(:project_ids => params[:project_ids], :from_tree_history_view => true, :current_showed_project_id => params['current_showed_project_id'])
          when "set_checkout_version_path"
            @string_url = set_checkout_version_path(:project_id => project_id)
          else
            @string_url = session[:return_to]
        end
      rescue
        @string_url = session[:return_to]
      end
    end
    respond_to do |format|
     format.js
    end
  end

  #Function for collapsing project version_number
  def collapse_project_version
    projects = Project.find_all_by_id(params[:project_ids])
    flash_error = ""
    Project.transaction do
      projects.each do |project|
        begin

          authorize! :delete_project, project

          if is_collapsible?(project.reload)
            project_parent =  project.parent
            project_child = project.children.first
            #delete link between project to delete and its parent and child
            #project_child.update_attribute project.class.ancestry_column, new_ancestry || nil
            project_child.update_attribute(:parent, project_parent)
            project_child.save
            project.destroy
            ###current_user.delete_recent_project(project.id)
            session[:current_project_id] = current_user.projects.first
            session[:project_id] = current_user.projects.first
          else
            flash_error += "\n\n" + I18n.t('project_is_not_collapsible', :project_title_version => "#{project.title}-#{project.version_number}")
            next
          end
        rescue CanCan::AccessDenied
          flash_error += "\n\n" + I18n.t('project_is_not_collapsible', :project_title_version => "#{project.title}-#{project.version_number}") + "," +  I18n.t(:error_access_denied)
          next
        end
      end
    end
    unless flash_error.blank?
      flash[:error] = flash_error + I18n.t('collapsible_project_only')
    end
    if params['current_showed_project_id'].nil? || (params['current_showed_project_id'] && params['current_showed_project_id'].in?(params[:project_ids]) )
      redirect_to organization_estimations_path(@current_organization), :notice => I18n.t('notice_successful_collapse_project_version')
    else
      redirect_to edit_project_path(:id => params['current_showed_project_id'], :anchor => 'tabs-history'), :notice => I18n.t('notice_successful_collapse_project_version')
    end
  end

  #Function that check if project is collapsible
  def is_collapsible?(project)
    #No authorize is required
    begin
      if project.checkpoint?
        if !project.is_root? && project.child_ids.length==1
          true
        else
          false
        end
      else
        false
      end
    rescue
      false
    end
  end

  def show_module_configuration
  end

  # Display the estimation results with activities by profile
  def results_with_activities_by_profile
    authorize! :execute_estimation_plan, @project

    @current_component = current_component
    @project_organization = @project.organization
    @project_organization_profiles = @project_organization.organization_profiles
    @module_project = current_module_project

    # Project pe_wbs_activity
    pe_wbs_activity = @project.pe_wbs_projects.activities_wbs.first

    # Get the wbs_project_element which contain the wbs_activity_ratio
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
    #wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
    # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
    wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

    # By default, use the project default Ratio as Reference, unless PSB got its own Ratio,
    @ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio

    # If Another default ratio was defined in PBS, it will override the one defined in module-project
    if !@current_component.wbs_activity_ratio.nil?
      @ratio_reference = @current_component.wbs_activity_ratio
    end

    @attribute = PeAttribute.find_by_alias("effort")
    @estimation_values = @module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', @attribute.id, "output").first
    @estimation_probable_results = @estimation_values.send('string_data_probable')
    @estimation_pbs_probable_results = @estimation_probable_results[@current_component.id]
  end

  # update and show comments regarding the estimation status changes
  def add_comment_on_status_change
    @project = Project.find(params[:project_id])
    @text_comments = ""
    if !@project.status_comment.nil?
      @text_comments = @project.status_comment
    end
  end

  # update comments on estimation status changes
  def update_comments_status_change

    # Biz.configure do |config|
    #   config.hours = {
    #       mon: {'09:00' => '12:00', '13:00' => '17:00'},
    #       tue: {'09:00' => '12:00', '13:00' => '17:00'},
    #       wed: {'09:00' => '12:00', '13:00' => '17:00'},
    #       thu: {'09:00' => '12:00', '13:00' => '17:00'},
    #       fri: {'09:00' => '12:00', '13:00' => '17:00'}
    #   }
    # end

    @project = Project.find(params[:project_id])

    # ptitle = @project.title
    # oname = @project.organization.name
    # status_history = StatusHistory.where(organization: oname,
    #                                      project: ptitle,
    #                                      version_number: @project.version_number).last
    #
    # time_now = Time.now
    #
    # unless status_history.nil?
    #   gap = Biz.within(status_history.change_date, time_now).in_seconds
    # end
    #
    # unless params[:project][:estimation_status_id].nil?
    #   StatusHistory.create(organization: @project.organization.name,
    #                        project_id: @project.id,
    #                        project: @project.title,
    #                        version_number: @project.version_number,
    #                        change_date: time_now,
    #                        action: "Changement de statut",
    #                        comments: params["project"]["new_status_comment"].to_s,
    #                        origin: @project.estimation_status.name,
    #                        target: EstimationStatus.find(params[:project][:estimation_status_id].to_i).name,
    #                        user: current_user.name,
    #                        gap: gap)
    # end

    new_comments = ""
    auto_updated_comments = ""
    # Add and update comments on estimation status change
    if params["project"]["new_status_comment"] and !params["project"]["new_status_comment"].empty?
      new_comments << show_status_change_comments(params["project"]["new_status_comment"])
    end

    # Before saving project, update the project comment when the status has changed
    if params[:project][:estimation_status_id]
      new_status_id = params[:project][:estimation_status_id].to_i
      if @project.estimation_status_id != new_status_id

        auto_updated_comments << auto_update_status_comment(params[:project_id], new_status_id)
        new_comments = auto_updated_comments + new_comments
        #update estimation status
        ###@project.estimation_status_id = params["project"]["estimation_status_id"]

        next_status = EstimationStatus.find(params["project"]["estimation_status_id"]) rescue nil
        if !next_status.nil? && next_status.create_new_version_when_changing_status == true

          new_version_number = set_project_version(@project)
          new_project = @project.create_new_version_when_changing_status(next_status, new_version_number)

          if new_project
            new_status_name = EstimationStatus.find(new_status_id).name rescue ""
            archive_status_name = @project.organization.estimation_statuses.where(is_archive_status: true).first.name rescue ""
            last_status_comments = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_status_from_to, from_status: new_status_name, to_status: archive_status_name, current_user_name: "l'automatisme de changement de statut")}. \r\n"
            last_status_comments << "___________________________________________________________________________\r\n"
            new_comments = last_status_comments + new_comments

          #   ptitle = @project.title
          #   oname = @project.organization.name
          #
          #   time_now = Time.now
          #
          #   @project.status_histories.each do |sh|
          #     StatusHistory.create(organization: sh.organization,
          #                          project_id: sh.project_id,
          #                          project: sh.project,
          #                          version_number: sh.version_number,
          #                          change_date: sh.change_date,
          #                          action: sh.action,
          #                          comments: sh.comments,
          #                          origin: sh.origin,
          #                          target: sh.target,
          #                          user: sh.user,
          #                          gap: sh.gap)
          #   end
          #
          #   StatusHistory.create(organization: new_project.organization.name,
          #                        project_id: new_project.id,
          #                        project: new_project.title,
          #                        version_number: new_project.version_number,
          #                        change_date: time_now,
          #                        action: "Création",
          #                        comments: params["project"]["new_status_comment"].to_s,
          #                        origin: @project.estimation_status.name,
          #                        target: EstimationStatus.find(params[:project][:estimation_status_id].to_i).name,
          #                        user: current_user.name,
          #                        gap: gap)
          end

        else
          @project.estimation_status_id = params["project"]["estimation_status_id"]
        end
      end
    end

    #add the last comments to the new comments
    new_comments << "#{@project.status_comment} \r\n"
    #update project's comments
    @project.status_comment = new_comments

    if @project.save
      flash[:notice] = I18n.t(:notice_comment_status_successfully_updated)
    else
      flash[:error] = I18n.t('errors.messages.not_saved')
    end

    if request.env["HTTP_REFERER"].present?
      redirect_to :back
    else
      redirect_to organization_estimations_path(@current_organization)
    end
  end

  # Display comments about estimation status changes
  def show_status_change_comments(new_comments, current_note_length = 0)
    user_infos = ""
    user_infos << "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name}\r\n"
    user_infos << "#{new_comments} \r\n"
    user_infos << "___________________________________________________________________________\r\n"
  end

  # Automatically update the project's comment when estimation_status has changed
  def auto_update_status_comment(project_id, new_status_id)
    project = Project.find(project_id)
    if project

      # Get the project status before updating the value
      last_estimation_status_name = project.estimation_status_id.nil? ? "" : project.estimation_status.name

      # Get changes on the project estimation_status_id after the update (to be compra with the last one)
      new_estimation_status_name = new_status_id.nil? ? "" : EstimationStatus.find(new_status_id).name

      new_comments = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_status_from_to, from_status: last_estimation_status_name, to_status: new_estimation_status_name, current_user_name: current_user.name)}. \r\n"
      new_comments << "___________________________________________________________________________\r\n"
      #new_comments << current_comments
    end
  end

  def export_dashboard
    @project = Project.find(params[:project_id])
    @current_organization = @project.organization
    @pbs_project_element = current_component
    @user = current_user
    @module_projects = @project.module_projects

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Test",
               encoding: "UTF-8",
               page_size: 'A4',
               orientation: :landscape
      end
    end
  end

  def multiple_export_dashboard
    @projects = []
    conditions = {}
    conditions[:request_number] = params[:request_number] unless params[:request_number].blank?
    conditions[:title] = params[:title] unless params[:title].blank?
    conditions[:business_need] = params[:business_need] unless params[:business_need].blank?
    #conditions[:date_min] = params[:date_min] unless params[:date_min].blank?
    #conditions[:date_max] = params[:date_max] unless params[:date_max].blank?

    @projects = {}
    tmp = Hash.new {|h,k| h[k] = [] }
    Project.where(conditions).where(start_date: params[:date_min] .. params[:date_max]).each do |project|
      tmp[project.request_number.to_s] << project
      @projects[project.business_need.to_s] = tmp
    end

    @user = current_user
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Test",
               encoding: "UTF-8",
               page_size: 'A4',
               orientation: :landscape
      end
    end
  end

  private
  def generate_dashboard
    authorize! :show_project, @project

    # return if user doesn't have the rigth to consult the estimation
    if !can_show_estimation?(@project)
      redirect_to(organization_estimations_path(@current_organization), flash: { warning: I18n.t(:warning_no_show_permission_on_project_status)}) and return
    end

    if @current_organization.is_image_organization == true
      redirect_to(root_url, flash: { error: "Vous ne pouvez pas accéder à une organization image"}) and return
    end

    set_page_title I18n.t(:spec_estimations, parameter: @current_organization)

    @user = current_user
    @pemodules ||= Pemodule.all
    @module_project = current_module_project
    @show_hidden = 'true'

    status_comment_link = ""
    if can_alter_estimation?(@project) && ( can?(:alter_estimation_status, @project) || can?(:alter_project_status_comment, @project))
      status_comment_link = "#{main_app.add_comment_on_status_change_path(:project_id => @project.id)}"
    end
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@current_organization.id}", @current_organization.to_s => organization_estimations_path(@current_organization), "#{@project}" => "#{main_app.edit_project_path(@project)}", "<span class='badge' style='background-color: #{@project.status_background_color}'> #{@project.status_name}" => status_comment_link

    @project_organization = @project.organization
    @module_projects = @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?

    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    if @module_project.pemodule.alias == "expert_judgement"
      if current_module_project.expert_judgement_instance.nil?
        @expert_judgement_instance = ExpertJudgement::Instance.first
      else
        @expert_judgement_instance = current_module_project.expert_judgement_instance
      end

      array_attributes = Array.new

      if @expert_judgement_instance.enabled_size?
        array_attributes << "retained_size"
      end

      if @expert_judgement_instance.enabled_effort?
        array_attributes << "effort"
      end

      if @expert_judgement_instance.enabled_cost?
        array_attributes << "cost"
      end

      @expert_judgement_attributes = PeAttribute.where(alias: array_attributes)

      array_attributes.each do |a|
        ExpertJudgement::InstanceEstimate.where( pe_attribute_id: PeAttribute.find_by_alias(a).id,
                                                 expert_judgement_instance_id: @expert_judgement_instance.id.to_i,
                                                 module_project_id: current_module_project.id,
                                                 pbs_project_element_id: current_component.id).first_or_create!
      end

    elsif @module_project.pemodule.alias == "skb"
      @kb_model = current_module_project.kb_model
      @kb_input = Kb::KbInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    kb_model_id: @kb_model.id).first_or_create
      @project_list = []

    elsif @module_project.pemodule.alias == "ge"
      @ge_model = current_module_project.ge_model
      @ge_input = Ge::GeInput.where(module_project_id: @module_project.id,
                                    organization_id: @project_organization.id,
                                    ge_model_id: @ge_model.id).first_or_create
      @ge_input_values = @ge_input.values
      @ge_factors = @ge_model.ge_factors

      @ge_factors_values = @ge_model.ge_factor_values
      if @ge_factors_values.length > 0
        @ge_factors_groups = @ge_factors_values.group_by(&:factor_scale_prod) #@ge_factors_values.group_by { |f| f.factor_scale_prod }
        @ge_scale_factors = @ge_factors_groups['S']
        @ge_prod_factors = @ge_factors_groups['P']
        @ge_conversion_factors = @ge_factors_groups['C']

        #@ge_factor_values_per_type = @ge_factors_values.group_by(&:factor_type)

        @ge_scale_factors_per_type =  @ge_scale_factors.nil? ? {} : @ge_scale_factors.group_by(&:factor_type)
        @ge_prod_factors_per_type = @ge_prod_factors.nil? ? {} : @ge_prod_factors.group_by(&:factor_type)
        @ge_conversion_factors_per_type = @ge_conversion_factors.nil? ? {} : @ge_conversion_factors.group_by(&:factor_type)

        @all_factors_values_hash = Hash.new
        @all_factors_values_hash["S"] = Hash.new
        @all_factors_values_hash["P"] = Hash.new
        @all_factors_values_hash["C"] = Hash.new

        @ge_type_factors_per_scale_prod = Hash.new
        @ge_type_factors_per_scale_prod["S"] = @ge_scale_factors_per_type
        @ge_type_factors_per_scale_prod["P"] = @ge_prod_factors_per_type
        @ge_type_factors_per_scale_prod["C"] = @ge_conversion_factors_per_type

        @ge_type_factors_per_scale_prod.each do |scale_prod, factors_per_type|
          factors_per_type.each do |type, factor_values_array|
            @type_factors_values_hash = Hash.new
            @ge_model.ge_factors.where(scale_prod: "#{scale_prod}").each do |f|
              if f.factor_type == type
                factors_array = Array.new
                factor_values_array.each do |factor_value|
                  if factor_value.factor_alias == f.alias
                    factors_array << factor_value  #[factor_value.value_text, factor_value.id]
                  end
                end
                @type_factors_values_hash["#{f.alias}"] = factors_array
              end
            end
            @all_factors_values_hash["#{scale_prod}"]["#{type}"] = @type_factors_values_hash
          end
        end
      end


    elsif @module_project.pemodule.alias == "operation"
      @operation_model = current_module_project.operation_model
    elsif @module_project.pemodule.alias == "guw"

      #if current_module_project.guw_model.nil?
      #  @guw_model = Guw::GuwModel.first
      #else
      @guw_model = current_module_project.guw_model
      #end
      @unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(pbs_project_element_id: current_component.id, module_project_id: current_module_project.id).all

    elsif @module_project.pemodule.alias == "staffing"
      @staffing_model = current_module_project.staffing_model
      trapeze_default_values = @staffing_model.trapeze_default_values
      @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: current_component.id).first
      if @staffing_custom_data.nil?
        @staffing_custom_data = Staffing::StaffingCustomDatum.create(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: current_component.id,
                                                                     staffing_method: 'trapeze',
                                                                     period_unit: 'week', global_effort_type: 'probable', mc_donell_coef: 6, puissance_n: 0.33,
                                                                     trapeze_default_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] },
                                                                     trapeze_parameter_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] } )
      end
    else
    end
  end

  private def clean_view_widget
    # if @project.is_model == true
    #   pf = ProjectField.where(project_id: @project.id,
    #                           value: nil).first
    #   unless pf.nil?
    #     if pf.view_widget.nil?
    #       pf.delete
    #     end
    #   end
    unless @project.is_model == false
      ProjectField.where(project_id: @project.id,
                         value: nil).all.each{ |i| i.delete }
    end
  end
end
