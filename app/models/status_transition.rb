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

class StatusTransition < ActiveRecord::Base
  attr_accessible :from_transition_status_id, :to_transition_status_id

  belongs_to :from_transition_status, class_name: "EstimationStatus"
  belongs_to :to_transition_status, class_name: "EstimationStatus"

  belongs_to :demand_from_transition_status, class_name: "DemandStatus"
  belongs_to :demand_to_transition_status, class_name: "DemandStatus"

  #validates :from_transition_status_id, :to_transition_status_id, presence: true

end
