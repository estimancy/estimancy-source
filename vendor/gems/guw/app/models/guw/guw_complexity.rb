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
  class GuwComplexity < ActiveRecord::Base
    belongs_to :guw_type

    ### added for copy
    has_many :guw_complexity_technologies, dependent: :destroy
    has_many :guw_complexity_work_units, dependent: :destroy
    has_many :guw_complexity_weightings, dependent: :destroy
    has_many :guw_complexity_factors, dependent: :destroy
    has_many :guw_output_associations, dependent: :destroy
    has_many :guw_output_complexities, dependent: :destroy
    has_many :guw_output_complexity_initializations, dependent: :destroy

    attr_accessible :organization_id, :name, :alias, :weight,
                    :bottom_range, :top_range, :guw_type_id,
                    :enable_value, :display_order, :default_value, :weight_b

    validates_presence_of :name#, :guw_type_id#, :bottom_range, :top_range,

    validates :bottom_range, numericality: { only_integer: true, allow_nil: true }
    validates :top_range, numericality: { only_integer: true, allow_nil: true }

    amoeba do
      enable
      customize(lambda { |original_guw_complexity, new_guw_complexity|
        new_guw_complexity.copy_id = original_guw_complexity.id
      })
    end

  end
end
