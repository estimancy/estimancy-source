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

module SearchesHelper
  def display_link(res, params)
    if defined? res.title
      result= res.title
    else
      if defined? res.name
        result=res.name
      end
    end
    if defined? res.alias
      result += " ("+res.alias+")"
    end
    query_string =  params.gsub /"/, ''
    begin
      link_to(raw("#{highlight(result, query_string.split) unless params.nil?}"),
              "/#{String::keep_clean_space(res.class.to_s.underscore.pluralize)}/#{res.id}/edit", :class => "search_result", :style => "font-size:12px; color: #467aa7;")
    rescue
      '#'
    end
  end

  def display_description(res, params=nil)
    if defined?  res.description
      query_string =  params.gsub /"/, ''
      params.nil? ? res.description : highlight(res.description, query_string.split) unless res.description.nil?
    end
  end

  def display_update(res, params=nil)
    unless res.updated_at.nil?
      "#{I18n.t(:text_latest_update)} #{I18n.l(res.updated_at)}"
    end
  end
end
