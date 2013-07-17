#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

#Master table
#Global attributes of project. Ex : size, cost, result, date etc...
#Those attributes are used into AttributeModule
class PeAttribute < ActiveRecord::Base
  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  serialize :options, Array

  has_many :attribute_organizations, :dependent => :destroy
  has_many :organizations, :through => :attribute_organizations

  has_many :attribute_modules, :dependent => :destroy
  has_many :pemodules, :through => :attribute_modules

  has_many :estimation_values

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :attribute_category

  validates_presence_of :description, :attr_type, :record_status
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :alias, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :custom_value, :presence => true, :if => :is_custom?

  ##Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    exclude_field [:attribute_modules]

    customize(lambda { |original_record, new_record|
      new_record.reference_uuid = original_record.uuid
      new_record.reference_id = original_record.id
      new_record.record_status = RecordStatus.find_by_name("Proposed") #RecordStatus.first
    })
  end

  searchable do
    text :name, :description, :alias
  end

  def self.attribute_list
    PeAttribute.all.map(&:alias)
  end

  def self.attribute_updated_at
    PeAttribute.all.map(&:updated_at)
  end

  #Override
  def to_s
    self.name + ' - ' + self.description.truncate(20)
  end

  #Type of the aggregation
  #Not finished
  def self.type_aggregation
    [["Moyenne", "average"], ["Somme", "sum"], ["Maximum", "maxi"]]
  end

  def self.type_values
    [["Integer", "integer"], ["Float", "float"], ["Date", "date"], ["Text", "text"], ["List", "list"]]
  end

  def self.value_options
    [
        ["Greater than or equal to", ">="],
        ["Greater than", ">"],
        ["Lower than or equal to", "<="],
        ["Lower than", "<"],
        ["Equal to", "=="],
        ["Not equal to", "!="],
        ["Between", "between"]
    ]
  end

  #return the data type
  def data_type
    self.attr_type
  end

  #return the data type
  def attribute_type
    case self.attr_type
      when "integer"
        "numeric"
      when "float"
        "numeric"
      when "date"
        "date"
      when "text"
        "string"
      when "list"
        "string"
      when "array"
        "string"
    end
  end

  #return the data type
  def explicit_data_type
    case self.attr_type
      when "integer"
        "numeric"
      when "float"
        "numeric"
      when "date"
        "date"
      when "text"
        "string"
      when "list"
        "string"
      when "array"
        "string"
    end
  end


end
