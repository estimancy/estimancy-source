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


class ModuleProject < ActiveRecord::Base

  attr_accessible :project_id, :pemodule_id, :pemodule, :position_x, :position_y,
                  :top_position, :left_position, :creation_order, :nb_input_attr,
                  :nb_output_attr, :view_id, :color, :organization_id, :show_results_view, :wbs_activity_ratio_id

  belongs_to :pemodule
  belongs_to :project, :touch => true
  belongs_to :organization
  belongs_to :organization_estimation, class_name: "OrganizationEstimation", :foreign_key => 'project_id'
  belongs_to :view, dependent: :destroy    # the current selected view

  belongs_to :guw_model, class_name: "Guw::GuwModel"
  belongs_to :ge_model, class_name: "Ge::GeModel"
  belongs_to :operation_model, class_name: "Operation::OperationModel"
  belongs_to :kb_model, class_name: "Kb::KbModel"
  belongs_to :skb_model, class_name: "Skb::SkbModel"
  belongs_to :staffing_model, class_name: "Staffing::StaffingModel"
  belongs_to :expert_judgement_instance, class_name: "ExpertJudgement::Instance"
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio

  has_many :guw_unit_of_work_groups, class_name: "Guw::GuwUnitOfWorkGroup", dependent: :destroy
  has_many :guw_unit_of_works, :through => :guw_unit_of_work_groups, class_name: "Guw::GuwUnitOfWork", dependent: :destroy
  has_many :staffing_custom_data, class_name: "Staffing::StaffingCustomDatum", dependent: :destroy

  has_many :estimation_values, :dependent => :destroy
  has_many :input_cocomos
  has_many :views_widgets, dependent: :delete_all

  has_and_belongs_to_many :pbs_project_elements

  has_many :first_module_projects, :class_name => 'AssociatedModuleProject', :foreign_key => 'module_project_id'
  has_many :associated_module_projects, :through => :first_module_projects   #predecesseurs

  has_many :second_module_projects, :class_name => 'AssociatedModuleProject', :foreign_key => 'associated_module_project_id'
  has_many :inverse_associated_module_projects, :through => :second_module_projects, :source => :module_project  # module_project sucesseurs

  has_many :wbs_activity_inputs, :dependent => :destroy
  has_many :module_project_ratio_elements, dependent: :destroy
  has_many :wbs_activity_elements, through: :module_project_ratio_elements
  has_many :module_project_ratio_variables, dependent: :destroy
  has_many :skb_inputs, class_name: "Skb::SkbInput", :dependent => :destroy
  has_many :kb_inputs, class_name: "Kb::KbInput", :dependent => :destroy

  has_many :ej_instance_estimates, class_name: "ExpertJudgement::InstanceEstimate", :dependent => :destroy
  has_many :staffing_custom_data, class_name: "Staffing::StaffingCustomDatum", :dependent => :destroy
  has_many :ge_model_factor_descriptions, class_name: "Ge::GeModelFactorDescription", dependent: :destroy

  default_scope { order('position_x ASC, position_y ASC') }

  amoeba do
    enable
    ###include_field [:estimation_values, :pbs_project_elements, :guw_unit_of_work_groups, :guw_unit_of_works, :views_widgets]
    include_association [:estimation_values, :pbs_project_elements, :guw_unit_of_work_groups, :wbs_activity_inputs]

    customize(lambda { |original_module_project, new_module_project|
      new_module_project.copy_id = original_module_project.id
      # the view will be copied
    })
  end

  #Return in a array previous modules project include self.
  def preceding
    #mps = ModuleProject.where("position_y < #{self.position_y.to_i} AND project_id = #{self.project.id}")
    mps = self.associated_module_projects
  end

  #Return in a array next modules project include self.
  def following
    #ModuleProject.where("position_y >= #{self.position_y.to_i} AND position_x = #{self.position_x.to_i} AND project_id = #{self.project.id}").all
    self.inverse_associated_module_projects
  end

  #Return in a array next modules project without self.
  def nexts
    #ModuleProject.where("position_y > #{self.position_y.to_i} AND position_x = #{self.position_x.to_i} AND project_id = #{self.project.id}").all.select{|i| i.id != self.id }
    self.inverse_associated_module_projects
  end


  def all_nexts_mp_with_links(all_nexts_mp=[], i=1)
    current_nexts = self.inverse_associated_module_projects.uniq
    all_nexts_mp << current_nexts

    unless current_nexts.blank?
      current_nexts.each do |next_mp|
        i = i + 1
        if i >= self.project.module_projects.where(organization_id: self.organization_id).size
          break
        else
          current_mp_link = next_mp.all_nexts_mp_with_links(all_nexts_mp, i)
        end
      end
    end

    all_nexts_mp.flatten.uniq.compact
  end

  #Return the inputs attributes of a module_projects
  def input_attributes
    res = Array.new
    self.estimation_values.each do |est_val|
      if est_val.in_out == 'input'
        res << est_val.pe_attribute
      end
    end
    res
  end

  #Return the outputs attributes of a module_projects
  def output_attributes
    res = Array.new
    self.estimation_values.each do |est_val|
      if est_val.in_out == 'output'
        res << est_val.pe_attribute
      end
    end
    res
  end

  #Return the common attributes (previous, next)
  def self.common_attributes(mp1, mp2)
    mp1.output_attributes & mp2.input_attributes
  end

  #Return the next pemodule with link
  def next
    # results = Array.new
    # tmp_results = self.associated_module_projects + self.inverse_associated_module_projects
    # tmp_results.each do |r|
    #   if self.nexts.map(&:id).include?(r.id)
    #     results << r
    #   end
    # end
    #results

    self.inverse_associated_module_projects
  end

  #Return the previous pemodule with link
  def previous
    # results = Array.new
    # tmp_results = self.associated_module_projects + self.inverse_associated_module_projects
    # tmp_results.each do |r|
    #   if self.preceding.map(&:id).include?(r.id)
    #     results << r
    #   end
    # end
    # results

    self.associated_module_projects
  end

  # Return all the module_project relations links (next and previous)
  def next_and_previous
    results = self.associated_module_projects + self.inverse_associated_module_projects
    results.uniq
  end

  #Return the previous module_project where their output attributes can be the input of the current module_project
  def possible_previous_mp_for_attribute(pe_attribute)
    possible_module_projects = []
    unless pe_attribute.nil?
      self.previous.each do |previous_mp|
        if previous_mp.pemodule.attribute_modules.where(:pe_attribute_id => pe_attribute.id, in_out: ["output", "both"]).length >= 1
          possible_module_projects << previous_mp
        end
      end
    end
    possible_module_projects
  end

  def links
    self.associated_module_project_ids
  end

  def compatible_with(wet_alias)
    if self.pemodule.compliant_component_type.nil?
      false
    else
      self.pemodule.compliant_component_type.include?(wet_alias)
    end
  end


  def to_s
    if self.pemodule.alias == Projestimate::Application::INITIALIZATION
      self.project.title
    elsif self.pemodule.alias == "operation"
      self.operation_model.nil? ? 'Undefined model': self.operation_model.to_s(self)
    elsif self.pemodule.alias == "ge"
      self.ge_model.nil? ? 'Undefined model': self.ge_model.to_s(self)
    elsif self.pemodule.alias == "kb"
      self.kb_model.nil? ? 'Undefined model': self.kb_model.to_s(self)
    elsif self.pemodule.alias == "skb"
      self.skb_model.nil? ? 'Undefined model': self.skb_model.to_s(self)
    elsif self.pemodule.alias == "guw"
      self.guw_model.nil? ? 'Undefined model': self.guw_model.to_s(self)
    elsif self.pemodule.alias == "staffing"
      self.staffing_model.nil? ? 'Undefined model': self.staffing_model.to_s(self)
    elsif self.pemodule.alias == "effort_breakdown"
      self.wbs_activity.nil? ? 'Undefined model': self.wbs_activity.to_s(self)
    elsif self.pemodule.alias == "expert_judgement"
      self.expert_judgement_instance.nil? ? 'Undefined model' : self.expert_judgement_instance.to_s(self)
    else
      "#{self.pemodule.title.humanize} (#{Projestimate::Application::ALPHABETICAL[self.position_x.to_i-1]};#{self.position_y.to_i})"
    end
  end


  def module_project_name
    if self.pemodule.alias == Projestimate::Application::INITIALIZATION
      self.project.title
    elsif self.pemodule.alias == "operation"
      self.operation_model.nil? ? 'Undefined model': self.operation_model.name
    elsif self.pemodule.alias == "ge"
      self.ge_model.nil? ? 'Undefined model': self.ge_model.name
    elsif self.pemodule.alias == "kb"
      self.kb_model.nil? ? 'Undefined model': self.kb_model.name
    elsif self.pemodule.alias == "skb"
      self.skb_model.nil? ? 'Undefined model': self.skb_model.name
    elsif self.pemodule.alias == "guw"
      self.guw_model.nil? ? 'Undefined model': self.guw_model.name
    elsif self.pemodule.alias == "staffing"
      self.staffing_model.nil? ? 'Undefined model': self.staffing_model.name
    elsif self.pemodule.alias == "effort_breakdown"
      self.wbs_activity.nil? ? 'Undefined model': self.wbs_activity.name
    elsif self.pemodule.alias == "expert_judgement"
      self.expert_judgement_instance.nil? ? 'Undefined model' : self.expert_judgement_instance.name
    else
      "#{self.pemodule.title.humanize} (#{Projestimate::Application::ALPHABETICAL[self.position_x.to_i-1]};#{self.position_y.to_i})"
    end
  end


  def size
    module_alias = self.pemodule.alias
    if module_alias == "operation"
      self.ge_model.size_unit
    elsif module_alias == "guw"
      self.guw_model.retained_size_unit
    elsif module_alias == "expert_judgement"
      self.expert_judgement_instance.retained_size_unit
    else
      ""
    end
  end

  
  # get Wbs-Activity-Ratio when the module_project use the WBS-Activity
  def get_wbs_activity_ratio(pbs_project_element_id = nil)
    module_project = self

    if module_project.wbs_activity_ratio.nil?
      #wai = WbsActivityInput.where(module_project_id: module_project.id, wbs_activity_id: module_project.wbs_activity_id, pbs_project_element_id: pbs_project_element_id).first #.first_or_create(module_project_id: module_project.id, pbs_project_element_id: pbs_project_element_id, wbs_activity_id: module_project.wbs_activity_id, wbs_activity_ratio_id: @wbs_activity_ratio.id)
      selected_ratio = nil #wai.nil? ? nil : wai.wbs_activity_ratio
    else
      selected_ratio = module_project.wbs_activity_ratio
    end

    if selected_ratio.nil?
      selected_ratio = module_project.wbs_activity.wbs_activity_ratios.first
      unless selected_ratio.nil?
        module_project.wbs_activity_ratio_id = selected_ratio.id
        module_project.save
      end
    end

    selected_ratio
  end


  # Get the module_project ratio-elements for WBS-ACTIVITY module
  def get_module_project_ratio_elements(wbs_activity_ratio, pbs_project_element, sort_result=true)
    # Module_project Ratio elements
    current_mp = self
    unless wbs_activity_ratio.nil?
      wbs_activity = wbs_activity_ratio.wbs_activity
      organization = wbs_activity.nil? ? nil : wbs_activity.organization

      ####if  mp_ratio_elements.nil? || mp_ratio_elements.all.empty?
      #create module_project ratio elements
      wbs_activity_ratio.wbs_activity_ratio_elements.where(organization_id: organization.id, wbs_activity_id: wbs_activity.id).each do |ratio_element|
        #mp_ratio_elt = ModuleProjectRatioElement.where(pbs_project_element_id: pbs_project_element.id, module_project_id: self.id, wbs_activity_ratio_id: wbs_activity_ratio.id, wbs_activity_ratio_element_id: ratio_element.id).first
        mp_ratio_elt = ModuleProjectRatioElement.where(organization_id: organization.id,
                                                       pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id,
                                                       module_project_id: current_mp.id,
                                                       wbs_activity_id: wbs_activity.id,
                                                       wbs_activity_ratio_id: wbs_activity_ratio.id,
                                                       wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                                       wbs_activity_ratio_element_id: ratio_element.id).first


        if mp_ratio_elt.nil?
          mp_ratio_elt = ModuleProjectRatioElement.where(organization_id: organization.id,
                                                         pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id,
                                                         module_project_id: current_mp.id,
                                                         wbs_activity_ratio_id: wbs_activity_ratio.id,
                                                         wbs_activity_ratio_element_id: ratio_element.id).first

          if !mp_ratio_elt.nil?
            mp_ratio_elt.update_attributes(organization_id: organization.id,
                                           pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id,
                                           module_project_id: current_mp.id,
                                           wbs_activity_id: wbs_activity.id,
                                           wbs_activity_ratio_id: wbs_activity_ratio.id,
                                           wbs_activity_ratio_element_id: ratio_element.id,
                                           is_optional: ratio_element.is_optional,
                                           multiple_references: ratio_element.multiple_references,
                                           wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                           name: ratio_element.wbs_activity_element.name,
                                           description: ratio_element.wbs_activity_element.description,
                                           ratio_value: ratio_element.ratio_value, position: ratio_element.wbs_activity_element.position, selected: mp_ratio_elt.selected)
          else
            mp_ratio_elt = ModuleProjectRatioElement.create(organization_id: organization.id,
                                                            pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id,
                                                            module_project_id: current_mp.id,
                                                            wbs_activity_ratio_id: wbs_activity_ratio.id,
                                                            wbs_activity_id: wbs_activity.id,
                                                            wbs_activity_ratio_element_id: ratio_element.id,
                                                            is_optional: ratio_element.is_optional,
                                                            multiple_references: ratio_element.multiple_references,
                                                            wbs_activity_element_id: ratio_element.wbs_activity_element_id,
                                                            name: ratio_element.wbs_activity_element.name, description: ratio_element.wbs_activity_element.description,
                                                            ratio_value: ratio_element.ratio_value, position: ratio_element.wbs_activity_element.position, selected: true)
          end
        end

        #current_ratio_mp_ratio_elements = self.module_project_ratio_elements.where(organization_id: organization.id, pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id, wbs_activity_ratio_id: wbs_activity_ratio.id)
        current_ratio_mp_ratio_elements = ModuleProjectRatioElement.where(organization_id: organization.id,
                                                                          pbs_project_element_id: pbs_project_element.nil? ? nil : pbs_project_element.id,
                                                                          module_project_id: current_mp.id,
                                                                          wbs_activity_id: wbs_activity.id,
                                                                          wbs_activity_ratio_id: wbs_activity_ratio.id)

        activity_elt = mp_ratio_elt.wbs_activity_element
        activity_elt_ancestor_ids = activity_elt.ancestor_ids
        new_ancestor_ids_list = []
        unless activity_elt.is_root?
          activity_elt_ancestor_ids.each do |ancestor_id|
            ancestor = current_ratio_mp_ratio_elements.where(wbs_activity_element_id: ancestor_id).first
            unless ancestor.nil?
              new_ancestor_ids_list.push(ancestor.id)
            end
          end
          new_ancestry = new_ancestor_ids_list.join('/')
          mp_ratio_elt.ancestry = new_ancestry
          mp_ratio_elt.save
        end

        #end
      end

      # il faut supprimer les mp_ratio_elements dont les wsb_activity_element n'existent plus.
      wbs_activity_element_ids = wbs_activity_ratio.wbs_activity.wbs_activity_element_ids

      #mp_ratio_elements = self.module_project_ratio_elements.where(organization_id: organization.id, wbs_activity_ratio_id: wbs_activity_ratio.id, pbs_project_element_id: pbs_project_element.nil? ? nil: pbs_project_element.id)
      mp_ratio_elements = ModuleProjectRatioElement.where(organization_id: organization.id,
                                                          pbs_project_element_id: pbs_project_element.nil? ? nil: pbs_project_element.id,
                                                          module_project_id: current_mp.id,
                                                          wbs_activity_id: wbs_activity.id,
                                                          wbs_activity_ratio_id: wbs_activity_ratio.id)
      ####end

      if sort_result
        module_project_ratio_elements = ModuleProjectRatioElement.sort_by_ancestry(mp_ratio_elements.arrange(order: 'position'))
      else
        module_project_ratio_elements = mp_ratio_elements
      end

      module_project_ratio_elements
    end
  end


  # get the module_project_ratio_variable
  def get_module_project_ratio_variables(wbs_activity_ratio, pbs_project_element)
    current_mp = self
    wbs_activity = wbs_activity_ratio.wbs_activity
    organization = wbs_activity.organization
    wbs_activity_ratio_variables = wbs_activity_ratio.wbs_activity_ratio_variables.where(organization_id: organization.id)

    #module_project_ratio_variables = current_mp.module_project_ratio_variables.where(pbs_project_element_id: pbs_project_element.id, wbs_activity_ratio_id: wbs_activity_ratio.id)
    module_project_ratio_variables = ModuleProjectRatioVariable.where(organization_id: organization.id, pbs_project_element_id: pbs_project_element.id, module_project_id: current_mp.id, wbs_activity_id: wbs_activity.id, wbs_activity_ratio_id: wbs_activity_ratio.id)

    if module_project_ratio_variables.all.empty?
      if wbs_activity_ratio_variables.all.empty?
        wbs_activity_ratio_variables = wbs_activity_ratio.get_wbs_activity_ratio_variables
      end
      # create the module_project_ratio_variable
      wbs_activity_ratio_variables.each do |ratio_variable|
        ModuleProjectRatioVariable.create(organization_id: organization.id,
                                          pbs_project_element_id: pbs_project_element.id,
                                          module_project_id: current_mp.id,
                                          wbs_activity_id: wbs_activity.id,
                                          wbs_activity_ratio_id: wbs_activity_ratio.id, wbs_activity_ratio_variable_id: ratio_variable.id,
                                          name: ratio_variable.name, description: ratio_variable.description, percentage_of_input: ratio_variable.percentage_of_input,
                                          is_modifiable: ratio_variable.is_modifiable, is_used_in_ratio_calculation: ratio_variable.is_used_in_ratio_calculation)
      end
    else
      wbs_activity_ratio_variables.each do |ratio_variable|

        unless ratio_variable.name.blank?
          case ratio_variable.name.downcase
            when "rtu"
              if !ratio_variable.percentage_of_input.nil? && !ratio_variable.percentage_of_input.include?("E1") && !ratio_variable.percentage_of_input.include?("E2") &&
                 !ratio_variable.percentage_of_input.include?("E3") && !ratio_variable.percentage_of_input.include?("E4")

                ratio_variable.percentage_of_input = "E1"
                ratio_variable.save
              end
            when "test"
              if !ratio_variable.percentage_of_input.nil? && !ratio_variable.percentage_of_input.include?("E1") && !ratio_variable.percentage_of_input.include?("E2") &&
                  !ratio_variable.percentage_of_input.include?("E3") && !ratio_variable.percentage_of_input.include?("E4")

                ratio_variable.percentage_of_input = "E2"
                ratio_variable.save
              end
            else
              # type code here
          end
        end

        mp_ratio_variable = module_project_ratio_variables.where(wbs_activity_ratio_variable_id: ratio_variable.id).first
        if mp_ratio_variable
          mp_ratio_variable.update_attributes(name: ratio_variable.name, percentage_of_input: ratio_variable.percentage_of_input,
                                              description: ratio_variable.description, is_modifiable: ratio_variable.is_modifiable)
        else
          ModuleProjectRatioVariable.create(organization_id: organization.id, wbs_activity_id: wbs_activity.id,
                                            pbs_project_element_id: pbs_project_element.id, module_project_id: current_mp.id,
                                            wbs_activity_ratio_id: wbs_activity_ratio.id, wbs_activity_ratio_variable_id: ratio_variable.id,
                                            name: ratio_variable.name, description: ratio_variable.description, percentage_of_input: ratio_variable.percentage_of_input,
                                            is_modifiable: ratio_variable.is_modifiable, is_used_in_ratio_calculation: ratio_variable.is_used_in_ratio_calculation)
        end
      end
    end

    #module_project_ratio_variables = self.module_project_ratio_variables.where(organization_id: organization.id, pbs_project_element_id: pbs_project_element.id, wbs_activity_ratio_id: wbs_activity_ratio.id)
    current_mp.module_project_ratio_variables.where(organization_id: organization.id,
                                                    pbs_project_element_id: pbs_project_element.id,
                                                    module_project_id: current_mp.id,
                                                    wbs_activity_id: wbs_activity.id,
                                                    wbs_activity_ratio_id: wbs_activity_ratio.id)
  end



  # Get the Efforts Attributes (E1, E2, E3, E4) estimations values
  def get_wbs_efforts_attributes_estimation_values(wbs_activity_ratio_id, pbs_id, input_low, input_ml, input_high)
    current_mp = self
    wbs_activity_ratio = WbsActivityRatio.find(wbs_activity_ratio_id)
    wbs_activity = wbs_activity_ratio.wbs_activity
    organization = wbs_activity.organization

    wbs_effort_ids = PeAttribute.where(alias: WbsActivity::INPUT_EFFORTS_ALIAS).map(&:id).flatten
    current_inputs_evs = current_mp.estimation_values.where(organization_id: organization.id, pe_attribute_id: wbs_effort_ids, in_out: "input")

    if current_inputs_evs.empty?
      # WbsActivity::INPUT_EFFORTS_ALIAS.each_with_index do |effort_alias, index|
      #   pe_attr = PeAttribute.where(alias: effort_alias).first_or_create(name: "Effort #{index+1}", alias: effort_alias, description: "Effort #{index+1} = entrée #{index+1} = #{effort_alias}",
      #                      attr_type: "float", options: ["float", ">=", "0"])
      # end


      #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
      current_mp.pemodule.attribute_modules.each do |am|

        if am.in_out == 'both'
          ['input', 'output'].each do |in_out|
            ev = EstimationValue.where(organization_id: organization.id, :module_project_id => current_mp.id, :pe_attribute_id => am.pe_attribute.id, :in_out => in_out)
                     .first_or_create(organization_id: organization.id,
                                      :pe_attribute_id => am.pe_attribute.id,
                                         :module_project_id => current_mp.id,
                                         :in_out => in_out,
                                         :is_mandatory => am.is_mandatory,
                                         :description => am.description,
                                         :display_order => am.display_order,
                                         :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                         :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                         :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                         :custom_attribute => am.custom_attribute,
                                         :project_value => am.project_value)
          end
        else
          ev = EstimationValue.where(organization_id: organization.id, :module_project_id => current_mp.id, :pe_attribute_id => am.pe_attribute.id, :in_out => am.in_out)
                    .first_or_create(organization_id: organization.id,
                                     :pe_attribute_id => am.pe_attribute.id,
                                     :module_project_id => current_mp.id,
                                     :in_out => am.in_out,
                                     :is_mandatory => am.is_mandatory,
                                     :display_order => am.display_order,
                                     :description => am.description,
                                     :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                     :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                     :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high },
                                     :custom_attribute => am.custom_attribute,
                                     :project_value => am.project_value)
        end


        if am.pe_attribute.alias == "E1"
          ev = current_mp.estimation_values.where(organization_id: organization.id, :pe_attribute_id => am.pe_attribute.id, :in_out => "input").first
          ev[:string_data_low][pbs_id] = input_low
          ev[:string_data_most_likely][pbs_id] = input_ml
          ev[:string_data_high][pbs_id] = input_high
          ev.save

          # update Wbs-activity_ratio_variable
          if wbs_activity_ratio
            rtu_wbs_ratio_variable = wbs_activity_ratio.wbs_activity_ratio_variables.where(organization_id: organization.id,
                                                                                           wbs_activity_ratio_id: wbs_activity_ratio.id,
                                                                                           name: "RTU").first
            if rtu_wbs_ratio_variable && !rtu_wbs_ratio_variable.percentage_of_input.include?("E1") && !rtu_wbs_ratio_variable.percentage_of_input.include?("E2") &&
                                         !rtu_wbs_ratio_variable.percentage_of_input.include?("E3") && !rtu_wbs_ratio_variable.percentage_of_input.include?("E4")
              rtu_wbs_ratio_variable.percentage_of_input = "E1"
              rtu_wbs_ratio_variable.is_used_in_ratio_calculation = true
              rtu_wbs_ratio_variable.save
            end
          end

          # update mp_ratio_variable
          rtu_mp_ratio_variable = current_mp.module_project_ratio_variables.where(organization_id: organization.id,
                                                                                  pbs_project_element_id: pbs_id,
                                                                                  :module_project_id => current_mp.id,
                                                                                  name: "RTU").first
          if rtu_mp_ratio_variable
            rtu_mp_ratio_variable.percentage_of_input = "E1"
            rtu_mp_ratio_variable.save
          end
        end

      end
    end

    current_inputs_evs = current_mp.estimation_values.where(organization_id: organization.id, pe_attribute_id: wbs_effort_ids, in_out: "input")
  end


  # Récupère les estimation-values du module_project avec le filtre sur le netoyage des attributs
  def get_module_project_estimation_values
    module_project = self
    organization_id = module_project.organization_id
    all_estimation_values = module_project.estimation_values.where(organization_id: organization_id).where.not(in_out: nil)

    begin
      case module_project.pemodule.alias
        when "guw"
          estimation_values = all_estimation_values.where(in_out: 'output')
          shared_attributes = module_project.pemodule.pe_attributes.where(alias: ['flagged_unit_of_work', 'offline_unit_of_work', 'selected_of_unit_of_work', 'number_of_unit_of_work'], guw_model_id: module_project.guw_model_id)
          shared_attribute_ids = shared_attributes.map(&:id).flatten

          if module_project.guw_model.config_type == "new"
            #module_project_attributes_ids = module_project.pemodule.pe_attributes.where("guw_model_id = ? OR id IN (?)", module_project.guw_model_id, shared_attribute_ids).map(&:id).flatten
            module_project_attributes_ids = module_project.pemodule.pe_attributes.where("pe_attributes.guw_model_id = ? OR pe_attributes.id IN (?)", module_project.guw_model_id, shared_attribute_ids).map(&:id)
            estimation_values = estimation_values.where(pe_attribute_id: module_project_attributes_ids)
          end

        when "ge"
          if module_project.ge_model.ge_model_instance_mode == "standard"
            module_project_attributes = module_project.pemodule.pe_attributes
            standard_effort_ids = module_project_attributes.where(alias: Ge::GeModel::GE_ATTRIBUTES_ALIAS).map(&:id).flatten
            estimation_values = all_estimation_values.where(pe_attribute_id: standard_effort_ids)
          else
            estimation_values = all_estimation_values
          end

        when "effort_breakdown"
          excluded_evs = all_estimation_values.includes(:pe_attribute).where(pe_attributes: {alias: ['theoretical_effort', 'effort']}, in_out:'input')
          estimation_values = all_estimation_values.where('id NOT IN (?)', excluded_evs.map(&:id))
        else
          estimation_values = all_estimation_values
      end
    rescue
      estimation_values = []
    end

    estimation_values
  end


  # Get Estimation_values or Create them if not exist
  def get_mp_inputs_outputs_estimation_values(input_attribute_ids, output_attribute_ids = [])

    organization_id = self.organization_id
    current_inputs_evs = self.get_module_project_estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")     #self.estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")
    current_outputs_evs = self.get_module_project_estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")  #self.estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")

    if (input_attribute_ids.length != current_inputs_evs.length) || (output_attribute_ids.length != current_outputs_evs.length)

      all_attribute_modules = self.pemodule.attribute_modules
      case self.pemodule.alias
        when "guw"
          attribute_modules = all_attribute_modules.where(guw_model_id: self.guw_model_id)
        when "operation"
          attribute_modules = all_attribute_modules.where(operation_model_id: self.operation_model_id)
        else
          attribute_modules = all_attribute_modules
      end

      #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
      #self.pemodule.attribute_modules.each do |am|
      attribute_modules.each do |am|
        unless am.pe_attribute.nil?
          if am.in_out == 'both'
            ['input', 'output'].each do |in_out|
              ev = EstimationValue.where(organization_id: organization_id, :module_project_id => self.id, :pe_attribute_id => am.pe_attribute_id, :in_out => in_out)
                       .first_or_create(organization_id: organization_id,
                                        :pe_attribute_id => am.pe_attribute.id,
                                        :module_project_id => self.id,
                                        :in_out => in_out,
                                        :is_mandatory => am.is_mandatory,
                                        :description => am.description,
                                        :display_order => am.display_order,
                                        :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                        :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                        :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                        :custom_attribute => am.custom_attribute,
                                        :project_value => am.project_value)
            end
          else
            ev = EstimationValue.where(organization_id: organization_id, :module_project_id => self.id, :pe_attribute_id => am.pe_attribute_id, :in_out => am.in_out)
                     .first_or_create(organization_id: organization_id,
                                      :pe_attribute_id => am.pe_attribute.id,
                                      :module_project_id => self.id,
                                      :in_out => am.in_out,
                                      :is_mandatory => am.is_mandatory,
                                      :display_order => am.display_order,
                                      :description => am.description,
                                      :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                      :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                      :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high },
                                      :custom_attribute => am.custom_attribute,
                                      :project_value => am.project_value)
          end
        end
      end
    end

    self.estimation_values.where(organization_id: organization_id)
  end


  # Get Estimation_values or Create them if not exist
  def get_mp_estimation_values
    organization_id = self.organization_id
    input_attribute_ids = PeAttribute.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:id).flatten
    current_inputs_evs = self.estimation_values.where(organization_id: organization_id, pe_attribute_id: input_attribute_ids, in_out: "input")

    if current_inputs_evs.empty?

      #For each attribute of this new ModuleProject, it copy in the table ModuleAttributeProject, the attributes of modules.
      self.pemodule.attribute_modules.each do |am|

        if am.in_out == 'both'
          ['input', 'output'].each do |in_out|
            ev = EstimationValue.where(organization_id: organization_id, :module_project_id => self.id, :pe_attribute_id => am.pe_attribute.id, :in_out => in_out)
                     .first_or_create(organization_id: organization_id,
                                      :pe_attribute_id => am.pe_attribute.id,
                                      :module_project_id => self.id,
                                      :in_out => in_out,
                                      :is_mandatory => am.is_mandatory,
                                      :description => am.description,
                                      :display_order => am.display_order,
                                      :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                      :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                      :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high},
                                      :custom_attribute => am.custom_attribute,
                                      :project_value => am.project_value)
          end
        else
          ev = EstimationValue.where(organization_id: organization_id, :module_project_id => self.id, :pe_attribute_id => am.pe_attribute.id, :in_out => am.in_out)
                   .first_or_create(organization_id: organization_id,
                                    :pe_attribute_id => am.pe_attribute.id,
                                    :module_project_id => self.id,
                                    :in_out => am.in_out,
                                    :is_mandatory => am.is_mandatory,
                                    :display_order => am.display_order,
                                    :description => am.description,
                                    :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => am.default_low},
                                    :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => am.default_most_likely},
                                    :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => am.default_high },
                                    :custom_attribute => am.custom_attribute,
                                    :project_value => am.project_value)
        end
      end
    end

    self.estimation_values.where(organization_id: organization_id, pe_attribute_id: input_attribute_ids, in_out: "input")
  end


end
