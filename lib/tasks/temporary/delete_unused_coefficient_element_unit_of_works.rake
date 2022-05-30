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
# Novembre 2021 : COEFF INUTILE
# rake users:delete_unused_coefficient_element_unit_of_works RAILS_ENV=production
namespace :users do

  desc 'delete_unused_coefficient_element_unit_of_works'

  task :delete_unused_coefficient_element_unit_of_works => :environment do

    # Afficher le nombre de CEUOW par ligne d'UO

    all_ceuows_to_delete = 0

    Organization.all.each do |organization|

      puts "CDS  =  #{organization}"
      guw_ceuow_count_to_delete_per_cds = 0

      organization_id = organization.id
      organization.guw_models.each do |guw_model|
        guw_model_id = guw_model.id

        all_guw_coefficient_elements = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id)

        all_guw_coefficient_element_unit_of_works = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                                               guw_model_id: guw_model_id#,
                                                                                               #project_id: project_id,
                                                                                               #module_project_id: module_project_id
                                                                                               )
        guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: organization_id,
                                                     guw_model_id: guw_model_id#,
                                                     #project_id:  project_id,
                                                     #module_project_id: module_project_id
                                                    ).order("name ASC")

        guw_unit_of_works.each do |guw_unit_of_work|
          #puts "#{guw_unit_of_work}"

          project_id = guw_unit_of_work.project_id
          module_project_id = guw_unit_of_work.module_project_id

          used_guw_coefficient_elements = all_guw_coefficient_elements.select{|i| i.guw_complexity_coefficient_elements
                                                                                   .where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)
                                                                                   .where.not(value: nil)
                                                                                   .size > 0
                                                                              }
          used_guw_coefficient_element_ids = used_guw_coefficient_elements.map(&:id)
          used_guw_coefficient_ids = used_guw_coefficient_elements.map(&:guw_coefficient_id)
          used_coefficients = used_guw_coefficient_elements.map(&:guw_coefficient)


          all_ceuows = all_guw_coefficient_element_unit_of_works.where(guw_unit_of_work_id: guw_unit_of_work.id)
          all_used_ceuows = all_guw_coefficient_element_unit_of_works.where(guw_unit_of_work_id: guw_unit_of_work.id, guw_coefficient_id: used_guw_coefficient_ids.compact.uniq)

          ceuows_to_delete = all_ceuows.where.not(id: all_used_ceuows.map(&:id))

          ceuows_to_delete_size = ceuows_to_delete.size
          guw_ceuow_count_to_delete_per_cds = guw_ceuow_count_to_delete_per_cds + ceuows_to_delete_size
          all_ceuows_to_delete = all_ceuows_to_delete + ceuows_to_delete_size

          # puts "Nb total lignes de ceow = #{all_ceuows.size}"
          # puts "Nb total utiles lignes de ceow = #{all_used_ceuows.size}"
          #
          # puts "\n"
          # puts "From coefficient_element_unit_of_works"
          # all_used_ceuows.each do |ceuow|
          #   puts "  -- #{ceuow.guw_coefficient.id} - #{ceuow.guw_coefficient.name}"
          # end
          #
          # puts "\n"

          #delete others
          #ceuows_to_delete.delete_all
          Guw::GuwCoefficientElementUnitOfWork.where(id: ceuows_to_delete.map(&:id)).delete_all

        end

        #puts "Nb to delete ceow = #{all_ceuows_to_delete}" # 211 pour le projet 615
      end

      puts "CDS #{organization} : Nb GuwCoefficientElementUnitOfWork à supprimer = #{guw_ceuow_count_to_delete_per_cds}"
    end

    puts "Nb TOTAL ceow à supprimer = #{all_ceuows_to_delete}"

  end




  # task :delete_unused_coefficient_element_unit_of_works_SAVE => :environment do
  #
  #   # Afficher le nombre de CEUOW par ligne d'UO
  #   organization_id = 73
  #
  #   project_id = 4729
  #   guw_model_id = 974
  #   module_project_id = 12580
  #
  #   # project_id = 4730
  #   # guw_model_id = 998
  #   # module_project_id = 12584
  #
  #   guw_model = Guw::GuwModel.find(guw_model_id)
  #   #guw_coefficients = guw_model.guw_coefficients.where(organization_id: organization_id)
  #   all_guw_coefficient_elements = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id)
  #
  #   all_guw_coefficient_element_unit_of_works = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
  #                                                                                          guw_model_id: guw_model_id,
  #                                                                                          project_id: project_id,
  #                                                                                          module_project_id: module_project_id)
  #
  #   #guw_outputs = guw_model.guw_outputs.where(organization_id: organization_id, guw_model_id: guw_model_id).order("display_order ASC")
  #   guw_unit_of_works = Guw::GuwUnitOfWork.where(organization_id: organization_id,
  #                                                guw_model_id: guw_model_id,
  #                                                project_id:  project_id,
  #                                                module_project_id: module_project_id).order("name ASC")
  #
  #   guw_unit_of_works.each do |guw_unit_of_work|
  #     puts "#{guw_unit_of_work}"
  #
  #     # used_guw_coefficient_elements = all_guw_coefficient_elements.map{|i| i.guw_complexity_coefficient_elements
  #     #                                                                       .where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)
  #     #                                                                       .select{|ct| ct.value != nil }
  #     #                                                                       .map{|i| i.guw_coefficient_element }.uniq }.flatten.compact.sort! { |a, b|  a.display_order.to_i <=> b.display_order.to_i }
  #
  #
  #     # used_guw_coefficient_elements = all_guw_coefficient_elements.select{|i| i.guw_complexity_coefficient_elements
  #     #                                                                          .where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)
  #     #                                                                          .where.not(value: nil)
  #     #                                                                          .size > 0
  #     #                                                                        }
  #     #used_guw_coefficient_element_ids = used_guw_coefficient_elements.map(&:id)
  #
  #
  #     #GuwComplexityCoefficientElement
  #     used_complexity_coefficient_elements = Guw::GuwComplexityCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id, guw_type_id: guw_unit_of_work.guw_type_id)
  #                                                                                .where.not(value: nil)
  #     #used_guw_coefficient_element_ids = used_complexity_coefficient_elements.map(&:guw_coefficient_element_id)
  #
  #     used_coefficients = Array.new
  #     used_coefficient_element_ids = Array.new
  #     used_complexity_coefficient_elements.each do |cce|
  #       # puts "Coeff_Elt #{cce.guw_coefficient_element.name}"
  #       # puts "Coeff #{cce.guw_coefficient_element.guw_coefficient.name}"
  #       used_coefficient_element_ids << cce.guw_coefficient_element_id
  #       used_coefficients << cce.guw_coefficient_element.guw_coefficient rescue nil
  #     end
  #
  #     #all_ceuows = all_guw_coefficient_element_unit_of_works.where(guw_unit_of_work_id: guw_unit_of_work.id, guw_coefficient_element_id: used_coefficient_element_ids.compact.uniq)
  #     all_ceuows = all_guw_coefficient_element_unit_of_works.where(guw_unit_of_work_id: guw_unit_of_work.id, guw_coefficient_id: used_coefficients.compact.uniq)
  #     puts "Nb lignes de ceow = #{all_ceuows.size}"
  #
  #     #from GuwComplexityCoefficientElement
  #     puts "\n"
  #     puts "From GuwComplexityCoefficientElement"
  #     used_coefficients.compact.uniq.each do |coefficient|
  #       puts "  -- #{coefficient.id} - #{coefficient.name}"
  #     end
  #
  #     #from coefficient_element_unit_of_works
  #     puts "\n"
  #     puts "From coefficient_element_unit_of_works"
  #     all_ceuows.each do |ceuow|
  #       puts "  -- #{ceuow.guw_coefficient.id} - #{ceuow.guw_coefficient.name}"
  #     end
  #
  #     puts "\n"
  #   end
  #
  # end
end