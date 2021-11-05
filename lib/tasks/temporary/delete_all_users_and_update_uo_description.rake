# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################
# octobre 2021
# rake users:delete_all_users_and_update_uo_description RAILS_ENV=production
namespace :users do

  desc 'delete_all_users_and_update_uo_type_description'

  task :delete_all_users_and_update_uo_description => :environment do

    #delete all users unless (admin, ebelle, sgaye)
    #User.where.not(login_name: ["admin", "ebellet", "sgaye"]).delete_all


    #update guw_type description
    Guw::GuwType.find_each do |uow_type|
      if uow_type.description.blank? || uow_type.description.to_s == "Description"
        uow_type.description = uow_type.name
        uow_type.save
      end
    end

  end
end