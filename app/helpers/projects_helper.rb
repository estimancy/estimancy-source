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


module ProjectsHelper
  include ActionView::Helpers::NumberHelper

  # This helper method will display Estimation Result according the estimation purpose (PBS and/or Activities)
  def display_results
    res = String.new
    unless @project.nil?
      #pbs_project_element = @pbs_project_element || @project.root_component
      pbs_project_element = @pbs_project_element || current_component
      #get the current module_project
      module_project_to_display = current_module_project

      if module_project_to_display.pemodule.yes_for_output_with_ratio? || module_project_to_display.pemodule.yes_for_output_without_ratio? || module_project_to_display.pemodule.yes_for_input_output_with_ratio? || module_project_to_display.pemodule.yes_for_input_output_without_ratio?
        if module_project_to_display.pemodule.alias == 'effort_balancing'
          res << display_effort_balancing_output(module_project_to_display)
        else
          res << display_results_with_activities(module_project_to_display)
        end
      else
        if module_project_to_display.pemodule.alias == Projestimate::Application::BALANCING_MODULE
          res << display_balancing_output(module_project_to_display)
        else
          res << display_results_without_activities(module_project_to_display)
        end
      end
      res
    end
    res
  end

  # Display the units of attributes
  def get_attribute_unit(pe_attribute)
    case pe_attribute.alias
      when "effort"
        I18n.t(:unit_effort_person_hour)
      when "staffing"
        I18n.t(:unit_staffing)
      when "end_date"
        "jj/mm/aaaa"
      when "delay"
        I18n.t(:delay)
      when "cost"
        #@project.organization.currency.nil? ? nil.to_s : "#{@project.organization.currency.name.underscore.pluralize}"
        @project.organization.currency.nil? ? nil.to_s : "#{@project.organization.currency.sign}"
      else
        ""
      end
  end

  #Conversion en fonction des seuils et de la précision de l'utilisateur #> 12.12300 (si precision = 5)
  def convert(v, organization)
    unless v.class == Hash
      value = v.to_f
      if value < organization.limit1.to_i
        convert_with_precision(value / organization.limit1_coef.to_f, user_number_precision, true)
      elsif value < organization.limit2.to_i
        convert_with_precision(value / organization.limit2_coef.to_f, user_number_precision, true)
      elsif value < organization.limit3.to_i
        convert_with_precision(value / organization.limit3_coef.to_f, user_number_precision, true)
      elsif value < organization.limit4.to_i
        convert_with_precision(value / organization.limit4_coef.to_f, user_number_precision, true)
      else
        convert_with_precision(value / organization.limit4_coef.to_f, user_number_precision, true)
      end
    else
      0
    end
  end

  #Conversion en fonction des seuils et de la précision en params #> 12.123 (si precision = 5) ou 12.12 si (si precision = 2)
  def convert_with_specific_precision(v, organization, precision)
    unless v.class == Hash
      value = v.to_f
      if value < organization.limit1.to_i
        (value / organization.limit1_coef.to_f).round(precision)
      elsif value < organization.limit2.to_i
        (value / organization.limit2_coef.to_f).round(precision)
      elsif value < organization.limit3.to_i
        (value / organization.limit3_coef.to_f).round(precision)
      elsif value < organization.limit4.to_i
        (value / organization.limit4_coef.to_f).round(precision)
      else
        (value / organization.limit4_coef.to_f).round(precision)
      end
    else
      0
    end
  end

  #Conversion en fonction des seuils uniquement #> 12.123 (si precision = 5) ou 12.12 si (si precision = 2)
  def convert_without_precision(v, organization)
    unless v.class == Hash
      value = v.to_f
      if value < organization.limit1.to_i
        value / organization.limit1_coef.to_f
      elsif value < organization.limit2.to_i
        value / organization.limit2_coef.to_f
      elsif value < organization.limit3.to_i
        value / organization.limit3_coef.to_f
      elsif value < organization.limit4.to_i
        value / organization.limit4_coef.to_f
      else
        value / organization.limit4_coef.to_f
      end
    else
      0
    end
  end

  #Conversion en fonction de la précision en params uniquement #> 12.12300 (si precision = 5) ou 12.12 si (si precision = 2)
  def convert_with_precision(value, precision, delimiter = false)
    begin
      v = number_with_precision(value, precision: precision, locale: :fr, delimiter: delimiter ? ' ' : '')
    rescue
      begin
        v = "%.#{precision}f" % value
      rescue
        v = 0
      end
    end
  end

  def convert_label(v, organization)
    unless v.class == Hash
      value = v.to_f
      if value < organization.limit1.to_i
        organization.limit1_unit
      elsif value < organization.limit2.to_i
        organization.limit2_unit
      elsif value < organization.limit3.to_i
        organization.limit3_unit
      elsif value < organization.limit4.to_i
        organization.limit4_unit
      else
        organization.limit4_unit
      end
    else
      0
    end
  end

  # Convert effort value according to the effort unit in the Effort instance module
  def convert_with_standard_unit_coefficient(estimation_value=nil, v, standard_unit_coefficient, precision)
    unless v.class == Hash
      value = v.to_f
      #(value / standard_unit_coefficient.to_f).round(precision)
      if estimation_value.nil?
        value.round(precision)
      else
        case estimation_value.pe_attribute.alias
          when "effort"
            (value / standard_unit_coefficient.to_f).round(precision)
          when "retained_size"
            value.round(precision)
          when "introduced_defects"
            value.round(precision)
          when "remaining_defects"
            value.round(precision)
        end
      end
    else
      0
    end
  end


  # Methdods that display estimation results
  def display_results_without_activities(module_project)
    res = String.new
    pbs_project_element = @pbs_project_element || current_component

    pemodule = Pemodule.find(module_project.pemodule.id)
    res << "<table class='table table-condensed table-bordered'>
                 <tr>
                   <th></th>"
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << "<th>#{level.humanize}</th>"
    end
    res << '</tr>'

    module_project.estimation_values.where('in_out = ?', 'output').order('display_order ASC').each do |est_val|
      est_val_pe_attribute = est_val.pe_attribute
      res << "<tr><td><span class='attribute_tooltip tree_element_in_out' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}'>#{est_val_pe_attribute.name} (#{get_attribute_unit(est_val_pe_attribute)})</span></td>"
      ['low', 'most_likely', 'high', 'probable'].each do |level|
        res << '<td>'
        level_estimation_values = Hash.new
        level_estimation_values = est_val.send("string_data_#{level}")
        total = []
        if level_estimation_values.nil? || level_estimation_values[pbs_project_element.id].nil? || level_estimation_values[pbs_project_element.id].blank?
          res << '-'
        else
          res << "#{display_value(level_estimation_values[pbs_project_element.id], est_val, module_project.id)}"
        end
        res << '</td>'
      end
      res << '</tr>'
    end
    res << '</table>'
    res
  end


  #The view to display result with ACTIVITIES
  def display_results_with_activities(module_project)
    res = String.new
    pbs_project_element = @pbs_project_element || current_component

    pe_wbs_activity = module_project.project.pe_wbs_projects.activities_wbs.first
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first

    pemodule = Pemodule.find(module_project.pemodule.id)
    res << " <table class='table table-condensed table-bordered'>
               <tr>
                 <th></th>"

    # Get the module_project probable estimation values for showing element consistency
    probable_est_value_for_consistency = nil
    pbs_level_data_for_consistency = Hash.new

    module_project.estimation_values.order('display_order ASC').each do |est_val|
      if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
        probable_est_value_for_consistency = est_val.send("string_data_probable")
        res << "<th colspan='4'><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}'> #{est_val.pe_attribute.name} (#{get_attribute_unit(est_val.pe_attribute)})</span></th>"

        # For is_consistent purpose
        ['low', 'most_likely', 'high', 'probable'].each do |level|
          unless level.eql?("probable")
            pbs_data_level = est_val.send("string_data_#{level}")
            pbs_data_level.nil? ? pbs_level_data_for_consistency[level] = nil : pbs_level_data_for_consistency[level] = pbs_data_level[pbs_project_element.id]
          end
        end
      end
    end
    res << '</tr>'

    # We are showing for each PBS and/or ACTIVITY the (low, most_likely, high) values
    res << '<tr>
              <th></th>'
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << "<th>#{level.humanize}</th>"
    end
    res << '</tr>'

    module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|

      pbs_probable_for_consistency = probable_est_value_for_consistency.nil? ? nil : probable_est_value_for_consistency[pbs_project_element.id]
      wbs_project_elt_consistency = (pbs_probable_for_consistency.nil? || pbs_probable_for_consistency[wbs_project_elt.id].nil?) ? false : pbs_probable_for_consistency[wbs_project_elt.id][:is_consistent]
      show_consistency_class = nil
      unless wbs_project_elt_consistency || module_project.pemodule.alias == "effort_breakdown"
        show_consistency_class = "<span class='icon-warning-sign not_consistent attribute_tooltip' title='<strong>#{I18n.t(:warning_caution)}</strong> </br>  #{I18n.t(:warning_wbs_not_complete, :value => wbs_project_elt.name)}'></span>"
      end

      #For wbs-activity-completion node consistency
      completion_consistency = ""
      title = ""
      if module_project.pemodule.alias == "wbs_activity_completion"
        current_wbs_consistency = true
        pbs_level_data_for_consistency.each do |level, level_value|
          #if !pbs_level_data_for_consistency.nil?
          if !level_value.nil? && !level_value.empty?
            wbs_level_data = level_value[wbs_project_elt.id]
            wbs_level_data.nil? ? current_wbs_consistency_level = nil : current_wbs_consistency_level = wbs_level_data[:is_consistent]
            current_wbs_consistency = current_wbs_consistency && current_wbs_consistency_level
            if !!current_wbs_consistency == false
              if show_consistency_class.nil?
                completion_consistency = "icon-warning-sign not_consistent attribute_tooltip"
                title = I18n.t(:warning_caution) + " : " + I18n.t(:warning_wbs_not_consistent)
              else
                show_consistency_class = "<span class='icon-warning-sign not_consistent attribute_tooltip' title=' <strong>#{I18n.t(:warning_caution)}</strong> </br> * #{I18n.t(:warning_wbs_not_complete, :value => wbs_project_elt.name)} </br> * #{I18n.t(:warning_wbs_not_consistent)}'></span>"
              end

              break
            end
          end
        end
      end

      res << "<tr> <td> <span class='tree_element_in_out #{completion_consistency}' title='#{title}' style='margin-left:#{wbs_project_elt.depth}em;'> #{show_consistency_class}  #{wbs_project_elt.name} </span> </td>"

      ['low', 'most_likely', 'high', 'probable'].each do |level|
        res << '<td>'
        module_project.estimation_values.where('in_out = ?', 'output').each do |est_val|
          if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
            level_estimation_values = Hash.new
            level_estimation_values = est_val.send("string_data_#{level}")
            if level_estimation_values.nil? || level_estimation_values[pbs_project_element.id].nil? || level_estimation_values[pbs_project_element.id][wbs_project_elt.id].nil? || level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value].nil?
              res << ' - '
            else
              res << "#{display_value(level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value], est_val, module_project.id)}"
            end
          end
        end
        res << '</td>'
      end
      res << '</tr>'
    end

    #Show the global result of the PBS
    res << '<tr>
              <td><strong>  </strong></td>'
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << '<td></td>'
    end
    res << '</tr>'

    # Show the probable values
    res << "<tr><td colspan='4'><strong> #{current_component.name} (Probable Value) </strong> </td>"
    module_project.estimation_values.each do |est_val|
      if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project_id == module_project.id
        res << "<td>"
        level_probable_value = est_val.send('string_data_probable')
        if level_probable_value.nil? || level_probable_value[pbs_project_element.id].nil? || level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id].nil? || level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id][:value].nil?
          res << '-'
        else
          res << "<div align='center'><strong>#{display_value(level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id][:value], est_val, module_project.id)}</strong></div>"
        end
        res << '</td>'
      end
    end
    res << '</tr>'
    res << '</table>'
    res
  end

  # The Balancing module output
  def display_balancing_output(module_project)
    #pbs_project_element = @pbs_project_element || @project.root_component
    pbs_project_element = current_component

    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<table class='table table-condensed table-bordered'>"

      # Get the current balancing attribute
      @current_balancing_attribute = current_balancing_attribute
      mp_attr_est_values = module_project.estimation_values.where('in_out = ? AND pe_attribute_id = ?', "output", @current_balancing_attribute)
      est_val = nil
      res << '<tr>
                <th></th>'
        if !mp_attr_est_values.nil? && !mp_attr_est_values.empty?
          est_val = mp_attr_est_values.last
          res << "<th><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val.pe_attribute.name} (#{get_attribute_unit(est_val.pe_attribute)})</span></th>"
        else
          res << "<th><span class='red_color'> #{I18n.t(:text_please_select_balancing_attribute)} </span></td>"
        end
      res << '</tr>'
      # Attribute Balancing résult
      res << "<tr>"
      res << "<td> #{current_component.name} </td>"
      res << "<td>"
      if est_val.nil?
        res << "-"
      else
        level_estimation_values = Hash.new
        level_estimation_values = est_val.send("string_data_probable")
        if !level_estimation_values[pbs_project_element.id].nil? && !level_estimation_values[pbs_project_element.id].blank?
          res << "#{ display_value(level_estimation_values[pbs_project_element.id], est_val, module_project.id) }"
        else
          res << "-"
        end
      end
      res << "</td>"
      res << "</tr>"
      res << '</table>'
    end
  end


  def display_effort_balancing_output(module_project)
    pbs_project_element = @pbs_project_element || current_component
    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<table class='table table-condensed table-bordered'>"

      res << '<tr>
                <th></th>'
      module_project.estimation_values.each do |est_val|
        if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val.pe_attribute.name} (#{get_attribute_unit(est_val.pe_attribute)})</span></th>"
        end
      end

      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        res << "<tr>
                    <td>
                      <span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>"
        res << '</td>'
        module_project.estimation_values.select { |i| i.in_out == 'output' or i.in_out=='both' }.each do |est_val|
          level_estimation_values = Hash.new
          level_estimation_values = est_val.send("string_data_probable")

          res << '<td>'
          if level_estimation_values and level_estimation_values[pbs_project_element.id]
            if level_estimation_values[pbs_project_element.id] and level_estimation_values[pbs_project_element.id][wbs_project_elt.id].blank?
              res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id]}"
            else
              if est_val.pe_attribute.attribute_type == "numeric"
                res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value]}"
              else
                res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id]}"
              end
            end
          else
            res << "-"
          end
          res << '</td>'
        end
        res << '</tr>'
      end
      res << '</table>'
    end
  end

  # Display link to add notes to attribute
  def add_attribute_notes_link(estimation_value, pbs_id)
    res = ""
    add_notes_title = I18n.t(:label_add_notes)
    icon_class = ""
    unless estimation_value.notes.nil?
      add_notes_title_est_val = estimation_value.notes
      if !estimation_value.notes["#{pbs_id}"].nil? && !estimation_value.notes["#{pbs_id}"].empty?
        add_notes_title = estimation_value.notes["#{pbs_id}"]
        icon_class = "icon-green"
      end
    end
    res << link_to('', main_app.add_note_to_attribute_path(:estimation_value_id => estimation_value.id, :pbs_project_elt_id => pbs_id), :class => "icon-edit #{icon_class}", :title => "#{add_notes_title}" , :remote => true)
  end

  # Display Estimations output results according to the module behavior
  def display_input
    res = String.new
    unless @project.nil?
      pbs_project_element = current_component

      @project = current_module_project.project
      current_module_project_pemodule = current_module_project.pemodule

      ##if module_project.pemodule.with_activities
      if current_module_project_pemodule.yes_for_input? || current_module_project_pemodule.yes_for_input_output_without_ratio? || current_module_project_pemodule.yes_for_input_output_with_ratio?

        # For WBS-ACTIVITY-COMPLETION MODULE
        if current_module_project_pemodule.alias == "wbs_activity_completion"
          @defined_status = RecordStatus.find_by_name("Defined")
          last_estimation_result = nil
          effort_breakdown_module = Pemodule.where("alias = ? AND record_status_id = ?", "effort_breakdown", @defined_status.id).first

          unless effort_breakdown_module.nil?
            #refer_module_potential_ids = module_project.associated_module_projects ###+ module_project.inverse_associated_module_projects
                                                                                   #unless refer_module.empty?

            refer_module_potential_ids = current_module_project.associated_module_projects
            refer_attribute = PeAttribute.where("alias = ? AND record_status_id = ?", "effort", @defined_status.id).first

            refer_modules_project = ModuleProject.joins(:project, :pbs_project_elements).where("pemodule_id = ? AND  project_id =? AND pbs_project_elements.id = ?", effort_breakdown_module.id, @project.id, pbs_project_element.id)
            refer_module_project = refer_modules_project.where(["module_project_id IN (?)", refer_module_potential_ids]).last

            unless refer_module_project.nil?
              # Get the estimation_value corresponding to the linked Effort_breakdown module (if there is one)
              last_estimation_results = EstimationValue.where('in_out = ? AND pe_attribute_id = ? AND module_project_id = ?', 'output', refer_attribute.id, refer_module_project.id).first

              if last_estimation_results.nil?
                last_estimation_result = Hash.new
              else
                last_estimation_result = last_estimation_results

                pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
                project_wbs_root = pe_wbs_project_activity.wbs_project_elements.where("is_added_wbs_root = ?", true).first

                # Get all complement children
                complement_children_ids = project_wbs_root.get_all_complement_children

                # This will be completed only if WBS has one or more not coming from library
                unless complement_children_ids.empty?
                  current_mp_est_value = current_module_project.estimation_values.where("pe_attribute_id = ? AND in_out = ?", refer_attribute.id, "output").last
                  ##new_created_estimation_value = EstimationValue.new
                  new_created_estimation_value = last_estimation_results

                  ['low', 'most_likely', 'high'].each do |level|

                    new_created_estimation_value_level = new_created_estimation_value.send("string_data_#{level}")

                    level_current_mp_est_val = current_mp_est_value.send("string_data_#{level}")

                    if !level_current_mp_est_val.nil? || !level_current_mp_est_val.empty?

                      pbs_level_value = level_current_mp_est_val[pbs_project_element.id]

                      unless pbs_level_value.nil?
                        complement_children_ids.each do |complement_child_id|
                          #new_created_estimation_value_level[pbs_project_element.id] << complement_child_id
                          if !pbs_level_value[complement_child_id].nil? && !level_current_mp_est_val[pbs_project_element.id][complement_child_id].nil?
                            new_created_estimation_value_level[pbs_project_element.id][complement_child_id] = {:value => level_current_mp_est_val[pbs_project_element.id][complement_child_id][:value]}
                          end
                        end
                        new_created_estimation_value.send("string_data_#{level}=".to_sym, new_created_estimation_value_level)
                      end
                    end

                  end
                  last_estimation_result = new_created_estimation_value
                end
              end
            end
          end
          res << display_inputs_with_activities(current_module_project, last_estimation_result)

          # For Effort balancing module
        elsif current_module_project_pemodule.alias == 'effort_balancing'
          res << display_effort_balancing_input(current_module_project, last_estimation_result)
          # For others module with Activities
        else
          res << display_inputs_with_activities(current_module_project)
        end

        # For effort balancing module without activities (only for component)
      elsif current_module_project_pemodule.alias == Projestimate::Application::BALANCING_MODULE
        res << display_balancing_input(current_module_project, last_estimation_result)

        # For others modules that don't use WSB-Activities values in input
      elsif current_module_project_pemodule.no? || current_module_project_pemodule.yes_for_output_with_ratio? || current_module_project_pemodule.yes_for_output_without_ratio?
        res << display_inputs_without_activities(current_module_project)
      end
    end
    res
  end

  # Display the Effort Balancing Input without activity
  def display_balancing_input(module_project, last_estimation_result)
    pbs_project_element = current_component
    #Get the current balancing attribute
    @current_balancing_attribute = current_balancing_attribute

    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)

      # render view according to the selected attribute
      res << "<div class='attribute_balancing_input' style='margin-bottom:15px;'>"
      res << "</div>"

      res << "<table class='table table-condensed table-bordered'>"
      if @current_balancing_attribute.nil?
        res << "<tr><th colspan='#{module_project.previous.size+2}'> <span class='red_color'> #{ I18n.t(:text_please_select_balancing_attribute) } </span> </th></tr>"
      else
        res << "<tr><th colspan='#{module_project.previous.size+2}'> #{ @current_balancing_attribute.name } </th></tr>"
      end
      res << '<tr>'
      # Get the balancing attribute
      # Only the module_project that have the @current_balancing_attribute attribute as OUTPUT attribute are compatibles
      compatible_previous_mp = []
      module_project.previous.each_with_index do |est_mp, i|
        compatible_attribute_module = est_mp.pemodule.attribute_modules.where('pe_attribute_id = ?', @current_balancing_attribute)
        if !compatible_attribute_module.nil?
          if !compatible_attribute_module.last.nil? && compatible_attribute_module.last.in_out.in?(%w(output both))
            compatible_previous_mp << compatible_attribute_module.last
          end
        end
        res << "<th>#{est_mp.pemodule.title}</th>"
      end
      res << "<th>#{I18n.t(:text_balancing_value)}</td>"
      res << "<th>Notes</th>"
      res << '</tr>'

      res << "<tr>"
      module_project.previous.each do |mp|
        res << "<td>"
          level = "probable"
          # Get estimation_value of previous mp for same attribute
          mp_attr_est_values = mp.estimation_values.where('in_out = ? AND pe_attribute_id = ?', "output", @current_balancing_attribute)
          if mp_attr_est_values == nil || mp_attr_est_values.length==0
            res << "-"
          else
            corresponding_est_val = mp_attr_est_values.last
            # Get probable value : value of output attributes of previous pemodule_projects
            level_estimation_values = Hash.new
            level_estimation_values = corresponding_est_val.send("string_data_probable")
            if level_estimation_values[pbs_project_element.id]
              begin
                res << text_field_tag("", display_value(level_estimation_values[pbs_project_element.id], corresponding_est_val, mp.id),
                                      :readonly => true, :class => "input-small #{level} #{corresponding_est_val.id}",
                                      "data-est_val_id" => corresponding_est_val.id)
              rescue
                res << "-"
              end
            else
              res << '-'
            end
          end
        res << "</td>"
      end

      # Text_field the balancing value
      balancing_attr_est_values = module_project.estimation_values.where('in_out = ? AND pe_attribute_id = ?', "input", @current_balancing_attribute)
      res << '<td>'
      balancing_attr_est_val = EstimationValue.new
      if !balancing_attr_est_values.nil? && balancing_attr_est_values.length !=0
        balancing_attr_est_val = balancing_attr_est_values.last
        level_estimation_values = Hash.new
        level_estimation_values = balancing_attr_est_val.send("string_data_low")  #balancing_attr_est_val.send("string_data_most_likely")

        if level_estimation_values[pbs_project_element.id].nil? or level_estimation_values[pbs_project_element.id].blank?
          #res << "#{text_field_tag "['low'][#{balancing_attr_est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}]",
          #                         nil,
          #                         :class => "input-small #{balancing_attr_est_val.id}",
          #                         "data-est_val_id" => balancing_attr_est_val.id}"
          res << pemodule_input("low", balancing_attr_est_val, module_project, level_estimation_values, pbs_project_element, attribute_type="", read_only_value=false)
        else
          #res << "#{text_field_tag "[#{balancing_attr_est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}]",
          #                         #level_estimation_values[pbs_project_element.id],
          #                         display_value(level_estimation_values[pbs_project_element.id], balancing_attr_est_val),
          #                         :class => "input-small #{balancing_attr_est_val.id}",
          #                         "data-est_val_id" => balancing_attr_est_val.id}"
          res << pemodule_input("low", balancing_attr_est_val, module_project, level_estimation_values, pbs_project_element, attribute_type="", read_only_value=false)
        end

        # As the estimation result is calculated today, we need to have
        ["high", "most_likely"].each do |level|
          res << "#{hidden_field_tag "[#{level}][#{balancing_attr_est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}]",
                                 nil,
                                 :class => "input_high_most_likely",
                                 "data-est_val_id" => balancing_attr_est_val.id}"
        end
      else
        res << "-"
        # Need to create estimation_value record for the balancing attribute if it doesn't exist
      end
      res << '</td>'
      # Notes to justify value
      res << '<td>'
      res << add_attribute_notes_link(balancing_attr_est_val, pbs_project_element.id)
      res << '</td>'

      res << "</tr>"
      res << '</table>'
    end
  end


  #Display the Effort Balancing Input
  def display_effort_balancing_input(module_project, last_estimation_result)
    pbs_project_element = current_component
    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<table class='table table-condensed table-bordered'>"

      res << '<tr>
                <th></th>'
      module_project.previous.each_with_index do |est_mp, i|
        res << "<th>#{display_path([], module_project, i).reverse.join('<br>')}</th>"
      end

      module_project.estimation_values.each do |est_val|
        if (est_val.in_out == 'input' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th>"
            res << "<span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val.pe_attribute.name}</span>"
            res << "<span class='note_input_with_activities'>"
              res << add_attribute_notes_link(est_val, pbs_project_element.id)
            res << '</span>'
          res << '</th>'
        end
      end

      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        res << "<tr>
                    <td>
                      <span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>"
        res << '</td>'
        module_project.previous.each do |mp|
          level = "probable"
          #value of output attributes of previous pemodule_projects
          mp.estimation_values.select { |i| i.in_out == 'output' }.each do |est_val|
            level_estimation_values = Hash.new
            level_estimation_values = est_val.send("string_data_probable")

            res << '<td>'
            if level_estimation_values[pbs_project_element.id]
              begin
                res << text_field_tag("", level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value],
                                      :readonly => true, :class => "input-small #{level} #{est_val.id}",
                                      "data-est_val_id" => est_val.id)
              rescue
                res << text_field_tag("", level_estimation_values[pbs_project_element.id],
                                      :readonly => true, :class => "input-small #{level} #{est_val.id}",
                                      "data-est_val_id" => est_val.id)
              end
            else
              res << '-'
            end
            res << '</td>'
          end
        end

        module_project.estimation_values.select { |i| i.in_out == 'output' }.each do |est_val|
          res << '<td>'
          level_estimation_values = Hash.new
          level_estimation_values = est_val.send("string_data_most_likely")

          if level_estimation_values[pbs_project_element.id].nil? or level_estimation_values[pbs_project_element.id][wbs_project_elt.id].blank?
            res << "#{text_field_tag "[#{est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                     nil,
                                     :class => "input-small #{est_val.id}",
                                     "data-est_val_id" => est_val.id}"
          else
            res << "#{text_field_tag "[#{est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                     level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value],
                                     :class => "input-small #{est_val.id}",
                                     "data-est_val_id" => est_val.id}"
          end
          res << '</td>'
        end
        res << '</tr>'
      end
      res << '</table>'
    end
  end



  #Display the Effort Balancing Output
  def display_inputs_with_activities(module_project, last_estimation_result=nil)
    pbs_project_element = current_component
    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias)# || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<table class='table table-condensed table-bordered'>"
      res << '<tr>
                <th></th>'
      module_project.estimation_values.order('display_order ASC').each do |est_val|
        est_val_pe_attribute = est_val.pe_attribute
        est_val_in_out = est_val.in_out
        if (est_val_in_out == 'output' or est_val_in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th colspan=4><span class='attribute_tooltip' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val_pe_attribute.name}</span>"
          res << "<span class='note_input_with_activities'>"
          res << add_attribute_notes_link(est_val, pbs_project_element.id)
          res << '</span>'
          res << '</th>'
        end
      end
      res << '</tr>'

      res << '<tr><th></th>'
      ['low', '', 'most_likely', 'high'].each do |level|
        res << "<th>#{level.humanize}</th>"
      end
      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        pe_attribute_alias = nil
        level_parameter = ''
        readonly_option = false
        res << "<tr><td><span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>" ###res << "<tr><td>#{wbs_project_elt.name}</td>"

        ['low', 'most_likely', 'high'].each do |level|
          res << '<td>'
          module_project.estimation_values.where('in_out = ?', 'input').each do |est_val|
            est_val_pe_attribute = est_val.pe_attribute
            est_val_in_out = est_val.in_out
            if (est_val_in_out == 'input' and est_val.module_project.id == module_project.id)
              level_estimation_values = nil
              level_estimation_values = est_val.send("string_data_#{level}")

              # customize the single attribute entry
              # this class will only be applied on the low level, as most_likely and high values are read_only
              attribute_type = ""
              read_only_attribute_level = false
              if est_val.pe_attribute.single_entry_attribute
                if level == "low"
                  attribute_type = "single_entry_attribute"
                else  # for otheres level(most-likely, high)
                  read_only_attribute_level = true
                end
              end

              # For Wbs_Activity Complemention module, input data are from last executed module
              if module_project.pemodule.alias == 'wbs_activity_completion'
                pbs_last_result = nil
                unless last_estimation_result.nil? || last_estimation_result.empty?
                  level_last_result = last_estimation_result.send("string_data_#{level}")
                  pbs_last_result = level_last_result[pbs_project_element.id]
                end

                if pbs_last_result.nil?
                  res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                           nil,
                                           :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                           "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id, :readonly => read_only_attribute_level}"

                elsif wbs_project_elt.wbs_activity_element.nil?
                  if wbs_project_elt.is_root? || wbs_project_elt.has_children?
                    res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                             pbs_last_result[wbs_project_elt.id][:value],
                                             :readonly => true,
                                             :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                             "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                    readonly_option = true
                  else
                    # If element is not from library
                    res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                             pbs_last_result[wbs_project_elt.id].nil? ? nil : pbs_last_result[wbs_project_elt.id][:value],
                                             :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                             "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                  end
                else
                  res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                           pbs_last_result[wbs_project_elt.id][:value],
                                           :readonly => true, :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                           "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                  readonly_option = true
                end
              else
                readonly_option = wbs_project_elt.has_children? ? true : false
                nullity_condition = (level_estimation_values.nil? or level_estimation_values[pbs_project_element.id].nil? or level_estimation_values[pbs_project_element.id][wbs_project_elt.id].nil?)

                if wbs_project_elt.is_root? || wbs_project_elt.has_children?
                  res << "#{ text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                            nullity_condition ? nil : level_estimation_values[pbs_project_element.id][wbs_project_elt.id],
                                            :readonly => readonly_option || read_only_attribute_level,
                                            :class => "input-small #{level}  #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                            "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id }"
                else
                  res << "#{ text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                            nullity_condition ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id][wbs_project_elt.id],
                                            :readonly => readonly_option || read_only_attribute_level,
                                            :class => "input-small #{level}  #{est_val.id} #{wbs_project_elt.id} #{attribute_type}",
                                            "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id }"
                end
              end

            end
            pe_attribute_alias = est_val_pe_attribute.alias
          end
          res << '</td>'

          if level == 'low'
            #Available to copy value
            input_id = "_#{pe_attribute_alias}_#{module_project.id}_#{wbs_project_elt.id}"
            res << '<td>'
            unless readonly_option
              res << "<span id='#{input_id}' class='copyLib icon  icon-chevron-right' data-effort_input_id='#{input_id}' title='Copy value in other fields' onblur='this.style.cursor='default''></span>"
            end
            res << '</td>'
          end
        end
        res << '</tr>'
      end
      res << '</table>'
    end
    res
  end


  # Display th inputs parameters view
  def display_inputs_without_activities(module_project)
    pbs_project_element = current_component
    res = String.new

    if module_project.compatible_with(current_component.work_element_type.alias) || current_component

      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<table class='table table-condensed table-bordered'>
                      <tr>
                        <th></th>"
      ['low', '', 'most_likely', 'high', ''].each do |level|
        res << "<th>#{level.humanize}</th>"
      end
      res << '</tr>'
      module_project.estimation_values.order('display_order ASC').each do |est_val|
        est_val_pe_attribute = est_val.pe_attribute
        est_val_in_out = est_val.in_out
        if (est_val_in_out == 'input' or est_val_in_out == 'both') and (est_val.module_project.id == module_project.id) and est_val_pe_attribute
          res << '<tr>'
          res << "<td><span class='attribute_tooltip tree_element_in_out' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}'>#{est_val_pe_attribute.name}</span></td>"
          level_estimation_values = Hash.new

          ['low', 'most_likely', 'high'].each do |level|
            attribute_type = ""
            read_only_attribute = false
            disable_attribute_level = false
            # customize the single attribute entry
            # this class will only be applied on the low level, as most_likely and high values are read_only
            if est_val.pe_attribute.single_entry_attribute
              if level == "low"
                attribute_type = "single_entry_attribute"
              else
                read_only_attribute = true
                disable_attribute_level = true
              end
            end

            level_estimation_values = est_val.send("string_data_#{level}")
            res << "<td>#{pemodule_input(level, est_val, module_project, level_estimation_values, pbs_project_element, attribute_type, read_only_attribute)}</td>"
            if level == 'low'
              input_id = "_#{est_val_pe_attribute.alias}_#{module_project.id}"
              res << "<td>"
              res << "<span id='#{input_id}' class='copyLib icon  icon-chevron-right' data-effort_input_id='#{input_id}' title='Copy value in other fields' onblur='this.style.cursor='default''></span>"
              res << '</td>'
            end
          end

          # Add link to add attribute Note to justify each estimation attribute
          res << '<td>'
          res << add_attribute_notes_link(est_val, pbs_project_element.id)
          res << '</td>'
          res << '</td>'
        end
        res << '</tr>'
      end
      res << '</table>'

    end
    res
  end

  def pemodule_input(level, est_val, module_project, level_estimation_values, pbs_project_element, attribute_type="", read_only_value=false)

    est_val_pe_attribute = est_val.pe_attribute
    if est_val_pe_attribute.attr_type == 'integer' or est_val_pe_attribute.attr_type == 'float'

      display_text_field_tag(level, est_val, module_project, level_estimation_values, pbs_project_element, attribute_type, read_only_value)

    elsif est_val_pe_attribute.attr_type == 'list'

      select_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                 options_for_select(
                     est_val_pe_attribute.options[2].split(';'),
                     :selected => (level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id])),
                 :class => "input-small #{level} #{est_val.id} #{attribute_type}",
                 :prompt => "Unset",
                 "data-est_val_id" => est_val.id,
                 "data-module_project_id" => module_project.id,
                 :readonly => read_only_value#, :disabled => read_only_value

    elsif est_val_pe_attribute.attr_type == 'date'

      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     level_estimation_values[pbs_project_element.id].nil? ? display_date(level_estimation_values["default_#{level}".to_sym]) : display_date(level_estimation_values[pbs_project_element.id]),
                     :class => "input-small #{level} #{est_val.id} date-picker #{attribute_type}",
                     "data-est_val_id" => est_val.id,
                     "data-module_project_id" => module_project.id,
                     :readonly => read_only_value

    else #type = text

      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     (level_estimation_values[pbs_project_element.id].nil?) ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id],
                     :class => "input-small #{level} #{est_val.id} #{attribute_type}",
                     "data-est_val_id" => est_val.id,
                     "data-module_project_id" => module_project.id,
                     :readonly => read_only_value
    end
  end


  def display_value(value, est_val, mp_id)
    module_project = ModuleProject.find(mp_id)
    est_val_pe_attribute = est_val.pe_attribute
    precision = est_val_pe_attribute.precision.nil? ? user_number_precision : est_val_pe_attribute.precision

    if est_val_pe_attribute.alias == "retained_size" || est_val_pe_attribute.alias == "theorical_size"
      if module_project.pemodule.alias == "ge"
        ge_model = module_project.ge_model
        effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
        size_unit = ge_model.output_size_unit
        if est_val.in_out == "input"
          effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
          size_unit = ge_model.input_size_unit
        end

        "#{convert_with_standard_unit_coefficient(est_val, value.to_f, effort_standard_unit_coefficient, precision)} #{size_unit}"
      else
        "#{convert_with_precision(value.to_f, precision, true)} #{module_project.size}"
      end

    elsif est_val_pe_attribute.alias == "effort"
      if module_project.pemodule.alias == "ge"
        ge_model = module_project.ge_model
        effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
        effort_unit = ge_model.output_effort_unit

        if est_val.in_out == "input"
          effort_standard_unit_coefficient = ge_model.input_effort_standard_unit_coefficient
          effort_unit = ge_model.input_effort_unit
        end

        "#{convert_with_standard_unit_coefficient(est_val, value, effort_standard_unit_coefficient, precision)} #{effort_unit}"
      else
        "#{convert_with_precision(convert(value, @project.organization), precision, true)} #{convert_label(value, @project.organization)}"
      end

    elsif est_val_pe_attribute.alias == "staffing" || est_val_pe_attribute.alias == "duration"
      "#{convert_with_precision(value, precision, true)}"
    elsif est_val_pe_attribute.alias == "cost"
      unless value.class == Hash
        "#{convert_with_precision(value, 2, true)} #{get_attribute_unit(est_val_pe_attribute)}"
        end
    elsif est_val_pe_attribute.alias == "remaining_defects" || est_val_pe_attribute.alias == "introduced_defects"
      unless value.class == Hash
        "#{convert_with_precision(value, 2, true)}"
      end
    else
      case est_val_pe_attribute
        when 'date'
          display_date(value)
        when 'float'
          "#{ convert_with_precision(convert(value, @project.organization), precision, true) } #{convert_label(value, @project.organization)}"
        when 'integer'
          "#{convert(value, @project.organization).round(precision)} #{convert_label(value, @project.organization)}"
        else
          value
      end
    end
  end

  #Display a date depending user time zone
  def display_date(date)
    begin
      I18n.l(date.to_date)
    rescue
      date
    end
  end

  #Display text field tag depending of estimation plan.
  #Some pemodules can take previous and computed values
  # attribute_type parameter will be aqual to "single_attribute_entry" if single_attribute_entry
  def display_text_field_tag(level, est_val, module_project, level_estimation_values, pbs_project_element, attribute_type="", read_only_value=false)

    est_val_pe_attribute = est_val.pe_attribute
    organization = module_project.project.organization
    precision = est_val_pe_attribute.precision.nil? ? user_number_precision : est_val_pe_attribute.precision
    res = []

    read_only_value = false
    if module_project.previous.empty? || !est_val["string_data_#{level}"][pbs_project_element.id].nil?
      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     convert(level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id], organization),
                     :class => "input-small #{level} #{est_val.id} #{attribute_type}",
                     "data-est_val_id" => est_val.id,
                     "data-module_project_id" => module_project.id,
                     :readonly => read_only_value
    else
      comm_attr = ModuleProject::common_attributes(module_project.previous.first, module_project)
      if comm_attr.empty?
        text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                       convert((level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id]), organization).to_f.round(precision),
                       :class => "input-small #{level} #{est_val.id} #{attribute_type}",
                       "data-est_val_id" => est_val.id,
                       "data-module_project_id" => module_project.id,
                       :readonly => read_only_value
      else
        estimation_value = EstimationValue.where(:pe_attribute_id => comm_attr.first.id,
                                                 :module_project_id => module_project.previous.first.id,
                                                 :in_out => "output").first
        new_level_estimation_values = estimation_value.send("string_data_#{level}")
        text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                       convert(new_level_estimation_values[pbs_project_element.id], organization).to_f.round(precision),
                       :class => "input-small #{level} #{est_val.id} #{attribute_type}",
                       "data-est_val_id" => est_val.id,
                       "data-module_project_id" => module_project.id,
                       :readonly => read_only_value
      end
    end
  end

  #Display rule and options of an attribute in a bootstrap tooltip
  def display_rule(est_val)
    "<br> #{I18n.t(:tooltip_attribute_rules)}: <strong>#{est_val.pe_attribute.options.join(' ')} </strong> <br> #{est_val.is_mandatory ? I18n.t(:mandatory) : I18n.t(:no_mandatory) }"
  end

  #Display Security_Level Description in a bootstrap tooltip
  def display_security_level_description(security_level)
    "#{security_level.description}"
  end

  def display_path(res, mp, i)
    if mp.previous[i].nil?
      res << ([mp] + mp.previous).flatten.reverse.join('<br>')
    else
      display_path(res, mp.previous[i], i)
    end
    res
  end

  def send_notice(project)
    #if project.state == "in_progress"
    #  I18n.t(:warning_project_state_to_checkpoint, :value_b => 'RELEASED')
    #elsif project.state == "in_review"
    #  I18n.t(:warning_project_state_to_released, :value_b => 'RELEASED')
    #end
  end

  #Helper method that build project history graph
  def build_project_history_graph
    #Project.arrange_as_array.each{|n| "#{'-' * n.depth} #{n.version}" }
    Project.arrange_as_json.each do |n|
      project = Project.find(n[:id])
      "#{'-' * project.depth} #{n[:title]}"
    end
  end

  def build_project_history_graph_as_array
    #Project.arrange_as_array.each{|n| "#{'-' * n.depth} #{n.version}" }
    Project.arrange_as_array.each do |n|
      "#{'-' * n.depth} #{n.title}"
    end
  end

  def build_project_history_graph_json
    proj = Project.find(304)
  end

  def helper_show_project_history
    @projects.each do |prj|
      "#{'-' * prj[0].depth} #{prj[0].title}(#{prj[0].version})"
    end
  end

  def show_project_history_graph(project)
    require 'gratr/import'
    require 'gratr/dot'

    #ObjectSpace.each_object(Module) do |m|
    #  m.ancestors.each {|a| module_graph.add_edge!(m,a) if m != a}
    #end
    project = Project.find(301)
    project_root = project.root
    project_tree = project_root.subtree

    module_graph = Digraph.new

    project_tree.each do |proj|
      #proj.parent.each {|parent| module_graph.add_edge!(parent.version, proj.version) if proj != parent} unless proj.is_root?
      module_graph.add_edge!(proj.parent.version, proj.version) unless proj.is_root?
      proj.children.each {|child| module_graph.add_edge!(proj.version, child.version) if proj != child}
    end

    gv = module_graph.vertices.select {|v| v.to_s.match(/GRATR/)}
    #module_graph.induced_subgraph(gv).write_to_graphic_file('jpg','module_graph_project')
    module_graph.write_to_graphic_file('jpg','graph_project_history')
  end


  # Authorizations based on estimations's statuses roles
  # Estimation status Role by groups
  # The possible project_permission_action_alias = ("see_project", "show_project", "edit_project", "delete_project")
  def can_do_action_on_estimation?(estimation, project_permission_action_alias)
    can_do_something = false

    # SuperAdmin user or those who has all permissions has all rights
    if current_user.super_admin? || can?(:manage, :all)
      can_do_something = true
    else
      #begin
        permission_to_show_project = ProjectSecurityLevel.find_by_alias(project_permission_action_alias)
        ###if can?(:show_project, estimation)
        #if can?(:see_project, estimation)
          # if at least one of the current_user's groups is in the estimation's organization groups
          groups_intersection = current_user.groups.all & estimation.organization.groups
          unless groups_intersection.nil?
            groups_intersection.each do |group|
              if estimation.estimation_status.estimation_status_group_roles.where(group_id: group.id).map(&:project_security_level_id).include?(permission_to_show_project.id)
                can_do_something = true
                break if can_do_something
              end
            end
          end
        #end
      #rescue
      #  false
      #end
    end

    can_do_something
  end

  # Got the right to see the estimation from estimations list
  def can_see_estimation?(estimation)
    #authorization =  can_do_action_on_estimation?(estimation, "see_project")# || can_do_action_on_estimation?(estimation, "show_project") || can_do_action_on_estimation?(estimation, "edit_project")
    #authorization &&
    can?(:see_project, estimation, estimation_status_id: estimation.estimation_status_id)
  end

  # Got the right to show the estimation details
  def can_show_estimation?(estimation)
    #authorization = can_do_action_on_estimation?(estimation, "show_project")# || can_do_action_on_estimation?(estimation, "edit_project")
    #authorization &&
    can?(:show_project, estimation)
  end

  # Got the right to edit and modify the estimation details
  def can_modify_estimation?(estimation)
    #authorization = can_do_action_on_estimation?(estimation, "edit_project")
    #authorization &&
    can?(:edit_project, estimation)
  end

  # Got the right to Alter and modify only some parts of the estimation details if user has the rights to edit the project in its status
  def can_alter_estimation?(estimation)
    can?(:show_project, estimation)# && can_do_action_on_estimation?(estimation, "edit_project")
    #can?(:show_project, estimation, estimation_status_id: estimation.estimation_status_id)
  end

  # Got the right to delete the estimation
  def can_delete_estimation?(estimation)
    #authorization = can_do_action_on_estimation?(estimation, "delete_project")
    #authorization &&
    can?(:delete_project, estimation)
  end

end
