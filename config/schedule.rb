#encoding: utf-8
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

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# whenever --update-crontab --set environment=development

# This task is planned to delete all history data according the the "audit_history_lifetime" parameter

# The projestimate crontab name is "projestimate_cron_job"
# Updating crontab with the following command : << whenever --update-crontab projestimate_cron_job >>


# Tâche quotidienne qui recherche toutes les estimations dans un statuts d'historisation et les historise en fonction de la date d'historisation

#set :output, "log/cron.log"

# every 5.minutes do
#   #utilisation de la fonction "update_historized_estimations" se trouvant dans le modèle Organization
#   runner "Organization.update_historized_estimations"
# end

#every :day, :at => '10:30 AM' do
every 5.minutes do
  #rake "projects:update_historized_estimations"
  runner "Organization.update_historized_estimations"
end

# every 1.day, :at => '4am' do
# rake "projestimate:purge_audit_history_data"
# end
# every 1.day, :at => '5:14 pm' do
#   rake "estimancy:check_subscription", environment: "development"
# end
# Only for local test
#every 5.minutes do
#  rake "projestimate:purge_audit_history_data"
#end

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
