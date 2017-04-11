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


class Guw::GuwOutputsController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_outputs = @guw_model.guw_outputs
    set_page_title I18n.t(:output)
  end

  def new
    @guw_output = Guw::GuwOutput.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title "New"

    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization)
  end

  def edit
    @guw_output = Guw::GuwOutput.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    set_page_title "Edit"
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params",
                    @current_organization.to_s => main_app.organization_estimations_path(@current_organization),
                    @guw_output => guw.edit_guw_model_path(@guw_output.guw_model, organization_id: @current_organization.id)
  end

  def create
    @guw_output = Guw::GuwOutput.new(params[:guw_output])
    @guw_model = @guw_output.guw_model
    @guw_output.save

    attr = PeAttribute.where(name: @guw_output.name,
                             alias: @guw_output.name.underscore.gsub(" ", "_"),
                             description: @guw_output.name,
                             guw_model_id: @guw_output.guw_model_id).first_or_create!

    pm = Pemodule.where(alias: "guw").first

    am = AttributeModule.where(pe_attribute_id: attr.id,
                               pemodule_id: pm.id,
                               in_out: "both",
                               guw_model_id: @guw_output.guw_model_id).first_or_create!

    @guw_model.module_projects.each do |module_project|
      ['input', 'output'].each do |in_out|
        mpa = EstimationValue.create(pe_attribute_id: attr.id,
                                     module_project_id: module_project.id,
                                     in_out: in_out,
                                     string_data_low: { :pe_attribute_name => @guw_output.name },
                                     string_data_most_likely: { :pe_attribute_name => @guw_output.name },
                                     string_data_high: { :pe_attribute_name => @guw_output.name })
      end
    end

    expire_fragment "guw"

    redirect_to guw.edit_guw_model_path(@guw_output.guw_model_id, organization_id: @current_organization.id, anchor: "tabs-factors")
  end

  def update
    @guw_output = Guw::GuwOutput.find(params[:id])
    @guw_model = @guw_output.guw_model

    old_attr_name = @guw_output.name
    @guw_output.update_attributes(params[:guw_output])

    pm = Pemodule.where(alias: "guw").first

    attr = PeAttribute.where(name: old_attr_name,
                             guw_model_id: @guw_model.id).first

    if attr.nil?

      at = PeAttribute.create(name: @guw_output.name,
                              alias: @guw_output.name.underscore.gsub(" ", "_"),
                              description: @guw_output.name,
                              guw_model_id: @guw_model.id)

      am = AttributeModule.create(pe_attribute_id: at.id,
                                  pemodule_id: pm.id,
                                  in_out: "both",
                                  guw_model_id: @guw_model.id)

      old_attr.estimation_values.each do |ev|
        ev.string_data_low = { pe_attribute_name: @guw_output.name, default_low: nil }
        ev.string_data_most_likely = { pe_attribute_name: @guw_output.name, default_low: nil }
        ev.string_data_high = { pe_attribute_name: @guw_output.name, default_low: nil }
        ev.pe_attribute_id = at.id
        ev.save(validate: false)
      end

    else

      attr.name = @guw_output.name
      attr.alias = @guw_output.name.underscore.gsub(" ", "_")
      attr.description = @guw_output.name
      attr.guw_model_id = @guw_model.id

      if attr.estimation_values.empty?
        @guw_model.module_projects.each do |module_project|
          ['input', 'output'].each do |in_out|
            mpa = EstimationValue.create(pe_attribute_id: attr.id,
                                         module_project_id: module_project.id,
                                         in_out: in_out,
                                         string_data_low: { :pe_attribute_name => @guw_output.name },
                                         string_data_most_likely: { :pe_attribute_name => @guw_output.name },
                                         string_data_high: { :pe_attribute_name => @guw_output.name })
          end
        end
      else
        attr.estimation_values.each do |ev|
          ev.string_data_low = { pe_attribute_name: @guw_output.name, default_low: nil }
          ev.string_data_most_likely = { pe_attribute_name: @guw_output.name, default_low: nil }
          ev.string_data_high = { pe_attribute_name: @guw_output.name, default_low: nil }
          ev.pe_attribute_id = attr.id
          ev.save(validate: false)
        end
      end

      am = AttributeModule.where(pe_attribute_id: attr.id,
                                 pemodule_id: pm.id,
                                 guw_model_id: nil).first_or_create

      am.guw_model_id = @guw_output.guw_model_id

      am.save
      attr.save
    end

    @guw_model.save

    set_page_title I18n.t(:Edit_Units_Of_Work)
    redirect_to guw.edit_guw_model_path(@guw_model.id,
                                        organization_id: @current_organization.id,
                                        anchor: "tabs-factors")

    expire_fragment "guw"

  end

  def destroy
    @guw_output = Guw::GuwOutput.find(params[:id])
    @guw_model = @guw_output.guw_model
    @guw_output.delete

    #Pas encore bon !
    attr = PeAttribute.where(alias: @guw_output.name.underscore.gsub(" ", "_")).first
    pm = Pemodule.where(alias: "guw").first
    AttributeModule.where(pe_attribute_id: attr.id,
                          pemodule_id: pm.id,
                          guw_model_id: @guw_output.guw_model.id).all.each do |am|
      am.delete
    end

    attr.delete

    orders = @guw_model.orders

    unless attr.nil?
      attr_name = attr.name
      orders.delete(attr_name)
      @guw_model.orders = orders
    end

    if @guw_model.default_display == "list"
      redirect_to guw.guw_model_all_guw_types_path(@guw_model)
    else
      redirect_to guw.guw_model_path(@guw_model)
    end
  end
end
