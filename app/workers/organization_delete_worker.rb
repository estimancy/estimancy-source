# ##########################################################################
# #
# # ProjEstimate, Open Source project estimation web application
# # Copyright (c) 2014 Estimancy (http://www.estimancy.com)
# #
# #    This program is free software: you can redistribute it and/or modify
# #    it under the terms of the GNU Affero General Public License as
# #    published by the Free Software Foundation, either version 3 of the
# #    License, or (at your option) any later version.
# #
# #    This program is distributed in the hope that it will be useful,
# #    but WITHOUT ANY WARRANTY; without even the implied warranty of
# #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# #    GNU Affero General Public License for more details.
# #
# #    You should have received a copy of the GNU Affero General Public License
# #    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# #
# ########################################################################
#
# class OrganizationDeleteWorker
#   include Sidekiq::Worker
#
#   def perform(organization_id)
#
#     organization = Organization.find(organization_id)
#     organization_groups = organization.groups
#
#     organization.transaction do
#       organization.destroy
#
#       OrganizationsUsers.delete_all("organization_id = #{organization_id}")
#
#       #organization.groups.each do |group|
#       organization_groups.each do |group|
#         GroupsUsers.delete_all("group_id = #{group.id}")
#       end
#       #organization.destroy
#     end
#
#   rescue ActiveRecord::RecordNotFound
#
#   end
# end