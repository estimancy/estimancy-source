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
  class GuwType < ActiveRecord::Base
    belongs_to :guw_model

    has_many :guw_unit_of_work_attributes, dependent: :destroy
    has_many :guw_attribute_complexities, dependent: :destroy
    has_many :guw_complexities, dependent: :destroy
    has_many :guw_type_complexities, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy
    has_many :guw_complexity_technologies, dependent: :destroy
    has_many :guw_complexity_coefficient_elements, dependent: :destroy

    # la Vue
    has_many :module_project_guw_unit_of_works, class_name: 'ModuleProjectGuwUnitOfWork'

    validates_presence_of :name

    amoeba do
      enable
      include_association [:guw_complexities, :guw_type_complexities]

      customize(lambda { |original_guw_type, new_guw_type|
        new_guw_type.copy_id = original_guw_type.id
      })
    end

    def to_s
      name
    end
  end
end
