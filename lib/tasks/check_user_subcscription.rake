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

namespace :estimancy do
  desc 'Load default data'
  task :check_subscription => :environment do
    User.all.take(3).each do |user|
      date_end = user.subscription_end_date.to_s
      day_prev_end = (Date.parse(user.subscription_end_date.to_s) - Date.parse(Time.now.to_s)).to_i
      if day_prev_end == 90 || day_prev_end == 30 || day_prev_end == 10 || day_prev_end == 3
        UserMailer.regular_end_sub_date_checker(user.email,user.subscription_end_date.to_s,day_prev_end, user.name).deliver
      elsif day_prev_end <= 0
        UserMailer.subscription_end(user.email,user.name).deliver
      end
    end
  end
end