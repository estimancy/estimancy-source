
# Certains éléments de ratios (wbs-activity-ratio-elements) n'ont pas la bonne valeur de wbs-activity-element
# Il s'agit principalement des élements de ratio liés au wbs-activity-element root
# Nous créons donc cette tache rake pour effectuer des corrections sur ces valeurs

namespace :wbs_activity_ratio_elements do
  desc "Correction des valeurs de wbs-activity-element au niveau des wbs-activity-ratio-elements"

  task correction_on_old_wbs_activity_ratio_elements: :environment do

    WbsActivity.all.each do |wbs_activity|

      # get the wbs-activity's activity-elements
      all_wbs_activity_elements_ids = wbs_activity.wbs_activity_element_ids || []

      ActiveRecord::Base.transaction do
        wbs_activity.wbs_activity_ratios.each do |ratio|

          wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements
          wbs_activity_ratio_element_ids = ratio.wbs_activity_ratio_element_ids

          # Get wbs-activity_element_ids from the ratio-element
          ratio_wbs_activity_element_ids = []
          wbs_activity_ratio_elements.each do |ratio_element|
            wbs_activity_element_id = ratio_element.wbs_activity_element_id
            unless wbs_activity_element_id.nil?
              ratio_wbs_activity_element_ids << wbs_activity_element_id
            end
          end

          ids_differences = ratio_wbs_activity_element_ids - all_wbs_activity_elements_ids

          unless ids_differences.empty?
            # Comparaison
            all_wbs_activity_elements_ids.each_with_index do |wbs_activity_element_id, index|
              wbs_activity_ratio_element = WbsActivityRatioElement.find(wbs_activity_ratio_element_ids[index])
              if wbs_activity_ratio_element
                false_wbs_activity_element_id = wbs_activity_ratio_element.wbs_activity_element_id
                unless false_wbs_activity_element_id.to_s == wbs_activity_element_id.to_s
                  puts "#{false_wbs_activity_element_id}, #{wbs_activity_element_id}  different"
                  wbs_activity_ratio_element.wbs_activity_element_id = wbs_activity_element_id
                  wbs_activity_ratio_element.save
                end
              end
            end
          end


        end
      end

    end

  end
end


# ids_differences.each do |false_element_id|
#   ratio_element_with_false_id = wbs_activity_ratio_elements.where(wbs_activity_element_id: false_element_id)
# end
# ratio_element_with_false_element_id = wbs_activity_ratio_elements.where("wbs_activity_element_id NOT IN (?)", all_wbs_activity_elements_ids )
# wbs_activity_ratio_elements.each do |ratio_element|
#   current_activity_element_id = ratio_element.wbs_activity_element_id
#   if !wbs_activity_element_ids.in?(current_activity_element_id)
#   end
# end
