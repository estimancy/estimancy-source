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

#Master Data
#Currency - not yet begin
class Currency < ActiveRecord::Base
  attr_accessible :name, :alias, :description, :iso_code, :iso_code_number, :sign, :conversion_rate

  has_many :organizations

  def to_s
    self.nil? ? '' : self.sign
  end
end

# oid = Organization.where(name: "CDS PROD TRAIN").first.id
# pid = Provider.where(name: "SOGETI").first.id
#
# Project.where(organization_id: oid).all.each do |project|
#   if project.is_model == true
#     project.use_automatic_quotation_number = true
#     project.save(validate: false)
#   end
# end
#
# Project.where(organization_id: oid).all.each do |project|
#   project.provider_id = pid
#   project.save(validate: false)
# end
#
# @
# orga = Organization.where(name: "CDS PROD TRAIN").first
# auth_type = AuthMethod.where(name: "SAML").first
#
# orga.users.each do |user|
#   unless user.super_admin == true
#     user.auth_type = auth_type.id
#     user.save(validate: false)
#   end
# end
