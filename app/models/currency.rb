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
#
# pct = [0.9, 0.8, 0.7, 1.05, 1.1, 1.13]
# o = Organization.where(name: "CDS FORMATION").first
# o.organization_profiles.each do |profile|
#   profile.cost_per_hour = profile.cost_per_hour * pct.sample
#   profile.save
# end
#
# pct = [0.9, 0.8, 0.7, 1.05, 1.1, 1.13]
# o = Organization.where(name: "CDS FORMATION").first
# o.guw_models.where("name LIKE ? OR name LIKE ?", "%CONSEIL%", "%DIRE%").each do |guw_model|
#   guw_model.guw_types.each do |guw_type|
#     guw_type.guw_complexities.each do |guw_complexity|
#       guw_complexity.weight = guw_complexity.weight * pct.sample
#       guw_complexity.save
#     end
#   end
# end
#
#
# organization = Organization.where(name: "CDS RH").first
# organization.guw_models.where("name LIKE ? OR name LIKE ?", "%CONSEIL%", "%DIRE%").each do |guw_model|
#   guw_model.guw_coefficients.each do |guw_coefficient|
#     if guw_coefficient.name == "Dégressivité"
#       guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#         if guw_coefficient_element.name == "A1"
#           guw_coefficient_element.value = 1
#         elsif guw_coefficient_element.name == "A2"
#           guw_coefficient_element.value = 0.95
#         elsif guw_coefficient_element.name == "A3"
#           guw_coefficient_element.value = 0.9215
#         elsif guw_coefficient_element.name == "A4"
#           guw_coefficient_element.value = 0.90307
#         elsif guw_coefficient_element.name == "A5"
#           guw_coefficient_element.value = 0.8850086
#         elsif guw_coefficient_element.name == "A6"
#           guw_coefficient_element.value = 0.867308428
#         elsif guw_coefficient_element.name == "A7"
#           guw_coefficient_element.value = 0.8499622594
#         elsif guw_coefficient_element.name == "A8"
#           guw_coefficient_element.value = 0.8329630143
#         else
#           # ignored
#         end
#
#         guw_coefficient_element.save
#       end
#     end
#   end
# end
#
# organization = Organization.where(name: "CDS RH").first
# organization.guw_models.each do |guw_model|
#   guw_model.guw_coefficients.each do |guw_coefficient|
#     if guw_coefficient.name == "Dégressivité"
#       guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#         if guw_coefficient_element.name == "2017"
#           guw_coefficient_element.name = "A1"
#         elsif guw_coefficient_element.name == "2018"
#           guw_coefficient_element.name = "A2"
#         elsif guw_coefficient_element.name == "2019"
#           guw_coefficient_element.name = "A3"
#         elsif guw_coefficient_element.name == "2020"
#           guw_coefficient_element.name = "A4"
#         elsif guw_coefficient_element.name == "2021"
#           guw_coefficient_element.name = "A5"
#         elsif guw_coefficient_element.name == "2022"
#           guw_coefficient_element.name = "A6"
#         elsif guw_coefficient_element.name == "2023"
#           guw_coefficient_element.name = "A7"
#         elsif guw_coefficient_element.name == "2024"
#           guw_coefficient_element.name = "A8"
#         else
#           # ignored
#         end
#
#         guw_coefficient_element.save
#       end
#     end
#   end
# end
######### Vérifier ficheir Excel #########
# o = Organization.where(name: "CDS RH").first
# path = "#{Rails.root}/PRIX-DE-CDS-RH.xlsx"
# workbook = RubyXL::Parser.parse(path)
# tab = workbook[0].extract_data
# tab.each_with_index do |row, index|
#   o.guw_models.where(name: row[0]).each do |guw_model|
#     guw_model.guw_types.each do |guw_type|
#       guw_type.guw_complexities.each do |guw_complexity|
#         guw_complexity.weight = row[1].to_f
#         guw_complexity.save
#       end
#     end
#   end
# end


# organizations = Organization.all
# organizations.each do |organization|
#   organization.guw_models.each do |guw_model|
#     guw_model.guw_coefficients.each do |guw_coefficient|
#       if guw_coefficient.name == "Dégressivité"
#         guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#           if guw_coefficient_element.name == "2017"
#             guw_coefficient_element.name = "A1"
#           elsif guw_coefficient_element.name == "2018"
#             guw_coefficient_element.name = "A2"
#           elsif guw_coefficient_element.name == "2019"
#             guw_coefficient_element.name = "A3"
#           elsif guw_coefficient_element.name == "2020"
#             guw_coefficient_element.name = "A4"
#           elsif guw_coefficient_element.name == "2021"
#             guw_coefficient_element.name = "A5"
#           elsif guw_coefficient_element.name == "2022"
#             guw_coefficient_element.name = "A6"
#           elsif guw_coefficient_element.name == "2023"
#             guw_coefficient_element.name = "A7"
#           elsif guw_coefficient_element.name == "2024"
#             guw_coefficient_element.name = "A8"
#           else
#             # ignored
#           end
#
#           guw_coefficient_element.save
#         end
#       end
#     end
#   end
# organization = Organization.where(name: "CDS RH").first
# organization.guw_models.where("name LIKE ? OR name LIKE ?", "%CONSEIL%", "%DIRE%").each do |guw_model|
#   guw_model.guw_coefficients.each do |guw_coefficient|
#     if guw_coefficient.name == "Dégressivité"
#       guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#         if guw_coefficient_element.name == "A1"
#           guw_coefficient_element.value = 1
#         elsif guw_coefficient_element.name == "A2"
#           guw_coefficient_element.value = 0.95
#         elsif guw_coefficient_element.name == "A3"
#           guw_coefficient_element.value = 0.9215
#         elsif guw_coefficient_element.name == "A4"
#           guw_coefficient_element.value = 0.90307
#         elsif guw_coefficient_element.name == "A5"
#           guw_coefficient_element.value = 0.8850086
#         elsif guw_coefficient_element.name == "A6"
#           guw_coefficient_element.value = 0.867308428
#         elsif guw_coefficient_element.name == "A7"
#           guw_coefficient_element.value = 0.8499622594
#         elsif guw_coefficient_element.name == "A8"
#           guw_coefficient_element.value = 0.8329630143
#         else
#           # ignored
#         end
#
#         guw_coefficient_element.save
#       end
#     end
#   end
# end
#
# organization = Organization.where(name: "CDS FORMATION").first
# organization.guw_models.each do |guw_model|
#   guw_model.guw_coefficients.each do |guw_coefficient|
#     if guw_coefficient.name == "Dégressivité"
#       guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#         if guw_coefficient_element.name == "A1"
#           guw_coefficient_element.value = 1
#         elsif guw_coefficient_element.name == "A2"
#           guw_coefficient_element.value = 0.95
#         elsif guw_coefficient_element.name == "A3"
#           guw_coefficient_element.value = 0.9
#         elsif guw_coefficient_element.name == "A4"
#           guw_coefficient_element.value = 0.85
#         elsif guw_coefficient_element.name == "A5"
#           guw_coefficient_element.value = 0.8
#         elsif guw_coefficient_element.name == "A6"
#           guw_coefficient_element.value = 0.77
#         elsif guw_coefficient_element.name == "A7"
#           guw_coefficient_element.value = 0.75
#         elsif guw_coefficient_element.name == "A8"
#           guw_coefficient_element.value = 0.72
#         else
#           # ignored
#         end
#
#         guw_coefficient_element.save
#       end
#     end
#   end
# end

