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

class OrganizationProfilesController < ApplicationController

  # GET /organization_profiles/new
  # GET /organization_profiles/new.json
  def new
    authorize! :manage, OrganizationProfile

    set_page_title I18n.t(:new_organization_profiles)
    @organization = Organization.find_by_id(params[:organization_id])
    @organization_profile = OrganizationProfile.new
    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('new_profile') => ""
  end

  # GET /organization_profiles/1/edit
  def edit
    authorize! :show_organization_profiles, OrganizationProfile
    set_page_title I18n.t(:edit_organization_profiles)
    @organization_profile = OrganizationProfile.find(params[:id])

    @organization = @organization_profile.organization

    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('organization_profiles_edition') => ""
  end

  # POST /organization_profiles
  # POST /organization_profiles.json
  def create
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:new_organization_profiles)

    @organization_profile = OrganizationProfile.new(params[:organization_profile])
    @organization = Organization.find_by_id(params['organization_profile']['organization_id'])

    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('new_profile') => ""

    if @organization_profile.save
      flash[:notice] = I18n.t(:notice_profile_successful_created)
     redirect_to redirect_apply(nil, new_organization_organization_profile_path(@organization), organization_setting_path(@organization, :anchor => 'tabs-profile'))
    else
      flash[:error] = I18n.t(:error_profile_failed_created)
      render action: "new"
    end
  end

  # PUT /organization_profiles/1
  # PUT /organization_profiles/1.json
  def update
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:update_organization_profiles)

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    set_breadcrumbs I18n.t(:profiles) => organization_setting_path(@organization, anchor: "tabs-profile"), I18n.t('organization_profiles_edition') => ""

    respond_to do |format|
      if @organization_profile.update_attributes(params[:organization_profile])
        format.html { redirect_to redirect_apply(edit_organization_organization_profile_path(@organization, @organization_profile), nil, organization_setting_path(@organization, :anchor => 'tabs-profile') ), notice: I18n.t(:notice_profile_successful_updated) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_profiles/1
  # DELETE /organization_profiles/1.json
  def destroy
    authorize! :manage, OrganizationProfile
    set_page_title I18n.t(:Delete_organization_profiles)

    @organization_profile = OrganizationProfile.find(params[:id])
    @organization = @organization_profile.organization
    @organization_profile.destroy

    respond_to do |format|
      format.html { redirect_to organization_setting_path(@organization, anchor: 'tabs-profile') }
      format.json { head :no_content }
    end
  end

  def refresh_organization_profiles
    if !params[:profile_category_id].nil?
      @profile_category = ProfileCategory.find(params[:profile_category_id])
      @profiles = @profile_category.profiles
    end
    #Voir si il faut modifier le cout horaire lorsqu'on change de profile
  end

  def refresh_organization_profile_data
    @profile_name = nil; @profile_description = nil; @profile_cost_per_hour= nil
    if !params[:profile_id].nil?
      @profile_for_organization = Profile.find(params[:profile_id])
      @profile_name = @profile_for_organization.name
      @profile_description = @profile_for_organization.description
      @profile_cost_per_hour = @profile_for_organization.cost_per_hour
    end
  end

  def maj_mix_profil
    # MIX_PROFIL
    project = Project.where(title: "EBE001 (Calcul Mix Profil)").first
    organization = project.organization
    module_project = project.module_projects.last
    project_pbs_project_element = project.pbs_project_elements.first

    mpres = ModuleProjectRatioElement.where(organization_id: project.organization_id,
                                            module_project_id: module_project.id,
                                            pbs_project_element_id: project_pbs_project_element.id).all

    mpres.each do |mpre|
      tjm = mpre.tjm.to_f.round(2)

      mpre_wbs_activity_element = mpre.wbs_activity_element
      mpre_wbs_activity_element_name = mpre_wbs_activity_element.name.to_s

      op = OrganizationProfile.where(organization_id: organization.id, name: mpre_wbs_activity_element_name).first
      unless op.nil?
        op.cost_per_hour = tjm
        op.save
      end

      mpre_wbs_activity_element_name_without_localisation = mpre_wbs_activity_element_name.gsub(' PARIS', '').gsub(' PROVINCE', '').gsub('MCO', '')

      organization.guw_models.each do |guw_model|

        guw_model.guw_types.where("name LIKE ?", "%#{mpre_wbs_activity_element_name_without_localisation}%").each do |guw_type|

          guw_type_guw_complexity = guw_type.guw_complexities.first

          if guw_type.name.include?("MCO")
            guw_type_guw_complexity.weight = tjm
          else

            gcces = Guw::GuwComplexityCoefficientElement.where(organization_id: organization.id,
                                                               guw_model_id: guw_model.id,
                                                               guw_complexity_id: guw_type_guw_complexity.id,
                                                               guw_type_id: guw_type.id).all

            gcces.each do |gcce|

              gcce_guw_coefficient_element = gcce.guw_coefficient_element

              if (gcce_guw_coefficient_element.name.include?(mpre_wbs_activity_element_name)) ||
                 (gcce_guw_coefficient_element.name.include?("Paris") && mpre_wbs_activity_element_name.include?('PARIS')) ||
                 (gcce_guw_coefficient_element.name.include?("Province") && mpre_wbs_activity_element_name.include?('PROVINCE'))

                if gcce_guw_coefficient_element.name.include?("SNCF")
                  unless tjm == 0.0
                    gcce.value = tjm + mpre_wbs_activity_element.description.to_i
                    gcce.save
                  end
                else
                  unless tjm == 0.0
                    gcce.value = tjm
                    gcce.save
                  end
                end
              end
            end
          end
        end
      end
    end
    redirect_to main_app.edit_organization_path(organization)
  end

  def maj_pe
    #PETITES EVOLUTIONS
    project = Project.where(title: "EBE0001 TJM Petites Evol.").first
    organization = project.organization
    module_project = project.module_projects.last

    mpres = ModuleProjectRatioElement.where(organization_id: project.organization_id,
                                            module_project_id: module_project.id,
                                            copy_id: nil,
                                            position: nil).all

    mpres.each do |mpre|

      value = mpre.retained_cost_probable / mpre.retained_effort_probable

      organization.guw_models.each do |guw_model|
        guw_model.guw_types.where(name: "CPT1").each do |guw_type|
          guw_type_guw_complexity = guw_type.guw_complexities.first

          gcces = Guw::GuwComplexityCoefficientElement.where(organization_id: organization.id,
                                                             guw_model_id: guw_model.id,
                                                             guw_complexity_id: guw_type_guw_complexity.id,
                                                             guw_type_id: guw_type.id).all

          gcces.each do |gcce|
            gcce_guw_coefficient_element = gcce.guw_coefficient_element
            if gcce_guw_coefficient_element.name == "Conv."
              gcce_guw_coefficient_element.value = value
              gcce_guw_coefficient_element.default_display_value = value
              gcce_guw_coefficient_element.save
            end
          end
        end
      end
    end
  end

end
