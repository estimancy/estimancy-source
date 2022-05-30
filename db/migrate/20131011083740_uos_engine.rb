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

# This migration comes from uow_engine (originally 20131009092730)
class UosEngine < ActiveRecord::Migration
  def self.up
    create_table :inputs, :force => true do |t|
      t.integer :module_project_id
      t.integer :technology_id
      t.integer :unit_of_work_id
      t.integer :complexity_id
      t.string  :flag
      t.string  :name
      t.integer :weight
      t.integer :size_low
      t.integer :size_most_likely
      t.integer :size_high
      t.integer :gross_low
      t.integer :gross_most_likely
      t.integer :gross_high
      t.timestamps
    end
  end

  def self.down
    drop_table :inputs
  end
end
