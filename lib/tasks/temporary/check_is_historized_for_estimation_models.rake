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



### Pour PROD TRAIN -  Enlever les droits pour tous les modèles commençant par "Prestation"
# Organization.where(id: 61).all.each do |organization|
#   puts "#{organization.name}"
#   #begin
#     Project.where(organization_id: organization.id, is_model: true).each do |estimation_model|
#       #if estimation_model.title.to_s.downcase.start_with?("prestation", "prestations", "prestation ", "prestations ", "Prestations", "Prestations ")
#       estimation_model_name = estimation_model.title.to_s.downcase
#       if estimation_model_name.start_with?("prestation") || estimation_model_name.start_with?(" prestation")
#         estimation_model.project_security_ids = []
#         estimation_model.save(validate: false)
#       end
#     end
#   #rescue
#     #nothing
#   #end
# end
