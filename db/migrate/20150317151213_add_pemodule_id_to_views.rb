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

class AddPemoduleIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :pemodule_id, :integer, after: :organization_id
    add_column :views, :is_default_view, :boolean, after: :pemodule_id
    add_column :views, :is_temporary_view, :boolean, after: :is_default_view
    add_column :views, :initial_view_id, :integer, after: :is_temporary_view


    add_column :views_widgets, :from_initial_view, :boolean
  end
end
