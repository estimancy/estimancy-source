#encoding: utf-8
#########################################################################
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
########################################################################

class AttributeOrganizationsController < ApplicationController
  load_and_authorize_resource

  # Update the Organization attributes
  def update_selected_attribute_organizations
    authorize! :manage_organizations, Organization
    @organization = Organization.find(params[:organization_id])
    @organization_projects = @organization.projects
    # Get the Initialization module. It is set in the ApplicationController : @initialization_module = Pemodule.find_by_alias("initialization")
    attributes_ids = params[:organization][:pe_attribute_ids]

    @organization.attribute_organizations.each do |m|
      unless attributes_ids.include?(m.pe_attribute_id.to_s)
        unless @initialization_module.nil?
          #Delete all estimations of its related projects
          @organization_projects.each do |project|
            project_cap_module_projects = project.module_projects.where(organization_id: @organization.id, pemodule_id: @initialization_module.id)

            project_cap_module_projects.each do |module_project|
              project_est_values = module_project.estimation_values.where(organization_id: @organization.id, pe_attribute_id: m.pe_attribute_id)
              project_est_values.destroy_all
            end
          end
        end
        #Delete the attribute_organization
        m.destroy
      end
      # We no longer need to delete attribute from the attributes_ids array because we are now using the "first_or_initialize" method
      ###attributes_ids.delete(m.pe_attribute_id.to_s)
    end

    attributes_ids.reject(&:empty?).each do |g|
      # Find the attribute_organization or create it if not exist
      attr_org = AttributeOrganization.where(:pe_attribute_id => g.to_i, :organization_id => @organization.id).first_or_initialize
      attr_org.update_attribute('is_mandatory', params[:is_mandatory][g])

      #Update de Initialization module 's estimation_values
      unless @initialization_module.nil?
        @organization_projects.each do |project|
          module_project = project.module_projects.where("pemodule_id = ?", @initialization_module.id).first
          unless module_project.nil?
            #Create corresponding Estimation_value
            ['input', 'output'].each do |in_out|
              mpa = EstimationValue.where(:organization_id => @organization.id, :module_project_id => module_project.id, :pe_attribute_id => g.to_i, :in_out => in_out).first_or_initialize
              mpa.update_attributes( :is_mandatory => attr_org.is_mandatory,
                                     :description => attr_org.pe_attribute.description,
                                     :string_data_low => {:pe_attribute_name => attr_org.pe_attribute.name, :default_low => ""},
                                     :string_data_most_likely => {:pe_attribute_name => attr_org.pe_attribute.name, :default_most_likely => ""},
                                     :string_data_high => {:pe_attribute_name => attr_org.pe_attribute.name, :default_high => ""})
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
    redirect_to redirect_apply(edit_organization_path(@organization, :anchor => 'tabs-2'), nil, '/organizationals_params')
  end

end
