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

module Guw
  class GuwUnitOfWorkAttribute < ActiveRecord::Base

    belongs_to :guw_type
    belongs_to :guw_unit_of_work
    belongs_to :guw_attribute
    belongs_to :guw_attribute_complexity

    def to_s
      self.guw_attribute.to_s
    end

    def get_level_value(level)
      begin
        level_value = self.send("#{level}")
        if level_value.nil?
          guw_type = self.guw_unit_of_work.guw_type
          gat = GuwAttributeType.where(organization_id: self.organization_id, guw_model_id: self.guw_model_id,
                                            guw_attribute_id: self.guw_attribute_id, guw_type_id: self.guw_unit_of_work.guw_type_id).first_or_create
          unless guw_type.nil?
            sum_range = self.guw_attribute.guw_attribute_complexities.where(organization_id: self.organization_id,
                                                                             guw_model_id: self.guw_model_id,
                                                                             guw_type_id: guw_type.id).map{|i| [i.bottom_range, i.top_range]}.flatten.compact

            unless sum_range.nil? || sum_range.blank? || sum_range == 0
              level_value = (gat.nil? ? nil : gat.default_value.to_i)
            end
          end
        end

        #rescue
        #level_value = self.send("#{level}")
      end
      level_value
    end

  end
end
