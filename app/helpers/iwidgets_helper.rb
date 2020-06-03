module IwidgetsHelper

  #get normal widget value
  def get_iwidget_value(iwidget, organization)
    widget_data = {}

    #begin

      series_results = Hash.new
      output_types = Hash.new

      number_values = Hash.new
      first_value = Hash.new
      last_value = Hash.new
      table_values = Hash.new
      line_chart = Hash.new
      bar_chart = Hash.new
      stacked_bar_chart = Hash.new
      pie_chart = Hash.new
      all_charts = Hash.new
      value_to_show = ""

      all_values_to_show = Array.new

      orga_controller = OrganizationsController.new

        # ['a', 'b', 'c', 'd'].each do |letter|
        #   kpi_config_id = iwidget.send("serie_#{letter}_kpi_id")
        #   unless kpi_config_id.blank?
        #     output_type = iwidget.send("serie_#{letter}_output_type")
        #
        #     if output_types[output_type]
        #       output_types[output_type] << kpi_config_id
        #     else
        #       output_types[output_type] = Array.new
        #       output_types[output_type] << kpi_config_id
        #     end
        #   end
        # end

      boolean_line_chart = false
      boolean_bar_chart = false
      boolean_stacked_bar_chart_chart = false

      ['a', 'b', 'c', 'd'].each do |letter|
        kpi_config_id = iwidget.send("serie_#{letter}_kpi_id")
        kpi_config_output_type = iwidget.send("serie_#{letter}_output_type")

        unless kpi_config_id.blank? || kpi_config_output_type.blank?
          kpi_config = organization.kpis.where(id: kpi_config_id).first
          output_type = iwidget.send("serie_#{letter}_output_type")

          if output_types[output_type]
            output_types[output_type] << kpi_config_id
          else
            output_types[output_type] = Array.new
            output_types[output_type] << kpi_config_id
          end

          if kpi_config

            serie_values = orga_controller.get_indicators_dashboard_kpi_values(organization.id, kpi_config_id)
            kpi_unit = kpi_config.kpi_unit

            case output_type

              when "first_value"
                if kpi_config.output_type.to_s.in?(["graphic", "serie"])

                  number_values["#{kpi_config.name}"] = [serie_values.first]
                else
                  #value_to_show = "#{serie_values} #{kpi_unit}"
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "last_value"
                if kpi_config.output_type.to_s.in?(["graphic", "serie"])
                  number_values["#{kpi_config.name}"] = [serie_values.last]
                else
                  #value_to_show = "#{serie_values} #{kpi_unit}"
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "table_values"
                #table_values["#{kpi_config_id}"] = serie_values
                number_values["#{kpi_config.name}"] = serie_values

              when "line_chart"

                line_chart["#{kpi_config_id}"] = serie_values
                #series_results["#{kpi_config.name}"] = { serie_value: serie_values, serie_type: "line_chart" }
                boolean_line_chart = true

              when "bar_chart"
                bar_chart["#{kpi_config_id}"] = serie_values
                #series_results["#{kpi_config.name}"] = { serie_value: serie_values, serie_type: "bar_chart" }

                boolean_bar_chart = true

              when "stacked_bar_chart"
                stacked_bar_chart["#{kpi_config_id}"] = serie_values
                #series_results["#{kpi_config.name}"] = { serie_value: serie_values, serie_type: "stacked_bar_chart" }

                boolean_stacked_bar_chart_chart = true

              when "pie_chart"
                pie_chart["#{kpi_config_id}"] = serie_values
            end

          else
            serie_values = nil
          end

          ###series_results["#{kpi_config_id}"] = serie_values
        end
      end

    #Table list of values
      unless number_values.blank?
        value_to_show = render :partial => 'iwidgets/series_table_values', :locals => { :table_values => number_values, organization: organization }

        #all_values_to_show << "\n\r"
        all_values_to_show << value_to_show
      end


      # serie_number = 0
      # series_results.each do |key, serie_hash|
      #   serie_value = serie_value[:serie_value]
      #   serie_type = serie_value[:serie_type]
      #
      #   all_charts = all_charts.merge(serie_value)
      # end


    series_options = {
        #legend: { position: 'top', maxLines: 5 },
        legend: { position: "right", alignment: 'start', orientation: 'horizontal' },
        chartArea: { left: '10%', top: '3%', width:'70%', height:'85%'},
        hAxis: { title: iwidget.x_axis_label },
        vAxis: { title: iwidget.y_axis_label },
        #colors: chart_colors,

        seriesType: 'bars',
        bar: { groupWidth: '65%' },
        isStacked: true,
        # series: {'<%= line_chart_position %>': { type: 'line', pointsVisible: true } }
        series: { }
    }



    #======== TEST
    # Stacked bar chart
    unless line_chart.blank? && bar_chart.blank? && stacked_bar_chart.blank?
      if (boolean_line_chart && boolean_bar_chart) || (boolean_line_chart && boolean_stacked_bar_chart_chart) || (boolean_bar_chart && boolean_stacked_bar_chart_chart)
        all_charts = Hash.new
        stacked_bar_chart_position = 0
        line_chart_position = 0


        # #TEST
        # # Stacked-Bar chart
        # unless stacked_bar_chart.blank?
        #
        #   if bar_chart.blank?
        #     series_options[:isStacked] = true
        #     all_charts = all_charts.merge(stacked_bar_chart)
        #   else
        #     stacked_bar_chart_position = bar_chart.size
        #     all_charts = all_charts.merge(stacked_bar_chart)
        #
        #     series_options[:series]["#{0}"] = { type: 'bars', isStacked: true }
        #   end
        # end
        #
        # # Bar chart
        # unless bar_chart.blank?
        #   bar_chart_position = all_charts.size
        #   all_charts = all_charts.merge(bar_chart)
        #   series_options[:series]["#{bar_chart_position-1}"] = { type: 'bars', isStacked: false}
        #
        # end
        #
        # #FIN TEST

        # Bar chart
        unless bar_chart.blank?
          bar_chart_position = all_charts.size
          #series_options[:series]["#{bar_chart_position}"] = { type: 'bars', isStacked: false}
          series_options[:series]["#{0}"] = { targetAxisIndex: 0 }
          all_charts = all_charts.merge(bar_chart)
        end

        # Stacked-Bar chart
        unless stacked_bar_chart.blank?

          if bar_chart.blank?
            #series_options[:isStacked] = true
            all_charts = all_charts.merge(stacked_bar_chart)
          else
            stacked_bar_chart_position = bar_chart.size
            all_charts = all_charts.merge(stacked_bar_chart)

            #series_options[:series]["#{stacked_bar_chart_position}"] = { type: 'bars', isStacked: true }
            #series_options[:series]["#{all_charts.size-1}"] = { targetAxisIndex: 0 }
          end
        end

        # Line chart
        if line_chart.blank?
          series_options[:series]["#{all_charts.size}"] = { targetAxisIndex: 0 }
        else
          series_options[:series]["#{all_charts.size - line_chart.size}"] = { targetAxisIndex: 0 }

          line_chart_position = all_charts.size
          all_charts = all_charts.merge(line_chart)

          line_chart.each do |line|
            series_options[:series]["#{line_chart_position}"] =  { type: 'line', pointsVisible: true, curveType: 'function' }
            line_chart_position = line_chart_position+1
          end
        end


        graphic_data = get_combine_chart_values(iwidget, organization, all_charts)
        value_to_show = render :partial => 'iwidgets/g_combo_chart', :locals => { :r_data => graphic_data, iwidget: iwidget, series_options: series_options }
        #value_to_show << "\n\r"
        all_values_to_show << value_to_show


      else  # Pas de combinaison de graphes
        # Line chart
        unless line_chart.blank?
          graphic_data = get_combine_chart_values(iwidget, organization, line_chart)
          value_to_show = render :partial => 'iwidgets/g_line_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }

          #value_to_show << "\n\r"
          all_values_to_show << value_to_show
        end

        # Bar chart
        unless bar_chart.blank?
          graphic_data = get_combine_chart_values(iwidget, organization, bar_chart)
          value_to_show = render :partial => 'iwidgets/g_column_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }

          #value_to_show << "\n\r"
          all_values_to_show << value_to_show
        end

        unless stacked_bar_chart.blank?
          graphic_data = get_combine_chart_values(iwidget, organization, stacked_bar_chart)
          value_to_show = render :partial => 'iwidgets/g_stacked_bar_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }

          ##value_to_show << "\n\r"
          all_values_to_show << value_to_show
        end

      end


    end

    #======== FIN TEST


      # # Line chart
      # unless line_chart.blank?
      #   if !bar_chart.blank? || !stacked_bar_chart.blank?
      #     bar_chart_position = line_chart.size
      #     stacked_bar_chart_position = line_chart.size + bar_chart.size
      #
      #     unless bar_chart.blank?
      #       line_chart = line_chart.merge(bar_chart)
      #     end
      #
      #     unless stacked_bar_chart.blank?
      #       line_chart = line_chart.merge(stacked_bar_chart)
      #     end
      #
      #   else
      #     graphic_data = get_combine_chart_values(iwidget, organization, line_chart)
      #     value_to_show = render :partial => 'iwidgets/g_line_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }
      #   end
      # end
      #
      #
      # # Stacked bar chart
      # unless stacked_bar_chart.blank?
      #   if line_chart.blank?
      #     graphic_data = get_combine_chart_values(iwidget, organization, stacked_bar_chart)
      #     value_to_show = render :partial => 'iwidgets/g_stacked_bar_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }
      #   else
      #     line_chart_position = stacked_bar_chart.size
      #     stacked_bar_chart = stacked_bar_chart.merge(line_chart)
      #
      #     graphic_data = get_combine_chart_values(iwidget, organization, stacked_bar_chart)
      #     value_to_show = render :partial => 'iwidgets/g_combo_chart', :locals => { :r_data => graphic_data, iwidget: iwidget, line_chart_position: line_chart_position}
      #   end
      # end


      # Pie chart
      unless pie_chart.blank?
        all_pie_charts_data = get_pie_chart_values(iwidget, organization, pie_chart)
        value_to_show = render :partial => 'iwidgets/g_pie_chart', :locals => { :multiple_r_data => all_pie_charts_data, iwidget: iwidget }

        ###value_to_show << "\n\r"
        all_values_to_show << value_to_show
      end


      #value_to_show = series_results
      # if kpi_config
      #   orga_controller = OrganizationsController.new
      #   value_to_show = orga_controller.projects_productivity_indicators(organization.id, kpi_config_id)
      #
      #   #if kpi_config.output_type != "graphic"
      #     #value_to_show = "#{ActionController::Base.helpers.number_with_precision(value_to_show_tmp.to_f, separator: ',', delimiter: ' ', precision: user_number_precision, locale: (current_user.language.locale rescue "fr"))} #{kpi_config.kpi_unit.to_s}"
      #     value_to_show = "#{ActionController::Base.helpers.number_with_precision(value_to_show.to_f, separator: ',', delimiter: ' ', precision: user_number_precision, locale: (current_user.language.locale rescue "fr"))}"
      #   #end
      # else
      #   value_to_show ="-"
      # end

      # all_values_to_show.each do |value_to_show|
      #   widget_data[:value_to_show] << value_to_show
      # end

      widget_data[:value_to_show] = value_to_show

    # rescue
    #   widget_data[:value_to_show] = "-"
    # end

    widget_data
  end


  def get_multiple_charts_values(iwidget, organization, multiple_charts_data)
  end


  def get_pie_chart_values(iwidget, organization, pie_chart_data_hash)

    all_graph_data = Hash.new

    pie_chart_data_hash.each do |kpi_config_id, array_values|

      # kpi_config_id = pie_chart_data_hash.keys[0]
      # array_values = pie_chart_data_hash["#{kpi_config_id}"]

      kpi_config = organization.kpis.where(id: kpi_config_id).first
      if kpi_config
        graphic_data = Array.new
        graphic_data << [I18n.t(:projects), "#{kpi_config.name}"]

        array_values.each do |project_hash|
          graphic_data << ["#{project_hash[:selected_date]}", project_hash[:field_value]]
        end

        all_graph_data["#{kpi_config.name}"] = graphic_data
      end
    end

    all_graph_data
  end

  #for Line, Bar, Stacked bar charts
  def get_combine_chart_values(iwidget, organization, line_chart_data_hash)
    graphic_data = Array.new
    graphic_data_by_date = Hash.new

    line_chart_size = line_chart_data_hash.size
    #graphic_data << [I18n.t("#{selected_date}"), "#{config_for_graph}", { role: 'tooltip' } ]
    header = ["Date"]
    #@res_graphic << [I18n.l(project.send("#{selected_date}").to_date), value, "#{project.to_s} : #{value.round(2)} #{kpi_config.kpi_unit}"]

    #test = indicator_values.group_by { |x| x[:field_value] }

    positions = Hash.new
    position = 1
    line_chart_data_hash.each do |kpi_config_id, array_values|
      kpi_config = organization.kpis.where(id: kpi_config_id).first
      if kpi_config
        positions["#{kpi_config_id}"] = position

        header << "#{kpi_config.get_config_label}"
        #header << "#{kpi_config.name}"

        array_values.group_by { |x| x[:selected_date] }.each do |selected_date, elts_array|

          if graphic_data_by_date["#{selected_date}"].blank?
            graphic_data_by_date["#{selected_date}"] = [selected_date]

            for i in 1..line_chart_size
              graphic_data_by_date["#{selected_date}"] << nil
            end
          end

          # elts_array.each do |elt_hash|
          # end
          #current_value = elts_array.group_by { |x| x[:field_value] }.sum
          current_value = 0.0
          elts_array.each do |x|
            current_value = current_value + x[:field_value]
          end


          graphic_data_by_date["#{selected_date}"][position] = current_value
        end

        position = position+1
      end
    end

    #header << { role: 'tooltip' }
    graphic_data << header
    #graphic_data << graphic_data_by_date.values
    graphic_data_by_date.each do |key, values|
      graphic_data << values
    end

    # order = 1
    # line_chart_data_hash.each do |kpi_config_id, array_values|
    #   kpi_config = organization.kpis.where(id: kpi_config_id).first
    #
    #   if kpi_config
    #     array_values.each do |project_hash|
    #       column_value = [project_hash[:selected_date]]
    #
    #       for i in 1..line_chart_size
    #         if i == order
    #           column_value << project_hash[:field_value]
    #         else
    #           column_value << nil
    #         end
    #       end
    #
    #       column_value << project_hash[:project_label]
    #
    #       graphic_data << column_value #[project_hash[:selected_date], project_hash[:field_value], project_hash[:project_label]]
    #     end
    #
    #     order = order+1
    #   end
    # end

    graphic_data

  end


  def get_combine_line_chart_values_v1(iwidget, organization, line_chart_data_hash)
    graphic_data = Array.new
    line_chart_size = line_chart_data_hash.size
    #graphic_data << [I18n.t("#{selected_date}"), "#{config_for_graph}", { role: 'tooltip' } ]
    header = ["Date"]
    #graphic_data << ["Date", "Configuration", { role: 'tooltip' } ]
    #@res_graphic << [I18n.l(project.send("#{selected_date}").to_date), value, "#{project.to_s} : #{value.round(2)} #{kpi_config.kpi_unit}"]

    positions = Hash.new
    position = 0
    line_chart_data_hash.each do |kpi_config_id, array_values|
      kpi_config = organization.kpis.where(id: kpi_config_id).first
      if kpi_config
        positions["#{kpi_config_id}"] = position

        #header << "#{kpi_config.get_config_label}"
        header << "#{kpi_config.name}"
        position = position+1
      end
    end

    header << { role: 'tooltip' }
    graphic_data << header


    order = 1
    line_chart_data_hash.each do |kpi_config_id, array_values|
      kpi_config = organization.kpis.where(id: kpi_config_id).first

      if kpi_config
        array_values.each do |project_hash|
          column_value = [project_hash[:selected_date]]

          for i in 1..line_chart_size
            if i == order
              column_value << project_hash[:field_value]
            else
              column_value << nil
            end
          end

          column_value << project_hash[:project_label]

          graphic_data << column_value #[project_hash[:selected_date], project_hash[:field_value], project_hash[:project_label]]
        end

        order = order+1
      end
    end

    graphic_data

  end

  def get_calculation_widget_value(iwidget)
    begin
      eq = iwidget.equation
      ev = iwidget.estimation_value

      formula = eq["formula"].to_s
      component = current_component
      user_number_precision = current_user.number_precision.nil? ? 2 : current_user.number_precision

      unless eq["A"].blank?
        a_value = get_ev_value(eq["A"].first, component.id, iwidget.id)
        formula = formula.gsub("A", a_value)
      end

      unless eq["B"].blank?
        b_value = get_ev_value(eq["B"].first, component.id, iwidget.id)
        formula = formula.gsub("B", b_value)
      end

      unless eq["C"].blank?
        c_value = get_ev_value(eq["C"].first, component.id, iwidget.id)
        formula = formula.gsub("C", c_value)
      end

      unless eq["D"].blank?
        d_value = get_ev_value(eq["D"].first, component.id, iwidget.id)
        formula = formula.gsub("D", d_value)
      end

      unless eq["E"].blank?
        e_value = get_ev_value(eq["E"].first, component.id, iwidget.id)
        formula = formula.gsub("E", e_value)
      end

      if correct_syntax?(formula)
        result_value = eval(formula).round(user_number_precision)
        if result_value.is_a?(Float) && result_value.nan?
          '-'
        else
          "#{ActionController::Base.helpers.number_with_precision(result_value.to_f, separator: ',', delimiter: ' ', precision: user_number_precision, locale: (current_user.language.locale rescue "fr"))} #{iwidget.kpi_unit.to_s}"
        end
      else
        '-'
      end
    rescue
      '-'
    end
  end

  def get_calculation_widget_value_without_unit(iwidget, component = nil)
    begin
      eq = iwidget.equation
      ev = iwidget.estimation_value
      formula = eq["formula"].to_s

      if component.nil?
        component = current_component
      end

      unless eq["A"].blank?
        a_value = get_ev_value(eq["A"].first, component.id, iwidget.id)
        formula = formula.gsub("A", a_value)
      end

      unless eq["B"].blank?
        b_value = get_ev_value(eq["B"].first, component.id, iwidget.id)
        formula = formula.gsub("B", b_value)
      end

      unless eq["C"].blank?
        c_value = get_ev_value(eq["C"].first, component.id, iwidget.id)
        formula = formula.gsub("C", c_value)
      end

      unless eq["D"].blank?
        d_value = get_ev_value(eq["D"].first, component.id, iwidget.id)
        formula = formula.gsub("D", d_value)
      end

      unless eq["E"].blank?
        e_value = get_ev_value(eq["E"].first, component.id, iwidget.id)
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
    rescue
      '-'
    end
  end
end
