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

module PemodulesHelper

  def display_attribute_rule(attr, module_attr=nil)
    unless attr.nil?
      title = String.new
      title << "#{I18n.t(:tooltip_attribute_rules)} : <strong>#{attr.options.join(' ')} </strong> <br> "
      unless module_attr.nil?
        title << "#{I18n.t(:mandatory)} : #{I18n.t(module_attr.is_mandatory)}"
      end
      title
    end
  end
end