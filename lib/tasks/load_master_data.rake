# # encoding: UTF-8
# #############################################################################
# #
# # Estimancy, Open Source project estimation web application
# # Copyright (c) 2014 Estimancy (http://www.estimancy.com)
# #
# #    This program is free software: you can redistribute it and/or modify
# #    it under the terms of the GNU Affero General Public License as
# #    published by the Free Software Foundation, either version 3 of the
# #    License, or (at your option) any later version.
# #
# #    This program is distributed in the hope that it will be useful,
# #    but WITHOUT ANY WARRANTY; without even the implied warranty of
# #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# #    GNU Affero General Public License for more details.
# #
# #    You should have received a copy of the GNU Affero General Public License
# #    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# #
# #############################################################################
#
# namespace :projestimate do
#   desc 'Load default data from remote repository'
#   task :load_master_data => :environment do
#
#     print "\n You're about to install the default data on #{Rails.env} database. Do you want : \n
#        1- Delete ALL DATA, then Re-install default data -- Press 1 \n
#        2- Do nothing and quit the prompt -- Press 3 or Ctrl + C \n
#     \n"
#
#     if (defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")) && Rails.env=='production'
#       print "You can't load yourself, as you already are on MasterData instance. \n"
#       print "Nothing to do. Bye. \n"
#       print "\n"
#
#     else
#
#       i = true
#       while i do
#         STDOUT.flush
#         response = STDIN.gets.chomp!
#
#         if response == '1'
#           print "\n-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-\n"
#           print "\n-!-!-!- CAUTION -- You are on the way to DELETE ALL DATA, you will not be able to go back -!-!-!-\n"
#           print "\n-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-\n\n"
#
#           are_you_sure? do
#             puts "Deleting all data...\n"
#             tables = []
#             ActiveRecord::Base.connection.execute('show tables').each { |r| tables << r[0] }
#             tables = tables - ['schema_migrations']
#             tables.each do |table|
#               ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
#             end
#
#             #Deleting all association tables data
#             #association_tables = ["acquisition_categories_project_areas", "activity_categories_project_areas", "groups_permissions", "groups_projects", "groups_users", "labor_categories_project_areas", "links_estimation_values", "organizations_users", "permissions_project_security_levels", "permissions_users", "platform_categories_project_areas", "project_areas_project_categories", "project_areas_work_element_types" ]
#
#             puts 'Loading Master Data'
#             Home::load_master_data!
#           end
#           i = false
#         elsif response == '2'
#           puts 'Nothing to do. Bye.'
#           i = false
#         end
#       end
#
#     end
#   end
# end
#
#
# def are_you_sure?(&block)
#   j = true
#   while j do
#     puts 'Are you sure do you continue (Y or N) ? : '
#     STDOUT.flush
#     res = STDIN.gets.chomp!
#     if res == 'Y' or res == 'y'
#       block.call
#       j = false
#     elsif res == 'N' or res == 'n'
#       puts 'Nothing to do. Bye.'
#       j = false
#     else
#       puts 'Incorrect answer'
#       j = true
#     end
#   end
# end