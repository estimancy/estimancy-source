#Fait le 24 Septembre 2019
namespace :wbs_activities do
  desc "Correction de wbs_activity_id dans les ratios élements"
  task check_wbs_activity_id_in_ratio_elements: :environment do

    WbsActivity.all.each do |wbs_activity|
      wbs_activity.wbs_activity_ratios.each do |wbs_activity_ratio|
        wbs_activity_ratio.wbs_activity_ratio_elements.each_with_index do |wbs_activity_ratio_element, index|
          if wbs_activity_ratio_element.wbs_activity_id != wbs_activity.id
            wbs_activity_ratio_element.wbs_activity_id = wbs_activity.id
            wbs_activity_ratio_element.save
          end
        end
      end
    end

    Guw::GuwCoefficient.all.each do |guw_coefficient|
      guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
        guw_coefficient_element.guw_model_id = guw_coefficient.guw_model_id
        guw_coefficient_element.save
      end
    end

    Guw::GuwComplexity.all.each do |guw_complexity|
      guw_complexity_guw_type = guw_complexity.guw_type
      unless guw_complexity_guw_type.nil?
        guw_complexity.guw_model_id = guw_complexity_guw_type.guw_model_id
        guw_complexity.save
      end
    end

    organization = Organization.find(71)
    organization.guw_complexity_coefficient_elements.each do |gcce|
      gcce_guw_type = gcce.guw_type
      unless gcce_guw_type.nil?
        gcce.guw_model_id = gcce_guw_type.guw_model_id
        gcce.save
      end
    end


    organization.guw_output_associations.each do |goa|
      goa_guw_complexity = goa.guw_complexity

      guw_output = Guw::GuwOutput.where(copy_id: goa.guw_output_id, organization_id: 71).first
      guw_output_associated = Guw::GuwOutput.where(copy_id: goa.guw_output_associated_id, organization_id: 71).first

      unless goa_guw_complexity.nil?
        goa.guw_model_id = goa_guw_complexity.guw_model_id

        unless guw_output.nil?
          goa.guw_output_id = guw_output.id
        end

        unless guw_output_associated.nil?
          goa.guw_output_associated_id = guw_output_associated.id
        end

        goa.save
      end
    end

    organization.guw_output_complexities.each do |goc|

      goc_guw_complexity = goc.guw_complexity
      guw_output = Guw::GuwOutput.where(copy_id: goc.guw_output_id, organization_id: 71).first

      unless goc_guw_complexity.nil?
        goc.guw_model_id = goc_guw_complexity.guw_model_id
      end

      unless guw_output.nil?
        goc.guw_output_id = guw_output.id
      end

      goc.save

    end

    organization.guw_output_complexity_initializations.each do |goci|
      goci_guw_complexity = goci.guw_complexity
      guw_output = Guw::GuwOutput.where(copy_id: goci.guw_output_id, organization_id: 71).first

      unless goci_guw_complexity.nil?
        goci.guw_model_id = goci_guw_complexity.guw_model_id
      end

      unless guw_output.nil?
        goci.guw_output_id = guw_output.id
      end

      goci.save

    end

  end
end


