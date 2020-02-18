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

class DeleteOutdatedTables < ActiveRecord::Migration
  def up
    remove_index "activity_categories", :name => "index_activity_categories_on_record_status_id"
    remove_index "activity_categories", :name => "index_activity_categories_on_parent_id"
    remove_index "activity_categories", :name => "index_activity_categories_on_uuid"

    drop_table :activity_categories
    drop_table :activity_categories_project_areas
    drop_table :project_staffs
    drop_table :reference_values
    drop_table :roles_users
    drop_table :links_module_project_attributes
    drop_table :helps
    drop_table :help_types
    drop_table :homes
    drop_table :results

    remove_column :module_projects, :reference_value_id
    remove_column :projects_users, :settings

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
