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
  class GeFactorValue < ActiveRecord::Base
    attr_accessible :factor_name, :factor_alias, :factor_scale_prod, :factor_type, :value_number, :default, :value_text, :ge_factor_id, :ge_model_id

    validates :factor_name, :factor_alias, :ge_factor_id, :ge_model_id, presence: true

    belongs_to :ge_factor
    belongs_to :ge_model

  end

end
