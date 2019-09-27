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
  class Instance < ActiveRecord::Base

    belongs_to :organization
    has_many :instance_estimates, foreign_key: "expert_judgement_instance_id"

    attr_accessible :organization_id, :name, :description, :three_points_estimation,
                    :enabled_cost, :cost_unit, :cost_unit_coefficient,
                    :enabled_effort, :effort_unit, :effort_unit_coefficient,
                    :enabled_size, :retained_size_unit, :copy_number

    ###validates_presence_of :organization_id
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false, message: I18n.t(:module_instance_name_already_exists)}

    INPUT_ATTRIBUTES_ALIAS = ["retained_size", "effort", "cost"]

    amoeba do
      enable
      customize(lambda { |original_expert_judgment_id, new_expert_judgment_id|
        new_expert_judgment_id.copy_id = original_expert_judgment_id.id
      })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end
  end
end
