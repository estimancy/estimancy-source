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

  desc 'Clean View Widget'

  task :clean_view_widget => :environment do

    Project.all.each do |project|
      if project.is_model == true
        pf = ProjectField.where(project_id: project.id,
                                value: nil).first

        unless pf.nil?
          if pf.view_widget.nil?
            pf.delete
          end
        end

      else

        ProjectField.where(project_id: project.id,
                           value: nil).all.each{ |i| i.delete }

      end
    end

  end
end