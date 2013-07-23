#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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
########################################################################

class AttributeOrganizationsController < ApplicationController

  # Update the Organization attributes
  def update_selected_attribute_organizations
    authorize! :manage_organizations, Organization
    @organization = Organization.find(params[:organization_id])
    @organization_projects = @organization.projects
    # Get the Capitalization module. It is set in the ApplicationController : @capitalization_module = Pemodule.find_by_alias("capitalization")
    attributes_ids = params[:organization][:pe_attribute_ids]

    @organization.attribute_organizations.each do |m|
      unless attributes_ids.include?(m.pe_attribute_id.to_s)
        unless @capitalization_module.nil?
          #Delete all estimations of its related projects
          @organization_projects.each do |project|
            project_cap_module_projects = project.module_projects.where("pemodule_id = ?", @capitalization_module.id)
            project_cap_module_projects.each do |module_project|
              project_est_values = module_project.estimation_values.where("pe_attribute_id = ?", m.pe_attribute_id)
              project_est_values.destroy_all
            end
          end
        end
        #Delete the attribute_organization
        m.destroy
      end
      attributes_ids.delete(m.pe_attribute_id.to_s)
    end

    attributes_ids.reject(&:empty?).each do |g|
      @organization.attribute_organizations.create(:pe_attribute_id => g.to_i)
      #Update de Capitalization's estimation_values
      unless @capitalization_module.nil?
        attr_org = @organization.attribute_organizations.where("pe_attribute_id = ?", g).first
        @organization_projects.each do |project|
          module_project = project.module_projects.where("pemodule_id = ?", @capitalization_module.id).first
          unless module_project.nil?
            #Create corresponding Estimation_value
            ['input', 'output'].each do |in_out|
              mpa = EstimationValue.create(:pe_attribute_id => g.to_i,
                                           :module_project_id => module_project.id,
                                           :in_out => in_out,
                                           :is_mandatory => attr_org.is_mandatory,
                                           :description => attr_org.pe_attribute.description,
                                           #:display_order => attr_org.display_order,
                                           :string_data_low => {:pe_attribute_name => attr_org.pe_attribute.name, :default_low => ""},
                                           :string_data_most_likely => {:pe_attribute_name => attr_org.pe_attribute.name, :default_most_likely => ""},
                                           :string_data_high => {:pe_attribute_name => attr_org.pe_attribute.name, :default_high => ""})
              #:custom_attribute => attr_org.custom_attribute,
              #:project_value => attr_org.project_value)
            end
          end
        end
      end
    end
    @organization.pe_attributes(force_reload = true)

    if @organization.save
      flash[:notice] = I18n.t (:notice_organization_successful_updated)
    else
      flash[:notice] = I18n.t (:error_administration_setting_failed_update)
    end

    @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => params[:organization_id]})
    redirect_to redirect_save("/organizationals_params"), :notice => "#{I18n.t (:notice_attribute_organization_successful_updated)}"
  end

  # Update the Organizational attribute parameters
  def update_attribute_organizations_settings
    authorize! :manage_organizations, Organization
    current_organization = Organization.find(params[:organization_id])
    organization_projects = current_organization.projects

    selected_attributes = params[:attributes]
    selected_attributes.each_with_index do |attr, i|
      attribute = AttributeOrganization.first(:conditions => {:pe_attribute_id => attr.to_i, :organization_id => params[:organization_id]})
      attribute.update_attribute('is_mandatory', params[:is_mandatory][i])

      unless @capitalization_module.nil?
        #Get Capitalization corresponding EstimationValues for each project of this organization
        organization_projects.each do |project|
          cap_module_project = project.module_projects.find_by_pemodule_id(@capitalization_module.id)
          unless cap_module_project.nil?
            cap_estimation_values = cap_module_project.estimation_values.where("pe_attribute_id = ?", attr.to_i)
            cap_estimation_values.each do |est_val|
              est_val.update_attribute("is_mandatory", params[:is_mandatory][i])
            end
          end
        end
      end
    end
    redirect_to redirect_save("/organizationals_params"), :notice => "#{I18n.t (:notice_attribute_organization_successful_updated)}"
  end

end
