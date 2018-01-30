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

#Permission  of the users and the groups
class Permission < ActiveRecord::Base
  attr_accessible :alias, :name, :description, :category, :is_master_permission, :is_permission_project, :object_type, :object_associated

  has_and_belongs_to_many :users

  has_many :groups, through: :groups_permission
  has_many :groups_permission, dependent: :destroy

  has_and_belongs_to_many :project_security_levels

  validates :name, :description, :alias, :presence => true

  # has_paper_trail

  def to_s
    self.nil? ? '' : self.name
  end
end
