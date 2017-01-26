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

#Master table
#Specific attribute for a module (Functionality)
class AttributeModule < ActiveRecord::Base
  attr_accessible :pe_attribute_id, :pemodule_id, :is_mandatory, :in_out, :description, :default_low, :default_most_likely, :default_high, :display_order, :guw_model_id
  # ,:custom_attribute, :project_value, :record_status_id, :custom_value, :change_comment

  # include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  # belongs_to :record_status
  # belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  belongs_to :pemodule
  belongs_to :pe_attribute, :class_name => 'PeAttribute', :foreign_key => 'pe_attribute_id'

  # validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates_presence_of :pe_attribute_id
  # validates :custom_value, :presence => true, :if => :is_custom?

  # Verify if params val is validate
  def is_validate(val)
    #deserialize options to do something like that : ['integer', '>=', 50]
    array = pe_attribute.options.compact.reject { |s| s.nil? or s.empty? or s.blank? }

    #test attribute type and check validity (numeric = float and integer)
    if pe_attribute.attribute_type == 'numeric'

      if pe_attribute.attr_type == 'integer' and !val.valid_integer?
        return false
      end

      if val.blank?
        return true
      end

      if !val.is_numeric?
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
          str = array[1] + array[2]
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
      str_to_eval = "'#{val}'.to_date#{ array[1]} '#{array[2]}'.to_date"
      begin
        #eval chain
        eval(str_to_eval)
      rescue => se
        return false
      end
    end
  end
end
