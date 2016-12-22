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
##############################################################################

require 'effort_breakdown/version'
require "dentaku"


module EffortBreakdown

  #Effort Breakdown class
  class EffortBreakdown
    include PemoduleEstimationMethods

    #module input/output parameters
    attr_accessor :pbs_project_element, :module_project, :input_effort, :project, :ratio, :changed_mp_ratio_element_ids,
                  :changed_retained_effort_values, :changed_retained_cost_values, :module_project_ratio_elements, :initialize_calculation,
                  :theoretical_effort, :retained_effort, :theoretical_cost, :retained_cost

    #def initialize(c, mp, e, r)
    def initialize(*args)
      #puts "INPUT_DATA = #{module_input_data}"   for ex. : INPUT_DATA = {:effort=>"10", :pbs_project_element_id=>271, :module_project_id=>265}
      @pbs_project_element = args[0]
      @module_project = args[1]
      @project = @module_project.project
      @ratio = args[3]
      args[2].nil? ? @input_effort = nil : @input_effort = args[2]
      @changed_mp_ratio_element_ids = args[4]      # mp_ratio_element_ids dont l'effort retenu a été modifié manuellement
      @changed_retained_effort_values = args[5]    # valeurs des efforts retenus (modifiés ou non)
      @changed_retained_cost_values = args[6]    # valeurs des coûts retenus (modifiés ou non)
      @initialize_calculation = args[7]
      @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@ratio, @pbs_project_element, false)

      # Output results
      @theoretical_effort = HashWithIndifferentAccess.new
      @retained_effort = HashWithIndifferentAccess.new
      @theoretical_cost = HashWithIndifferentAccess.new
      @retained_cost = HashWithIndifferentAccess.new
    end

    # Getters for module outputs

    def input_effort
      @input_effort
    end

    def input_effort=(new_effort)
      @input_effort = new_effort
    end

    def theoretical_effort
      @theoretical_effort
    end

    def retained_effort
      @retained_effort
    end

    def theoretical_cost
      @theoretical_cost
    end

    def retained_cost
      @retained_cost
    end


    def changed_retained_effort_values=(retained_effort_values)
      @changed_retained_effort_values = retained_effort_values
    end

    def changed_retained_cost_values=(retained_cost_values)
      @changed_retained_cost_values = retained_cost_values
    end


    def calculate_estimations
      @theoretical_effort = get_theoretical_effort
      @retained_effort = get_effort

      @theoretical_cost = get_theoretical_cost
      @retained_cost = get_cost

      theoretical_effort, theoretical_cost, retained_effort,retained_effort = [@theoretical_effort, @theoretical_cost, @retained_effort, @retained_cost]
    end


    # Calculate each Wbs activity effort according to Ratio and Reference_Value and PBS effort
    def get_effort(*args)
      # First build cache_depth
      WbsActivityElement.rebuild_depth_cache!

      efforts_man_month = nil
      if @initialize_calculation == true
        efforts_man_month = get_effort_with_module_project_ratio_elements_with_formula  ###get_effort_with_activities_elements
      else
        #some retained effort values have manuelly changed
        efforts_man_month = get_effort_with_module_project_ratio_elements_with_formula_and_changed_retained_effort_values  ###get_effort_with_activities_elements
      end

      efforts_man_month
    end


    def get_theoretical_effort(*args)
      # First build cache_depth
      WbsActivityElement.rebuild_depth_cache!

      efforts_man_month = nil
      efforts_man_month = get_effort_with_module_project_ratio_elements_with_formula  ###get_effort_with_activities_elements

      efforts_man_month
    end


    # Proc that calculate each profile cost
    calculate_warp_profile_cost = Proc.new do |element|
      tmp = Hash.new
      wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: key).first
      unless wbs_activity_ratio_element.nil?
        wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
          tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * value * warp.ratio_value.to_f / 100
        end
      end
      tmp
    end  # end Proc


    # Calculate the Cost for each WBS-Project-Element/Phase
    # Cout Moyen
    def get_cost(*args)
      cost = Hash.new {|h,k| h[k]=[]}
      output_cost = Hash.new

      wbs_activity = @module_project.wbs_activity
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      efforts_man_month = @retained_effort
      if efforts_man_month.empty?
        efforts_man_month = get_effort
      end

      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |element|
          key = element.id   # wbs_activity_element_id
          value = efforts_man_month[key].to_f

          mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

          if mp_ratio_element && mp_ratio_element.wbs_activity_ratio_element.is_modifiable && @changed_retained_cost_values[element.id].to_f != 0
            output_cost[element.id] = @changed_retained_cost_values[element.id].to_f
          else
            if element.is_childless? || element.has_new_complement_child?
              # Calculate cost for each profile
              tmp = Hash.new
              wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: key).first
              unless wbs_activity_ratio_element.nil?
                wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                  tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * value * warp.ratio_value.to_f / 100
                end
              end

              tmp.each do |k, v|
                cost[key] << tmp[k]
              end

              output_cost[key] = cost[key].sum
            else
              output_cost[key] = compact_array_and_compute_node_value(element, output_cost)
            end
          end
        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_cost[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_cost)

      output_cost
    end


    def get_theoretical_cost(*args)
      cost = Hash.new {|h,k| h[k]=[]}
      output_cost = Hash.new

      wbs_activity = @module_project.wbs_activity

      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      efforts_man_month = @theoretical_effort
      if efforts_man_month.empty?
        efforts_man_month = get_theoretical_effort
      end

      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |element|
          key = element.id
          value = efforts_man_month[key]

          if element.is_childless? || element.has_new_complement_child?
            # Calculate cost for each profile
            tmp = Hash.new
            wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: key).first
            unless wbs_activity_ratio_element.nil?
              wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
                tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * efforts_man_month[key].to_f * warp.ratio_value.to_f / 100
              end
            end

            tmp.each do |k, v|
              cost[key] << tmp[k]
            end

            output_cost[key] = cost[key].sum
          else
            output_cost[key] = compact_array_and_compute_node_value(element, output_cost)
          end

        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_cost[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_cost)

      output_cost
    end


    # Get the costs by profile
    def get_cost_by_profile(efforts_man_month)

      efforts_man_month.each do |key, value|
        tmp = Hash.new
        wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio_reference.id, wbs_activity_element_id: key).first
        unless wbs_activity_ratio_element.nil?
          wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
            tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * (efforts_man_month[key].to_f * @wbs_activity.effort_unit_coefficient.to_f) * (warp.ratio_value.to_f / 100)
          end
        end
        res[key] = tmp

        current_activity_element = WbsActivityElement.find(key)
        if current_activity_element.root?
          res[key] = tmp.values.sum
        else
          res[key] = tmp
        end
      end
    end


    def get_theoretical_cost_save(*args)
      cost = Hash.new {|h,k| h[k]=[]}
      res = Hash.new

      wbs_activity = @module_project.wbs_activity

      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      efforts_man_month = get_effort
      efforts_man_month.each do |key, value|
        tmp = Hash.new
        wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: key).first
        unless wbs_activity_ratio_element.nil?
          wbs_activity_ratio_element.wbs_activity_ratio_profiles.each do |warp|
            tmp[warp.organization_profile.id] = warp.organization_profile.cost_per_hour.to_f * efforts_man_month[key].to_f * warp.ratio_value / 100
          end
        end

        tmp.each do |k, v|
          cost[key] << tmp[k]
        end

        cost.each do |k, v|
          if WbsActivityElement.find(key).root?
            res[key] = cost.values.sum.sum
          else
            res[key] = cost[k].sum
          end
        end
      end

      res
    end


    ####################   TEST  #################

    # Use the changed retained effort values before reexcuting
    # get_effort_with_module_project_ratio_elements_with_formula_and_changed_retained_effort
    def get_effort_with_module_project_ratio_elements_with_formula_and_changed_retained_effort_values

      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      wbs_activity = @module_project.wbs_activity

      # Get the wbs_activity_element which contain the wbs_activity_ratio
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      #Get the referenced wbs_activity_elt of the @ratio
      referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', @ratio.id, true)
      # If there is no referenced elements, all elements will be consider as references
      if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
        referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', @ratio.id)
      end

      output_effort = Hash.new

      current_output_effort = @input_effort
      calculator = Dentaku::Calculator.new

      # Calculate the module_project_ratio_variable value_percentage
      mp_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio.id)
      mp_ratio_variables.each do |mp_var|

        # Store the ratio_variables value in the calculator
        calculator.store(:"#{mp_var.name.downcase}" => mp_var.value_from_percentage)

        # wbs_ratio_variable  = mp_var.wbs_activity_ratio_variable
        # percentage_of_input = wbs_ratio_variable.percentage_of_input
        # if wbs_ratio_variable.is_modifiable
        #   percentage_of_input = mp_var.percentage_of_input
        # end
        #
        # # calculate value from percentage of input
        # if current_output_effort.nil? || percentage_of_input.blank?
        #   mp_var.update_attribute(:value_from_percentage, nil)
        # else
        #   value_from_percentage = calculator.evaluate("#{current_output_effort.to_f} * #{percentage_of_input}")
        #   mp_var.update_attribute(:value_from_percentage, value_from_percentage)
        #
        #   # Store the ratio_variables value in the calculator
        #   calculator.store(:"#{mp_var.name}" => value_from_percentage)
        # end

      end


      # get retained values in calculations with wbs_activity_element_id
      changed_wbs_activity_element_ids = []
      @changed_mp_ratio_element_ids.each do |changed_value_id|
        mp_ratio_element = ModuleProjectRatioElement.find(changed_value_id)
        wbs_activity_element = mp_ratio_element.wbs_activity_element
        wbs_activity_element_id = wbs_activity_element.id

        ####element_effort = @changed_retained_effort_values["#{changed_value_id}"].to_f
        element_effort = @changed_retained_effort_values[wbs_activity_element_id].to_f
        output_effort[wbs_activity_element_id] = element_effort.to_f

        changed_wbs_activity_element_ids << wbs_activity_element_id

        # Add element short_name in calculator
        element_phase_short_name = wbs_activity_element.phase_short_name
        unless element_phase_short_name.nil?
          if mp_ratio_element.selected == true
            calculator.store(:"#{element_phase_short_name.downcase}" => element_effort)
          else
            calculator.store(:"#{element_phase_short_name.downcase}" => 0.0)
          end
        end
      end

      # need to compute all formula after reordering the dependencies
      all_formula_to_compute = Hash.new
      output_effort_with_dependencies = HashWithIndifferentAccess.new
      parents_to_compute_after = Array.new

      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |element|

          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless element.nil? ####|| element.id.in?(referenced_ratio_activity_element_ids)

            # Sauf si la valeur de l'élément n'est pas pas encore enregistrée ou que les valeurs retenues ne sont pas à prendre en compte
            if output_effort[element.id].nil?

              mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first

                unless corresponding_ratio_elt.nil?
                  formula = corresponding_ratio_elt.formula
                  if current_output_effort.nil? || formula.blank?
                    output_effort[element.id] = nil
                  else
                    formula_expression = "#{formula.downcase}"
                    begin
                      normalized_formula_expression = formula_expression.gsub('%', ' * 0.01 ')
                    rescue
                      normalized_formula_expression = nil
                    end

                    ####element_effort = calculator.evaluate(normalized_formula_expression)
                    ####output_effort[element.id] = element_effort
                    ####all_formula_to_compute[:"#{element.id}"] = normalized_formula_expression

                    # Add element short_name in calculator
                    element_phase_short_name = element.phase_short_name.downcase
                    unless element_phase_short_name.nil?
                      if mp_ratio_element.selected == true
                        all_formula_to_compute[:"#{element_phase_short_name}"] = normalized_formula_expression
                      else
                        all_formula_to_compute[:"#{element.id}"] = normalized_formula_expression
                        calculator.store(:"#{element_phase_short_name}" => 0.0)
                      end
                    end
                  end

                end
              else
                parent_element_formula = ""
                element.children.each do |child|
                  child_mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: child.id).first
                  if child_mp_ratio_element && child_mp_ratio_element.selected == true
                    if parent_element_formula.blank?
                      parent_element_formula = "#{child_mp_ratio_element.wbs_activity_element.phase_short_name.downcase}"
                    else
                      parent_element_formula += "+ #{child_mp_ratio_element.wbs_activity_element.phase_short_name.downcase}"
                    end
                  end
                end
                all_formula_to_compute[:"#{element.phase_short_name.downcase}"] = parent_element_formula

                ####output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
                #### add element ID in the parents elements to compute
                ###parents_to_compute_after << element.id
              end

            end
          end
        end
      end

      ### Then compute all formula expression
      output_effort_with_dependencies = calculator.solve(all_formula_to_compute)

      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |element|
          if output_effort[element.id].nil?
            mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first
            current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.phase_short_name.downcase}"]
            if !mp_ratio_element.selected == true
              current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.id}"]
            end

            if mp_ratio_element && mp_ratio_element.wbs_activity_ratio_element.is_modifiable
              if @changed_retained_effort_values[element.id].nil? || @changed_retained_effort_values[element.id].to_f == 0
                output_effort[element.id] = current_effort_with_dependencies ###output_effort_with_dependencies[:"#{element.phase_short_name}"]
              else
                output_effort[element.id] = @changed_retained_effort_values[element.id].to_f
              end
            else
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                output_effort[element.id] = current_effort_with_dependencies ###output_effort_with_dependencies[:"#{element.phase_short_name}"]
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end
      end


      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)


      # Global output efforts
      # if @changed_mp_ratio_element_ids.nil? || @changed_mp_ratio_element_ids.empty?
      #   output_effort = calculate_formula_expression(current_output_effort, wbs_activity_root, @ratio, @changed_mp_ratio_element_ids, calculator)
      # else
      #   output_effort = calculate_formula_expression(current_output_effort, wbs_activity_root, @ratio, @changed_mp_ratio_element_ids, calculator, output_effort)
      # end


      output_effort

    end




    def calculate_formula_expression(current_input_effort, wbs_activity_root, ratio, changed_mp_ratio_element_ids, calculator, output_effort={} )

      formula_output_effort_to_compute = Hash.new

      wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |element|
          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless element.nil? ####|| element.id.in?(referenced_ratio_activity_element_ids)

            # Sauf si la valeur de l'élément n'est pas pas encore enregistrée ou que les valeurs retenues ne sont pas à prendre en compte
            #if output_effort[element.id].nil?
            if output_effort[element.id].nil? ###&& !@changed_mp_ratio_element_ids.nil? && !@changed_mp_ratio_element_ids.empty?) || @changed_mp_ratio_element_ids.nil? || @changed_mp_ratio_element_ids.empty?
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio.id, element.id).first

                unless corresponding_ratio_elt.nil?

                  formula = corresponding_ratio_elt.formula

                  if current_input_effort.nil? || formula.blank?
                    output_effort[element.id] = nil
                  else
                    formula_expression = "#{formula.downcase}"
                    begin
                      normalized_formula_expression = formula_expression.gsub('%', ' * 0.01')
                    rescue
                      normalized_formula_expression = nil
                    end

                    formula_dependencies = calculator.calc.dependencies(normalized_formula_expression)
                    if formula_dependencies.empty?
                      element_effort = calculator.evaluate(normalized_formula_expression)
                      output_effort[element.id] = element_effort

                      # Add element short_name in calculator
                      element_phase_short_name = element.phase_short_name
                      unless element_phase_short_name.nil?
                        calculator.store(:"#{element_phase_short_name}" => element_effort)
                      end
                    else
                      # Save formula to be compute after
                      formula_output_effort_to_compute[element.id] = normalized_formula_expression
                    end

                  end
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end

            end
          end
        end

      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)

      output_effort

    end



    ####################  FIN TEST  #################


    # Use module_project_ratio_element FORMULA
    # Calculate the WBS-Activity effort according to the selected value as ratio and the Module-Project Ratio-Elements
    def get_effort_with_module_project_ratio_elements_with_formula

        #project on which estimation is
        project = @module_project.project

        # Project pe_wbs_activity
        wbs_activity = @module_project.wbs_activity

        # Get the wbs_activity_element which contain the wbs_activity_ratio
        wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

        #Get the referenced wbs_activity_elt of the @ratio
        referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', @ratio.id, true)
        # If there is no referenced elements, all elements will be consider as references
        if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
          referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', @ratio.id)
        end

        output_effort = Hash.new


        current_output_effort = @input_effort
        calculator = Dentaku::Calculator.new

        # Calculate the module_project_ratio_variable value_percentage
        mp_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio.id)
        mp_ratio_variables.each do |mp_var|

          # Store the ratio_variables value in the calculator
          calculator.store(:"#{mp_var.name.downcase}" => mp_var.value_from_percentage.to_f)

          # wbs_ratio_variable  = mp_var.wbs_activity_ratio_variable
          # percentage_of_input = wbs_ratio_variable.percentage_of_input
          # if wbs_ratio_variable.is_modifiable
          #   percentage_of_input = mp_var.percentage_of_input
          # end
          #
          # # calculate value from percentage of input
          # if current_output_effort.nil? || percentage_of_input.blank?
          #   mp_var.update_attribute(:value_from_percentage, nil)
          # else
          #   value_from_percentage = calculator.evaluate("#{current_output_effort.to_f} * #{percentage_of_input}")
          #   mp_var.update_attribute(:value_from_percentage, value_from_percentage)
          #
          #   # Store the ratio_variables value in the calculator
          #   calculator.store(:"#{mp_var.name}" => value_from_percentage)
          # end

        end

        # need to compute all formula after reordering the dependencies
        all_formula_to_compute = Hash.new
        parents_to_compute_after = Array.new

        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|

            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil? ####|| element.id.in?(referenced_ratio_activity_element_ids)
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first

                unless corresponding_ratio_elt.nil?
                  formula = corresponding_ratio_elt.formula

                  if current_output_effort.nil? || formula.blank?
                    output_effort[element.id] = nil
                  else
                    formula_expression = "#{formula.downcase}"
                    begin
                      normalized_formula_expression = formula_expression.gsub('%', ' * 0.01 ')
                    rescue
                      normalized_formula_expression = nil
                    end

                    ####element_effort = calculator.evaluate(normalized_formula_expression)
                    ####output_effort[element.id] = element_effort

                    ####all_formula_to_compute[:"#{element.id}"] = normalized_formula_expression

                    # Add element short_name in calculator
                    element_phase_short_name = element.phase_short_name.downcase
                    unless element_phase_short_name.nil?
                      ####calculator.store(:"#{element_phase_short_name}" => element_effort)
                      if mp_ratio_element.selected == true
                        all_formula_to_compute[:"#{element_phase_short_name.downcase}"] = normalized_formula_expression
                      else
                        all_formula_to_compute[:"#{element.id}"] = normalized_formula_expression
                        calculator.store(:"#{element_phase_short_name.downcase}" => 0.0)
                      end
                    end
                  end
                end
              else

                parent_element_formula = ""
                element.children.each do |child|
                  child_mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: child.id).first
                  if child_mp_ratio_element && child_mp_ratio_element.selected == true
                    if parent_element_formula.blank?
                      parent_element_formula = "#{child_mp_ratio_element.wbs_activity_element.phase_short_name.downcase}"
                    else
                      parent_element_formula += "+ #{child_mp_ratio_element.wbs_activity_element.phase_short_name.downcase}"
                    end
                  end
                end
                all_formula_to_compute[:"#{element.phase_short_name.downcase}"] = parent_element_formula

                ####output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)

                #### add element ID in the parents elements to compute 
                ###parents_to_compute_after << element.id
              end
            end
          end
        end


        ### Then compute all formula expression
        output_effort_with_dependencies = calculator.solve(all_formula_to_compute)

        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            if output_effort[element.id].nil?
              mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first
              current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.phase_short_name.downcase}"]
              if !mp_ratio_element.selected == true
                current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.id}"]
              end

              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                output_effort[element.id] = current_effort_with_dependencies.to_f ####output_effort_with_dependencies[:"#{element.phase_short_name}"]
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

        # After treating all leaf and node elements, the root element is going to compute by aggregation
        output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)


        # Global output efforts
        ###output_effort = calculate_formula_expression(current_output_effort, wbs_activity_root, @ratio, @changed_mp_ratio_element_ids, calculator)

        output_effort
    end


    # Calculate the WBS-Activity effort according to the selected value as ratio and the Module-Project Ratio-Elements
    # Ratio references will be based on the selected reference,
    # If there is no selected reference, all Ratio elements will be consider as being a reference
    def get_effort_with_module_project_ratio_elements
      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      wbs_activity = @module_project.wbs_activity

      # Get the wbs_activity_element which contain the wbs_activity_ratio
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      #Get the referenced wbs_activity_elt of the @ratio
      ##WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', @ratio.id, true)
      module_project_ratio_elements = @module_project.module_project_ratio_elements
      referenced_ratio_elements = module_project_ratio_elements.where('wbs_activity_ratio_id =? and pbs_project_element_id = ? and multiple_references = ?', @ratio.id, @pbs_project_element.id, true)
      # If there is no referenced elements, all elements will be consider as references
      if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
        referenced_ratio_elements = module_project_ratio_elements.where('wbs_activity_ratio_id = ? and pbs_project_element_id = ?', @ratio.id, @pbs_project_element.id)
      end

      output_effort = Hash.new

      # If using base-100 percentages
      if @ratio.use_real_base_percentage == true

        #The real ratio elements percentages will be use
        referenced_values_efforts = 0.0
        referenced_ratio_activity_element_ids = []
        referenced_ratio_elements.each do |reference_value|
          wbs_activity_element_id = reference_value.wbs_activity_element_id
          referenced_ratio_activity_element_ids << wbs_activity_element_id

          current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * reference_value.ratio_value.to_f / 100)
          output_effort[wbs_activity_element_id] = current_output_effort.to_f
          referenced_values_efforts = referenced_values_efforts + current_output_effort.to_f
        end

        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil? || element.id.in?(referenced_ratio_activity_element_ids)
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                #corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first
                corresponding_ratio_elt = module_project_ratio_elements.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ? and pbs_project_element_id = ?', @ratio.id, element.id, @pbs_project_element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = (referenced_values_efforts.to_f  * corresponding_ratio_value.to_f / 100)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      else
        # Utilise les valeurs des pourcentage en base 100
        referenced_values_efforts = 0.0
        referenced_ratio_elements.each do |reference_value|
          referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
        end

        #output_effort = Hash.new
        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil?
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = module_project_ratio_elements.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ? and pbs_project_element_id =?', @ratio.id, element.id, @pbs_project_element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * corresponding_ratio_value.to_f / referenced_values_efforts)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)

      # Global output efforts
      output_effort
    end


    # Calculate the WBS-Activity effort according to the selected value as ratio
    # Ratio references will be based on the selected reference,
    # If there is no selected reference, all Ratio elements will be consider as being a reference
    def get_effort_with_activities_elements
      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      wbs_activity = @module_project.wbs_activity

      # Get the wbs_activity_element which contain the wbs_activity_ratio
      wbs_activity_root = wbs_activity.wbs_activity_elements.first.root

      #Get the referenced wbs_activity_elt of the @ratio
      referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', @ratio.id, true)
      # If there is no referenced elements, all elements will be consider as references
      if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
        referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', @ratio.id)
      end

      output_effort = Hash.new

      # If using base-100 percentages
      if @ratio.use_real_base_percentage == true

        #The real ratio elements percentages will be use
        referenced_values_efforts = 0.0
        referenced_ratio_activity_element_ids = []
        referenced_ratio_elements.each do |reference_value|
          wbs_activity_element_id = reference_value.wbs_activity_element_id
          referenced_ratio_activity_element_ids << wbs_activity_element_id

          current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * reference_value.ratio_value.to_f / 100)
          output_effort[wbs_activity_element_id] = current_output_effort.to_f
          referenced_values_efforts = referenced_values_efforts + current_output_effort.to_f
        end

        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil? || element.id.in?(referenced_ratio_activity_element_ids)
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = (referenced_values_efforts.to_f  * corresponding_ratio_value.to_f / 100)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      else
        # Utilise les valeurs des pourcentage en base 100
        referenced_values_efforts = 0.0
        referenced_ratio_elements.each do |reference_value|
          referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
        end

        #output_effort = Hash.new
        wbs_activity_root.children.each do |node|
          # Sort node subtree by ancestry_depth
          sorted_node_elements = node.subtree.order('ancestry_depth desc')
          sorted_node_elements.each do |element|
            # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
            unless element.nil?
              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first
                unless corresponding_ratio_elt.nil?
                  corresponding_ratio_value = corresponding_ratio_elt.ratio_value
                  current_output_effort = @input_effort.nil? ? nil : (@input_effort.to_f * corresponding_ratio_value.to_f / referenced_values_efforts)
                  output_effort[element.id] = current_output_effort
                end
              else
                output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
              end
            end
          end
        end

      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[wbs_activity_root.id] = compact_array_and_compute_node_value(wbs_activity_root, output_effort)

      # Global output efforts
      output_effort
    end

    # redefinition of the methods
    # method that compute not leaf node estimation value by aggregation
    def compact_array_and_compute_node_value(node, effort_array)
      tab = []
      node.children.map do |child|
        unless child.nil? || child.wbs_activity.nil?
          value = effort_array[child.id]

          # Test if node is selected or not ( it will be taken in account only if the node is selected)
          mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: child.id).first

          if (mp_ratio_element && mp_ratio_element.selected==true) ###|| mp_ratio_element.nil?
            if value.is_a?(Integer) || value.is_a?(Float) || value.class.superclass == Integer || value.class.superclass == Numeric  ###if value.is_a?(Integer) || value.is_a?(Float)
              tab << value
            end
          end
        end
      end

      estimation_value = nil
      unless tab.empty?
        estimation_value = tab.compact.sum
      end

      estimation_value
    end

  end
end



