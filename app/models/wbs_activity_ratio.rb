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

class WbsActivityRatio < ActiveRecord::Base
  attr_accessible :name, :description, :wbs_activity_id, :allow_modify_retained_effort, :do_not_show_cost, :do_not_show_phases_with_zero_value,
                  :comment_required_if_modifiable, :organization_id

  has_many :pbs_project_elements
  has_many :wbs_activity_ratio_elements, :dependent => :destroy
  has_many :wbs_activity_ratio_profiles, :through => :wbs_activity_ratio_elements
  has_many :wbs_activity_ratio_variables, :dependent => :destroy

  has_many :module_project_ratio_elements, dependent: :destroy
  has_many :module_project_ratio_variables, dependent: :destroy

  belongs_to :wbs_activity
  belongs_to :organization

  validates :name, :presence => true, :uniqueness => { :scope => :wbs_activity_id, :case_sensitive => false }

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    include_association [:wbs_activity_ratio_elements]

    customize(lambda { |original_wbs_activity_ratio, new_wbs_activity_ratio|
      new_wbs_activity_ratio.copy_id = original_wbs_activity_ratio.id
      new_wbs_activity_ratio.copy_number = 0
      original_wbs_activity_ratio.copy_number = original_wbs_activity_ratio.copy_number.to_i+1
    })

    #propagate
  end

  def self.export(activity_ratio_id)
    activity_ratio = WbsActivityRatio.find(activity_ratio_id)
    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
      csv << ['id', 'Ratio Name', 'Position', 'Element Name', 'Element Description', 'Formula', 'Is optionel', 'Effort is modifiable', "Cost is modifiable"]
      activity_ratio.wbs_activity_ratio_elements.each do |element|
        csv << [element.id, "#{activity_ratio.name}", "#{element.wbs_activity_element.position}", "#{element.wbs_activity_element.name}", "#{element.wbs_activity_element.description}", element.formula, element.is_optional, element.effort_is_modifiable, element.cost_is_modifiable]
      end
    end
    csv_string.encode(I18n.t(:general_csv_encoding))
  end

  def self.import(file, sep, encoding, organization_id, wbs_activity_id, wbs_activity_ratio_id)
    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"
    error_count = 0
    CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "#{encoding}:utf-8") do |csv|
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          begin
            wbs_activity_element = WbsActivityElement.where(organization_id: organization_id,
                                                            wbs_activity_id: wbs_activity_id,
                                                            name: row[3].value).first
            if wbs_activity_element
              @ware = WbsActivityRatioElement.where(organization_id: organization_id,
                                                    wbs_activity_id: wbs_activity_id,
                                                    wbs_activity_ratio_id: wbs_activity_ratio_id,
                                                    wbs_activity_element_id: wbs_activity_element.id).first #WbsActivityRatioElement.find(row[0].value)
              if @ware.nil?
                WbsActivityRatioElement.create(organization_id: organization_id,
                                               wbs_activity_id: wbs_activity_id,
                                               wbs_activity_ratio_id: wbs_activity_ratio_id,
                                               wbs_activity_element_id: wbs_activity_element.id,
                                               description: row[4].value,
                                               formula: row[5].value,
                                               is_optional: row[6].value,
                                               effort_is_modifiable: row[7].value,
                                               cost_is_modifiable: row[8].value)
              else
                #@ware.wbs_activity_element.has_children?
                @ware.update_attributes(formula: row[5].value, is_optional: row[6].value, effort_is_modifiable: row[7].value, cost_is_modifiable: row[8].value)
              end
            end
          rescue
            error_count = error_count + 1
          end
        end
      end
    end
    error_count
  end

  def to_s
    self.nil? ? '' : self.name
  end

  # Create the ratio wbs_activity_ratio_variables
  def create_wbs_activity_ratio_variables
    [["RTU", ""], ["TEST", ""], ["", ""], ["", ""]].each do |var|
      variable = WbsActivityRatioVariable.new(name: var[0],  percentage_of_input: var[1], wbs_activity_ratio_id: self.id,
                                              organization_id: self.organization_id, :wbs_activity_id => self.wbs_activity_id)
      variable.save
    end

    self.wbs_activity_ratio_variables
  end

  #get the current ratio wbs_activity_ratio_variable
  def get_wbs_activity_ratio_variables
    wbs_activity_ratio_variables = self.wbs_activity_ratio_variables
    nb_ratio_variables = wbs_activity_ratio_variables.all.length

    if  nb_ratio_variables <= 0
      [["RTU", ""], ["TEST", ""], ["", ""], ["", ""]].each do |var|
        variable = WbsActivityRatioVariable.new(name: var[0],  percentage_of_input: var[1], wbs_activity_ratio_id: self.id,
                                                organization_id: self.organization_id, :wbs_activity_id => self.wbs_activity_id)
        variable.save
      end
    elsif nb_ratio_variables < 4

      wbs_activity_ratio_variables.each do |ratio_variable|
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

      begin
        variable = WbsActivityRatioVariable.new(name: "",  percentage_of_input: "", wbs_activity_ratio_id: self.id,
                                                organization_id: self.organization_id, :wbs_activity_id => self.wbs_activity_id)
        if variable.save
          nb_ratio_variables += 1
        end
      end while nb_ratio_variables < 4
    end

    self.wbs_activity_ratio_variables
  end


end
