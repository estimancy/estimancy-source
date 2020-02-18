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

class CreateGeFactorsData < ActiveRecord::Migration

  def up

    create_table :ge_ge_factors do |t|
      t.integer :ge_model_id
      t.string :alias
      t.string :scale_prod
      t.string :factor_type
      t.string :short_name
      t.string :long_name
      t.text :description
      t.string :data_filename

      t.timestamps
    end


    create_table :ge_ge_factor_values do |t|
      t.string :factor_name
      t.string :factor_alias
      t.string :value_text
      t.float :value_number
      t.string :factor_scale_prod
      t.string :factor_type
      t.integer :ge_factor_id
      t.integer :ge_model_id

      t.timestamps
    end


    create_table :ge_ge_inputs do |t|
      t.string :formula
      t.float :scale_factor_sum
      t.float :prod_factor_product
      t.text :values
      t.integer :ge_model_id
      t.integer :module_project_id
      t.integer :organization_id

      t.timestamps
    end

  end

  def down
    drop_table :ge_ge_factors
    drop_table :ge_ge_factor_values
    drop_table :ge_ge_inputs
  end

end
