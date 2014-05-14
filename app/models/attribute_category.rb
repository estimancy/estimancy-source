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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

class AttributeCategory < ActiveRecord::Base
  attr_accessible :name, :alias, :record_status_id, :custom_value, :change_comment

  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  serialize :options, Array

  attr_accessible :alias, :name, :record_status_id, :custom_value, :change_comment

  has_many :pe_attributes

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :alias, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}


  def to_s
    self.name.humanize
  end
end
