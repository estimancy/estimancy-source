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
    attr_accessor :pbs_project_element, :module_project, :input_effort, :project, :ratio, :initialize_calculation,
                  :wbs_activity, :wbs_activity_root, :wbs_activity_elements, :wbs_activity_ratio, :wbs_activity_ratio_elements,
                  :tjm_per_phase, :efforts_tjm_costs_per_phase_profiles, :wbs_activity_profiles,

                  :module_project_ratio_variables, :module_project_ratio_elements,
                  :changed_mp_ratio_element_ids, :changed_retained_effort_values, :changed_retained_cost_values,
                  :theoretical_effort, :retained_effort, :theoretical_cost, :retained_cost,
                  :theoretical_effort_by_phase_profiles, :retained_effort_by_phase_profiles,
                  :theoretical_cost_by_phase_profiles, :retained_cost_by_phase_profiles

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

      # Les elements de la WBS-Activity
      @wbs_activity = @module_project.wbs_activity
      @wbs_activity_elements = wbs_activity.wbs_activity_elements
      @wbs_activity_root = @wbs_activity_elements.first.root # Get the wbs_activity_element which contain the wbs_activity_ratio
      @wbs_activity_ratio = @ratio
      @wbs_activity_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', @ratio.id)
      @wbs_activity_profiles = @wbs_activity.organization_profiles

      # Elements du module_project - execution
      @module_project_ratio_elements = @module_project.get_module_project_ratio_elements(@ratio, @pbs_project_element, false)
      @module_project_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio.id)

      # Output results
      @efforts_tjm_costs_per_phase_profiles = HashWithIndifferentAccess.new

      @wbs_activity_elements.each do |element|
        element_hash = { theoretical_effort: nil, retained_effort: nil, tjm: 0, theoretical_cost: nil, retained_cost: nil,
                         theoretical_effort_profiles: HashWithIndifferentAccess.new,
                         retained_effort_profiles: HashWithIndifferentAccess.new,
                         theoretical_cost_profiles: HashWithIndifferentAccess.new,
                         retained_cost_profiles: HashWithIndifferentAccess.new
                       }

        @wbs_activity_profiles.each do |profile|
          ['theoretical_effort_profiles', 'retained_effort_profiles', 'theoretical_cost_profiles', 'retained_cost_profiles'].each do |profile_values|
            element_hash["#{profile_values}".to_sym][profile.id] = nil
          end
        end

        @efforts_tjm_costs_per_phase_profiles[element.id] = element_hash
      end

      # Calcule des TJM par phase
      @tjm_per_phase = calculate_tjm_per_phase

      @theoretical_effort = HashWithIndifferentAccess.new
      @retained_effort = HashWithIndifferentAccess.new
      @theoretical_cost = HashWithIndifferentAccess.new
      @retained_cost = HashWithIndifferentAccess.new

      # Output results by phase profiles
      @theoretical_effort_by_phase_profiles = HashWithIndifferentAccess.new
      @retained_effort_by_phase_profiles = HashWithIndifferentAccess.new
      @theoretical_cost_by_phase_profiles = HashWithIndifferentAccess.new
      @retained_cost_by_phase_profiles = HashWithIndifferentAccess.new
    end

    ###Dentaku.enable_ast_cache!

    # Calcul le TJM par phase - servira à calculer le cout plus rapidement
    def calculate_tjm_per_phase
        tjm_per_phase = Hash.new
        
        @wbs_activity_elements.each do |element|
            if element.is_root?
              tjm_per_phase[element.id] = nil
              @efforts_tjm_costs_per_phase_profiles[element.id][:tjm] = nil
            else
              tjm_per_phase[element.id] = 0.0
              element_tjm = 0.0
              tjm_is_nil = true

              wbs_activity_ratio_element = @wbs_activity_ratio_elements.where(wbs_activity_element_id: element.id).first
              unless wbs_activity_ratio_element.nil?
                  wbs_activity_ratio_profiles = wbs_activity_ratio_element.wbs_activity_ratio_profiles
                  unless wbs_activity_ratio_profiles.nil?
                      wbs_activity_ratio_profiles.each do |warp|
                          unless warp.ratio_value.nil?
                            tjm_is_nil = false
                            element_tjm += warp.organization_profile.cost_per_hour.to_f * warp.ratio_value.to_f / 100
                          end
                      end
                      tjm_value = (tjm_is_nil == true) ? nil : element_tjm
                      tjm_per_phase[element.id] = tjm_value
                      @efforts_tjm_costs_per_phase_profiles[element.id][:tjm] = tjm_value
                  end
              end
            end
        end
        tjm_per_phase
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

      # calcul des valeurs théoriques
      get_theoretical_effort

      # Calcul des valeurs modifiées / retenues
      if @initialize_calculation != true
        get_effort
      end

      #29092017
      # @theoretical_effort = get_theoretical_effort
      # @theoretical_cost = get_theoretical_cost
      #
      # if @initialize_calculation == true
      #   @retained_effort = @theoretical_effort
      #   @retained_cost = @theoretical_cost
      # else
      #   @retained_effort = get_effort
      #   @retained_cost = get_cost
      # end



      # Calculate the Efforts and Costs per Phases Profiles
      # @theoretical_effort_by_phase_profiles = get_efforts_by_phase_profiles(@theoretical_effort)
      # @theoretical_cost_by_phase_profiles = get_costs_by_phase_profiles(@theoretical_cost)
      #
      # if @initialize_calculation == true
      #   @retained_effort_by_phase_profiles = @theoretical_effort_by_phase_profiles
      #   @retained_cost_by_phase_profiles = @theoretical_cost_by_phase_profiles
      # else
      #   @retained_effort_by_phase_profiles = get_efforts_by_phase_profiles(@retained_effort)
      #   @retained_cost_by_phase_profiles = get_costs_by_phase_profiles(@retained_cost)
      # end

      ###global_results = @efforts_tjm_costs_per_phase_profiles

      # Return all results
      #theoretical_effort, theoretical_cost, retained_effort,retained_cost, global_results, tjm_per_phase = [@theoretical_effort, @theoretical_cost, @retained_effort, @retained_cost, @efforts_tjm_costs_per_phase_profiles, @tjm_per_phase]
      { theoretical_effort: @theoretical_effort, theoretical_cost: @theoretical_cost,
        retained_effort: @retained_effort, retained_cost: @retained_cost,
        global_results: @efforts_tjm_costs_per_phase_profiles,
        tjm_per_phase: @tjm_per_phase
      }
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
      wbs_activity_ratio_element = WbsActivityRatioElement.where(wbs_activity_ratio_id: @ratio.id, wbs_activity_element_id: element.id).first
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

      efforts_man_month = @retained_effort
      if efforts_man_month.empty?
        efforts_man_month = get_effort
      end

      @wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |element|
          key = element.id   # wbs_activity_element_id
          value = efforts_man_month[key]
          mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

          if mp_ratio_element.selected != true
            output_cost[key] = nil
          else
            if mp_ratio_element && mp_ratio_element.wbs_activity_ratio_element.cost_is_modifiable
              if @changed_retained_cost_values[element.id].blank?
                output_cost[element.id] = @theoretical_cost[element.id]
              else
                output_cost[element.id] = @changed_retained_cost_values[element.id].blank? ? nil : @changed_retained_cost_values[element.id].to_f
              end
            else
              if element.is_childless? || element.has_new_complement_child?
                # Calculate cost for each profile
                tjm = @tjm_per_phase[element.id]
                output_cost[key] = (tjm.nil? || value.nil?) ? nil : (tjm * value)
              else
                output_cost[key] = compact_array_and_compute_node_value(element, output_cost)
              end
            end
          end
        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_cost[@wbs_activity_root.id] = compact_array_and_compute_node_value(@wbs_activity_root, output_cost)
      output_cost
    end


    def get_theoretical_cost(*args)
      cost = Hash.new {|h,k| h[k]=[]}
      output_cost = Hash.new

      efforts_man_month = @theoretical_effort
      if efforts_man_month.empty?
        efforts_man_month = get_theoretical_effort
      end

      @wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |element|
          key = element.id
          value = efforts_man_month[key]

          if element.is_childless? || element.has_new_complement_child?
            # Calculate cost for each profile
            tjm = @tjm_per_phase[element.id]
            output_cost[key] = (tjm.nil? || value.nil?) ? nil : (tjm * value)
          else
            output_cost[key] = compact_array_and_compute_node_value(element, output_cost)
          end

        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_cost[@wbs_activity_root.id] = compact_array_and_compute_node_value(@wbs_activity_root, output_cost)
      output_cost
    end

    # Get the theoretical or retained Effort by phases profiles
    def get_efforts_by_phase_profiles(efforts_by_phase)
    end

    # Get the theoretical or retained Cost by phases profiles
    def get_costs_by_phase_profiles(costs_by_phase)
    end


    # # Debut fonction recursive pour calcul de l'effort
    # def get_effort_and_cost_per_phase_as_subtree_SAVE(element, output_effort_from_formula, theoretical_or_retained)
    #
    #   efforts_tjm_costs = @efforts_tjm_costs_per_phase_profiles
    #
    #   if element.is_childless?
    #     begin
    #       #effort
    #       effort_value = output_effort_from_formula[:"#{element.phase_short_name.downcase}"]
    #       effort = effort_value.nil? ? nil : effort_value.to_f
    #       #cost
    #       tjm = efforts_tjm_costs[element.id][:tjm]
    #       cost = ( effort.nil? || tjm.nil? ) ? nil : (effort.to_f * tjm.to_f)
    #     rescue
    #       effort = 0
    #       cost = 0
    #     end
    #
    #   else
    #     effort = 0.0
    #     cost = 0.0
    #
    #     element.children.each do |node|
    #       # Test if node is selected or not ( it will be taken in account only if the node is selected)
    #       mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: node.id).first
    #       if (mp_ratio_element && mp_ratio_element.selected==true)
    #         child_effort, child_cost = get_effort_and_cost_per_phase_as_subtree(node, output_effort_from_formula, theoretical_or_retained)
    #
    #         effort += child_effort unless child_effort.nil?
    #         cost += child_cost unless child_cost.nil?
    #       end
    #     end
    #   end
    #
    #   efforts_tjm_costs[element.id]["#{theoretical_or_retained}_effort".to_sym] = effort
    #   efforts_tjm_costs[element.id]["#{theoretical_or_retained}_cost".to_sym] = cost
    #
    #   if theoretical_or_retained == "theoretical"
    #     efforts_tjm_costs[element.id][:retained_effort] = effort
    #     efforts_tjm_costs[element.id][:retained_cost] = cost
    #   end
    #
    #   [effort, cost]
    # end

    # get retained efforts and costs
    def get_effort_and_cost_per_phase_as_subtree(element, output_effort_from_formula, theoretical_or_retained)
      efforts_tjm_costs = @efforts_tjm_costs_per_phase_profiles
      mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first
      tjm = efforts_tjm_costs[element.id][:tjm]

      # effort value
      if mp_ratio_element.selected == true
        effort_value = output_effort_from_formula[:"#{element.phase_short_name.downcase}"]
      else
        if theoretical_or_retained == "retained"
          effort_value = nil
        else
          effort_value = output_effort_from_formula[:"#{element.id}"]
        end
      end

      # get the retained values
      if (theoretical_or_retained == "retained" && mp_ratio_element.wbs_activity_ratio_element.effort_is_modifiable)
        changed_retained_effort_value = @changed_retained_effort_values[element.id]

        #effort
        if changed_retained_effort_value.blank?
          begin
            effort = effort_value.nil? ? nil : effort_value.to_f
          rescue
            effort = 0.0
          end
        else
          effort = changed_retained_effort_value.to_f
        end

        #cost
        if (theoretical_or_retained == "retained" && mp_ratio_element.wbs_activity_ratio_element.cost_is_modifiable)
          changed_retained_cost_value =  @changed_retained_cost_values[element.id]
          if changed_retained_cost_value.blank?
            if mp_ratio_element.selected == true
              cost = @theoretical_cost[element.id]
            else
              cost = nil
            end
          else
            cost = changed_retained_cost_value.to_f
          end
        else
          cost = ( effort.nil? || tjm.nil? ) ? nil : (effort.to_f * tjm.to_f)
        end

      elsif element.is_childless?
        begin
          #effort
          effort = effort_value.nil? ? nil : effort_value.to_f

          #cost
          if (theoretical_or_retained == "retained" && mp_ratio_element.wbs_activity_ratio_element.cost_is_modifiable)
            changed_retained_cost_value =  @changed_retained_cost_values[element.id]
            if changed_retained_cost_value.blank?
              if mp_ratio_element.selected == true
                cost = @theoretical_cost[element.id]
              else
                cost = nil
              end
            else
              cost = changed_retained_cost_value.to_f
            end
          else
            cost = ( effort.nil? || tjm.nil? ) ? nil : (effort.to_f * tjm.to_f)
          end

        rescue
          effort = 0
          cost = 0
        end

      else
        effort = 0.0
        cost = 0.0
        element.children.each do |node|
          #unless node.nil? || node.wbs_activity.nil?
          # Test if node is selected or not ( it will be taken in account only if the node is selected)
          node_mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: node.id).first
          #if (mp_ratio_element && mp_ratio_element.selected == true)
          child_effort, child_cost = get_effort_and_cost_per_phase_as_subtree(node, output_effort_from_formula, theoretical_or_retained)

          # on ajoute la valeur du fils que si celui-ci est sélectionné
          if (node_mp_ratio_element && node_mp_ratio_element.selected == true)
            effort += child_effort unless child_effort.nil?
            cost += child_cost unless child_cost.nil?
          end
          #end
        end
      end

      efforts_tjm_costs[element.id]["#{theoretical_or_retained}_effort".to_sym] = effort
      efforts_tjm_costs[element.id]["#{theoretical_or_retained}_cost".to_sym] = cost

      if theoretical_or_retained == "theoretical"
        efforts_tjm_costs[element.id][:retained_effort] = effort
        efforts_tjm_costs[element.id][:retained_cost] = cost
      end

      [effort, cost]
    end


    # Use the changed retained effort values before reexcuting
    # get_effort_with_module_project_ratio_elements_with_formula_and_changed_retained_effort
    def get_effort_with_module_project_ratio_elements_with_formula_and_changed_retained_effort_values

      output_effort = Hash.new
      output_cost = Hash.new

      current_output_effort = @input_effort
      calculator = Dentaku::Calculator.new

      #store entries value
      effort_ids = PeAttribute.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten
      current_inputs_evs = @module_project.estimation_values.where(pe_attribute_id: effort_ids, in_out: "input")
      current_inputs_evs.each do |ev|
        calculator.store(:"#{ev.pe_attribute.alias.downcase}" => @input_effort["#{ev.id}"])
      end

      # Calculate the module_project_ratio_variable value_percentage
      @module_project_ratio_variables.each do |mp_var|
        # Store the ratio_variables value in the calculator
        unless mp_var.name.blank?
          calculator.store(:"#{mp_var.name.downcase}" => mp_var.value_from_percentage.to_f)
        end
      end

      # get retained values in calculations with wbs_activity_element_id
      changed_wbs_activity_element_ids = []
      @changed_mp_ratio_element_ids.each do |changed_value_id|
        mp_ratio_element = @module_project_ratio_elements.where(id: changed_value_id).first ###ModuleProjectRatioElement.find(changed_value_id)
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

      @wbs_activity_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |element|

          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless element.nil? 

            # Sauf si la valeur de l'élément n'est pas pas encore enregistrée ou que les valeurs retenues ne sont pas à prendre en compte
            if output_effort[element.id].nil?

              mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

              # Element effort is really computed only on leaf element
              if element.is_childless? || element.has_new_complement_child?
                # Get the ratio Value of current element
                corresponding_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', @ratio.id, element.id).first

                unless corresponding_ratio_elt.nil?
                  formula = corresponding_ratio_elt.formula
                  if formula.blank?
                    output_effort[element.id] = nil
                  else
                    formula_expression = "#{formula.downcase}"
                    begin
                      normalized_formula_expression = formula_expression.gsub('%', ' * 0.01 ')
                    rescue
                      normalized_formula_expression = nil
                    end

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
              end

            end
          end
        end
      end

      ### Then compute all formula expression
      #output_effort_with_dependencies = calculator.solve(all_formula_to_compute)
      begin
        output_effort_with_dependencies = calculator.solve(all_formula_to_compute)
      rescue => e
        #p e#.unbound_variables
        output_effort_with_dependencies = Hash.new
        all_formula_to_compute.each do |var, formula|
          begin
            output_effort_with_dependencies[var] = calculator.evaluate(formula)
          rescue
            output_effort_with_dependencies[var] = 0.0
          end
        end
      end

      #29092017
      # Utiliser la recursivite pour optimiser les acces et recuperer les valeurs de l'effort
      # @wbs_activity_root.children.each do |node|
      #   # Sort node subtree by ancestry_depth
      #   sorted_node_elements = node.subtree.order('ancestry_depth desc')
      #
      #   sorted_node_elements.each do |element|
      #     if output_effort[element.id].nil?
      #       mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first
      #
      #       current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.phase_short_name.downcase}"]
      #       if !mp_ratio_element.selected == true
      #         current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.id}"]
      #       end
      #
      #       if mp_ratio_element && mp_ratio_element.wbs_activity_ratio_element.effort_is_modifiable
      #         if @changed_retained_effort_values[element.id].blank?
      #           begin
      #             output_effort[element.id] = current_effort_with_dependencies.nil? ? nil : current_effort_with_dependencies.to_f
      #           rescue
      #             output_effort[element.id] = 0.0
      #           end
      #         else
      #           output_effort[element.id] = @changed_retained_effort_values[element.id].to_f
      #         end
      #       else
      #         # Element effort is really computed only on leaf element
      #         if element.is_childless? || element.has_new_complement_child?
      #           begin
      #             output_effort[element.id] = current_effort_with_dependencies.nil? ? nil : current_effort_with_dependencies.to_f
      #           rescue
      #             output_effort[element.id] = 0.0
      #           end
      #         else
      #           output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
      #         end
      #       end
      #     end
      #
      #     #calculate output_cost
      #     @efforts_tjm_costs_per_phase_profiles[element.id][:retained_effort] = output_effort[element.id]
      #   end
      # end

      #29092017
      # After treating all leaf and node elements, the root element is going to compute by aggregation
      # output_effort[@wbs_activity_root.id] = compact_array_and_compute_node_value(@wbs_activity_root, output_effort)
      # @efforts_tjm_costs_per_phase_profiles[@wbs_activity_root.id][:retained_effort] = output_effort[@wbs_activity_root.id]


      # calculate theoretical and retained effort value
      get_effort_and_cost_per_phase_as_subtree(@wbs_activity_root, output_effort_with_dependencies, "retained")

      @wbs_activity_root.subtree.each do |element|
        if output_effort[element.id].nil?
          output_effort[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:retained_effort]
        else
          @efforts_tjm_costs_per_phase_profiles[element.id][:retained_effort] = output_effort[element.id]
        end

        @retained_cost[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:retained_cost]
      end

      @retained_effort = output_effort

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

        output_effort = Hash.new

        current_output_effort = @input_effort
        calculator = Dentaku::Calculator.new

        #store entries value
        effort_ids = PeAttribute.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten
        current_inputs_evs = @module_project.estimation_values.where(pe_attribute_id: effort_ids, in_out: "input")
        current_inputs_evs.each do |ev|
          calculator.store(:"#{ev.pe_attribute.alias.downcase}" => @input_effort["#{ev.id}"])
        end

        # Calculate the module_project_ratio_variable value_percentage
        mp_ratio_variables = @module_project.module_project_ratio_variables.where(pbs_project_element_id: @pbs_project_element.id, wbs_activity_ratio_id: @ratio.id)
        mp_ratio_variables.each do |mp_var|
          unless mp_var.name.blank?
            # Store the ratio_variables value in the calculator
            calculator.store(:"#{mp_var.name.downcase}" => mp_var.value_from_percentage.to_f)
          end
        end

        # need to compute all formula after reordering the dependencies
        all_formula_to_compute = Hash.new
        parents_to_compute_after = Array.new

        @wbs_activity_root.children.each do |node|
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

                  if formula.blank? ###if current_output_effort.nil? || formula.blank?
                    output_effort[element.id] = nil
                  else
                    formula_expression = "#{formula.downcase}"
                    begin
                      normalized_formula_expression = formula_expression.gsub('%', ' * 0.01 ')
                    rescue
                      normalized_formula_expression = nil
                    end

                    # Add element short_name in calculator
                    element_phase_short_name = element.phase_short_name.downcase
                    unless element_phase_short_name.nil?
                      if mp_ratio_element.selected == true
                        all_formula_to_compute[:"#{element_phase_short_name.downcase}"] = normalized_formula_expression
                      else
                        all_formula_to_compute[:"#{element.id}"] = normalized_formula_expression
                        calculator.store(:"#{element_phase_short_name.downcase}" => 0.0)  #mettre a nil
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
              end
            end
          end
        end

        ### Then compute all formula expression
        begin
          output_effort_with_dependencies = calculator.solve(all_formula_to_compute)
        rescue => e
          #p e#.unbound_variables
          output_effort_with_dependencies = Hash.new
          all_formula_to_compute.each do |var, formula|
            begin
              output_effort_with_dependencies[var] = calculator.evaluate(formula)
            rescue
              output_effort_with_dependencies[var] = 0.0 #mettre a nil
            end
          end
        end

        # @wbs_activity_root.children.each do |node|
        #   # Sort node subtree by ancestry_depth
        #   sorted_node_elements = node.subtree.order('ancestry_depth desc')
        #   sorted_node_elements.each do |element|
        #
        #     if output_effort[element.id].nil?
        #       mp_ratio_element = @module_project_ratio_elements.where(wbs_activity_element_id: element.id).first

        #       current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.phase_short_name.downcase}"]
        #       if !mp_ratio_element.selected == true
        #         current_effort_with_dependencies = output_effort_with_dependencies[:"#{element.id}"]
        #       end
        #
        #       # Element effort is really computed only on leaf element
        #       if element.is_childless?
        #         begin
        #           output_effort[element.id] = current_effort_with_dependencies.nil? ? nil : current_effort_with_dependencies.to_f ####output_effort_with_dependencies[:"#{element.phase_short_name}"]
        #         rescue
        #           output_effort[element.id] = 0
        #         end
        #
        #       else
        #         output_effort[element.id] = compact_array_and_compute_node_value(element, output_effort)
        #       end
        #     end
        #   end
        # end

        # calculate theoretical and retained effort value
        get_effort_and_cost_per_phase_as_subtree(@wbs_activity_root, output_effort_with_dependencies, "theoretical")

        @wbs_activity_root.subtree.each do |element|
          if output_effort[element.id].nil?
            output_effort[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:theoretical_effort]
          else
            @efforts_tjm_costs_per_phase_profiles[element.id][:theoretical_effort] = output_effort[element.id]
          end

          #update theoretical_effort and retained_effort
          ###@theoretical_effort[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:theoretical_effort]
          @retained_effort[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:retained_effort]
          @theoretical_cost[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:theoretical_cost]
          @retained_cost[element.id] = @efforts_tjm_costs_per_phase_profiles[element.id][:retained_cost]
        end

        @theoretical_effort = output_effort
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

          if mp_ratio_element && mp_ratio_element.selected==true
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



