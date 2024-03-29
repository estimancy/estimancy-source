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

class GroupsProjects < ActiveRecord::Base
  attr_accessible  :group_id, :project_id
  belongs_to :group
  belongs_to :project

  # Security Audit management
  before_save :update_transaction_id_for_triggers

  private
  def update_transaction_id_for_triggers
    begin
      self.transaction_id = self.estimation_status.transaction_id || self.estimation_status.transaction_id rescue nil
      self.originator_id = User.current
      self.event_organization_id = Organization.current
    rescue
    end
  end

end