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
# octobre 2021
# rake users:delete_all_users_and_update_uo_description RAILS_ENV=production
namespace :users do

  desc 'delete_all_users_and_update_uo_type_description'

  task :delete_all_users_and_update_uo_description => :environment do

    #delete all users unless (admin, ebelle, sgaye)
    #User.where.not(login_name: ["admin", "ebellet", "sgaye"]).delete_all

    #changement des dates de fin d'abonnement
    # estimancy_users =  User.where("email LIKE ?", "%@estimancy.com%")
    # estimancy_emails = estimancy_users.map(&:email)
    # estimancy_users.update_all(subscription_end_date: "2030-12-31")
    # other_users = User.where.not(email: estimancy_emails).update_all(subscription_end_date: "2021-12-16")

    #update guw_type description
    Guw::GuwType.find_each do |uow_type|
      if uow_type.description.blank? || uow_type.description.to_s == "Description"
        uow_type.description = uow_type.name
        uow_type.save
      end
    end

  end
end




# organizations = Organization.where(name: ["07_DSI Matériel_CdS Matériel"]).all
#
# organizations.each do |o|
#
#   p " **** =========> #{o.name} <========== **** "
#
#   o.guw_models.each do |guw_model|
#
#     p " =====> #{guw_model.name} <===== "
#
#     rtu_ris_outputs = Guw::GuwOutput.where(organization_id: o.id,
#                                            guw_model_id: guw_model.id,
#                                            name: ["Charge RIS (jh)", "Charge RTU (jh)", "Assiette Test (jh)", "Charge RTU Avec Dégr.", "Charge RTU avec prod. (jh)"])
#
#     t_outputs = Guw::GuwOutput.where(organization_id: o.id,
#                                      guw_model_id: guw_model.id,
#                                      name: ["Charges T (jh)", "Charge T (jh)", "Charge Services (jh)", "Coût Services (€)"])
#
#     guw_types = guw_model.guw_types
#
#     guw_model.guw_coefficients.each do |guw_coefficient|
#
#       if guw_coefficient.name.include?("Dégressivité")  || guw_coefficient.name.include?("Dégréssivité")
#         guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#           if guw_coefficient_element.name == 'A5'
#
#           elsif guw_coefficient_element.name.in?(%w(A3 A4 A6 A7 A8 A9 A10))
#             guw_coefficient_element.default = false
#             guw_coefficient_element.save
#
#             guw_coefficient_element.guw_complexity_coefficient_elements.each do |cce|
#               #guw_coefficient = cce.guw_coefficient
#               #if guw_coefficient.name.include?("Dégressivité")  || guw_coefficient.name.include?("Dégréssivité")
#                 cce_guw_output = cce.guw_output
#                 unless cce_guw_output.nil?
#                     if cce.guw_output.name.in?(["Charge RIS (jh)", "Charge RTU Avec Dégr.", "Charge RTU (jh)", "Assiette Test (jh)", "Charges T (jh)", "Charge T (jh)", "Coût Services (€)", "Charge Services (jh)"])
#                     # cce.value = nil
#                     # cce.save
#                     cce.delete
#                   end
#                 end
#               #end
#
#             end
#           end
#         end
#       end
#     end
#   end
# end