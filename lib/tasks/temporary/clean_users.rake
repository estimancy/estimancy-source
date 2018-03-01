## rake users:clean_users RAILS_ENV=production

namespace :users do
  desc "Suppression des comptes utilisateurs"
  task clean_users: :environment do

    User.all.each do |user|
      begin
        unless (user.super_admin == true) or (user.login_name == "owner")
          user.destroy
        end
      rescue
        #nothing
      end
    end
  end
end


