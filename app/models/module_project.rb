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
  attr_accessible  :project_id, :pemodule_id, :pemodule, :position_x, :position_y, :top_position, :left_position, :creation_order, :nb_input_attr, :nb_output_attr, :view_id, :color

  belongs_to :pemodule
  belongs_to :project, :touch => true
  belongs_to :view, dependent: :destroy    # the current selected view

  belongs_to :guw_model, class_name: "Guw::GuwModel"
  belongs_to :ge_model, class_name: "Ge::GeModel"
  belongs_to :operation_model, class_name: "Operation::OperationModel"
  belongs_to :kb_model, class_name: "Kb::KbModel"
  belongs_to :skb_model, class_name: "Skb::SkbModel"
  belongs_to :staffing_model, class_name: "Staffing::StaffingModel"
  belongs_to :expert_judgement_instance, class_name: "ExpertJudgement::Instance"
  belongs_to :wbs_activity

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

  default_scope :order => 'position_x ASC, position_y ASC'

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
    self.previous.each do |previous_mp|
      if previous_mp.pemodule.attribute_modules.where(:pe_attribute_id => pe_attribute.id, in_out: ["output", "both"]).length >= 1
        possible_module_projects << previous_mp
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
end
