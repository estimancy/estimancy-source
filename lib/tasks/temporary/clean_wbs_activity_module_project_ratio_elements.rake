#update_wbs_activity_module_project_ratio_elements
## rake wbs_activities:clean_wbs_activity_module_project_ratio_elements RAILS_ENV=production

namespace :wbs_activities do
  desc "Prise en compte des modifications de la WBS avec les formules"
  task clean_wbs_activity_module_project_ratio_elements: :environment do

    Organization.all.each do |organization|

      ActiveRecord::Base.transaction do

        ModuleProject.where("organization_id = ? AND wbs_activity_id != ? ", organization.id, "").each do |module_project|
        #ModuleProject.where(id: 3229).each do |module_project|
          wbs_activity = module_project.wbs_activity
          wbs_activity_elements_size = wbs_activity.wbs_activity_elements.length

          module_project_ratio_elements = module_project.module_project_ratio_elements.first(wbs_activity_elements_size)
          module_project.module_project_ratio_elements.where("id NOT IN (?)", module_project_ratio_elements.map(&:id)).delete_all

          module_project_ratio_elements.each do | mp_ratio_elt|
            mp_ratio_elt.update_attributes(organization_id: module_project.organization_id, wbs_activity_id: wbs_activity.id)
          end
        end
      end
    end
  end
end


