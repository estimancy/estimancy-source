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

class CreateExpertJugementInstanceEstimate < ActiveRecord::Migration
  def change
    create_table :expert_judgement_instance_estimates do |t|
      t.integer :pbs_project_element_id
      t.integer :module_project_id
      t.integer :pe_attribute_id
      t.integer :expert_judgement_instance_id

      t.float :low_input
      t.float :most_likely_input
      t.float :high_input

      t.float :low_output
      t.float :most_likely_output
      t.float :high_output
    end
  end
end
