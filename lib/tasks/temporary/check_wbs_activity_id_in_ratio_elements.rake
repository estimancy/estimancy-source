#Fait le 24 Septembre 2019
namespace :wbs_activities do
  desc "Correction de wbs_activity_id dans les ratios élements"
  task check_wbs_activity_id_in_ratio_elements: :environment do

    WbsActivity.all.each do |wbs_activity|
      wbs_activity.wbs_activity_ratios.each do |wbs_activity_ratio|
        wbs_activity_ratio.wbs_activity_ratio_elements.each_with_index do |wbs_activity_ratio_element, index|
          if wbs_activity_ratio_element.wbs_activity_id != wbs_activity.id

            puts wbs_activity.id

            wbs_activity_ratio_element.wbs_activity_id = wbs_activity.id
            wbs_activity_ratio_element.save

          end
        end
      end
    end

  end
end


