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
  class GeInput < ActiveRecord::Base
    attr_accessible :formula, :s_factors_value, :p_factors_value, :c_factors_value, :values, :ge_model_id, :module_project_id, :organization_id

    serialize :values, Hash  # Hash of Hash  ==> { { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... }

    belongs_to :ge_model

  end
end
