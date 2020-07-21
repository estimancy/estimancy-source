module IwidgetsHelper

  #get normal widget value
  def get_iwidget_value(iwidget, organization, is_project_widget=false, end_of_series=nil, project_id=nil, number_value_for_calculation_widget=false)
    widget_data = {}

    #begin

      series_results = Hash.new
      output_types = Hash.new

      number_values = Hash.new
      number_values_for_calculation_widget = Hash.new
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

            serie_values = orga_controller.get_indicators_dashboard_kpi_values(organization.id, kpi_config_id, is_project_widget, end_of_series, project_id)
            kpi_unit = kpi_config.kpi_unit

            case output_type

              #[I18n.t(:minimum), "minimum"], [I18n.t(:maximum), "maximum"], [I18n.t(:average), "average"], [I18n.t(:median), "median"], [I18n.t(:sum), "sum"], [I18n.t(:counter), "counter"]
              when "minimum"
                if kpi_config.output_type.to_s.in?(["graphic", "serie"])
                  min_value = serie_values.min{ |a, b| a[:field_value] <=> b[:field_value] }
                  number_values["#{kpi_config.name}"] = [min_value]
                else
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "maximum"

                if kpi_config.output_type.to_s.in?(["graphic", "serie"])
                  max_value = serie_values.max{ |a, b| a[:field_value] <=> b[:field_value] }
                  number_values["#{kpi_config.name}"] = [max_value]
                else
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "average"

                if kpi_config.output_type.to_s.in?(["graphic", "serie"])

                  average = (serie_values.map{ |k| k[:field_value]}.sum / serie_values.size) rescue nil
                  average_value = {  project_id: "",
                                     selected_date: I18n.l(Time.now.to_date),
                                     field_value: average.round(2),
                                     project_label: "",
                                     kpi_unit: kpi_unit
                                }

                  number_values["#{kpi_config.name}"] = [average_value]
                else
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "median"

                if kpi_config.output_type.to_s.in?(["graphic", "serie"])

                  sorted = serie_values.map{ |k| k[:field_value]}.sort
                  nb_projects = serie_values.size

                  median = (sorted[(nb_projects - 1) / 2] + sorted[nb_projects / 2]) / 2.0
                  median_value = {  project_id: "",
                                     selected_date: I18n.l(Time.now.to_date),
                                     field_value: median.round(2),
                                     project_label: "",
                                     kpi_unit: kpi_unit
                  }

                  number_values["#{kpi_config.name}"] = [median_value]
                else
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "sum"

                if kpi_config.output_type.to_s.in?(["graphic", "serie"])

                  sum = serie_values.map{ |k| k[:field_value]}.sum
                  sum_value = {  project_id: "",
                                     selected_date: I18n.l(Time.now.to_date),
                                     field_value: sum.round(2),
                                     project_label: "",
                                     kpi_unit: kpi_unit
                  }

                  number_values["#{kpi_config.name}"] = [sum_value]
                else
                  number_values["#{kpi_config.name}"] = serie_values
                end

              when "counter"

                counter = serie_values.size
                counter_value = {  project_id: "",
                               selected_date: I18n.l(Time.now.to_date),
                               field_value: counter,
                               project_label: "",
                               kpi_unit: kpi_unit
                }

                number_values["#{kpi_config.name}"] = [counter_value]

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
          number_values_for_calculation_widget["#{letter}"] = number_values["#{kpi_config.name}"]
        end
      end

    #Table list of values
      unless number_values.blank?
        if number_value_for_calculation_widget == true
          value_to_show = number_values_for_calculation_widget
        else
          value_to_show = render :partial => 'iwidgets/series_table_values', :locals => { :table_values => number_values, organization: organization }
        end

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
        legend: { position: "right", alignment: 'start', orientation: 'vertical' },
        chartArea: { left: '10%', top: '3%', width:'70%', height:'80%'},

        hAxis: { title: iwidget.x_axis_label },
        vAxis: { title: iwidget.y_axis_label },

        #colors: chart_colors,

        seriesType: 'bars',
        bar: { groupWidth: '65%' },
        #isStacked: true,
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
          series_options[:series]["#{0}"] = { targetAxisIndex: 1 }
          all_charts = all_charts.merge(bar_chart)
        end

        # Stacked-Bar chart
        unless stacked_bar_chart.blank?
          series_options[:isStacked] = true

          if bar_chart.blank?
            #series_options[:isStacked] = true
            all_charts = all_charts.merge(stacked_bar_chart)
          else

            stacked_bar_chart_position = bar_chart.size
            all_charts = all_charts.merge(stacked_bar_chart)

            #series_options[:series]["#{stacked_bar_chart_position}"] = { type: 'bars', isStacked: true }
            #series_options[:series]["#{all_charts.size-1}"] = { targetAxisIndex: 0 }

            bars_max = bar_chart.values.flatten.map{|k| k[:field_value] }.max
            stacked_bars_max = stacked_bar_chart.values.flatten.map{|k| k[:field_value] }.sum
            vAxis_max_value = [bars_max.to_f, stacked_bars_max.to_f].max.floor

            series_options[:vAxis][:viewWindow] = { min: 0, max: vAxis_max_value }
          end
        end

        # Line chart
        if line_chart.blank?
          series_options[:series]["#{all_charts.size}"] = { targetAxisIndex: 0 }
          series_options[:chartArea] = { width:'100%', height:'70%'}
          series_options[:legend] = { position: "bottom", alignment: 'start'}

          graphic_data = get_combine_chart_values(iwidget, organization, all_charts)
          value_to_show = render :partial => 'iwidgets/g_bar_chart', :locals => { :r_data => graphic_data, iwidget: iwidget, series_options: series_options }
          #value_to_show << "\n\r"
          all_values_to_show << value_to_show

        else
          #series_options[:series]["#{all_charts.size - line_chart.size}"] = { targetAxisIndex: 0 }
          series_options[:vAxis] =  { title: iwidget.y_axis_label }
          series_options[:series]["#{0}"] = { targetAxisIndex: 0 }

          line_chart_position = all_charts.size
          all_charts = all_charts.merge(line_chart)

          line_chart.each do |line|
            series_options[:series]["#{line_chart_position}"] =  { type: 'line', pointsVisible: true, curveType: 'function' }
            line_chart_position = line_chart_position+1
          end

          graphic_data = get_combine_chart_values(iwidget, organization, all_charts)
          value_to_show = render :partial => 'iwidgets/g_combo_chart', :locals => { :r_data => graphic_data, iwidget: iwidget, series_options: series_options }
          #value_to_show << "\n\r"
          all_values_to_show << value_to_show
        end


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

      widget_data[:value_to_show] = all_values_to_show #value_to_show

    # rescue
    #   widget_data[:value_to_show] = "-"
    # end

    widget_data
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
    #graphic_data << header
    graphic_data_by_date.each do |key, values|
      graphic_data << values
    end

    new_graphic_data = graphic_data.sort_by { |e| e.nil? ? 0 : e[0] }
    graphic_data = [header] + new_graphic_data

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



  def get_calculation_iwidget_value(iwidget, organization)
    #begin
      formula = iwidget.equation.to_s.downcase
      output_types = Hash.new
      number_values = Hash.new
      final_letter_values = HashWithIndifferentAccess.new
      final_hash = HashWithIndifferentAccess.new
      equation_result_hash = HashWithIndifferentAccess.new
      first_letter_unit = ""
      user_number_precision = current_user.number_precision.nil? ? 2 : current_user.number_precision

      iwidget_number_value = get_iwidget_value(iwidget, organization, false, nil, nil, true)
      number_values = iwidget_number_value[:value_to_show].first

      number_values.each do |letter, array_values|
        data_by_date = Hash.new

        array_values.each do |elt_hash|
          selected_date = elt_hash[:selected_date]

          if data_by_date["#{selected_date}"].blank?
            project_value  = elt_hash[:field_value]

            # data_by_date["#{selected_date}"] = {
            #     project_id: [ elt_hash[:project_id] ],
            #     selected_date: selected_date,
            #     field_value: project_value,
            #     project_label: "",
            #     kpi_unit: elt_hash[:kpi_unit]
            # }

            first_letter_unit = elt_hash[:kpi_unit].to_s
            data_by_date["#{selected_date}"] = project_value
          else

            #data_by_date["#{selected_date}"][:project_id] << elt_hash[:project_id]
            #data_by_date["#{selected_date}"][:project_label] << elt_hash[:project_label]

            field_value = data_by_date["#{selected_date}"][:field_value]
            project_value = field_value + elt_hash[:field_value]
            data_by_date["#{selected_date}"] = project_value
          end
        end

        final_letter_values["#{letter}"] = data_by_date
      end

      #a_hash.merge(b_hash){ |k, a_value, b_value| a_value + b_value }
      #final_hash.merge(letter_hash){ |k, a_value, b_value| a_value + b_value }

      final_letter_values.each do |letter, letter_hash|

        letter_hash.each do |key, value|
          if final_hash["#{key}"].blank?
            final_hash["#{key}"] = { :"#{letter}" => value }
          else
            final_hash["#{key}"]["#{letter}"] = value
          end
        end
      end

      # on calcule la formule
      final_hash.each do |selected_date, hash_value|
        selected_date_formula = formula

        final_letter_values.keys.each do |letter|
          letter_value = hash_value[:"#{letter}"].to_f
          selected_date_formula = selected_date_formula.gsub(letter.to_s, letter_value.to_s)
        end

        if correct_syntax?(selected_date_formula)
          selected_date_result_value = eval(selected_date_formula)#.round(user_number_precision)

          if selected_date_result_value.is_a?(Float) && selected_date_result_value.nan?
            selected_date_result_value = nil
          end
        else
          selected_date_result_value = nil
        end
        equation_result_hash["#{selected_date}"] = selected_date_result_value
      end

      equation_result_hash_values = equation_result_hash.values
      equation_result_nb_elts = equation_result_hash.size
      equation_output_type = iwidget.equation_output_type
      case equation_output_type

        when "minimum"
          #result_value = equation_result_hash_values.min
          result_value = equation_result_hash.group_by{|k, v| v}.min_by{|k, v| k}.last.to_h
          value_to_show = ""
          result_value.each do |key, val|
            value_to_show << "#{key}  : #{val.to_f.round(user_number_precision)} #{first_letter_unit}"
          end
          return [value_to_show]

        when "maximum"

          result_value = equation_result_hash.group_by{|k, v| v}.max_by{|k, v| k}.last.to_h
          value_to_show = ""
          result_value.each do |key, val|
            value_to_show << "#{key}  : #{val.to_f.round(user_number_precision)} #{first_letter_unit}"
          end
          return [value_to_show]

        when "average"
          result_value = equation_result_hash_values.sum / equation_result_nb_elts rescue nil
          return ["#{result_value.to_f.round(user_number_precision)} #{first_letter_unit}"]

        when "median"

          result_value = equation_result_hash_values.sum / equation_result_nb_elts rescue nil
          return ["#{result_value.to_f.round(user_number_precision)} #{first_letter_unit}"]

        when "sum"
          result_value = equation_result_hash_values.sum
          return ["#{result_value.to_f.round(user_number_precision)} #{first_letter_unit}"]

        when "counter"
          return [equation_result_hash.size]

        when "first_value"
          result_value = equation_result_hash.first
          value_to_show = "#{result_value.first}  : #{result_value.last.to_f.round(user_number_precision)} #{first_letter_unit}"
          return [value_to_show]

        when "last_value"
          last_key = equation_result_hash.keys.last
          value_to_show = "#{last_key}  : #{equation_result_hash[last_key].to_f.round(user_number_precision)} #{first_letter_unit}"
          return [value_to_show]

        when "table_values"
          result_value = equation_result_hash

          value_to_show = ""

          result_value.each do |key, val|
            value_to_show << "#{key}  :  #{val.to_f.round(user_number_precision)} #{first_letter_unit} \n\r"
            value_to_show << "</br>"
          end
          return [raw(value_to_show)]

        when "line_chart"
          graphic_data_with_options = calculation_iwidget_graphic_values(iwidget, equation_result_hash, false, false)
          graphic_data = graphic_data_with_options.first
          series_options = graphic_data_with_options.last
          value_to_show = raw (render :partial => 'iwidgets/g_line_chart', :locals => { :r_data => graphic_data, iwidget: iwidget })
          return [value_to_show]

        when "bar_chart"
          graphic_data_with_options = calculation_iwidget_graphic_values(iwidget, equation_result_hash, false, false)
          graphic_data = graphic_data_with_options.first
          series_options = graphic_data_with_options.last
          value_to_show = render :partial => 'iwidgets/g_bar_chart', :locals => { :r_data => graphic_data, iwidget: iwidget, series_options: series_options }
          return [value_to_show]

        when "stacked_bar_chart"
          graphic_data_with_options = calculation_iwidget_graphic_values(iwidget, equation_result_hash, false, false)
          graphic_data = graphic_data_with_options.first
          series_options = graphic_data_with_options.last

          value_to_show = render :partial => 'iwidgets/g_stacked_bar_chart', :locals => { :r_data => graphic_data, iwidget: iwidget }
          return [value_to_show]

        when "pie_chart"
          graphic_data_with_options = calculation_iwidget_graphic_values(iwidget, equation_result_hash, false, false)
          graphic_data = graphic_data_with_options.first
          series_options = graphic_data_with_options.last

          value_to_show = render :partial => 'iwidgets/g_pie_chart', :locals => { :multiple_r_data => { "#{iwidget.name}" => graphic_data }, iwidget: iwidget }
          return [value_to_show]
        else
          return equation_result_hash
      end


      # if correct_syntax?(formula)
      #   result_value = eval(formula).round(user_number_precision)
      #   if result_value.is_a?(Float) && result_value.nan?
      #     '-'
      #   else
      #     #"#{ActionController::Base.helpers.number_with_precision(result_value.to_f, separator: ',', delimiter: ' ', precision: user_number_precision, locale: (current_user.language.locale rescue "fr"))} #{iwidget.kpi_unit.to_s}"
      #     ["#{result_value.to_f} #{first_letter_unit.to_s}"]
      #   end
      # else
      #   '-'
      # end
    # rescue
    #   '-'
    # end

  end

  def calculation_iwidget_graphic_values(iwidget, calculation_iwidget_hash_values, is_bar=false, is_stacked=false)

    series_options = {
      legend: { position: "right", alignment: 'start', orientation: 'vertical' },
      chartArea: { left: '10%', top: '3%', width:'70%', height:'80%'},

      hAxis: { title: iwidget.x_axis_label },
      vAxis: { title: iwidget.y_axis_label }
    }

    if is_bar == true
      series_options[:seriesType] = 'bars'
      series_options[:bar] = { groupWidth: '65%' }
    end

    if is_stacked == true
      series_options[:isStacked] = true
    end

    graphic_data = Array.new
    graphic_data << ['Selected data', 'Values']
    calculation_iwidget_hash_values.each do |key, value|
      graphic_data << [key, value]
    end

    [graphic_data, series_options]
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
