# Novembre 2021
## rake projects:check_is_historized_for_estimation_models RAILS_ENV=production

namespace :projects do
  desc "check_is_historized_for_estimation_models"
  task check_is_historized_for_estimation_models: :environment do

    Organization.all.each do |organization|
      puts "#{organization.name}"
      begin
        Project.where(organization_id: organization.id, is_model: true).each do |estimation_model|
          #project_securities = estimation_model.project_securities.where(organization_id: organization.id)
          if estimation_model.project_securities.where(organization_id: organization.id, is_model_permission: false, is_estimation_permission: true).size == 0
            estimation_model.is_historized = true
            estimation_model.historization_time = Time.now
          else
            estimation_model.is_historized = false
            estimation_model.historization_time = nil
          end
          estimation_model.save(validate: false)
        end

      rescue
        #nothing
      end
    end

  end
end


