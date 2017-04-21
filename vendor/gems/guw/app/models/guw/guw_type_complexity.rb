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
  class GuwTypeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    has_many :guw_attribute_complexities, dependent: :delete_all

    amoeba do
      enable
      exclude_association [:guw_attribute_complexities]
      customize(lambda { |original_guw_type_complexity, new_guw_type_complexity|
        new_guw_type_complexity.copy_id = original_guw_type_complexity.id
      })
    end

    def to_s
      name
    end

  end
end
