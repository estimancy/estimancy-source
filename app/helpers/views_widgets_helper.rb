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

module ViewsWidgetsHelper


  def get_kpi_value(view_widget)
    eq = view_widget.equation
    ev = view_widget.estimation_value
    formula = eq["formula"].to_s
    component = current_component
    user_number_precision = current_user.number_precision.nil? ? 2 : current_user.number_precision

    unless eq["A"].blank?
      a_value = get_ev_value(eq["A"].first, component.id, view_widget.id)
      formula = formula.gsub("A", a_value)
    end

    unless eq["B"].blank?
      b_value = get_ev_value(eq["B"].first, component.id, view_widget.id)
      formula = formula.gsub("B", b_value)
    end

    unless eq["C"].blank?
      c_value = get_ev_value(eq["C"].first, component.id, view_widget.id)
      formula = formula.gsub("C", c_value)
    end

    unless eq["D"].blank?
      d_value = get_ev_value(eq["D"].first, component.id, view_widget.id)
      formula = formula.gsub("D", d_value)
    end

    unless eq["E"].blank?
      e_value = get_ev_value(eq["E"].first, component.id, view_widget.id)
      formula = formula.gsub("E", e_value)
    end

    begin
      if correct_syntax?(formula)
        result_value = eval(formula).round(user_number_precision)
        if result_value.is_a?(Float) && result_value.nan?
          '-'
        else
          "#{ActionController::Base.helpers.number_with_precision(result_value.to_f, separator: ',', delimiter: ' ', precision: user_number_precision, locale: (current_user.language.locale rescue "fr"))} #{view_widget.kpi_unit.to_s}"
        end
      else
        '-'
      end
    rescue
      '-'
    end
  end

  def get_kpi_value_without_unit(view_widget, component = nil)
    eq = view_widget.equation
    ev = view_widget.estimation_value
    formula = eq["formula"].to_s

    if component.nil?
      component = current_component
    end

    unless eq["A"].blank?
      a_value = get_ev_value(eq["A"].first, component.id, view_widget.id)
      formula = formula.gsub("A", a_value)
    end

    unless eq["B"].blank?
      b_value = get_ev_value(eq["B"].first, component.id, view_widget.id)
      formula = formula.gsub("B", b_value)
    end

    unless eq["C"].blank?
      c_value = get_ev_value(eq["C"].first, component.id, view_widget.id)
      formula = formula.gsub("C", c_value)
    end

    unless eq["D"].blank?
      d_value = get_ev_value(eq["D"].first, component.id, view_widget.id)
      formula = formula.gsub("D", d_value)
    end

    unless eq["E"].blank?
      e_value = get_ev_value(eq["E"].first, component.id, view_widget.id)
      formula = formula.gsub("E", e_value)
    end

    begin
      if correct_syntax?(formula)
        result_value = eval(formula) #.round(current_user.number_precision)
        if result_value.is_a?(Float) && result_value.nan?
          '-'
        else
          #"#{ActionController::Base.helpers.number_with_precision(result_value.to_f, separator: ',', delimiter: ' ', precision: current_user.number_precision.nil? ? 2 : current_user.number_precision, locale: (current_user.language.locale rescue "fr"))}"
          result_value.to_f
        end
      else
        '-'
      end
    rescue
      '-'
    end
  end

  def get_ev_value(ev_id, current_component_id, view_widget_id=nil)

    unless view_widget_id.nil?
      view_widget = ViewsWidget.find(view_widget_id)
    end

    unless ev_id.to_i == 0
      current_ev = EstimationValue.find(ev_id.to_i)

      unless current_ev.nil?
        if !current_ev.estimation_value_id.nil?
          ev = EstimationValue.find(current_ev.estimation_value_id)
        else
          ev = current_ev
        end

        ###val = ev.string_data_probable[current_component_id]
        begin
          if ev.module_project.pemodule.alias == "effort_breakdown"
            wbs_activity = ev.module_project.wbs_activity
            val = ev.send("string_data_probable")[current_component_id][wbs_activity.root_element.id][:value].to_f
          else
            val = ev.send("string_data_probable")[current_component_id].to_f
          end
        rescue
          val = 0
        end

        if val.is_a?(Hash)
          val = compute_value(val, ev, ev.module_project_id, view_widget.use_organization_effort_unit)
          val.to_s
        else
          val.to_s
        end
      else
        nil
      end
    end
  end


  # Get the Attribute Alias/name to display
  def get_attribute_human_name(pe_attribute)
    case pe_attribute.alias
      when "effort", "cost"
        I18n.t("retained_#{pe_attribute.alias}")
      when "theoretical_effort", "theoretical_cost"
        I18n.t("#{pe_attribute.alias}")
      when "E1", "E2", "E3", "E4"
        "#{pe_attribute.alias}"
      else
        ""
    end
  end


  # def get_ev_value_SAVE(ev_id, current_component_id)
  #   unless ev_id.to_i == 0
  #     ev = EstimationValue.find(ev_id.to_i)
  #     val = ev.string_data_probable[current_component_id]
  #     unless ev.nil?
  #       if ev.is_a?(Hash)
  #         compute_value(val, ev, current_component_id)
  #         val.to_s
  #       else
  #         val.to_s
  #       end
  #     else
  #       nil
  #     end
  #   end
  # end

  private def correct_syntax? code
    stderr = $stderr
    $stderr.reopen(IO::NULL)
    RubyVM::InstructionSequence.compile(code)
    true
  rescue Exception
    false
  ensure
    $stderr.reopen(stderr)
  end

  # Final founction : A voir si c'est utile ou pas ... in progress
  private def compute_value(value, est_val, mp_id, use_organization_effort_unit=false)
    module_project = ModuleProject.find(mp_id)
    est_val_pe_attribute = est_val.pe_attribute
    precision = est_val_pe_attribute.precision.nil? ? user_number_precision : est_val_pe_attribute.precision

    if est_val_pe_attribute.alias == "retained_size" || est_val_pe_attribute.alias == "theorical_size"
      if module_project.pemodule.alias == "ge"
        ge_model = module_project.ge_model
        effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
        #size_unit = ge_model.output_size_unit
        if est_val.in_out == "input"
          effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
          #size_unit = ge_model.input_size_unit
        end
        "#{convert_with_standard_unit_coefficient(est_val, value.to_f, effort_standard_unit_coefficient, precision)}"

      elsif module_project.pemodule.alias == "skb"
        skb_model = module_project.skb_model
        #size_unit = skb_model.size_unit
        "#{value.to_f}"
      else
        "#{convert_with_precision(value.to_f, precision, true)} #{module_project.size}"
      end

    elsif est_val_pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS)  ### ("effort", "theoretical_effort", ...)
      if module_project.pemodule.alias == "ge"
        ge_model = module_project.ge_model
        effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
        #effort_unit = ge_model.output_effort_unit

        if est_val.in_out == "input"
          effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
          #effort_unit = ge_model.input_effort_unit
        end

        "#{convert_with_standard_unit_coefficient(est_val, value, effort_standard_unit_coefficient, precision)}"

      elsif module_project.pemodule.alias == "effort_breakdown"
        wbs_activity = module_project.wbs_activity
        if wbs_activity
          effort_unit_coefficient = wbs_activity.effort_unit_coefficient

          # By default use module instance effort unit
          if use_organization_effort_unit == true
            # Use orgnization effort unit
            organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(value, @project.organization)
            "#{convert_with_precision(convert_effort_with_organization_unit(value, organization_effort_limit_coeff, organization_effort_unit), precision, true)}"
          else
            # Use orgnization effort unit
            "#{convert_with_precision(convert_wbs_activity_value(value, effort_unit_coefficient), precision, true)}"
          end
        else
          "#{convert_with_precision(convert(value, @project.organization), precision, true)}"
        end
      elsif module_project.pemodule.alias == "staffing"
        staffing_model = module_project.staffing_model
        effort_standard_unit_coefficient = staffing_model.standard_unit_coefficient.nil? ? 1 : staffing_model.standard_unit_coefficient.to_f
        effort_unit = staffing_model.effort_unit
        if use_organization_effort_unit == true
          organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(value, @project.organization)
          "#{convert_with_precision(convert_effort_with_organization_unit(value, organization_effort_limit_coeff, organization_effort_unit), precision, true)}"
        else
          "#{convert_with_standard_unit_coefficient(est_val, value, effort_standard_unit_coefficient, precision)}"
        end

      else
        "#{convert_with_precision(convert(value, @project.organization), precision, true)}"
      end

    elsif est_val_pe_attribute.alias == "ratio"
      "#{value.to_f.round(user_number_precision)}"
    elsif est_val_pe_attribute.alias == "staffing" || est_val_pe_attribute.alias == "duration"
      "#{convert_with_precision(value, precision, true)}"
      #elsif est_val_pe_attribute.alias == "cost"
    elsif est_val_pe_attribute.alias.in?(["cost", "theoretical_cost"])
      unless value.class == Hash
        "#{convert_with_precision(value, precision, true)}"
      end
    elsif est_val_pe_attribute.alias == "remaining_defects" || est_val_pe_attribute.alias == "introduced_defects"
      unless value.class == Hash
        "#{convert_with_precision(value, precision, true)}"
      end
    elsif est_val_pe_attribute.alias.in?(Ge::GeModel::GE_ATTRIBUTES_ALIAS)
      ge_model = module_project.ge_model
      "#{convert_ge_model_value_with_precision(ge_model, est_val, value, precision)}"
    else
      case est_val_pe_attribute
        when 'date'
          display_date(value)
        when 'float'
          "#{ convert_with_precision(convert(value, @project.organization), precision, true) }"
        when 'integer'
          "#{convert(value, @project.organization).round(precision)}"
        else
          # guw_model = module_project.guw_model
          # conv = guw_model.hour_coefficient_conversion
          #
          # begin
          #   "#{value.to_f.round(user_number_precision) / (conv.nil? ? 1 : conv.to_f)} #{guw_model.effort_unit}"
          # rescue
          #   if module_project.pemodule.alias == "guw"
          #     "#{value.to_f / conv} #{guw_model.effort_unit}"
          #   else
          #     value.to_f
          #   end
          # end

          value.to_f
      end
    end
  end


  #Work In Progress avant correction KPI
  # private def compute_value_SAVE(value, est_val, mp_id)
  #   module_project = ModuleProject.find(mp_id)
  #   est_val_pe_attribute = est_val.pe_attribute
  #   precision = est_val_pe_attribute.precision.nil? ? user_number_precision : est_val_pe_attribute.precision
  #
  #   if est_val_pe_attribute.alias == "retained_size" || est_val_pe_attribute.alias == "theorical_size"
  #     if module_project.pemodule.alias == "ge"
  #       ge_model = module_project.ge_model
  #       effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
  #       size_unit = ge_model.output_size_unit
  #       if est_val.in_out == "input"
  #         effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
  #         size_unit = ge_model.input_size_unit
  #       end
  #
  #       "#{convert_with_standard_unit_coefficient(est_val, value.to_f, effort_standard_unit_coefficient, precision)}"
  #     else
  #       "#{convert_with_precision(value.to_f, precision, true)}"
  #     end
  #
  #   elsif est_val_pe_attribute.alias.in?("effort", "theoretical_effort")
  #     if module_project.pemodule.alias == "ge"
  #       ge_model = module_project.ge_model
  #       effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
  #       effort_unit = ge_model.output_effort_unit
  #
  #       if est_val.in_out == "input"
  #         effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
  #         effort_unit = ge_model.input_effort_unit
  #       end
  #
  #       "#{convert_with_standard_unit_coefficient(est_val, value, effort_standard_unit_coefficient, precision)}"
  #     else
  #       "#{convert_with_precision(convert(value, @project.organization), precision, true)}"
  #     end
  #
  #   elsif est_val_pe_attribute.alias == "staffing" || est_val_pe_attribute.alias == "duration"
  #     "#{convert_with_precision(value, precision, true)}"
  #   elsif est_val_pe_attribute.alias.in?("cost", "theoretical_cost")
  #     unless value.class == Hash
  #       "#{convert_with_precision(value, 2, true)} #{get_attribute_unit(est_val_pe_attribute)}"
  #     end
  #   elsif est_val_pe_attribute.alias == "remaining_defects" || est_val_pe_attribute.alias == "introduced_defects"
  #     unless value.class == Hash
  #       "#{convert_with_precision(value, 2, true)}"
  #     end
  #   else
  #     case est_val_pe_attribute
  #       when 'date'
  #         display_date(value)
  #       when 'float'
  #         "#{ convert_with_precision(convert(value, @project.organization), precision, true) }"
  #       when 'integer'
  #         "#{convert(value, @project.organization).round(precision)}"
  #       else
  #         value
  #     end
  #   end
  # end

  def get_kpi_widget_data(view_widget_id)
    view_widget = ViewsWidget.find(view_widget_id)
    widget_data = {}
    initial_width = 60; initial_height = 60
    value_to_show = nil
    ft_maxFontSize_without_mm = 50
    icon_font_size = 1.6

    height = (initial_height*view_widget.height.to_i) + 5*(view_widget.height.to_i - 1)   #margin is now 5 unless of 10
    width = (initial_width*view_widget.width.to_i) + 5*(view_widget.width.to_i - 1)

    widget_data[:width] = width
    widget_data[:height] = height

    case view_widget.height.to_i
      when 1..2
        icon_font_size = 1.7 ###2
        if view_widget.height.to_i == 3
          icon_font_size = 2.5 ###3
        end
        ft_maxFontSize_without_mm = 20 #10###20
        if view_widget.width.to_i <= 1
          ft_minMax_minFontSize = 4 #3###3.5
        else
          ft_minMax_minFontSize = 5###6.5
        end
      when 3
        icon_font_size = 2 #2.5
        ft_maxFontSize_without_mm = 20 #10###20
      else
        icon_font_size = ((height+width)/2) * 0.025
        if icon_font_size > 3 && icon_font_size < 6
          icon_font_size = 3
        elsif icon_font_size > 6
          icon_font_size = 4
        end
    end

    text_size = ((height+width)/2) * 0.011  #0.006  # 0.015
    # get the fitText minFontSize and maxFontSize
    widget_data[:icon_font_size] = icon_font_size
    widget_data[:text_size] = text_size
    widget_data[:ft_maxFontSize_without_mm] = ft_maxFontSize_without_mm

    begin
      #Regexp a utiliser mais j'y arrive pas [ABCDEF\d{*+\/}]
      widget_data[:value_to_show] = get_kpi_value(view_widget)
    rescue
      widget_data[:value_to_show] = "-"
    end

    widget_data
  end

  # Get the label widget data
  def get_label_widget_data(view_widget_id)
    view_widget = ViewsWidget.find(view_widget_id)
    widget_data = {}
    initial_width = 60;  initial_height = 60
    value_to_show = nil # according to the widget type
    ############################ Get the view_widget size  ############################
    ft_maxFontSize_without_mm = 50 #75
    icon_font_size = 1.7 ###2

    # The widget size with : margin-right = 10px
    height = (initial_height*view_widget.height.to_i) + 5*(view_widget.height.to_i - 1)   #margin is now 5 unless of 10
    width = (initial_width*view_widget.width.to_i) + 5*(view_widget.width.to_i - 1)
    # update size in the results hash
    widget_data[:width] = width
    widget_data[:height] = height

    case view_widget.height.to_i
      when 1..2
        icon_font_size = 1.2 ###2
        if view_widget.height.to_i == 3
          icon_font_size = 2.6 ###3
        end
        ft_maxFontSize_without_mm = 10###20
        if view_widget.width.to_i <= 1
          ft_minMax_minFontSize = 3###3.5
        else
          ft_minMax_minFontSize = 5###6.5
        end
      when 3
        icon_font_size = 2.5
        ft_maxFontSize_without_mm = 10###20
      else
        icon_font_size = ((height+width)/2) * 0.025
        if icon_font_size > 3 && icon_font_size < 6
          icon_font_size = 3
        elsif icon_font_size > 6
          icon_font_size = 4
        end
    end
    text_size = ((height+width)/2) * 0.006  # 0.015
    # get the fitText minFontSize and maxFontSize
    widget_data[:icon_font_size] = icon_font_size
    widget_data[:text_size] = text_size
    widget_data[:ft_maxFontSize_without_mm] = ft_maxFontSize_without_mm
    widget_data[:value_to_show] = simple_format(view_widget.comment.to_s.html_safe) ###view_widget.name

    widget_data
  end


  # Get the view_widget data for each view/widget/module_project
  def get_view_widget_data(module_project_id, view_widget_id)

    # General data
    view_widget = ViewsWidget.find(view_widget_id)
    pbs_project_elt = view_widget.pbs_project_element.nil? ? current_component : view_widget.pbs_project_element
    # pbs_project_elt = current_component
    module_project = ModuleProject.find(module_project_id)
    project = module_project.project
    pemodule = module_project.pemodule

    widget_data = {}
    data_probable = ""; min_value = ""; max_value = ""; value_to_show = ""
    initial_width = 60;  initial_height = 60
    value_to_show = nil # according to the widget type
    data_low = nil; data_most_likely=nil; data_high=nil; data_probable=nil
    widget_data = { data_low: data_low, data_high: data_high, data_most_likely: data_most_likely, data_probable: data_probable }

    ############################ Get the view_widget size  ############################

    if view_widget.estimation_value.pe_attribute.nil?
      value_to_show = {}
      return value_to_show
    end

    # Si on affiche une vignette du nom du Ratio
    if view_widget.estimation_value.pe_attribute.alias == "ratio_name"
      ft_maxFontSize_without_mm = 50 #75
      icon_font_size = 1.7 ###2

      # The widget size with : margin-right = 10px
      height = (initial_height*view_widget.height.to_i) + 5*(view_widget.height.to_i - 1)   #margin is now 5 unless of 10
      width = (initial_width*view_widget.width.to_i) + 5*(view_widget.width.to_i - 1)
      # update size in the results hash
      widget_data[:width] = width
      widget_data[:height] = height

      case view_widget.height.to_i
        when 1..2
          icon_font_size = 1.2 ###2
          if view_widget.height.to_i == 3
            icon_font_size = 2.6 ###3
          end
          ft_maxFontSize_without_mm = 10###20
          if view_widget.width.to_i <= 1
            ft_minMax_minFontSize = 3###3.5
          else
            ft_minMax_minFontSize = 5###6.5
          end
        when 3
          icon_font_size = 2.5
          ft_maxFontSize_without_mm = 10###20
        else
          icon_font_size = ((height+width)/2) * 0.025
          if icon_font_size > 3 && icon_font_size < 6
            icon_font_size = 3
          elsif icon_font_size > 6
            icon_font_size = 4
          end
      end
      text_size = ((height+width)/2) * 0.006  # 0.015

    else

      ############################ Get the view_widget size  ############################
      ft_maxFontSize_without_mm = 50###75
      ft_maxFontSize_with_mm = 45###60
      ft_minMax_maxFontSize = 15###20
      icon_font_size = 1.6###2

      # The widget size with : margin-right = 10px
      height = (initial_height*view_widget.height.to_i) + 5*(view_widget.height.to_i - 1)   #margin is now 5 unless of 10
      width = (initial_width*view_widget.width.to_i) + 5*(view_widget.width.to_i - 1)
      # update size in the results hash
      widget_data[:width] = width
      widget_data[:height] = height

      case view_widget.height.to_i
        when 1..2
          icon_font_size = 1.7###2
          if view_widget.height.to_i == 3
            icon_font_size = 2.5###3
          end
          ft_maxFontSize_without_mm = 20###30
          ft_maxFontSize_with_mm = 15###30
          ft_minMax_minFontSize = 5###6
          ft_minMax_maxFontSize = 10###12

          if view_widget.width.to_i <= 1
            ft_minMax_minFontSize = 4###4.5
          else
            ft_minMax_minFontSize = 5###7.5
          end
        when 3
          icon_font_size = 2###2.5 #3
          ft_maxFontSize_without_mm = 20###30
          ft_maxFontSize_with_mm = 15###30
          ft_minMax_maxFontSize = 10###12
        else
          icon_font_size = ((height+width)/2) * 0.025
          if icon_font_size > 3 && icon_font_size < 6
            icon_font_size = 3 #4
          elsif icon_font_size > 6
            icon_font_size = 4 #5
          end
      end
      text_size = ((height+width)/2) * 0.011  #((height+width)/2) * 0.015
    end


    min_max_size = ((height+width)/2) * 0.005   #((height+width)/2) * 0.009

    # get the fitText minFontSize and maxFontSize
    widget_data[:icon_font_size] = icon_font_size
    widget_data[:text_size] = text_size
    widget_data[:min_max_size] = min_max_size
    # fitText parameters
    widget_data[:ft_maxFontSize_without_mm] = ft_maxFontSize_without_mm
    widget_data[:ft_maxFontSize_with_mm] = ft_maxFontSize_with_mm
    widget_data[:ft_minMax_minFontSize] = ft_minMax_minFontSize
    widget_data[:ft_minMax_maxFontSize] = ft_minMax_maxFontSize

    ############################ Get the view_widget estimation value  ############################

    view_widget_est_val = view_widget.estimation_value
    user_precision = user_number_precision
    effort_unit_coefficient = 1

    unless view_widget_est_val.nil?
      est_val_in_out = view_widget_est_val.in_out
      view_widget_attribute = view_widget_est_val.pe_attribute #view_widget.pe_attribute
      view_widget_attribute_name = view_widget_attribute.nil? ? "" : get_attribute_human_name(view_widget_attribute) #view_widget_attribute.name

      unless view_widget_attribute.nil?
        estimation_value = module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', view_widget_attribute.id, view_widget_est_val.in_out).last
      end

      attribute_unit_label = get_attribute_unit(view_widget_attribute, view_widget_est_val)

      unless estimation_value.nil?
        data_low = estimation_value.string_data_low[pbs_project_elt.id]
        data_high = estimation_value.string_data_high[pbs_project_elt.id]
        data_most_likely = estimation_value.string_data_most_likely[pbs_project_elt.id]
        data_probable = estimation_value.string_data_probable[pbs_project_elt.id]

        min_value_text = nil
        max_value_text = nil
        probable_value_text = nil

        # Get the project wbs_project_element root if module with activities
        if estimation_value.module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          wbs_activity = module_project.wbs_activity

          # root element
          wbs_activity_elt_root = wbs_activity.wbs_activity_elements.first.root
          return if wbs_activity_elt_root.nil?

          wbs_activity_elt_root_id = wbs_activity_elt_root.id

          # get the wbs_activity_selected ratio
          #ratio_reference = module_project.get_wbs_activity_ratio(pbs_project_elt.id) #module_project.wbs_activity_ratio #@wbs_activity_ratio
          ratio_reference = module_project.wbs_activity_ratio #@wbs_activity_ratio
          if ratio_reference.nil?
            ratio_reference = module_project.get_wbs_activity_ratio(pbs_project_elt.id)
          end

          text_data_probable = data_probable

          if estimation_value.in_out == "output"
            unless estimation_value.pe_attribute.alias == "ratio" || estimation_value.pe_attribute.alias == "ratio_name"

              wbs_data_low = data_low.nil? ? nil : data_low
              wbs_data_most_likely = data_most_likely.nil? ? nil : data_most_likely
              wbs_data_high = data_high.nil? ? nil : data_high
              wbs_data_probable = data_probable.nil? ? nil : data_probable

              data_low = wbs_data_low.nil? ? nil : wbs_data_low
              data_high = wbs_data_high.nil? ? nil : wbs_data_high

              if wbs_data_probable.nil?
                wbs_activity_elt_root_data_probable = nil
              else
                begin
                  wbs_activity_elt_root_data_probable = wbs_data_probable[wbs_activity_elt_root.id]
                rescue
                  wbs_activity_elt_root_data_probable = nil
                end
              end

              if wbs_activity_elt_root_data_probable.nil? || wbs_activity_elt_root_data_probable.empty?
                text_data_probable = nil
              else
                text_data_probable = (wbs_data_probable.nil? || wbs_data_probable.empty?) ? nil : wbs_activity_elt_root_data_probable[:value]
              end
            end
          end

          if data_probable.nil?
            probable_value_text = "-" #display_value(data_probable.to_f, estimation_value, module_project_id)
          else
            if is_number?(text_data_probable)
              probable_value_text = display_value(text_data_probable.to_f, estimation_value, module_project_id, view_widget.use_organization_effort_unit)
            else
              probable_value_text = text_data_probable
            end
          end

          if is_number?(data_high) && is_number?(data_low)
            max_value_text = "Max. #{data_high.nil? ? '-' : display_value(data_high, estimation_value, module_project_id)}" #max_value_text = "Max: #{data_high.nil? ? '-' : data_high.round(user_number_precision)}"
            min_value_text = "Min. #{data_low.nil? ? '-' : display_value(data_low, estimation_value, module_project_id)}"   #min_value_text = "Min: #{data_low.nil? ? '-' : data_low.round(user_number_precision)}"
          else
            begin
              if data_high.is_a?(Hash) || data_low.is_a(Hash)
                max_value_text = "Max. #{data_high.nil? ? '-' : display_value(data_high[wbs_activity_elt_root_id], estimation_value, module_project_id)}"
                min_value_text = "Min. #{data_low.nil? ? '-' : display_value(data_low[wbs_activity_elt_root_id], estimation_value, module_project_id)}"
              else
                max_value_text = "Max: #{data_high.nil? ? '-' : data_high.round(user_precision)}"
                min_value_text = "Min: #{data_low.nil? ? '-' : data_low.round(user_precision)}"
              end
            rescue
              max_value_text = "Max: #{data_high.nil? ? '-' : data_high}"
              min_value_text = "Min: #{data_low.nil? ? '-' : data_low}"
            end
          end
        elsif estimation_value.module_project.pemodule.alias == "guw"

          probable_value_text = Guw::GuwModel.display_value(data_probable, estimation_value, view_widget, current_user)

          max_value_text = "Max. #{data_high.nil? ? '-' :  Guw::GuwModel.display_value(data_high, estimation_value, view_widget, current_user)}"
          min_value_text = "Min. #{data_low.nil? ? '-' :  Guw::GuwModel.display_value(data_low, estimation_value, view_widget, current_user)}"

        elsif estimation_value.module_project.pemodule.alias == "operation"
          probable_value_text = Operation::OperationModel.display_value(data_probable, estimation_value, view_widget, current_user)

          max_value_text = "Max. #{data_high.nil? ? '-' :  Operation::OperationModel.display_value(data_high, estimation_value, view_widget, current_user)}"
          min_value_text = "Min. #{data_low.nil? ? '-' :  Operation::OperationModel.display_value(data_low, estimation_value, view_widget, current_user)}"

        elsif  estimation_value.module_project.pemodule.alias == "ge" && estimation_value.pe_attribute.alias.in?(Ge::GeModel::GE_ATTRIBUTES_ALIAS)
          ge_model = module_project.ge_model
          probable_value_text = Ge::GeModel.display_value(data_probable, estimation_value, view_widget, current_user)

          max_value_text = "Max. #{data_high.nil? ? '-' : Ge::GeModel.display_value(data_high, estimation_value, view_widget, current_user)}"
          min_value_text = "Min. #{data_low.nil? ? '-' : Ge::GeModel.display_value(data_low, estimation_value, view_widget, current_user)}"

        elsif  estimation_value.module_project.pemodule.alias == "kb"
          probable_value_text = Kb::KbModel.display_value(data_probable, estimation_value, view_widget, current_user)

          max_value_text = "Max. #{data_high.nil? ? '-' : Kb::KbModel.display_value(data_high, estimation_value, view_widget, current_user)}"
          min_value_text = "Min. #{data_low.nil? ? '-' : Kb::KbModel.display_value(data_low, estimation_value, view_widget, current_user)}"

        elsif  estimation_value.module_project.pemodule.alias == "skb"
          probable_value_text = Skb::SkbModel.display_value(data_probable, estimation_value, view_widget, current_user)

          max_value_text = "Max. #{data_high.nil? ? '-' : Skb::SkbModel.display_value(data_high, estimation_value, view_widget, current_user)}"
          min_value_text = "Min. #{data_low.nil? ? '-' : Skb::SkbModel.display_value(data_low, estimation_value, view_widget, current_user)}"

        else
          if data_probable.nil?
            probable_value_text = "-" #display_value(data_probable.to_f, estimation_value, module_project_id)
          else
            if is_number?(data_probable)
              probable_value_text = display_value(data_probable.to_f, estimation_value, module_project_id, view_widget.use_organization_effort_unit)
            else
              probable_value_text = data_probable
            end
          end

          max_value_text = "Max. #{data_high.nil? ? '-' : display_value(data_high, estimation_value, module_project_id)}" #max_value_text = "Max: #{data_high.nil? ? '-' : data_high.round(user_number_precision)}"
          min_value_text = "Min. #{data_low.nil? ? '-' : display_value(data_low, estimation_value, module_project_id)}"   #min_value_text = "Min: #{data_low.nil? ? '-' : data_low.round(user_number_precision)}"
        end

        #Update the widget data
        #widget_data = { data_low: data_low, data_high: data_high, data_most_likely: data_most_likely, data_probable: data_probable, max_value_text: max_value_text, min_value_text: min_value_text, probable_value_text: probable_value_text }
        widget_data[:data_low] = data_low
        widget_data[:data_high] = data_high
        widget_data[:data_most_likely] = data_most_likely
        widget_data[:data_probable] = data_probable
        widget_data[:max_value_text] = max_value_text
        widget_data[:min_value_text] = min_value_text
        widget_data[:probable_value_text] = probable_value_text

        #WIDGETS_TYPE = [["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ]
        #According to the widget type, we will show simple text, charts, timeline, etc


        #get  rounded values before use
        if estimation_value.module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN

          if wbs_activity
            effort_unit_coefficient = wbs_activity.effort_unit_coefficient.nil? ? 1 : wbs_activity.effort_unit_coefficient

            unless ratio_reference.nil?
              module_project_ratio_elements = estimation_value.module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id)

              if view_widget.use_organization_effort_unit == true
                 min_effort_value = get_min_effort_value_from_mp_ratio_elements(module_project_ratio_elements, estimation_value.pe_attribute.alias)
                 organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(min_effort_value, @project.organization)

                 effort_unit_coefficient = organization_effort_limit_coeff
                 attribute_unit_label = organization_effort_unit
              end
            end
          end


          data_low = data_low.is_a?(Hash) ? data_low.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) } : data_low
          data_most_likely = data_most_likely.is_a?(Hash) ? data_most_likely.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) } : data_most_likely
          data_high = data_high.is_a?(Hash) ? data_high.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) } : data_high

          #data_probable = data_probable.is_a?(Hash) ? (data_probable.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) }.first) : data_probable
          if data_probable.is_a?(Hash)
            data_probable = data_probable.map{|key,value| (value.nil? || value.empty?) ? 0 : (value[:value].nil? ? 0 : value[:value].round(user_precision)) }
          else
            data_probable = data_probable
          end
        else
          data_low = data_low.is_a?(Hash) ? data_low.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) }.first : data_low
          data_most_likely = data_most_likely.is_a?(Hash) ? data_most_likely.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) }.first : data_most_likely
          data_high = data_high.is_a?(Hash) ? data_high.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) }.first : data_high
          data_probable = data_probable.is_a?(Hash) ? (data_probable.map{|key,value| value.nil? ? value.to_f : value.round(user_precision) }.first) : data_probable
        end

        chart_level_values = []
        chart_level_values << [I18n.t(:value_low), data_low]
        chart_level_values << [I18n.t(:value_most_likely), data_most_likely]
        chart_level_values << [I18n.t(:value_high), data_high]
        chart_level_values << [I18n.t(:value_probable), data_probable]

        widget_data[:chart_level_values] = chart_level_values
        chart_height = height-50
        chart_width = width -40
        chart_title = view_widget.name
        attribute_unit = get_attribute_unit(view_widget_attribute)

        ### Organization effort unit coefficient
        # Get min value and organization effort unit coeff
        if estimation_value.pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS)
          if view_widget.use_organization_effort_unit == true
            min_value = data_low #get_min_effort_value_from_mp_ratio_elements(module_project_ratio_elements, estimation_value.pe_attribute.alias)
            organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(min_value, @project.organization)

            attribute_unit = organization_effort_unit
          end
        end

        chart_vAxis = "#{view_widget_attribute_name} (#{attribute_unit})"
        chart_hAxis = "Level"

        case view_widget.widget_type
          when "text"
            value_to_show = probable_value_text
            is_simple_text = true

          when "line_chart"
            #value_to_show = line_chart(chart_level_values, height: "#{chart_height}px", library: {backgroundColor: view_widget.color})
            value_to_show =  line_chart([ {name: I18n.t(:low), data: {Time.new => data_low} },  #10
                                          {name: I18n.t(:most_likely), data: {Time.new => data_most_likely} }, #30
                                          {name: I18n.t(:high), data: {Time.new => data_high} } ],  #50
                                          {height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title, hAxis: {title: "Level", format: 'MMM y'}, vAxis: {title: chart_vAxis}}})
          when "bar_chart"
            #value_to_show = column_chart(chart_level_values, height: "1000px", library: {backgroundColor: "transparent", title: chart_title, vAxis: {title: chart_vAxis}})

            # new data
            bar_chart_level_values = Array.new

            if view_widget.show_min_max == true
              bar_chart_level_values << [I18n.t(:value_low), wbs_data_low.nil? ? 0 : wbs_data_low[wbs_activity_elt_root_id]]
              bar_chart_level_values << [I18n.t(:value_most_likely), wbs_data_most_likely.nil? ? 0 : wbs_data_most_likely[wbs_activity_elt_root_id]]
              bar_chart_level_values << [I18n.t(:value_high), wbs_data_high.nil? ? 0 : wbs_data_high[wbs_activity_elt_root_id]]
            else
              chart_probable = wbs_data_probable.nil? ? 0 : wbs_data_probable[wbs_activity_elt_root_id]

              begin
                bar_chart_level_values << [I18n.t(:value_probable), chart_probable.nil? ? 0 : chart_probable[:value]]
              rescue
                bar_chart_level_values << [I18n.t(:value_probable), chart_probable]
              end
            end

            # bar_chart_level_values << [I18n.t(:value_low), 0]
            # bar_chart_level_values << [I18n.t(:value_most_likely), 0]
            # bar_chart_level_values << [I18n.t(:value_high), 0]
            # bar_chart_level_values << [I18n.t(:value_probable), 0]

            # Divise par le coeff
            bar_chart_level_values
            # TEST

            # # récuperer l'unité de l'effort de l'organisation
            if view_widget.use_organization_effort_unit == true
              # Use orgnization effort unit
              organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(data_most_likely, @project.organization)
              #"#{convert_with_precision(convert_effort_with_organization_unit(value, organization_effort_limit_coeff, organization_effort_unit), user_precision, true)} #{organization_effort_unit}"
              bar_chart_level_values.each_with_index do |array, index|
                bar_chart_level_values[index][1] = (array[1] / organization_effort_limit_coeff).round(user_precision)
              end
            else
              # Use orgnization effort unit
              #"#{convert_with_precision(convert_wbs_activity_value(value, effort_unit_coefficient), user_precision, true)} #{wbs_activity.effort_unit}"
              bar_chart_level_values.each_with_index do |array, index|
                bar_chart_level_values[index][1] = (array[1] / effort_unit_coefficient).round(user_precision)
              end

            end

            # TEST

            widget_data[:max_value_text] = ""
            widget_data[:min_value_text] = ""

            # Now with google-chart
            value_to_show = raw(render :partial => 'views_widgets/g_column_chart',
                                       :locals => { level_values: bar_chart_level_values,  #chart_level_values,
                                                    estimation_value: estimation_value,
                                                    widget_id: view_widget.id,
                                                    chart_title: chart_title,
                                                    chart_height: chart_height,
                                                    chart_vAxis_title: chart_vAxis
                                       })

          when "area_chart"
            value_to_show =  line_chart([ {name: I18n.t(:low), data: {Time.new => data_low} },  #10
                                          {name: I18n.t(:most_likely), data: {Time.new => data_most_likely} }, #30
                                          {name: I18n.t(:high), data: {Time.new => data_high} } ],  #50
                                          {height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title, hAxis: {title: "Level", format: 'MMM y'}, vAxis: {title: chart_vAxis}}})

          when "pie_chart"
            #value_to_show = pie_chart(chart_level_values, height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title})

            # Now with google-chart
            value_to_show = raw(render :partial => 'views_widgets/g_pie_chart',
                                       :locals => { level_values: chart_level_values,
                                                    widget_id: view_widget.id,
                                                    chart_title: chart_vAxis, #chart_title,
                                                    chart_height: chart_height
                                       })

          when "stacked_bar_chart"
            value_to_show = probable_value_text

          when "timeline"
            timeline_data = []

            #delay = PeAttribute.where(alias: "delay").first
            delay = PeAttribute.where(alias: "duration").first
            end_date = PeAttribute.where(alias: "end_date").first
            staffing = PeAttribute.where(alias: "staffing").first
            effort = PeAttribute.where(alias: "effort").first
            is_ok = false

            # Get the component/PBS children
            products = pbs_project_elt.root.subtree.all

            products.each_with_index do |element, i|
              dev = nil
              est_val = module_project.estimation_values.where(pe_attribute_id: delay.id).last
              unless est_val.nil?
                str_data_probable = est_val.string_data_probable
                str_data_probable.nil? ? nil : (dev = str_data_probable[element.id])
              end

              if !dev.nil?

                d = dev.to_f

                if d.nil?
                  dh = 1.hours
                else
                  dh = d.hours
                end

                end_date_ev = module_project.estimation_values.where(pe_attribute_id: end_date.id).last
                unless end_date_ev.nil?
                  ed = end_date_ev.string_data_probable[element.id]
                end

                begin
                  timeline_data << [
                      element.name,
                      element.start_date,
                      element.start_date + dh
                  ]
                  is_ok = true
                rescue
                  is_ok = false
                end
              end
            end

            if is_ok == true
              ###value_to_show = timeline(timeline_data, library: {backgroundColor: "transparent", title: view_widget_attribute_name})

              # Now with google-chart
              value_to_show = raw(render :partial => 'views_widgets/g_timeline_chart',
                                         :locals => { level_values: timeline_data,
                                                      widget_id: view_widget.id,
                                                      chart_title: view_widget_attribute_name,
                                                      chart_height: chart_height
                                         })
            else
              value_to_show = "" #I18n.t(:error_invalid_date)
            end

          when "table_effort_per_phase", "table_cost_per_phase", "table_effort_per_phase_without_zero", "table_cost_per_phase_without_zero",
               "table_effort_and_cost_per_phase", "table_effort_and_cost_per_phase_without_zero"

            unless estimation_value.in_out == "input"
              wbs_activity = module_project.wbs_activity
              wai = WbsActivityInput.where(wbs_activity_id: wbs_activity, wbs_activity_ratio_id: ratio_reference.id, module_project_id: module_project.id, pbs_project_element_id: pbs_project_elt.id).first

              if ratio_reference.nil?
                module_project_ratio_elements = []
              else
                module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_elt.id, selected: true)
              end

              if module_project_ratio_elements.empty? || module_project_ratio_elements.nil?
                value_to_show =  raw estimation_value.nil? ? "#{ content_tag(:div, I18n.t(:notice_no_estimation_saved), :class => 'no_estimation_value')}" : display_effort_or_cost_per_phase(pbs_project_elt, module_project, estimation_value, view_widget_id, ratio_reference)
              else
                # Avec les module_project Ratio-Elements
                value_to_show = get_chart_data_by_phase_and_profile(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
              end
            end

          when "histogram_effort_per_phase", "histogram_cost_per_phase"

            unless estimation_value.in_out == "input"
              chart_height = height+10
              chart_data = get_chart_data_effort_and_cost(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
              ###value_to_show = column_chart(chart_data, width: "1px", height: "#{chart_height}px", library: {backgroundColor: "transparent", weight: "normal", title: chart_title, vAxis: {title: chart_vAxis}})

              # Now with google-chart
              value_to_show = raw(render :partial => 'views_widgets/g_column_chart',
                                         :locals => { level_values: chart_data,
                                                      estimation_value: estimation_value,
                                                      widget_id: view_widget.id,
                                                      chart_title: chart_title,
                                                      chart_height: chart_height,
                                                      chart_vAxis_title: chart_vAxis
                                         })
            end

          when "pie_chart_effort_per_phase", "pie_chart_cost_per_phase"
            chart_height = height-90

            unless estimation_value.in_out == "input"
              chart_data = get_chart_data_effort_and_cost(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
            end
            #value_to_show = pie_chart(chart_data, height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title})

            # Now with google-chart
            g_chart_data = [] #["Phases", "Effort par phase"]
            chart_data.each do |key, value|
              g_chart_data << [key, value.to_s.gsub(',', '.').to_f]
            end

            value_to_show = raw(render :partial => 'views_widgets/g_pie_chart',
                                       #value_to_show = raw(render :partial => 'views_widgets/g_bubble_test2',
                                       :locals => { level_values: g_chart_data,
                                                    widget_id: view_widget.id,
                                                    chart_title: chart_vAxis, #"#{chart_title} : #{get_attribute_human_name(estimation_value.pe_attribute)}",
                                                    chart_height: chart_height
                                       })

          when "effort_per_phases_profiles_table", "cost_per_phases_profiles_table", "effort_per_phases_profiles_table_without_zero", "cost_per_phases_profiles_table_without_zero",
              "table_effort_and_cost_per_phases_profiles", "table_effort_and_cost_per_phases_profiles_without_zero"

            unless estimation_value.in_out == "input"
              value_to_show = get_chart_data_by_phase_and_profile(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
            end

          when "stacked_bar_chart_effort_per_phases_profiles", "stacked_bar_chart_cost_per_phases_profiles",
              "stacked_grouped_bar_chart_effort_per_phases_profiles", "stacked_grouped_bar_chart_cost_per_phases_profiles"

            unless estimation_value.in_out == "input"
              chart_height = height-90
              #stacked_chart_data = get_chart_data_by_phase_and_profile(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
              #value_to_show = column_chart(stacked_chart_data, stacked: true, height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title, vAxis: {title: chart_vAxis}})

              # Now with google chart
              wbs_activity = module_project.wbs_activity
              wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity.wbs_activity_elements.arrange(:order => :position))
              stacked_chart_data = get_chart_data_by_phase_and_profile(pbs_project_elt, module_project, estimation_value, view_widget, ratio_reference)
              ###value_to_show = column_chart(stacked_chart_data, stacked: true, height: "#{chart_height}px", library: {backgroundColor: "transparent", title: chart_title, vAxis: {title: chart_vAxis}})

              if view_widget.widget_type.in?("stacked_bar_chart_effort_per_phases_profiles", "stacked_bar_chart_cost_per_phases_profiles")
                value_to_show = raw(render :partial => 'views_widgets/g_stacked_bar_chart',
                                         :locals => { level_values: stacked_chart_data,
                                                      widget_id: view_widget.id,
                                                      widget_name: view_widget.name,
                                                      chart_title: "#{chart_title} : #{get_attribute_human_name(estimation_value.pe_attribute)}",
                                                      chart_height: chart_height,
                                                      chart_vAxis_title: chart_vAxis,
                                                      wbs_activity_elements: wbs_activity_elements
                                         })
              elsif view_widget.widget_type.in?("stacked_grouped_bar_chart_effort_per_phases_profiles", "stacked_grouped_bar_chart_cost_per_phases_profiles")
                value_to_show = raw(render :partial => 'views_widgets/g_stacked_grouped_bar_chart',
                                           :locals => { level_values: stacked_chart_data,
                                                        widget_id: view_widget.id,
                                                        widget_name: view_widget.name,
                                                        chart_title: "#{chart_title} : #{get_attribute_human_name(estimation_value.pe_attribute)}",
                                                        chart_height: chart_height,
                                                        chart_vAxis_title: chart_vAxis,
                                                        wbs_activity_elements: wbs_activity_elements
                                           })
              end

            end

          else
            value_to_show = probable_value_text
        end

        widget_data[:value_to_show] = value_to_show
      end
    end

    # Return the view_widget HASH
    widget_data
  end


  # Get Effort and Cost data by Phases and by Profiles
  def get_chart_data_by_phase_and_profile(pbs_project_element, module_project, estimation_value, view_widget, ratio_reference)
    result = String.new
    stacked_data = Array.new
    profiles_wbs_data = Hash.new
    probable_est_value = estimation_value.send("string_data_probable")

    pbs_probable_est_value = probable_est_value[pbs_project_element.id]

    ###return result if probable_est_value.nil? || pbs_probable_est_value.nil?

    wbs_activity = module_project.wbs_activity
    return nil if wbs_activity.nil?

    if ratio_reference.nil?
      ratio_reference = module_project.get_wbs_activity_ratio(pbs_project_element.id)
    end
    return nil if ratio_reference.nil?

    wai = WbsActivityInput.where(wbs_activity_id: wbs_activity, wbs_activity_ratio_id: ratio_reference.id, module_project_id: module_project.id, pbs_project_element_id: pbs_project_element.id).first_or_create

    if estimation_value.pe_attribute.alias.in?(["cost", "theoretical_cost"])
      wbs_unit = get_attribute_unit(estimation_value.pe_attribute)
    else
      wbs_unit = wbs_activity.effort_unit
    end
    effort_unit_coefficient = wbs_activity.effort_unit_coefficient || 1

    project_organization = module_project.project.organization
    ###wbs_activity_elements = wbs_activity.wbs_activity_elements
    wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity.wbs_activity_elements.arrange(:order => :position))
    wbs_activity_element_root = wbs_activity_elements.first.root

    # We don't want to show element with nil ratio value
    project_organization_profiles = []
    ratio_profiles_with_nil_ratio = []
    wbs_activity_ratio_profiles = []
    unless ratio_reference.nil?
      ratio_reference.wbs_activity_ratio_elements.each do |ratio_elt|
        ratio_profiles_with_nil_ratio << ratio_elt.wbs_activity_ratio_profiles
      end
      # Reject all RatioProfile with nil ratio_value
      wbs_activity_ratio_profiles = ratio_profiles_with_nil_ratio.flatten.reject{|i| i.ratio_value.nil? }
    end
    wbs_activity_ratio_profiles.each do |ratio_profile|
      project_organization_profiles << ratio_profile.organization_profile
    end
    project_organization_profiles = project_organization_profiles.uniq

    pe_attribute_alias = estimation_value.pe_attribute.alias
    if pe_attribute_alias.in?(["cost", "effort"])
      #pe_attribute_alias = "theoretical_#{pe_attribute_alias}"
      pe_attribute_alias = "retained_#{pe_attribute_alias}"
    end

    if ratio_reference.nil?
      module_project_ratio_elements = []
    else

      if module_project.module_project_ratio_elements.all.empty?
        module_project.get_module_project_ratio_elements(ratio_reference, pbs_project_element)
      end

      module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, selected: true)

      if view_widget.widget_type.in?(["table_effort_per_phase_without_zero", "table_cost_per_phase_without_zero",
                                      "effort_per_phases_profiles_table_without_zero", "cost_per_phases_profiles_table_without_zero",
                                      "table_effort_and_cost_per_phase_without_zero", "table_effort_and_cost_per_phases_profiles_without_zero"
                                     ])
        # module_project_ratio_elements = module_project_ratio_elements.where(
        #     "retained_effort_probable IS NOT NULL && retained_effort_most_likely IS NOT NULL OR
        #      retained_cost_probable IS NOT NULL && retained_cost_most_likely IS NOT NULL AND
        #      retained_effort_probable <> ? AND retained_effort_most_likely <> ? OR
        #      retained_cost_probable <> ? AND retained_cost_most_likely <> ?", 0, 0, 0, 0)

        module_project_ratio_elements = module_project_ratio_elements.where(
            "((retained_effort_probable IS NOT NULL && retained_effort_most_likely IS NOT NULL) OR
             (retained_cost_probable IS NOT NULL && retained_cost_most_likely IS NOT NULL))
             AND
             ((retained_effort_probable <> ? AND retained_effort_most_likely <> ?) OR
             (retained_cost_probable <> ? AND retained_cost_most_likely <> ?))", 0, 0, 0, 0)
      end
    end

    # Get min value and organization effort unit coeff
    if estimation_value.pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS)###("effort", "theoretical_effort")
      if view_widget.use_organization_effort_unit == true
        min_value = get_min_effort_value_from_mp_ratio_elements(module_project_ratio_elements, estimation_value.pe_attribute.alias)
        organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(min_value, @project.organization)

        wbs_unit = organization_effort_unit
      end
    end

    case view_widget.widget_type

      when "table_effort_per_phase", "table_cost_per_phase", "table_effort_per_phase_without_zero", "table_cost_per_phase_without_zero"

        result = raw(render :partial => 'views_widgets/effort_by_phases_with_mp_ratio_elements',
                            :locals => { project_wbs_activity_elements: wbs_activity_elements,
                                            estimation_value: estimation_value,
                                            pe_attribute: estimation_value.pe_attribute,
                                            module_project: module_project,
                                            project_organization_profiles: project_organization_profiles,
                                            estimation_pbs_probable_results: pbs_probable_est_value,
                                            ratio_reference: ratio_reference,
                                            pe_attribute_alias: pe_attribute_alias,
                                            wbs_unit: wbs_unit,
                                            module_project_ratio_elements: module_project_ratio_elements,
                                            wbs_activity_element_root: wbs_activity_element_root,
                                            view_widget_type: view_widget.widget_type,
                                            view_widget_id: view_widget.id
                                       } )


      when "effort_per_phases_profiles_table", "effort_per_phases_profiles_table_without_zero"
        if ratio_reference.nil?
          added_module_project_ratio_elements = []
        else
          added_module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, wbs_activity_ratio_element_id: nil).all
        end

        result = raw(render :partial => 'views_widgets/effort_by_phases_profiles',
                                        :locals => { project_wbs_activity_elements: wbs_activity_elements,
                                                      estimation_value: estimation_value,
                                                      pe_attribute: estimation_value.pe_attribute,
                                                      module_project: module_project,
                                                      project_organization_profiles: project_organization_profiles,
                                                      estimation_pbs_probable_results: pbs_probable_est_value,
                                                      ratio_reference: ratio_reference,
                                                      added_module_project_ratio_elements: added_module_project_ratio_elements,
                                                      pe_attribute_alias: pe_attribute_alias,
                                                      wbs_unit: wbs_unit,
                                                      module_project_ratio_elements: module_project_ratio_elements,
                                                      wbs_activity_element_root: wbs_activity_element_root,
                                                      view_widget_type: view_widget.widget_type,
                                                      view_widget_id: view_widget.id
                                       } )

      when "cost_per_phases_profiles_table", "cost_per_phases_profiles_table_without_zero"
        if ratio_reference.nil?
          added_module_project_ratio_elements = []
        else
          added_module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, wbs_activity_ratio_element_id: nil).all
        end
        result = raw(render :partial => 'views_widgets/cost_by_phases_profiles',
                                        :locals => { project_wbs_activity_elements: wbs_activity_elements,
                                                    estimation_value: estimation_value,
                                                    pe_attribute: estimation_value.pe_attribute,
                                                    module_project: module_project,
                                                    project_organization_profiles: project_organization_profiles,
                                                    estimation_pbs_probable_results: pbs_probable_est_value,
                                                    ratio_reference: ratio_reference,
                                                    added_module_project_ratio_elements: added_module_project_ratio_elements,
                                                    pe_attribute_alias: pe_attribute_alias,
                                                    wbs_unit: wbs_unit,
                                                    module_project_ratio_elements: module_project_ratio_elements,
                                                    wbs_activity_element_root: wbs_activity_element_root,
                                                    view_widget_type: view_widget.widget_type,
                                                    view_widget_id: view_widget.id
                                        } )


      when "table_effort_and_cost_per_phase", "table_effort_and_cost_per_phase_without_zero"

        result = raw(render :partial => 'views_widgets/effort_and_cost_by_phases_with_mp_ratio_elements',
                            :locals => { project_wbs_activity_elements: wbs_activity_elements,
                                         estimation_value: estimation_value,
                                         pe_attribute: estimation_value.pe_attribute,
                                         module_project: module_project,
                                         project_organization_profiles: project_organization_profiles,
                                         estimation_pbs_probable_results: pbs_probable_est_value,
                                         ratio_reference: ratio_reference,
                                         pe_attribute_alias: pe_attribute_alias,
                                         wbs_unit: wbs_unit,
                                         module_project_ratio_elements: module_project_ratio_elements,
                                         wbs_activity_element_root: wbs_activity_element_root,
                                         view_widget_type: view_widget.widget_type,
                                         view_widget_id: view_widget.id

                            } )

      when "table_effort_and_cost_per_phases_profiles", "table_effort_and_cost_per_phases_profiles_without_zero"

        if ratio_reference.nil?
          added_module_project_ratio_elements = []
        else
          added_module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, wbs_activity_ratio_element_id: nil).all
        end
        result = raw(render :partial => 'views_widgets/effort_and_cost_by_phases_profiles',
                            :locals => { project_wbs_activity_elements: wbs_activity_elements,
                                         estimation_value: estimation_value,
                                         pe_attribute: estimation_value.pe_attribute,
                                         module_project: module_project,
                                         pbs_project_element_id: pbs_project_element.id,
                                         project_organization_profiles: project_organization_profiles,
                                         estimation_pbs_probable_results: pbs_probable_est_value,
                                         ratio_reference: ratio_reference,
                                         added_module_project_ratio_elements: added_module_project_ratio_elements,
                                         pe_attribute_alias: pe_attribute_alias,
                                         wbs_unit: wbs_unit,
                                         module_project_ratio_elements: module_project_ratio_elements,
                                         wbs_activity_element_root: wbs_activity_element_root,
                                         view_widget_type: view_widget.widget_type,
                                         view_widget_id: view_widget.id
                            } )


      when "stacked_bar_chart_effort_per_phases_profiles", "stacked_bar_chart_cost_per_phases_profiles",
           "stacked_grouped_bar_chart_effort_per_phases_profiles", "stacked_grouped_bar_chart_cost_per_phases_profiles"

        wbs_activity_elements_root = wbs_activity_elements.first.root
        root_profiles_wbs_data = Hash.new
        ###colors = ViewsWidget::WIDGETS_COLORS #['#e5e4e2', '#C5A5CF', '#b87333', 'silver', 'gold', '#76A7FA', '#703593', '#871B47', '#C5A5CF', '#BC5679']
        stacked_chart_data = Array.new
        # entête des données
        header_data = ['Phases']

        if project_organization_profiles.length > 0
          project_organization_profiles.each do |profile|
            header_data << profile.name
            #Create individual hash for the profile data
            root_profiles_wbs_data["profile_id_#{profile.id}"] = 0
          end

          header_data << { role: 'style' } #{ role: 'annotation' }
          stacked_chart_data << header_data

          #Update chart data
          wbs_activity_elements.each do |wbs_activity_elt|
            mp_ratio_element = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elt.id).first

            if !wbs_activity_elt.is_root?
              activity_profiles = Array.new
              activity_profiles << mp_ratio_element.name_to_show #wbs_activity_elt.name
              root_wbs_profiles_value = 0

              wbs_probable_value = pbs_probable_est_value[wbs_activity_elt.id]
              unless wbs_probable_value.nil?
                wbs_estimation_profiles_values = wbs_probable_value["profiles"]
                project_organization_profiles.each do |profile|
                  wbs_profiles_value = nil
                  if wbs_estimation_profiles_values.nil? || wbs_estimation_profiles_values.empty? || wbs_estimation_profiles_values["profile_id_#{profile.id}"].nil?
                    wbs_profiles_value = nil
                  else
                    if wbs_estimation_profiles_values["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"].nil?
                      wbs_profiles_value = nil
                    else
                      wbs_profiles_value = wbs_estimation_profiles_values["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"][:value]
                    end
                  end
                  #if !wbs_activity_elt.is_root?
                    if wbs_profiles_value.nil?
                      wbs_profiles_value = 0
                    else

                      ###value = wbs_profiles_value.round(user_number_precision)

                      ### TEST
                      if estimation_value.pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS)###("effort", "theoretical_effort")
                        if view_widget.use_organization_effort_unit == true
                          # use the organization effort unit
                          value = convert_with_precision(convert_effort_with_organization_unit(wbs_profiles_value, organization_effort_limit_coeff, organization_effort_unit), user_number_precision, true)
                        else
                          # use module instance effort unit
                          value = convert_with_precision(convert_wbs_activity_value(wbs_profiles_value, effort_unit_coefficient), user_number_precision, true)
                        end
                      else
                        value = convert_with_precision(wbs_profiles_value.to_f, user_number_precision, true)
                      end
                      ### FIN TEST

                      wbs_profiles_value = value.to_s.gsub(',', '.').to_f
                    end
                  #end

                  activity_profiles << wbs_profiles_value

                  # update root value
                  if wbs_activity_elt.parent_id == wbs_activity_elements_root.id
                    root_wbs_profiles_value = root_profiles_wbs_data["profile_id_#{profile.id}"]
                    root_wbs_profiles_value += wbs_profiles_value
                    root_profiles_wbs_data["profile_id_#{profile.id}"] = root_wbs_profiles_value
                  end
                end
              end

              activity_profiles << '' #colors[i]
              stacked_chart_data << activity_profiles
            end
          end

          # For the root element
          mp_ratio_element_root = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elements_root.id).first
          root_value_per_profile = [mp_ratio_element_root.name_to_show] #[wbs_activity_elements_root.name]

          project_organization_profiles.each do |profile|
            root_value_per_profile << root_profiles_wbs_data["profile_id_#{profile.id}"]
          end
          root_value_per_profile << ''
          stacked_chart_data.insert(1, root_value_per_profile)
        end

        stacked_chart_data

      #when "stacked_bar_chart_cost_per_phases_profiles"

      else
        # type code here
    end
    ###result
  end


  # Get Stacked bar chart data (for Effort and Cost per phase profiles)
  # A supprimer après test
  def get_stacked_bar_chart_data_effort_and_cost_per_phase_profile(pbs_project_element, module_project, estimation_value, view_widget)
    effort_breakdown_stacked_bar_dataset = {}

    wbs_activity = module_project.wbs_activity
    wbs_activity_root = wbs_activity.wbs_activity_elements.first.root
    effort_unit_coefficient = wbs_activity.effort_unit_coefficient

    view_widget.show_min_max ? (levels = ['low', 'most_likely', 'high', 'probable']) : (levels = ['probable'])

    #  # get all project's wbs-project_elements
    wbs_activity_elements = wbs_activity.wbs_activity_elements
    module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, selected: true)

    wbs_activity_elements.each do |wbs_activity_elt|
      mp_ratio_element = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elt.id).first
      begin
        effort_breakdown_stacked_bar_dataset["#{mp_ratio_element.name_to_show.parameterize.underscore}"] = Array.new
      rescue
        effort_breakdown_stacked_bar_dataset["#{wbs_activity_elt.name.parameterize.underscore}"] = Array.new
      end

    end


    if project_organization_profiles.length > 0
      project_organization_profiles.each do |profile|
        #Create individual hash for the profile data
        profiles_wbs_data["profile_id_#{profile.id}"] = Hash.new
      end

      #Update chart data
      wbs_activity_elements.each do |wbs_activity_elt|
        mp_ratio_element = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elt.id).first

        wbs_probable_value = pbs_probable_est_value[wbs_activity_elt.id]
        unless wbs_probable_value.nil?
          wbs_estimation_profiles_values = wbs_probable_value["profiles"]
          project_organization_profiles.each do |profile|
            wbs_profiles_value = nil
            unless wbs_estimation_profiles_values.nil? || wbs_estimation_profiles_values.empty? || wbs_estimation_profiles_values["profile_id_#{profile.id}"].nil?
              if !wbs_estimation_profiles_values["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"].nil?
                wbs_profiles_value = wbs_estimation_profiles_values["profile_id_#{profile.id}"]["ratio_id_#{ratio_reference.id}"][:value]
              end
            end
            if !wbs_activity_elt.is_root?
              if wbs_profiles_value.nil?
                begin
                  profiles_wbs_data["profile_id_#{profile.id}"]["#{mp_ratio_element.name_to_show}"] = 0
                rescue
                  profiles_wbs_data["profile_id_#{profile.id}"]["#{wbs_activity_elt.name}"] = 0
                end
              else
                value = number_with_delimiter(wbs_profiles_value.round(estimation_value.pe_attribute.precision.nil? ? user_number_precision : estimation_value.pe_attribute.precision))
                begin
                  profiles_wbs_data["profile_id_#{profile.id}"]["#{mp_ratio_element.name_to_show}"] = value
                rescue
                  profiles_wbs_data["profile_id_#{profile.id}"]["#{wbs_activity_elt.name}"] = value
                end
              end
            end
          end
        end
      end

      # Update stacked chart data
      project_organization_profiles.each do |profile|
        #Prepare the final Stacked data hash for each profile
        profile_hash = Hash.new
        profile_hash["name"] = profile.name
        profile_hash["data"] = Hash.new
        profile_hash["data"] = profiles_wbs_data["profile_id_#{profile.id}"]
        stacked_data << profile_hash
      end
    end
    stacked_data
  end

  # Get the BAR or PIE CHART data for effort per phase or Cost per phase
  def get_chart_data_effort_and_cost(pbs_project_element, module_project, estimation_value, view_widget, ratio_reference=nil)
    chart_data = []
    effort_breakdown_stacked_bar_dataset = {}

    return chart_data if (!module_project.pemodule.alias.eql?(Projestimate::Application::EFFORT_BREAKDOWN) || estimation_value.nil?)

    wbs_activity = module_project.wbs_activity
    wbs_activity_root = wbs_activity.wbs_activity_elements.first.root
    effort_unit_coefficient = wbs_activity.effort_unit_coefficient

    view_widget.show_min_max ? (levels = ['low', 'most_likely', 'high', 'probable']) : (levels = ['probable'])

    if view_widget.show_min_max
      #  # get all project's wbs-project_elements
      wbs_activity_elements = wbs_activity.wbs_activity_elements
      wbs_activity_elements.each do |wbs_activity_elt|
        mp_ratio_element = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id,
                                                                              pbs_project_element_id: pbs_project_element.id, selected: true,
                                                                              wbs_activity_element_id: wbs_activity_elt.id).first
        #effort_breakdown_stacked_bar_dataset["#{wbs_activity_elt.name.parameterize.underscore}"] = Array.new
        effort_breakdown_stacked_bar_dataset["#{mp_ratio_element.name_to_show.parameterize.underscore}"] = Array.new
      end
    else
      probable_est_value = estimation_value.send("string_data_probable")
      pbs_probable_for_consistency = probable_est_value.nil? ? nil : probable_est_value[pbs_project_element.id]

      # Get min value and organization effort unit coeff
      if ratio_reference.nil?
        module_project_ratio_elements = []
      else
        module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, selected: true)
      end

      # get phases min value
      min_value = get_min_effort_value_from_mp_ratio_elements(module_project_ratio_elements, estimation_value.pe_attribute.alias)
      organization_effort_limit_coeff, organization_effort_unit = get_organization_effort_limit_and_unit(min_value, @project.organization)

      wbs_activity.wbs_activity_elements.each do |wbs_activity_elt|
        if wbs_activity_elt.is_childless? #!= wbs_activity_root
          mp_ratio_element = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elt.id).first

          if mp_ratio_element
            activity_value = 0
            level_estimation_values = probable_est_value
            if level_estimation_values.nil? || level_estimation_values[pbs_project_element.id].nil? || level_estimation_values[pbs_project_element.id][wbs_activity_elt.id].nil? || level_estimation_values[pbs_project_element.id][wbs_activity_elt.id][:value].nil?
              activity_value = 0
            else
              wbs_value = level_estimation_values[pbs_project_element.id][wbs_activity_elt.id][:value]
              if estimation_value.pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS)###("effort", "theoretical_effort")

                if view_widget.use_organization_effort_unit == true
                  # use the organization effort unit
                  activity_value =  wbs_value.nil? ? 0 : convert_with_precision(convert_effort_with_organization_unit(wbs_value, organization_effort_limit_coeff, organization_effort_unit), user_number_precision, true)
                else
                  # use module instance effort unit
                  activity_value =  wbs_value.nil? ? 0 : convert_with_precision(convert_wbs_activity_value(wbs_value, effort_unit_coefficient), user_number_precision, true)
                end
              else
                activity_value = convert_with_precision(wbs_value.to_f, user_number_precision, true)
              end
            end

            #chart_data << ["#{wbs_activity_elt.name}", activity_value.to_s.gsub(',', '.').to_f]
            chart_data << ["#{mp_ratio_element.name_to_show}", activity_value.to_s.gsub(',', '.').to_f]
          end
        end
      end
    end
    chart_data
  end

  #The view to display result with ACTIVITIES : EFFORT PER PHASE AND COST PER PHASE TABLE
  def display_effort_or_cost_per_phase(pbs_project_element, module_project_id, estimation_value, view_widget_id, ratio_reference)
    res = String.new
    unless view_widget_id.nil?
      view_widget = ViewsWidget.find(view_widget_id)
    end

    module_project = ModuleProject.find(module_project_id)
    pemodule = module_project.pemodule

    precision = estimation_value.pe_attribute.precision.nil? ? user_number_precision : estimation_value.pe_attribute.precision

    # Only the Modules with activities
    with_activities = pemodule.yes_for_output_with_ratio? || pemodule.yes_for_output_without_ratio? || pemodule.yes_for_input_output_with_ratio? || pemodule.yes_for_input_output_without_ratio?
    return res unless with_activities

    wbs_activity = module_project.wbs_activity
    wbs_activity_elements = wbs_activity.wbs_activity_elements

    unless view_widget.nil?
      if view_widget.show_min_max
        levels = ['low', 'most_likely', 'high', 'probable']
        colspan = 4
        rowspan = 2
      else
        levels = ['probable']
        colspan = 1
        rowspan = 1
      end
    else
      levels = ['probable']
      colspan = 1
      rowspan = 1
    end

    res << "<table class='table table-condensed table-bordered table_effort_per_phase' style='margin-left: 15px;'>
              <tr><th rowspan=#{rowspan}>Phases</th>"

    # Get the module_project probable estimation values for showing element consistency
    probable_est_value_for_consistency = nil
    pbs_level_data_for_consistency = Hash.new
    probable_est_value_for_consistency = estimation_value.send("string_data_probable")

    res << "<th colspan='#{colspan}'>
              <span class='attribute_tooltip' title='#{estimation_value.pe_attribute.description} #{display_rule(estimation_value)}'>
                #{estimation_value.pe_attribute.name} #{estimation_value.pe_attribute.alias.in?("cost", "theoretical_cost") ? "(#{@project.organization.currency})" : ''}
              </span>
            </th>"

    # For is_consistent purpose
    levels.each do |level|
      unless level.eql?("probable")
        pbs_data_level = estimation_value.send("string_data_#{level}")
        pbs_data_level.nil? ? pbs_level_data_for_consistency[level] = nil : pbs_level_data_for_consistency[level] = pbs_data_level[pbs_project_element.id]
      end
    end
    res << '</tr>'

    unless view_widget.nil?
      # We are showing for each PBS and/or ACTIVITY the (low, most_likely, high) values
      if view_widget.show_min_max
        res << '<tr>'
        levels.each do |level|
          res << "<th>#{level.humanize}</th>"
        end
        res << '</tr>'
      end
    end

    current_wbs_activity_elements = module_project.wbs_activity.wbs_activity_elements.arrange(:order => :position)
    module_project_ratio_elements = module_project.module_project_ratio_elements.where(wbs_activity_ratio_id: ratio_reference.id, pbs_project_element_id: pbs_project_element.id, selected: true)
    WbsActivityElement.sort_by_ancestry(current_wbs_activity_elements).each do |wbs_activity_elt|
      mp_ratio_element = module_project_ratio_elements.where(wbs_activity_element_id: wbs_activity_elt.id).first
      if mp_ratio_element
        #For wbs-activity-completion node consistency
        completion_consistency = ""
        title = ""
        res << "<tr>
                  <td>
                    <span class='tree_element_in_out' title='#{title}' style='margin-left:#{wbs_activity_elt.depth}em;'> <strong>#{mp_ratio_element.name_to_show}</strong></span>
                  </td>"

        levels.each do |level|
          res << "<td class=''>"
          res << "<span class='pull-right'>"
            level_estimation_values = Hash.new
            level_estimation_values = estimation_value.send("string_data_#{level}")
            pbs_estimation_values = level_estimation_values[pbs_project_element.id]

            if wbs_activity_elt.is_root?
              begin
                if estimation_value.pe_attribute.alias.in?(["cost", "theoretical_cost"])
                  @wbs_unit = get_attribute_unit(estimation_value.pe_attribute)
                else
                  @wbs_unit = convert_label(pbs_estimation_values[wbs_activity_elt.id][:value], @project.organization)
                end
              rescue
                if estimation_value.pe_attribute.alias.in?(["cost", "theoretical_cost"])
                  @wbs_unit = get_attribute_unit(estimation_value.pe_attribute)
                else
                  @wbs_unit = convert_label(pbs_estimation_values[wbs_activity_elt.id], @project.organization) unless pbs_estimation_values.nil?
                end
              end
            end

            begin
              if estimation_value.pe_attribute.alias.in?(["cost", "theoretical_cost"])
                if pbs_estimation_values.nil?
                  res << "-"
                else
                  res << "#{convert_with_precision(pbs_estimation_values[wbs_activity_elt.id][:value], user_number_precision, true)} #{@wbs_unit}"
                end
              else
                res << "#{convert_with_precision(convert(pbs_estimation_values[wbs_activity_elt.id][:value], @project.organization), user_number_precision, true)} #{@wbs_unit}"
              end
            rescue
              if estimation_value.pe_attribute.alias.in?(["cost", "theoretical_cost"])
                if pbs_estimation_values.nil?
                  res << "-"
                else
                  res << "#{ convert_with_precision(pbs_estimation_values[wbs_activity_elt.id], user_number_precision, true) } #{@wbs_unit}"
                end
              else
                res << " #{ convert_with_precision(convert(pbs_estimation_values[wbs_activity_elt.id], @project.organization), user_number_precision, true) } #{@wbs_unit}" unless pbs_estimation_values.nil?
              end
            end

          res << "</span>"
          res << "</td>"
        end
        res << '</tr>'
      end
    end


    res << '</table>'
    res
  end

  def view_widget_title(view_widget)
    title = String.new
    title << "#{view_widget.name} \n"
    title << "#{I18n.t(:associate_pbs_element)} : #{current_component.to_s} \n"
    title << "Module : #{view_widget.module_project.to_s}"
    title
  end

end