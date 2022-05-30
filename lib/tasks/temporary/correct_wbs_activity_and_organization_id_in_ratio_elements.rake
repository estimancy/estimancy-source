#Fait le 07 Janvier 2020
## rake wbs_activities:correct_wbs_activity_and_organization_id_in_ratio_elements RAILS_ENV=production

namespace :wbs_activities do
  desc "Correction de wbs_activity_id dans les ratios élements"
  task correct_wbs_activity_and_organization_id_in_ratio_elements: :environment do

    ###TESTS
    WbsActivity.all.each do |wbs_activity|
      wbs_activity.wbs_activity_ratios.each do |wbs_activity_ratio|
        wbs_activity_ratio.wbs_activity_ratio_elements.each_with_index do |wbs_activity_ratio_element, index|
          if wbs_activity_ratio_element.wbs_activity_id != wbs_activity.id
            wbs_activity_ratio_element.wbs_activity_id = wbs_activity.id
            wbs_activity_ratio_element.organization_id = wbs_activity_ratio.organization_id
            wbs_activity_ratio_element.save
          end
        end
      end
    end
    ###TESTS

  end
end


