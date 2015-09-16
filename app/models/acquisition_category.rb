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

#Master Table
class AcquisitionCategory < ActiveRecord::Base
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment, :organization_id

  has_and_belongs_to_many :project_areas

  validates_presence_of :description
  validates :name, :presence => true

  amoeba do
    enable
    exclude_association [:projects]
  end

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  def to_s
    self.nil? ? '' : self.name
  end
end
