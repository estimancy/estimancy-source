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

#Module Attribute are duplicated on AttributeProject in order to use it.
class EstimationValue < ActiveRecord::Base
  attr_accessible :string_data_low, :string_data_most_likely, :string_data_high, :string_data_probable,:pe_attribute_id, :pe_attribute,
                  :module_project_id,:in_out, :is_mandatory, :description, :display_order, :custom_attribute, :project_value, :notes,
                  :estimation_value_id, :copy_id, :organization_id

  belongs_to :organization
  belongs_to :pe_attribute
  belongs_to :module_project
  belongs_to :pbs_project_element

  belongs_to :associated_estimation_value, class_name: "EstimationValue", foreign_key: :estimation_value_id

  has_many :associated_estimation_values, class_name: "EstimationValue", foreign_key: :estimation_value_id, dependent: :nullify

  has_many :views_widgets, :dependent => :destroy


  amoeba do
    enable
    exclude_association [:views_widgets, :associated_estimation_values]
    customize(lambda { |original_ev, new_ev|
                new_ev.copy_id = original_ev.id
              })
  end

  #validates :pe_attribute_id, :module_project_id, presence: true

  #Serialize some output data for estimation result
  serialize :string_data_low, Hash
  serialize :string_data_most_likely, Hash
  serialize :string_data_high, Hash
  serialize :string_data_probable, Hash
  serialize :notes, Hash

  def to_s
    self.nil? ? '' : (self.pe_attribute.nil? ? '-' : self.pe_attribute.name)
  end

  # Verify if params val is validate
  def is_validate(val)
    pe_attribute = self.pe_attribute
    #if value is mandatory and not fill => false
    if self.is_mandatory and val.blank?
      false
      #if value is not mandatory and not fill => true
    elsif val.blank?
      true
      #if value is filled...
    else
      #deserialize options to do something like that : ['integer', '>=', 50]
      array = pe_attribute.options.compact.reject { |s| s.nil? or s.empty? or s.blank? }

      #test attribute type and check validity (numeric = float and integer)
      if pe_attribute.attribute_type == 'numeric'

        if pe_attribute.attr_type == 'integer' and !val.valid_integer?
          return false
        end

        unless val.is_numeric?
          #return false is value is not numeric
          return false
        end

        #unless there are not conditions/options
        unless array.empty?
          #number between 1 and 10 (ex : 3 = true, 15 = false, -5 = false)
          if pe_attribute.options[1] == 'between'
            v1 = pe_attribute.options[2].split(';').first.to_i
            v2 = pe_attribute.options[2].split(';').last.to_i
            val.to_i.between?(v1, v2)
          else
            #ex : eval('val <= 42')
            str = array[1].to_s + array[2].to_s
            str_to_eval = val + str.to_s
            begin
              eval(str_to_eval)
            rescue => se
              return false
            end
          end
        else
          return true
        end

        #test class of val but not really good because '15565' is also an string
      elsif pe_attribute.attribute_type == 'string'
        val.class == String
        #test validity of date. Problem with translated date (fr: 28/02/2013 => true en: 02/28/2013 => false but both valid)
      elsif pe_attribute.attribute_type == 'date'
        str_to_eval = "'#{val}'.to_date #{ array[1]} '#{array[2]}'.to_date"
        begin
          #eval chain
          eval(str_to_eval)
        rescue => se
          return false
        end
      end
    end
  end
end
