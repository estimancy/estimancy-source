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

# rake guw_models:coefficient_element_unit_of_works RAILS_ENV=production
namespace :guw_models do

  desc 'Clean coefficient_element_unit_of_works'

  task :coefficient_element_unit_of_works => :environment do

    #Dans cette table, il ya plusieurs elts pour une ligne d'UO, ce qui n'est pas normal
    guw_ceuow_count_to_delete = 0
    Organization.all.each do |organization|
      puts "CDS  =  #{organization}"
      guw_ceuow_count_to_delete_per_cds = 0

      Guw::GuwUnitOfWork.where(organization_id: organization.id).each_with_index do |guw_unit_of_work, i|

        organization_id = guw_unit_of_work.organization_id
        guw_model = guw_unit_of_work.guw_model
        guw_model_id = guw_unit_of_work.guw_model_id
        project_id = guw_unit_of_work.project_id
        module_project_id = guw_unit_of_work.module_project_id
        guw_unit_of_work_id = guw_unit_of_work.id

        @guw_coefficients = guw_model.guw_coefficients.where(organization_id: organization_id)
        @guw_coefficients.each do |guw_coefficient|
          #guw_coefficient_guw_coefficient_elements = guw_coefficient.guw_coefficient_elements.where(organization_id: organization.id, guw_model_id: @guw_model.id)

          guw_coefficient_id = guw_coefficient.id
          if guw_coefficient.coefficient_type == "Pourcentage" || guw_coefficient.coefficient_type == "Coefficient"

            ceuws = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                               guw_model_id: guw_model_id,
                                                               guw_coefficient_id: guw_coefficient_id,
                                                               #guw_coefficient_element_id: nil,
                                                               project_id: project_id,
                                                               module_project_id: module_project_id,
                                                               guw_unit_of_work_id: guw_unit_of_work_id).order("updated_at DESC")


            last_ceuw = ceuws.last
            if last_ceuw
              ce = Guw::GuwCoefficientElement.where(organization_id: organization_id,
                                                    guw_model_id: guw_model_id,
                                                    guw_coefficient_id: guw_coefficient_id).first

              if ce && ce.value.to_f == 100
                if last_ceuw.percent.to_f != 100
                  first_ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                          guw_model_id: guw_model_id,
                                                                          guw_coefficient_id: guw_coefficient_id,
                                                                          guw_coefficient_element_id: ce.id,
                                                                          project_id: project_id,
                                                                          module_project_id: module_project_id,
                                                                          guw_unit_of_work_id: guw_unit_of_work_id).order("updated_at DESC").first

                  comments = first_ceuw.comments rescue nil
                  last_ceuw.comments = comments
                end
              end

              last_ceuw.guw_coefficient_element_id = ce.id
              #last_ceuw.save

              other_ceuows = ceuws.where.not(id: last_ceuw.id)
              guw_ceuow_count_to_delete = guw_ceuow_count_to_delete + other_ceuows.size

              #delete others
              #other_ceuows.delete_all
            end
          end
        end
      end
      puts "CDS #{organization} : Nb GuwCoefficientElementUnitOfWork en plus = #{guw_ceuow_count_to_delete_per_cds}"
    end

    puts "Nb TOTAL GuwCoefficientElementUnitOfWork en plus = #{guw_ceuow_count_to_delete}"

  end
end