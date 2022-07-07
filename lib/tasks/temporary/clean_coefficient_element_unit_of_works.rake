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
# octobre 2021 : IMPACT
# rake guw_models:clean_coefficient_element_unit_of_works RAILS_ENV=production
namespace :guw_models do

  desc 'Clean coefficient_element_unit_of_works'

  task :clean_coefficient_element_unit_of_works => :environment do

    #================================================================================================
    #==== Donnes fantomes pour : GuwUnitOfWorkAttribute (Nb fantôme = 343 963)  nb total records = 1 846 501
    guw_uowa_count = 0
    Guw::GuwUnitOfWorkAttribute.find_each do |uowa|
      unless Guw::GuwUnitOfWork.where(id: uowa.guw_unit_of_work_id).exists?
        guw_uowa_count = guw_uowa_count+1
        uowa.delete
      end
    end
    puts "Nb GuwUnitOfWorkAttribute fantôme = #{guw_uowa_count}"  # 295686 + 6815 + 408512

    #================================================================================================

    #==== Donnes fantomes pour : GuwCoefficientElementUnitOfWork (Nb fantôme = 343 964)  nb total records = 2 162 426
    guw_ceuow_count = 0
    Guw::GuwCoefficientElementUnitOfWork.find_each do |ceuow|
      unless Guw::GuwUnitOfWork.where(id: ceuow.guw_unit_of_work_id).exists?
        guw_ceuow_count = guw_uowa_count+1
        ceuow.delete
      end
    end
    puts "Nb GuwCoefficientElementUnitOfWork fantôme = #{guw_ceuow_count}" # 408513

    #================================================================================================

    #Mettre nb devis par users à 10 pour tout le monde
    User.update_all(object_per_page: 10)


    #=== Utilisateurs fantômes qui ne sont rattachés à aucune organisation

    fantome_user_count = 0
    User.find_each do |user|
      if user.organizations.all.size == 0
        fantome_user_count = fantome_user_count+1
        #puts user
        user.delete
      end
    end
    puts "NB user fantômes = #{fantome_user_count}" #NB user fantômes = 153

    #================================================================================================
    #Dans cette table, il ya plusieurs elts pour une ligne d'UO, ce qui n'est pas normal
    guw_ceuow_count_to_delete = 0
    nb_guw_unit_of_work_with_no_model = 0
    Organization.all.each do |organization|

      puts "CDS  =  #{organization}"
      guw_ceuow_count_to_delete_per_cds = 0

      organization_id = organization.id

      organization.guw_models.each do |guw_model|
        guw_model_id = guw_model.id

        Guw::GuwUnitOfWork.where(organization_id: organization.id, guw_model_id: guw_model_id).each_with_index do |guw_unit_of_work, i|

          project_id = guw_unit_of_work.project_id
          module_project_id = guw_unit_of_work.module_project_id
          guw_unit_of_work_id = guw_unit_of_work.id

          guw_coefficients = guw_model.guw_coefficients.where(organization_id: organization_id)
          guw_coefficients.each do |guw_coefficient|

            guw_coefficient_id = guw_coefficient.id
            if guw_coefficient.coefficient_type == "Pourcentage" || guw_coefficient.coefficient_type == "Coefficient"

              ceuws = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                 guw_model_id: guw_model_id,
                                                                 guw_coefficient_id: guw_coefficient_id,
                                                                 #guw_coefficient_element_id: nil,
                                                                 project_id: project_id,
                                                                 module_project_id: module_project_id,
                                                                 guw_unit_of_work_id: guw_unit_of_work_id)


              last_ceuw = ceuws.order(updated_at: :asc, id: :asc).last
              if last_ceuw
                ce = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id, guw_coefficient_id: guw_coefficient_id).first

                if ce
                  if ce.value.to_f == 100
                    if last_ceuw.percent.to_f != 100
                      first_ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                              guw_model_id: guw_model_id,
                                                                              guw_coefficient_id: guw_coefficient_id,
                                                                              guw_coefficient_element_id: ce.id,
                                                                              project_id: project_id,
                                                                              module_project_id: module_project_id,
                                                                              guw_unit_of_work_id: guw_unit_of_work_id).order(updated_at: :asc, id: :asc).first

                      comments = first_ceuw.comments rescue nil
                      last_ceuw.comments = comments
                    end
                  end

                  last_ceuw.guw_coefficient_element_id = ce.id
                  last_ceuw.save
                end


                other_ceuows = ceuws.where.not(id: last_ceuw.id)
                other_ceuows_size = other_ceuows.size
                guw_ceuow_count_to_delete = guw_ceuow_count_to_delete + other_ceuows_size
                guw_ceuow_count_to_delete_per_cds = guw_ceuow_count_to_delete_per_cds + other_ceuows_size

                #delete others
                other_ceuows.delete_all
              end
            end
          end
        end
      end
      puts "CDS #{organization} : Nb GuwCoefficientElementUnitOfWork en plus = #{guw_ceuow_count_to_delete_per_cds}"
    end

    puts "Nb TOTAL GuwCoefficientElementUnitOfWork en plus = #{guw_ceuow_count_to_delete}"  #sur test2 = Nb TOTAL GuwCoefficientElementUnitOfWork en plus = 407918

  end


  task :clean_coefficient_element_test => :environment do

    guw_ceuow_count_to_delete = 0
    guw_ceuow_count_to_delete_per_cds = 0
    organization_id = 75
    guw_model_id = 721
    guw_model = Guw::GuwModel.find(guw_model_id)
    guw_coefficient_id = 1282
    project_id = 32964
    module_project_id = 96010
    guw_unit_of_work_id = 220052 #219957

    Guw::GuwUnitOfWork.where(organization_id: organization_id, guw_model_id: guw_model_id, id: guw_unit_of_work_id).each_with_index do |guw_unit_of_work, i|

      project_id = guw_unit_of_work.project_id
      module_project_id = guw_unit_of_work.module_project_id
      guw_unit_of_work_id = guw_unit_of_work.id

      guw_coefficients = guw_model.guw_coefficients.where(organization_id: organization_id, id: guw_coefficient_id)
      guw_coefficients.each do |guw_coefficient|

        guw_coefficient_id = guw_coefficient.id
        if guw_coefficient.coefficient_type == "Pourcentage" || guw_coefficient.coefficient_type == "Coefficient"

          ceuws = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                             guw_model_id: guw_model_id,
                                                             guw_coefficient_id: guw_coefficient_id,
                                                             #guw_coefficient_element_id: nil,
                                                             project_id: project_id,
                                                             module_project_id: module_project_id,
                                                             guw_unit_of_work_id: guw_unit_of_work_id)


          puts "#{ceuws.map(&:id)}"
          puts "#{ceuws.map(&:updated_at).max}"
          #puts "#{ceuws.order(updated_at: :asc).last.id}"

          last_ceuw = ceuws.order(updated_at: :asc, id: :asc).last
          puts "LAST ID = #{last_ceuw.id}"
          puts "LAST VALUE = #{last_ceuw.percent}"

          if last_ceuw
            ce = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id, guw_coefficient_id: guw_coefficient_id).first

            if ce
              if ce.value.to_f == 100
                if last_ceuw.percent.to_f != 100
                  first_ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: organization_id,
                                                                          guw_model_id: guw_model_id,
                                                                          guw_coefficient_id: guw_coefficient_id,
                                                                          guw_coefficient_element_id: ce.id,
                                                                          project_id: project_id,
                                                                          module_project_id: module_project_id,
                                                                          guw_unit_of_work_id: guw_unit_of_work_id).order("updated_at ASC").first

                  puts "FIRST ID = #{first_ceuw.id}"
                  puts "FIRST VALUE = #{first_ceuw.percent}"

                  comments = first_ceuw.comments rescue nil
                  last_ceuw.comments = comments
                end
              end

              last_ceuw.guw_coefficient_element_id = ce.id
              last_ceuw.save
            end


            other_ceuows = ceuws.where.not(id: last_ceuw.id)
            other_ceuows_size = other_ceuows.size
            guw_ceuow_count_to_delete = guw_ceuow_count_to_delete + other_ceuows_size
            guw_ceuow_count_to_delete_per_cds = guw_ceuow_count_to_delete_per_cds + other_ceuows_size

            #delete others
            ##other_ceuows.delete_all
          end
        end
      end
    end

  end



end