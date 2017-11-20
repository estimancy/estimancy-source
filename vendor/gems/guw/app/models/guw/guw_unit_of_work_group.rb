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
  class GuwUnitOfWorkGroup < ActiveRecord::Base

    has_many :guw_unit_of_works, dependent: :destroy
    # la Vue
    has_many :module_project_guw_unit_of_works, class_name: 'ModuleProjectGuwUnitOfWork'

    belongs_to :module_project
    belongs_to :pbs_project_element
    belongs_to :organization_technology

    validates_presence_of :name#, :organization_technology_id

    amoeba do
      enable
      include_association [:guw_unit_of_works]
    end

    def to_s
      name
    end
  end
end
