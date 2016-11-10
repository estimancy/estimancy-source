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

#Project

FactoryGirl.define do

  sequence :project_title do |n|
    "Project_#{n}"
  end

  sequence :project_alias do |n|
    "P#{n}"
  end

  sequence :project_description do |n|
    "Project number #{n}"
  end

  # Projects
  factory :new_project, :class => :project do |p|
    p.association :estimation_status, :factory => :estimation_status
    p.association :organization, :factory => :organization
    p.start_date Time.now
    after :build do |proj|
      proj.title = FactoryGirl.generate(:project_title)
      proj.alias = FactoryGirl.generate(:project_alias)
      proj.description = FactoryGirl.generate(:project_description)
    end
  end

  # Projects
  factory :project do |p|
    p.sequence(:title) {|n| "Project_#{n}"}
    p.sequence(:version_number) {|n| "v#{n}"}
    p.alias FactoryGirl.generate(:project_alias)  #p.sequence(:alias) {|n| "P#{n}"}
    p.sequence(:description) {|n| "Project number #{n}"}
    p.association :organization, :factory => :organization
    p.association :estimation_status, :factory => :estimation_status
    p.state 'preliminary'
    p.start_date Time.now
  end

end