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
    #filter_version = params[:filter_version] || '4'
    filter_version = @filter_version.blank? ? params[:filter_version] : @filter_version
    filter_version = filter_version.blank? ? '4' : filter_version

    if sort_column.blank? || sort_order.blank?
      sort_column = session[:sort_column]
      sort_order = session[:sort_order]
    end

    search_column = session[:search_column]
    search_order = session[:search_order]

    case column.name
      when :start_date
        column_sort_order = "asc"
        if column.name.to_s != sort_column  #params[:f]
          sort_order = "desc"
        end
      when :title
        column_sort_order = "asc" #"desc"
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

    ###if(column.name.to_s == params[:f]) || (column.name.to_s == sort_column) || (column.name.to_s == "start_date" && params[:f].blank? && params[:sort_column].blank?)
    if(column.name.to_s == params[:f]) || (column.name.to_s == sort_column) || (column.name.to_s == "start_date" && sort_column.blank?)
      column_chevron_icon = ""
      case sort_order
        when "desc"
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini icon-chevron-down chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "asc"), class: '', remote: true)
          # lk = content_tag(:span, I18n.t(column.caption))

          lk = link_to(raw("#{I18n.t(column.caption)}"), sort_path(f: column.name, s: "asc", filter_version: filter_version), remote: true, class: "estimancy")

        when "asc"
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini icon-chevron-up chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "desc"), class: '', remote: true)
          # lk = content_tag(:span, I18n.t(column.caption))

          lk = link_to(raw("#{I18n.t(column.caption)}"), sort_path(f: column.name, s: "desc", filter_version: filter_version), remote: true, class: "estimancy")

        else
          # lk_text = content_tag(:span, I18n.t(column.caption))
          # lk_text << content_tag(:i, nil, class: 'btn btn-mini fa fa-chevron-up chevron_up_down')
          # lk = link_to(lk_text, sort_path(f: column.name, s: "desc"), remote: true)
          # lk = content_tag(:span, I18n.t(column.caption))

          lk = link_to(raw("#{I18n.t(column.caption)}"), sort_path(f: column.name, s: "desc", filter_version: filter_version), remote: true, class: "estimancy")

      end

    else
      #lk = link_to(I18n.t(column.caption), sort_path(f: column.name, s: column_sort_order), remote: true)

      lk = link_to(raw("#{I18n.t(column.caption)}"), sort_path(f: column.name, s: column_sort_order, filter_version: filter_version), remote: true, class: "estimancy")
    end


    case column.name
      when :title
        content_tag("th class='text-left'", lk)
      when :description
        content_tag("th class='text-left'", I18n.t(column.caption))
      when :version_number
        content_tag("th class='text-left'", lk)
      when :status_name
        content_tag("th class='text-center'", lk)
      else
        if column.field_id
          content_tag("th class='text-left'", column.caption)
        else
          content_tag("th class='text-left'", lk)
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

  def column_content_without_content_tag(pfs, column, project, fields_coefficients)
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
      column_value_without_content_tag(column, project, value)
    end
  end

  def column_value_without_content_tag(column, project, value)
    case column.name
      when :application
        if value.blank?
          project.application_name
        else
          if project.application.nil?
            nil
          else
            project.application.name
          end
        end
      when :title
        value
      when :original_model
        value
      when :version_number
        value
      when :request_number
        if project.demand_id.nil?
          value
        else
          project.demand
        end
      when :business_need
        value
      when :status_name
        project.status_name
      when :description
        value
      when :private
        # mettre un truncate sinon ca plante sous ie8

        value ? I18n.t(:private) : I18n.t(:unprivate)
      when :start_date, :created_at, :updated_at
        if value.nil?
          value
        else
          I18n.l(value)
        end
      else
        if column.field_id
          if value == "-" or is_number?(value)
            if is_number?(value)
              convert_with_precision(value, user_number_precision)
            else
              value
            end
          else
            value
          end
        else
          value
        end
    end
  end

  def column_value(column, project, value)
    case column.name
      when :urgent_project
        content_tag("td class='text-left'", project.urgent_project)
      when :application
        if value.blank?
          content_tag("td class='text-left'", project.application_name)
        else
          if project.application.nil?
            content_tag("td class='text-left'", '')
          else
            content_tag("td class='text-left'", project.application.name)
          end
        end
      when :title
        content_tag('td', can_show_estimation?(project) ?
                              link_to(value, dashboard_path(project), :class => 'estimancy') : value)
      when :original_model
        begin
          if project.original_model
            content_tag('td', can_show_estimation?(project.original_model) ? link_to(value, dashboard_path(project.original_model), :class => 'button_attribute_tooltip pull-left') : value)
          else
            content_tag("td class='text-left'", value)
          end
        rescue
          content_tag("td class='text-left'", '-')
        end
      when :version_number
        content_tag("td class='center'", value)
      when :request_number
        if project.demand_id.nil?
          content_tag("td", value)
        else
          demand = project.demand
          organization = project.organization
          unless demand.nil?
            content_tag("td", link_to(demand, edit_organization_demand_path(organization, demand)))
          else
            content_tag("td", "-")
          end
        end
      when :business_need
        content_tag("td", value)
      when :status_name
        if can_show_estimation?(project) || project.private == false || current_user.super_admin == true || can?(:manage, project)
          content_tag("td class='text-left'") do
            content_tag('button', project.status_name, onclick: "location.href='#{main_app.add_comment_on_status_change_url(:project_id => project.id)}'", :remote => true, class: "btn btn-status", style: "background-color: #{project.status_background_color}").to_s.html_safe
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


  def show_trigger_object_changes(column_name, column_value)
    #jsonArray = JSON.parse(column_value)
    case column_name
      when "organization_ids", "Organization"
        Organization.where(id: column_value).map(&:name)
      when "group_ids", "Group"
        Group.where(id: column_value).map(&:name)
      when "User"
        User.where(id: column_value)
      when "Permission"
        Permission.where(id: column_value)
      when "ProjectSecurityLevel"
        ProjectSecurityLevel.where(id: column_value)
      when "Project"
        Project.where(id: column_value)
      when "ProjectSecurity"
        ProjectSecurity.where(id: column_value)
      else
        []
    end
  end


end
