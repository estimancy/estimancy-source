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
                    :effort_unit, :standard_unit_coefficient, :staffing_method, :effort_week_unit, :config_type

    attr_accessor :x0, :y0, :x1, :x2, :x3, :y3

    serialize :trapeze_default_values, Hash

    validates :name, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false}
    validates :mc_donell_coef, :puissance_n, :organization_id, presence: true
    validates :standard_unit_coefficient, :presence => true
    validates :effort_unit, :presence => true

    validate :trapeze_parameters

    def trapeze_parameters
      trapeze_default_values.each do |key, value|
        case key.to_s
          when "x0"
            if value.present?
              if value.to_f < 0
                errors.add(:x0, "doit être supérieur ou égal à 0")
              end
            else
              errors.add(:x0, "obligatoire et doit être inférieur à x1")
            end

          when "x1"
            if value.present?
              if value.to_f <= trapeze_default_values[:x0].to_f
                errors.add(:x1, "doit être supérieur à x0")
              end
            else
              errors.add(:x1, "obligatoire et doit être supérieur à x0")
            end

          when "x2"
            if value.present?
              if value.to_f <= trapeze_default_values[:x1].to_f
                errors.add(:x2, "doit être supérieur à x1")
              end
            else
              errors.add(:x2, "obligatoire et doit être supérieur à x1")
            end

          when "x3"
            if value.present?
              if value.to_f <= trapeze_default_values[:x2].to_f
                errors.add(:x3, "doit être supérieur à x2")
              end
            else
              errors.add(:x3, "obligatoire et doit être supérieur à x2")
            end
        end
      end

    end

    belongs_to :organization
    has_many :module_projects, :dependent => :destroy
    has_many :staffing

    INPUT_EFFORTS_ALIAS = ["effort"]

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end

  end
end
