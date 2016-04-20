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
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment, :wbs_activity_id, :use_base_100

  ###has_many :wbs_project_elements
  has_many :pbs_project_elements
  has_many :wbs_activity_ratio_elements, :dependent => :destroy
  has_many :wbs_activity_ratio_profiles, :through => :wbs_activity_ratio_elements

  belongs_to :wbs_activity

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :name, :presence => true, :uniqueness => {:scope => :wbs_activity_id, :case_sensitive => false}

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
      csv << ['id', 'Ratio Name', 'Outline', 'Element Name', 'Element Description', 'Ratio Value', 'Simple Reference', 'Multiple References']
      activity_ratio.wbs_activity_ratio_elements.each do |element|
        csv << [element.id, "#{activity_ratio.name}", "#{element.wbs_activity_element.dotted_id}", "#{element.wbs_activity_element.name}", "#{element.wbs_activity_element.description}", element.ratio_value, element.simple_reference, element.multiple_references]
      end
    end
    csv_string.encode(I18n.t(:general_csv_encoding))
  end

  def self.import(file, sep, encoding)
    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"
    error_count = 0
    CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "#{encoding}:utf-8") do |csv|
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          begin
            @ware = WbsActivityRatioElement.find(row[0])
            if @ware.nil?
              WbsActivityRatioElement.create(ratio_value: row[5],
                                             simple_reference: row[6],
                                             multiple_references: row[7])
            else
              @ware.wbs_activity_element.has_children?
              @ware.update_attribute('ratio_value', row[5])
              @ware.update_attribute('simple_reference', row[6])
              @ware.update_attribute('multiple_references', row[7])
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

end
