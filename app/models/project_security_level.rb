#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

#Master Data
class ProjectSecurityLevel < ActiveRecord::Base
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment

  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  has_many :project_securities
  has_and_belongs_to_many :permissions

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :record_status_id}
  validates :custom_value, :presence => true, :if => :is_custom?


  def to_s
    self.name
  end
end
