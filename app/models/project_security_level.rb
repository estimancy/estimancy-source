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
class ProjectSecurityLevel < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id

  has_many :project_securities, dependent: :destroy
  has_and_belongs_to_many :permissions
  has_many :estimation_status_group_roles  #Estimations permissions on Group according to the estimation status

  belongs_to :organization

  validates :name, :presence => true

  amoeba do
    enable
    #include_association []
    exclude_association [:project_securities]
    customize(lambda { |original_project_security_level, new_project_security_level|
      new_project_security_level.copy_id = original_project_security_level.id
    })
  end

  def to_s
    name
  end
end
