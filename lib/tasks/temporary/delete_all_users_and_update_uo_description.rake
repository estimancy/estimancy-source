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

    # Afficher le nombre de CEUOW par ligne d'UO
    organization_id = 73

    project_id = 4729
    guw_model_id = 974
    module_project_id = 12580

    # project_id = 4730
    # guw_model_id = 998
    # module_project_id = 12584

    guw_model = Guw::GuwModel.find(guw_model_id)
    #guw_coefficients = guw_model.guw_coefficients.where(organization_id: organization_id)
    all_guw_coefficient_elements = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id)

    all_guw_coefficient_element_unit_of_works = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                                            guw_model_id: guw_model_id,
                                                                                            project_id: project_id,
                                                                                            module_project_id: module_project_id)

    #guw_outputs = guw_model.guw_outputs.where(organization_id: organization_id, guw_model_id: guw_model_id).order("display_order ASC")
    guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                 guw_model_id: guw_model_id,
                                                 project_id:  project_id,
                                                 module_project_id: module_project_id).order("name ASC")
    guw_unit_of_works.each do |guw_unit_of_work|
      puts "#{guw_unit_of_work}"

      # used_guw_coefficient_elements = all_guw_coefficient_elements.map{|i| i.guw_complexity_coefficient_elements
      #                                                                       .where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)
      #                                                                       .select{|ct| ct.value != nil }
      #                                                                       .map{|i| i.guw_coefficient_element }.uniq }.flatten.compact.sort! { |a, b|  a.display_order.to_i <=> b.display_order.to_i }

      #GuwComplexityCoefficientElement
      used_guw_coefficient_elements = all_guw_coefficient_elements.select{|i| i.guw_complexity_coefficient_elements
                                                                               .where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)#.where.not(value: nil)
                                                                               .size > 0
                                                                             }

      used_guw_coefficient_element_ids = used_guw_coefficient_elements.map(&:id)
      all_ceuows = all_guw_coefficient_element_unit_of_works.where(guw_unit_of_work_id: guw_unit_of_work.id, guw_coefficient_element_id: used_guw_coefficient_element_ids)
      puts "Nb lignes de ceow = #{all_ceuows.size}"

      all_ceuows.each do |ceuow|
        puts "  -- #{ceuow.guw_coefficient.id} - #{ceuow.guw_coefficient.name}"
      end

      puts "\n"
    end


    #update guw_type description
    Guw::GuwType.find_each do |uow_type|
      if uow_type.description.blank? || uow_type.description.to_s == "Description"
        uow_type.description = uow_type.name
        uow_type.save
      end
    end

  end
end