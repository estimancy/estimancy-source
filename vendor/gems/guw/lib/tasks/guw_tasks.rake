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

# desc "Explaining what the task does"
# task :guw do
#   # Task goes here
# end

# find all models and group them on keys which should be common

######## A executer en console sur R7 et prod ########
# grouped = Guw::GuwCoefficientElementUnitOfWork.all.group_by{|model| [model.guw_unit_of_work_id, model.guw_coefficient_element_id, model.guw_coefficient_id] }
# grouped.values.each do |duplicates|
#   # the first one we want to keep right?
#   first_one = duplicates.pop # or pop for last one
#   # if there are any more left, they are duplicates
#   # so delete all of them
#   duplicates.each{|double| double.destroy} # duplicates can now be destroyed
# end
# ################################################################
#
#
# ######## A executer en console sur R7 et prod ########
# grouped = Guw::GuwOutputType.all.group_by{|model| [model.guw_model_id, model.guw_output_id, model.guw_type_id] }
# grouped.values.each do |duplicates|
#   # the first one we want to keep right?
#   first_one = duplicates.pop # or pop for last one
#   # if there are any more left, they are duplicates
#   # so delete all of them
#   duplicates.each{|double| double.destroy} # duplicates can now be destroyed
# end
################################################################


