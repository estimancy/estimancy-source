# Novembre 2021
## rake projects:devis_par_cds RAILS_ENV=production

namespace :projects do
  desc "devis_par_cds"
  task devis_par_cds: :environment do

    from = (Time.now-90.days).beginning_of_day
    to   = Time.zone.now

    Organization.all.each do |organization|
      puts "#{organization.name}"
      begin
        #count = Project.where(organization_id: organization.id, is_model: [false, nil]).where('created_at > ?', Time.now-90.days)
        puts Project.where(organization_id: organization.id, is_model: [false, nil]).group('date(created_at)').where(created_at: from .. to).count
        puts "\n \n"
      rescue
        #nothing
      end
    end

  end
end


