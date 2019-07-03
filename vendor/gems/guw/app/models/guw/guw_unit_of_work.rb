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

    belongs_to :guw_unit_of_work

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
    end

    def to_s
      name
    end
  end
end
