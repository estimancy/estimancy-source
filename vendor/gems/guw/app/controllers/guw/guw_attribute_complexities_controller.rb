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


class Guw::GuwAttributeComplexitiesController < ApplicationController

  def save_attributs_complexities

    unless params["bottom"].nil?
      params["bottom"].each do |attribute|
        attribute.last.each do |type_complexity|
          tc = Guw::GuwTypeComplexity.find(type_complexity.first.to_i)
          @guw_type = tc.guw_type
          a = Guw::GuwAttribute.find(attribute.first.to_i)

          gac = Guw::GuwAttributeComplexity.where( guw_type_id: params[:guw_type_id],
                                                   guw_attribute_id: a.id.to_i,
                                                   guw_type_complexity_id: tc.id).first
          if gac.nil?
            Guw::GuwAttributeComplexity.create(bottom_range: params["bottom"]["#{a.id}"][type_complexity.first],
                                               top_range: params["top"]["#{a.id}"][type_complexity.first],
                                               guw_type_id: params[:guw_type_id],
                                               guw_attribute_id: a.id.to_i,
                                               guw_type_complexity_id: tc.id,
                                               value: params["coefficient"]["#{a.id}"][type_complexity.first],
                                               enable_value: false)
          else
            gac.bottom_range = params["bottom"]["#{a.id}"][type_complexity.first]
            gac.top_range = params["top"]["#{a.id}"][type_complexity.first]
            gac.value = params["coefficient"]["#{a.id}"][type_complexity.first]
            #unless params["enable"].nil?
            #  gac.enable_value = params["enable"]["#{a.id}"]
            #else
              if params["enable"]["#{a.id}"].nil?
                gac.enable_value = false
              else
                gac.enable_value = true
              end
            #end
            gac.save
          end
        end
      end
    end

    if @guw_type.nil?
      redirect_to :back
    else
      redirect_to guw.guw_model_path(params[:guw_model_id], anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
    end
  end
end
