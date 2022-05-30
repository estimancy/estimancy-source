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

class View < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id, :pemodule_id, :is_default_view, :is_reference_view, :initial_view_id

  belongs_to :organization
  belongs_to :pemodule

  has_many :module_projects, dependent: :nullify
  has_many :views_widgets, dependent: :destroy
  has_many :widgets, through: :views_widgets

  # validates :name, presence: true, uniqueness: { scope: [:organization_id, :pemodule_id], case_sensitive: false }
  validates :organization_id, :pemodule_id, presence: true

  scope :referenced_views, -> { where(is_reference_view: true) }
  scope :activities_wbs, -> {
    where(is_reference_view: true)
  }

  def to_s
    self.nil? ? '' : self.name
  end
end
