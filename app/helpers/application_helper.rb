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

#Some helper for the app...
module ApplicationHelper
  def is_number?(v)
    true if Float(v) rescue false
  end

  def convert_project_category(project, value)
    case value
      when I18n.t(:project_area)
        tmp = "project_area"
      when I18n.t(:project_category)
        tmp = "project_category"
      when I18n.t(:platform_category)
        tmp = "platform_category"
      when I18n.t(:acquisition_category)
        tmp = "acquisition_category"
      else
        # type code here
    end

    unless tmp.nil?
      project.send(tmp)
    end
  end

  def display_alert(uo)
    begin
      model = Project.where(id: uo.project.original_model_id).first
      if model.title == "IFPUG Sourcing"
        if uo.project.estimation_status.name == "Controled"
          if uo.name.gsub(/[^0-9A-Za-z]/, '') == "EFR01"
            if uo.guw_type.name == "EI" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Create"
              is_valid = false
            elsif uo.guw_type.name == "ILF" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Create"
              is_valid = false
            else
              is_valid = true
            end
          elsif uo.name.gsub(/[^0-9A-Za-z]/, '') == "EFR02"
            if uo.guw_type.name == "EQ" && uo.guw_complexity.name == "Average" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Create"
              is_valid = false
            else
              is_valid = true
            end
          elsif uo.name.gsub(/[^0-9A-Za-z]/, '') == "EFR03"
            if uo.guw_type.name == "EI" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Modify"
              is_valid = false
            elsif uo.guw_type.name == "EQ" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Modify"
              is_valid = false
            elsif uo.guw_type.name == "ILF" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Modify"
              is_valid = false
            else
              is_valid = true
            end
          elsif uo.name.gsub(/[^0-9A-Za-z]/, '') == "EFR04"
            if uo.guw_type.name == "EQ" && uo.guw_complexity.name == "Low" && uo.guw_coefficient_element_unit_of_works.map(&:guw_coefficient_element).map(&:name).first == "Delete"
              is_valid = false
            else
              is_valid = true
            end
          else
            is_valid = true
          end
        else
          is_valid = false
        end
      end
    rescue
      is_valid = false
    end

    @project.is_valid = !is_valid
    @project.save
  end
end
