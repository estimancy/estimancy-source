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


#Special Data
#Group class contains some User.
class Group < ActiveRecord::Base
  attr_accessible :name, :description, :for_global_permission, :for_project_security, :organization_id


  has_and_belongs_to_many :users
  has_and_belongs_to_many :projects

  has_many :project_securities

  has_many :groups_permission, dependent: :destroy
  has_many :permissions, through: :groups_permission

  # has_paper_trail

  #Estimations permissions on Group according to the estimation status
  has_many :estimation_status_group_roles

  belongs_to :organization

  has_many :groups_users, class_name: 'GroupsUsers'
  has_many :users, through: :groups_users

  validates :name, :presence => true , :uniqueness => { :scope => :organization_id, :case_sensitive => false }

  default_scope order('name ASC')

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    self.nil? ? '' : self.name
  end

  #Return group project_securities for selected project_id
  def project_securities_for_select(prj_id, is_model_permission=nil)
    if is_model_permission == true
      #self.project_securities.select { |i| i.project_id == prj_id }.first
      self.project_securities.select { |i| i.project_id == prj_id && i.is_model_permission == true}.first
    else
      self.project_securities.select { |i| i.project_id == prj_id && i.is_model_permission != true}.first
    end
  end

  amoeba do
    enable
    include_association [:permissions]
    customize(lambda { |original_group, new_group|
      new_group.copy_id = original_group.id
    })
  end

end
