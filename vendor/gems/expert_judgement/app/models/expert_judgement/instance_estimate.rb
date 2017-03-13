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

module ExpertJudgement
  class InstanceEstimate < ActiveRecord::Base
    belongs_to :pbs_project_element
    belongs_to :pe_attribute
    belongs_to :instance, foreign_key: "expert_judgement_instance_id"

    belongs_to :module_project, dependent: :destroy

    def convert_effort(level, eja, ev, component)
      gross = (self.send("#{level}_input").blank? ? ev.nil? ? '' : ev.send("string_data_#{level}")[component.id] : self.send("#{level}_input")).to_f
      if eja.alias == "effort"
        gross * self.instance.effort_unit_coefficient.to_f
      elsif eja.alias == "cost"
        gross * self.instance.cost_unit_coefficient.to_f
      else
        gross
      end
    end


    def convert_effort_to_show(level, eja, ev, component)
      gross = (self.send("#{level}_input").blank? ? ev.nil? ? '' : ev.send("string_data_#{level}")[component.id] : self.send("#{level}_input")).to_f
      if eja.alias == "effort"
        begin
          gross / self.instance.effort_unit_coefficient.to_f
        rescue
          gross
        end

      elsif eja.alias == "cost"
        begin
          gross / self.instance.cost_unit_coefficient.to_f
        rescue
          gross
        end
      else
        gross
      end
    end



    def to_s(mp)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end
  end
end
