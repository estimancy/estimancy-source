#encoding: utf-8
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

#Master Data
#ProjectArea management
class ProjectArea < ActiveRecord::Base
  attr_accessible :name, :description, :acquisition_category_ids, :platform_category_ids, :project_category_ids, :labor_category_ids, :organization_id

  has_many :projects

  validates :name, :presence => true

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  default_scope order('name ASC')

  amoeba do
    enable
    exclude_association [:projects]
  end

  #Override
  def to_s
    self.nil? ? 'N/A' : self.name
  end
end
