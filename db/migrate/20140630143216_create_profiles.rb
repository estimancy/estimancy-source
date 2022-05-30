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

class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.text :description
      t.float :cost_per_hour
      t.string   :uuid
      t.integer  :record_status_id
      t.string   :custom_value
      t.integer  :owner_id
      t.text     :change_comment
      t.integer  :reference_id
      t.string   :reference_uuid

      t.timestamps
    end

    add_index "profiles", ["record_status_id"], :name => "index_profiles_on_record_status_id"
    add_index "profiles", ["reference_id"], :name => "index_profiles_on_parent_id"
    add_index "profiles", ["uuid"], :name => "index_profiles_on_uuid", :unique => true
  end
end
