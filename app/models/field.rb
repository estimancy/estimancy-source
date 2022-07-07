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

class Field < ActiveRecord::Base
  attr_accessible :name, :organization_id, :coefficient

  belongs_to :organization
  belongs_to :project_field

  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates_presence_of :coefficient

  #Search fields
  scoped_search :on => [:name]

  amoeba do
    enable
    customize(lambda { |original_field, new_field|
      new_field.copy_id = original_field.id
    })
  end
end
