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

module Guw
  class GuwUnitOfWork < ActiveRecord::Base

    belongs_to :organization
    belongs_to :guw_type
    belongs_to :guw_model
    belongs_to :guw_complexity
    belongs_to :guw_unit_of_work_group
    belongs_to :organization_technology
    belongs_to :guw_work_unit
    belongs_to :guw_weighting
    belongs_to :guw_factor
    belongs_to :module_project
    belongs_to :project

    has_many :guw_unit_of_work_attributes, dependent: :destroy
    has_many :guw_coefficient_element_unit_of_works, dependent: :destroy

    # validates_presence_of :name

    serialize :ajusted_size
    serialize :size
    serialize :effort
    serialize :cost

    amoeba do
      enable
      include_association [:guw_unit_of_work_attributes, :guw_coefficient_element_unit_of_works]
      # include_association [:guw_coefficient_element_unit_of_works]
    end

    def to_s
      name
    end

    def self.update_estimation_values(module_project, pbs_project_element)
      #we save the effort now in estimation values
      @module_project = module_project
      @project = @module_project.project
      @guw_model = @module_project.guw_model
      organization_id = @module_project.organization_id
      component = pbs_project_element

      unless @guw_model.nil?
        if @guw_model.config_type == "old"
          @module_project.guw_model_id = @guw_model.id
          @module_project.save

          retained_size = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                   guw_model_id: @guw_model.id,
                                                   project_id: @project.id,
                                                   module_project_id: @module_project.id,
                                                   pbs_project_element_id: component.id,
                                                   selected: true,
                                                   guw_unit_of_work_id: nil).map(&:ajusted_size).compact.sum

          theorical_size = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                    guw_model_id: @guw_model.id,
                                                    project_id: @project.id,
                                                    module_project_id: @module_project.id,
                                                    pbs_project_element_id: component.id,
                                                    selected: true,
                                                    guw_unit_of_work_id: nil).map(&:size).compact.sum

          effort = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                            guw_model_id: @guw_model.id,
                                            project_id: @project.id,
                                            module_project_id: @module_project.id,
                                            pbs_project_element_id: component.id,
                                            selected: true, guw_unit_of_work_id: nil).map(&:effort).compact.sum

          cost = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                          guw_model_id: @guw_model.id,
                                          project_id: @project.id,
                                          module_project_id: @module_project.id,
                                          pbs_project_element_id: component.id,
                                          selected: true, guw_unit_of_work_id: nil).map(&:cost).compact.sum

          all_unit_of_work_groups = Guw::GuwUnitOfWorkGroup.where(organization_id: organization_id,
                                                                  guw_model_id: @guw_model.id,
                                                                  project_id: @project.id,
                                                                  module_project_id: @module_project.id,
                                                                  pbs_project_element_id: component.id).all

          number_of_unit_of_work = all_unit_of_work_groups.map{|i| i.guw_unit_of_works}.flatten.size

          selected_of_unit_of_work = all_unit_of_work_groups.map{|i| i.guw_unit_of_works.where(selected: true)}.flatten.size

          offline_unit_of_work = all_unit_of_work_groups.map{|i| i.guw_unit_of_works.where(off_line: true)}.flatten.size

          flagged_unit_of_work = all_unit_of_work_groups.map{|i| i.guw_unit_of_works.where(flagged: true)}.flatten.size


          @module_project.pemodule.attribute_modules.each do |am|
            am_pe_attribute = am.pe_attribute
            unless am_pe_attribute.nil?
              @evs = EstimationValue.where(organization_id: organization_id,
                                           :module_project_id => @module_project.id,
                                           :pe_attribute_id => am_pe_attribute.id).all
              @evs.each do |ev|
                tmp_prbl = Array.new
                ["low", "most_likely", "high"].each do |level|


                  if am_pe_attribute.alias == "retained_size"
                    ev.send("string_data_#{level}")[component.id] = retained_size
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "effort"
                    ev.send("string_data_#{level}")[component.id] = effort.to_f * (@guw_model.hour_coefficient_conversion.nil? ? 1 : @guw_model.hour_coefficient_conversion)
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "theorical_size"
                    ev.send("string_data_#{level}")[component.id] = theorical_size
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  end

                  guw = Guw::Guw.new(theorical_size, retained_size, params["complexity_#{level}"], @project)

                  if am_pe_attribute.alias == "cost"
                    ev.send("string_data_#{level}")[component.id] = cost
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "introduced_defects"
                    ev.send("string_data_#{level}")[component.id] = guw.get_defects(retained_size, component, @module_project)
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "number_of_unit_of_work"
                    ev.send("string_data_#{level}")[component.id] = number_of_unit_of_work
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "offline_unit_of_work"
                    ev.send("string_data_#{level}")[component.id] = offline_unit_of_work
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "flagged_unit_of_work"
                    ev.send("string_data_#{level}")[component.id] = flagged_unit_of_work
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  elsif am_pe_attribute.alias == "selected_of_unit_of_work"
                    ev.send("string_data_#{level}")[component.id] = selected_of_unit_of_work
                    tmp_prbl << ev.send("string_data_#{level}")[component.id]
                  end
                  ev.update_attribute(:"string_data_#{level}", ev.send("string_data_#{level}"))
                end

                if ev.in_out == "output"

                  h = Hash.new
                  h = {
                      :"string_data_low" => { @component.id => tmp_prbl[0] },
                      :"string_data_most_likely" => { @component.id => tmp_prbl[1].to_f },
                      :"string_data_high" => { @component.id => tmp_prbl[2].to_f },
                      :"string_data_probable" => { @component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) }
                  }

                  ev.update_attributes(h)
                end
              end
            end
          end
        else
          @module_project.guw_model_id = @guw_model.id
          # @module_project.save
          @guw_outputs = @guw_model.guw_outputs.where(organization_id: organization_id) #.order("display_order ASC")

          # number_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(module_project_id: @module_project.id,
          #                                                        pbs_project_element_id: component.id).all.map{|i| i.guw_unit_of_works}.flatten.size
          #
          # selected_of_unit_of_work = Guw::GuwUnitOfWorkGroup.where(module_project_id: @module_project.id,
          #                                                          pbs_project_element_id: component.id).all.map{|i| i.guw_unit_of_works.where(selected: true)}.flatten.size
          #
          # offline_unit_of_work = Guw::GuwUnitOfWorkGroup.where(module_project_id: @module_project.id,
          #                                                      pbs_project_element_id: component.id).all.map{|i| i.guw_unit_of_works.where(off_line: true)}.flatten.size
          #
          # flagged_unit_of_work = Guw::GuwUnitOfWorkGroup.where(module_project_id: @module_project.id,
          #                                                      pbs_project_element_id: component.id).all.map{|i| i.guw_unit_of_works.where(flagged: true)}.flatten.size

          @selected_guw_unit_of_works = GuwUnitOfWork.where( organization_id: organization_id,
                                                                  guw_model_id: @guw_model.id,
                                                                  project_id: @project.id,
                                                                  module_project_id: @module_project.id,
                                                                  pbs_project_element_id: component.id,
                                                                  selected: true)
          #guw_unit_of_work_id: nil)

          @hash_evs = Hash.new {|h,k| h[k] = Array.new }
          EstimationValue.where(organization_id: organization_id, :module_project_id => @module_project.id).each do |tmp_ev|
            @hash_evs[tmp_ev.pe_attribute_id] << tmp_ev
          end

          @module_project.pemodule.attribute_modules.where(guw_model_id: @guw_model.id).each do |am|

            am_pe_attribute = am.pe_attribute

            unless am_pe_attribute.nil?

              # @evs = EstimationValue.where(organization_id: organization_id, :module_project_id => @module_project.id,
              #                            :pe_attribute_id => am_pe_attribute.id).all
              @evs = @hash_evs[am_pe_attribute.id]

              @evs.each do |ev|
                @guw_outputs.each do |guw_output|

                  value = @selected_guw_unit_of_works.map{ |i|
                    i.ajusted_size.nil? ? nil :
                        (i.ajusted_size.is_a?(Numeric) ?
                            i.ajusted_size.to_f :
                            i.ajusted_size["#{guw_output.id}"].to_f)}.compact.sum

                  tmp_prbl = Array.new
                  ["low", "most_likely", "high"].each do |level|
                    if am_pe_attribute.alias == guw_output.name.underscore.gsub(" ", "_")
                      ev.send("string_data_#{level}")[component.id] = value.to_f
                      if guw_output.output_type == "Effort"
                        tmp_prbl << ev.send("string_data_#{level}")[component.id] * (guw_output.standard_coefficient.nil? ? 1 : guw_output.standard_coefficient.to_f )
                      else
                        tmp_prbl << ev.send("string_data_#{level}")[component.id]
                      end
                    end

                    if am_pe_attribute.alias == "number_of_unit_of_work"
                      ev.send("string_data_#{level}")[component.id] = number_of_unit_of_work
                      tmp_prbl << ev.send("string_data_#{level}")[component.id]
                    elsif am_pe_attribute.alias == "offline_unit_of_work"
                      ev.send("string_data_#{level}")[component.id] = offline_unit_of_work
                      tmp_prbl << ev.send("string_data_#{level}")[component.id]
                    elsif am_pe_attribute.alias == "flagged_unit_of_work"
                      ev.send("string_data_#{level}")[component.id] = flagged_unit_of_work
                      tmp_prbl << ev.send("string_data_#{level}")[component.id]
                    elsif am_pe_attribute.alias == "selected_of_unit_of_work"
                      ev.send("string_data_#{level}")[component.id] = selected_of_unit_of_work
                      tmp_prbl << ev.send("string_data_#{level}")[component.id]
                    end

                    ev.send(:"string_data_#{level}=", ev.send("string_data_#{level}"))
                  end

                  if ev.in_out == "output" && am_pe_attribute.alias == guw_output.name.underscore.gsub(" ", "_")
                    h = Hash.new
                    h = {
                        :"string_data_low" => { component.id => tmp_prbl[0] },
                        :"string_data_most_likely" => { component.id => tmp_prbl[1].to_f },
                        :"string_data_high" => { component.id => tmp_prbl[2].to_f },
                        :"string_data_probable" => { component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) }
                    }
                    # unless ev.changed?
                    ev.update_attributes(h)
                    # end
                  end
                end
              end
            end
          end
        end
      end

      # Reset all view_widget results
      ViewsWidget.reset_nexts_mp_estimation_values(@module_project, component)
    end


    def self.update_view_widgets_and_project_fields(current_organization, module_project, pbs_project_element)
      @module_project = module_project
      ViewsWidget::update_field(@module_project, current_organization, @module_project.project, pbs_project_element)

      @module_project.all_nexts_mp_with_links.each do |module_project|
        ViewsWidget::update_field(module_project, current_organization, @module_project.project, pbs_project_element, true)
      end

      # Reset all view_widget results
      ViewsWidget.reset_nexts_mp_estimation_values(@module_project, pbs_project_element)
    end
  end
end
