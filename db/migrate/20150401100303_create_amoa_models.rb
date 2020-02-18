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

class CreateAmoaModels < ActiveRecord::Migration
  def up
    create_table :amoa_amoa_models do |t|
      t.string :name
      t.float :three_points_estimation
      t.integer :organization_id
    end

    create_table :amoa_amoa_applications do |t|
      t.string :name
      t.integer :amoa_model_id
    end

    create_table :amoa_amoa_contexts do |t|
      t.string :name
      t.float :weight
      t.integer :amoa_application_id
      t.integer :amoa_amoa_context_type_id
    end

    create_table :amoa_amoa_context_types do |t|
      t.string :name
    end

    create_table :amoa_amoa_services do |t|
      t.string :name
    end

    create_table :amoa_amoa_criterias do |t|
      t.string :name
    end

    create_table :amoa_amoa_criteria_services do |t|
      t.integer :amoa_amoa_criteria_id
      t.integer :amoa_amoa_service_id
      t.float :weight
    end

    create_table :amoa_amoa_unit_of_works do |t|
      t.string :name
      t.string :description
      t.string :tracability
      t.float :result
      t.integer :amoa_amoa_service_id
    end

    create_table :amoa_amoa_criteria_unit_of_works do |t|
      t.integer :amoa_amoa_criteria_id
      t.integer :amoa_amoa_unit_of_work_id
      t.integer :quantity
    end

    create_table :amoa_amoa_weightings_unit_of_works do |t|
      t.integer :amoa_amoa_weighting_id
      t.integer :amoa_amoa_unit_of_work_id
    end

    create_table :amoa_amoa_weightings do |t|
      t.string :name
      t.float :weight
      t.integer :amoa_amoa_service_id
    end

  end

  def down
    drop_table :amoa_amoa_models
    drop_table :amoa_amoa_applications
    drop_table :amoa_amoa_contexts
    drop_table :amoa_amoa_context_types
    drop_table :amoa_amoa_services
    drop_table :amoa_amoa_criterias
    drop_table :amoa_amoa_criteria_services
    drop_table :amoa_amoa_unit_of_works
    drop_table :amoa_amoa_criteria_unit_of_works
    drop_table :amoa_amoa_weightings_unit_of_works
    drop_table :amoa_amoa_weightings
  end
end
