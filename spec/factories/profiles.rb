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

# Read about factories at https://github.com/thoughtbot/factory_girl


#attr_accessible :cost_per_hour, :description, :name, :record_status, :profile_category_id

FactoryGirl.define do
  factory :profile do
    sequence(:name) {|n| "Profile_#{n}"}
    description "MyText"
    cost_per_hour 1.5
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end
end
