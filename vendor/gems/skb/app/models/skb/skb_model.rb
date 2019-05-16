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

module Skb
  class SkbModel < ActiveRecord::Base

    attr_accessible :name, :size_unit, :three_points_estimation, :enabled_input, :organization_id, :copy_number, :copy_id,
                    :description, :label_x, :label_y, :filter_a, :filter_b, :filter_c, :filter_d, :selected_attributes,
                    :date_min, :date_max, :n_max

    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}

    belongs_to :organization

    has_many :module_projects, :dependent => :destroy
    has_many :skb_datas, :dependent => :destroy
    has_many :skb_inputs, :dependent => :destroy

    serialize :selected_attributes, Array

    INPUT_ATTRIBUTES_ALIAS = ["retained_size"]

    amoeba do
      enable
      exclude_association [:module_projects]

      customize(lambda { |original_skb_model, new_skb_model|
                  new_skb_model.copy_id = original_skb_model.id
                  new_skb_model.size_unit = original_skb_model.size_unit
                })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        # "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
        self.name
      end
    end

    def self.display_size(p, c, level, component_id)
      if c.send("string_data_#{level}")[component_id].nil?
        begin
          p.send("string_data_#{level}")[component_id]
        rescue
          nil
        end
      else
        c.send("string_data_#{level}")[component_id]
      end
    end


    # Display Value and unit
    def self.display_value(data_probable, estimation_value, view_widget, user)
      module_project = estimation_value.module_project
      skb_model = module_project.skb_model
      value = data_probable
      unit_coefficient = 1

      case estimation_value.pe_attribute.alias

        when "effort"
          if view_widget.use_organization_effort_unit == true
            tab = Organization.get_organization_unit(value, skb_model.organization)
            unit_coefficient = tab.first
            unit = tab.last
          else
            begin

              unit_coefficient = 1 #skb_model.send("standard_unit_coefficient")
              unit = "" #"jh" #skb_model.send("effort_unit")
            rescue
              unit_coefficient = 1
              unit = ""
            end
          end

        when "retained_size"
          unit_coefficient = 1
          unit = skb_model.send("size_unit")
        else
          # type code here
      end

      begin
        if value.nil?
          result_value = nil
        else
          result_value = (value / unit_coefficient.to_f)
        end
      rescue
        result_value = nil
      end

      return "#{ActionController::Base.helpers.number_with_precision(result_value, precision: user.number_precision.nil? ? 2 : user.number_precision, delimiter: I18n.l('number.format.delimiter'), locale: (user.language.locale rescue "fr"))} #{unit}"
    end


  end
end