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

module Staffing
  class StaffingModel < ActiveRecord::Base
    attr_accessible :puissance_n, :mc_donell_coef, :copy_id, :copy_number, :enabled_input, :name,
                    :description, :organization_id, :trapeze_default_values, :three_points_estimation,
                    :effort_unit, :standard_unit_coefficient
    attr_accessor :x0, :y0, :x1, :x2, :x3, :y3

    serialize :trapeze_default_values, Hash

    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false}
    validates :mc_donell_coef, :puissance_n, :organization_id, presence: true
    validates :standard_unit_coefficient, :presence => true
    validates :effort_unit, :presence => true

    belongs_to :organization
    has_many :module_projects, :dependent => :destroy
    has_many :staffing

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end

  end
end
