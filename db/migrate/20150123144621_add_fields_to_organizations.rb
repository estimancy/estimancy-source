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

class AddFieldsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :limit4, :integer

    add_column :organizations, :limit1_coef, :float
    add_column :organizations, :limit2_coef, :float
    add_column :organizations, :limit3_coef, :float
    add_column :organizations, :limit4_coef, :float

    add_column :organizations, :limit1_unit, :string
    add_column :organizations, :limit2_unit, :string
    add_column :organizations, :limit3_unit, :string
    add_column :organizations, :limit4_unit, :string
  end
end
