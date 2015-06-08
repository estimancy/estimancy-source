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

    #attr_accessible :name, :guw_type_id, :guw_unit_of_work_group_id, :guw_type, :guw_unit_of_work_group

    belongs_to :guw_type
    belongs_to :guw_model
    belongs_to :guw_complexity
    belongs_to :guw_unit_of_work_group
    belongs_to :organization_technology
    belongs_to :guw_work_unit

    has_many :guw_unit_of_work_attributes, dependent: :destroy

    validates_presence_of :name#, :guw_type_id, :guw_unit_of_work_group_id

    amoeba do
      enable
      include_association [:guw_unit_of_work_attributes]
    end

    def to_s
      name
    end
  end
end
