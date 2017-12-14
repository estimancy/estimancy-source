#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2015 Estimancy (http://www.estimancy.com)
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

module OrganizationsHelper

  def update_selected_inline_columns(query)
    selected_columns = []
    # Get the organization Custom fields for QueryColumn
    query.available_inline_columns = query.available_inline_columns.reject{ |column| !column.field_id.nil? }

    @current_organization.fields.each do |custom_field|
      custom_fields_query_columns = query.available_inline_columns.reject{ |column| column.field_id.nil? }
      unless custom_fields_query_columns.map(&:field_id).include?(custom_field.id)
        query.available_inline_columns << QueryColumn.new(custom_field.name.to_sym, :sortable => "#{Field.table_name}.name", :caption => "#{custom_field.name}", :field_id => custom_field.id, organization_id: @current_organization.id)
      end
    end

    #selected_columns = query.available_inline_columns.select{ |column| column.name.to_s.in?(@current_organization.project_selected_columns)}
    @current_organization.project_selected_columns.each do |column_name|
      selected_columns << query.available_inline_columns.select{ |column| column.name.to_s == column_name}
    end
    selected_columns.flatten
  end

  def query_available_inline_columns_options(query)

    selected_inline_columns = update_selected_inline_columns(query)
    #(query.available_inline_columns - selected_inline_columns).collect {|column| [I18n.t(column.caption), column.name]}
    (query.available_inline_columns - selected_inline_columns).collect do |column|
      if column.field_id
        [column.caption, column.name]
      else
        [I18n.t(column.caption), column.name]
      end
    end
  end

  def query_selected_inline_columns_options(query)
    selected_inline_columns = update_selected_inline_columns(query)
    #selected_inline_columns.collect {|column| [ I18n.t(column.caption), column.name]}
    selected_inline_columns.collect do |column|
      if column.field_id
        [ column.caption, column.name]
      else
        [ I18n.t(column.caption), column.name]
      end
    end
  end

  def column_header(column)

    # lk = link_to(I18n.t(column.caption), sort_path(f: column.name, s: (params[:s] == "desc" ? "asc" : "desc")), remote: true)

    column_chevron_icon = ""
    column_sort_order = ""

    sort_column = params[:f] || params[:sort_column]
    sort_order = params[:s] || params[:sort_order]

    # if sort_column.blank? || sort_order.blank?
    #   sort_column = session[:sort_column]
    #   sort_order = session[:sort_order]
    # end

    search_column = session[:search_column]
    search_order = session[:search_order]

    case column.name
      when :start_date
        column_sort_order = "asc"
        if column.name.to_s != sort_column  #params[:f]
          sort_order = "desc"
        end
      when :title
        column_sort_order = "desc"
      when :description
        column_sort_order = "asc"
      when :version_number
        column_sort_order = "asc"
      when :status_name
        column_sort_order = "asc"
      when :creator
        column_sort_order = "asc"
      else
        if column.field_id
        else
          column_sort_order = "asc"
        end
    end

    if(column.name.to_s == params[:f]) || (column.name.to_s == sort_column) || (column.name.to_s == "start_date" && params[:f].blank? && params[:sort_column].blank?)
    ###if(column.name.to_s == params[:f]) || (column.name.to_s == sort_column) || (column.name.to_s == "start_date" && sort_column.blank?)
      column_chevron_icon = ""
      case sort_order
        when "desc"
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini icon-chevron-down chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "asc"), class: '', remote: true)

          lk = content_tag(:span, I18n.t(column.caption))
          lk << link_to("", sort_path(f: column.name, s: "asc"), class: 'btn btn-mini fa fa-sort-down fa-lg chevron_up_down', remote: true)

        when "asc"
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini icon-chevron-up chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "desc"), class: '', remote: true)

          lk = content_tag(:span, I18n.t(column.caption))
          lk << link_to("", sort_path(f: column.name, s: "desc"), class: 'btn btn-mini fa fa-sort-up fa-lg chevron_up_down', remote: true)

        else
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini fa fa-chevron-up chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "desc"), remote: true)

          lk = content_tag(:span, I18n.t(column.caption))
          lk << link_to("", sort_path(f: column.name, s: "desc"), class: 'btn btn-mini fa fa-sort-up fa-lg chevron_up_down', remote: true)

      end

    else
      #lk = link_to(I18n.t(column.caption), sort_path(f: column.name, s: column_sort_order), remote: true)

      lk = content_tag(:span, I18n.t(column.caption))
      lk << link_to("", sort_path(f: column.name, s: column_sort_order), class: 'btn btn-mini fa fa-unsorted fa-lg chevron_up_down', remote: true)
    end


    case column.name
      when :title
        content_tag('th class="center"', lk)
      when :description
        content_tag('th class="center"', I18n.t(column.caption))
      when :version_number
        content_tag('th class="center"', lk)
      when :status_name
        content_tag('th id="toto" style="width: 50px"', lk)
      else
        if column.field_id
          content_tag('th class="project_field_text_overflow"', column.caption)
        else
          content_tag('th', lk)
        end
    end
  end

  def column_content(pfs, column, project, fields_coefficients)
    if column.field_id
      value = column.project_field_value(pfs, project, fields_coefficients)
    else
      value = column.value_object(project)
    end

    if value.is_a?(Array)
      val = value.collect {|v| column_value(column, project, v)}.compact.join(', ')
      if val.nil?
        ''
      else
        val.to_s.html_safe
      end
    else
      column_value(column, project, value)
    end
  end

  def column_value(column, project, value)
    case column.name
      when :application
        if value.blank?
          content_tag('td', project.application_name)
        else
          if project.application.nil?
            content_tag('td', '')
          else
            content_tag('td', project.application.name)
          end
        end
      when :title
        content_tag('td', can_show_estimation?(project) ? link_to(value, dashboard_path(project), :class => 'button_attribute_tooltip pull-left') : value)
      when :original_model
        begin
          if project.original_model
            content_tag('td', can_show_estimation?(project.original_model) ? link_to(value, dashboard_path(project.original_model), :class => 'button_attribute_tooltip pull-left') : value)
          else
            content_tag('td', value)
          end
        rescue
          content_tag('td', '-')
        end
      when :version_number, :request_number
        content_tag("td class='center'", value)
      when :status_name
        if can_show_estimation?(project) || project.private == false || current_user.super_admin == true || can?(:manage, project)
            content_tag("td class='center'") do
            content_tag(:span, link_to(project.status_name, main_app.add_comment_on_status_change_path(:project_id => project.id), style: "color: #FFFFFF;", :title => "#{I18n.t(:label_add_status_change_comment)}" , :remote => true),
                        class: "badge", style: "background-color: #{project.status_background_color}").to_s.html_safe
          end
        else
          content_tag("td class='center'") do
            content_tag(:span, project.status_name, class: "badge", style: "background-color: #{project.status_background_color}").to_s.html_safe
          end
        end
      when :description
        v = ActionView::Base.full_sanitizer.sanitize(value).to_s.html_safe
        content_tag('td', :class => "text_field_text_overflow") do
          content_tag('span', v.to_s.html_safe, title: v)
        end
      when :private
        # mettre un truncate sinon ca plante sous ie8

        content_tag('td', value ? I18n.t(:private) : I18n.t(:unprivate))
      when :start_date, :created_at, :updated_at
        if value.nil?
          content_tag('td', value, class: "center")
        else
          content_tag('td', I18n.l(value), class: "center")
        end
      else
        if column.field_id
          content_tag("td") do
            if value == "-" or is_number?(value)
              if is_number?(value)
                content_tag(:span, convert_with_precision(value, user_number_precision), class: "pull-right").to_s.html_safe
              else
                content_tag(:span, value, class: "pull-right").to_s.html_safe
              end
            else
              value
            end
          end
        else
          content_tag("td") do
            content_tag(:span, value, class: "pull-left").to_s.html_safe
          end
        end
    end
  end

  def is_number? string
    true if Float(string) rescue false
  end

end
