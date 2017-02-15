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

class Profile < ActiveRecord::Base
  attr_accessible :cost_per_hour, :description, :name

  validates :name, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :cost_per_hour, :numericality => { :allow_blank => true }
  validates :custom_value, :presence => true, :if => :is_custom?

  amoeba do
    enable
  end

  def to_s
    self.nil? ? '' : self.name
  end

end
