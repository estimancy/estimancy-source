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


namespace :estimancy do
  desc "Load default data from remote repository"
  task :verif_nearshore, [:organization_id, :model_id] => :environment do |task, args|

    ## SCRIPT DE VERIFICATION ##

    total = 0

    organization = Organization.where(id: args[:organization_id]).first
    guw_model = Guw::GuwModel.where(organization_id: organization.id, id: args[:model_id]).first

    puts organization
    puts guw_model

    guw_model.guw_types.each do |guw_type|

      if guw_type.name.include?("SRV")

        guw_complexity = guw_type.guw_complexities.first


        gcces = Guw::GuwComplexityCoefficientElement.where(organization_id: organization.id,
                                                           guw_model_id: guw_model.id,
                                                           guw_complexity_id: guw_complexity.id,
                                                           guw_type_id: guw_type.id).all

        gcces.each do |gcce|

          gcce_e = gcce.guw_coefficient_element

          if gcce_e.name.include?("Paris") || gcce_e.name.include?("Province")
            total += gcce.value.to_f
          end
        end

      end
    end

    puts "Résultat : #{total.to_f}"

  end
end