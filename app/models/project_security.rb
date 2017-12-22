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

#ProjectSecurity belongs to User, Group and Project
class ProjectSecurity < ActiveRecord::Base
  attr_accessible :project_id, :user_id, :group_id, :project_security_level_id, :is_estimation_permission, :is_model_permission

  belongs_to :user
  belongs_to :group
  belongs_to :project, :touch => true
  belongs_to :project_security_level

  audited

  #Return level of security project
  def level
    self.project_security_level.nil? ? '-' : self.project_security_level.name
  end

  def to_s
    id.to_s
  end
end
