# rake projects:update_historized_estimations RAILS_ENV=production

namespace :projects do

  desc "Met à jour les estimations qui sont dans un statut d'historisation (en fonction de la)"

  task update_historized_estimations: :environment do

    Organization.all.each do |organization|
      historized_statuses = organization.estimation_statuses.where(is_historization_status: true)
      historized_status_ids = historized_statuses.map(&:id)
      organization.projects.where(estimation_status_id: historized_status_ids).each do |project|

        if project.historization_time.blank?
          project.update_attributes(historization_time: Time.now, is_historized: true)
          puts "#{project.to_s} : historisé sans date d'historisation"
        elsif project.historization_time >= Time.now
          project.update_attributes(is_historized: true)
          puts project.to_s #3984
        end
      end
    end
  end
end