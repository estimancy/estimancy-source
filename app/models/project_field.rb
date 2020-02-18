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

class ProjectField < ActiveRecord::Base
  attr_accessible :field_id, :project_id, :views_widget_id, :value

  belongs_to :field
  belongs_to :project
  belongs_to :views_widget

  validates :field_id, :presence => true, :uniqueness => {  :scope => :project_id, :message => I18n.t(:identical_project_field_exists)}

  #Search fields
  scoped_search :in => :field, :on => :name
end
