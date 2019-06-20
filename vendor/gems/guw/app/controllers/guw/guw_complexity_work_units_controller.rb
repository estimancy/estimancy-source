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


class Guw::GuwComplexityWorkUnitsController < ApplicationController

  def save_complexity_work_units
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_model = @guw_type.guw_model
    organization_id = @guw_model.organization_id
    guw_model_id = @guw_model.id

    expire_fragment "guw"

    unless params[:config].nil?
      params[:config].each do |i|
        i.last.each do |j|

          got = Guw::GuwOutputType.where(organization_id: organization_id,
                                         guw_model_id: guw_model_id,
                                         guw_output_id: j.first.to_i,
                                         guw_type_id: @guw_type.id).first

          if got.nil?
            Guw::GuwOutputType.create(organization_id: organization_id,
                                      guw_model_id: guw_model_id,
                                      guw_output_id: j.first.to_i,
                                      guw_type_id: @guw_type.id,
                                      display_type: params[:display_modif]["#{j.first.to_i}"])
          else
            got.display_type = params[:display_modif]["#{j.first.to_i}"]
            got.save
          end

          j.last.each do |k|

            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)

            a_output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: j.first.to_i).first #.find(j.first.to_i)

            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            oa = Guw::GuwOutputAssociation.where(organization_id: organization_id,
                                                 guw_model_id: guw_model_id,
                                                 guw_output_id: output.id,
                                                 guw_complexity_id: cplx.id,
                                                 guw_output_associated_id: a_output.id).first

            value = params[:config]["#{cplx.id}"]["#{output.id}"]["#{a_output.id}"]

            if oa.nil?
              unless value.blank?
                Guw::GuwOutputAssociation.create(organization_id: organization_id,
                                                 guw_model_id: guw_model_id,
                                                 guw_output_id: output.id,
                                                 guw_complexity_id: cplx.id,
                                                 guw_output_associated_id: a_output.id,
                                                 value: value)
              end
            else
              oa.value = value
              oa.save
            end
          end
        end
      end
    end

    unless params[:config].nil?
      params[:config].each do |i|
        i.last.each do |j|
          j.last.each do |k|

            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            oci = Guw::GuwOutputComplexityInitialization.where(organization_id: organization_id,
                                                               guw_model_id: guw_model_id,
                                                               guw_output_id: output.id,
                                                               guw_complexity_id: cplx.id).first

            # Pour GuwOutputComplexityInitialization ? Tester que init_value.blank? ??!!

            if oci.nil?
              Guw::GuwOutputComplexityInitialization.create(organization_id: organization_id,
                                                            guw_model_id: guw_model_id,
                                                            guw_output_id: output.id,
                                                            guw_complexity_id: cplx.id,
                                                            init_value: params[:value_init]["#{cplx.id}"]["#{output.id}"])

            else
              oci.init_value = params[:value_init]["#{cplx.id}"]["#{output.id}"]
              oci.save
            end
          end
        end
      end
    end

    unless params[:config].nil?
      params[:config].each do |i|
        i.last.each do |j|
          j.last.each do |k|

            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            oc = Guw::GuwOutputComplexity.where(organization_id: organization_id,
                                                guw_model_id: guw_model_id,
                                                guw_output_id: output.id,
                                                guw_complexity_id: cplx.id).first
            if oc.nil?
              Guw::GuwOutputComplexity.create(organization_id: organization_id,
                                              guw_model_id: guw_model_id,
                                              guw_output_id: output.id,
                                              guw_complexity_id: cplx.id,
                                              value: params[:value_cplx]["#{cplx.id}"]["#{output.id}"])

            else
              oc.value = params[:value_cplx]["#{cplx.id}"]["#{output.id}"]
              oc.save
            end
          end
        end
      end
    end


    unless params[:coefficient_elements_value].nil?
      params[:coefficient_elements_value].each do |i|
        i.last.each do |j|
          j.last.each do |k|
            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
            ce = Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id, id: j.first.to_i).first#.find(j.first.to_i)
            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            cwu = Guw::GuwComplexityCoefficientElement.where(organization_id: organization_id,
                                                             guw_model_id: guw_model_id,
                                                             guw_output_id: output.id,
                                                             guw_complexity_id: cplx.id,
                                                             guw_coefficient_element_id: ce.id).first

            value = params[:coefficient_elements_value]["#{cplx.id}"]["#{ce.id}"]["#{output.id}"]
            if cwu.nil?
              unless value.blank?
                Guw::GuwComplexityCoefficientElement.create(organization_id: organization_id,
                                                            guw_model_id: guw_model_id,
                                                            guw_complexity_id: cplx.id,
                                                            guw_coefficient_element_id: ce.id,
                                                            guw_output_id: output.id,
                                                            value: params[:coefficient_elements_value]["#{cplx.id}"]["#{ce.id}"]["#{output.id}"],
                                                            guw_type_id: @guw_type.id)
              end
            else
              cwu.value = params[:coefficient_elements_value]["#{cplx.id}"]["#{ce.id}"]["#{output.id}"]
              cwu.guw_type_id = @guw_type.id
              cwu.guw_output_id = output.id
              cwu.save
            end
          end
        end
      end
    end

    unless params[:work_unit_value].nil?
      params[:work_unit_value].each do |i|
        i.last.each do |j|
          j.last.each do |k|
            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
            wu = Guw::GuwWorkUnit.where(organization_id: organization_id, guw_model_id: guw_model_id, id: j.first.to_i).first #.find(j.first.to_i)
            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            cwu = Guw::GuwComplexityWorkUnit.where(organization_id: organization_id,
                                                   guw_model_id: guw_model_id,
                                                   guw_work_unit_id: wu.id,
                                                   guw_complexity_id: cplx.id,
                                                   guw_output_id: output.id).first
            if cwu.nil?
              Guw::GuwComplexityWorkUnit.create(organization_id: organization_id,
                                                guw_model_id: guw_model_id,
                                                guw_complexity_id: cplx.id,
                                                guw_work_unit_id: wu.id,
                                                guw_output_id: output.id,
                                                value: params[:work_unit_value]["#{cplx.id}"]["#{wu.id}"]["#{output.id}"],
                                                guw_type_id: @guw_type.id)
            else
              cwu.value = params[:work_unit_value]["#{cplx.id}"]["#{wu.id}"]["#{output.id}"]
              cwu.guw_type_id = @guw_type.id
              cwu.guw_output_id = output.id
              cwu.save
            end
          end
        end
      end
    end

    unless params[:weightings_value].nil?
      params[:weightings_value].each do |i|
        i.last.each do |j|
          j.last.each do |k|
            cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
            we = Guw::GuwWeighting.where(organization_id: organization_id, guw_model_id: guw_model_id, id: j.first.to_i).first #.find(j.first.to_i)
            output = Guw::GuwOutput.where(organization_id: organization_id, guw_model_id: guw_model_id, id: k.first.to_i).first #.find(k.first.to_i)

            cwe = Guw::GuwComplexityWeighting.where(guw_complexity_id: cplx.id,
                                                    guw_weighting_id: we.id,
                                                    guw_output_id: output.id).first
            if cwe.nil?
              Guw::GuwComplexityWeighting.create(guw_complexity_id: cplx.id,
                                                 guw_weighting_id: we.id,
                                                 guw_output_id: output.id,
                                                 value: params[:weightings_value]["#{cplx.id}"]["#{we.id}"]["#{output.id}"],
                                                 guw_type_id: @guw_type.id)
            else
              cwe.value = params[:weightings_value]["#{cplx.id}"]["#{we.id}"]["#{output.id}"]
              cwe.guw_type_id = @guw_type.id
              cwe.guw_output_id = output.id
              cwe.save
            end
          end
        end
      end
    end

    # unless params[:factors_value].nil?
    #   params[:factors_value].each do |i|
    #     i.last.each do |j|
    #       j.last.each do |k|
    #         cplx = Guw::GuwComplexity.find(i.first.to_i)
    #         fa = Guw::GuwFactor.find(j.first.to_i)
    #         output = Guw::GuwOutput.find(k.first.to_i)
    #
    #         cfa = Guw::GuwComplexityFactor.where(guw_complexity_id: cplx.id,
    #                                              guw_factor_id: fa.id,
    #                                              guw_output_id: output.id).first
    #         if cfa.nil?
    #           Guw::GuwComplexityFactor.create(guw_complexity_id: cplx.id,
    #                                           guw_factor_id: fa.id,
    #                                           guw_output_id: output.id,
    #                                           value: params[:factors_value]["#{cplx.id}"]["#{fa.id}"]["#{output.id}"],
    #                                           guw_type_id: @guw_type.id)
    #         else
    #           cfa.value = params[:factors_value]["#{cplx.id}"]["#{fa.id}"]["#{output.id}"]
    #           cfa.guw_type_id = @guw_type.id
    #           cfa.guw_output_id = output.id
    #           cfa.save
    #         end
    #       end
    #     end
    #   end
    # end

    unless params[:technology_value].nil?
      params[:technology_value].each do |i|
        i.last.each do |j|
          ot = OrganizationTechnology.find(j.first.to_i)
          cplx = Guw::GuwComplexity.where(organization_id: organization_id, guw_model_id: guw_model_id, id: i.first.to_i).first #.find(i.first.to_i)
          # @guw_type = cplx.guw_type

          ct = Guw::GuwComplexityTechnology.where(organization_id: organization_id,
                                                  guw_model_id: guw_model_id,
                                                  organization_technology_id: ot.id,
                                                  guw_complexity_id: cplx.id).first_or_create
          ct.coefficient = params[:technology_value]["#{cplx.id}"]["#{ot.id}"]
          ct.guw_type_id = @guw_type.id
          ct.save

        end
      end
    end

    @guw_type.guw_complexities.where(organization_id: organization_id, guw_model_id: guw_model_id).each do |cplx|
      if params['enable_value'].present?
        cplx.enable_value = params['enable_value']["#{cplx.guw_type.id}"]["#{cplx.id}"].nil? ? false : true
      else
        cplx.enable_value = false
      end
      cplx.save
    end

    # Attention
    Guw::GuwOutputAssociation.where(organization_id: organization_id, guw_model_id: guw_model_id, value: nil).each do |goa|
      goa.delete
    end

    Guw::GuwComplexityCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id, value: nil).each do |gcce|
      gcce.delete
    end

    Guw::GuwCoefficientElement.where(organization_id: organization_id, guw_model_id: guw_model_id).all.each do |gce|
      if gce.default_display_value.nil?
        gce.default_display_value = gce.value
        gce.save
      end
    end

    if @guw_type.nil?
      redirect_to :back
    else
      if @guw_model.default_display == "list"
        redirect_to guw.guw_type_path(@guw_type)
      else
        redirect_to guw.guw_model_path(@guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
      end
    end
  end
end
