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

module Ge
  class GeFactor < ActiveRecord::Base
    attr_accessible :alias, :description, :factor_type, :ge_model_id, :long_name, :scale_prod, :short_name, :data_filename, :copy_id

    validates :scale_prod, presence: true
    validates :short_name, :alias, presence: true, uniqueness: { :scope => :ge_model_id, :case_sensitive => false }

    belongs_to :ge_model

    has_many :ge_factor_values, :dependent => :destroy

    amoeba do
      enable
      exclude_association [:ge_factor_values]

      customize(lambda { |original_ge_factor, new_ge_factor|
          new_ge_factor.copy_id = original_ge_factor.id
      })
    end

  end
end


# 2/