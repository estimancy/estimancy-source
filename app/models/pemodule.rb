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

#Master Data
#Pemodule represent the Module of the application.
#Pemodule can be common (sum, average) or typed(cocomo, pnr...)
class Pemodule < ActiveRecord::Base
  attr_accessible :alias, :title, :description#, :with_activities, :compliant_component_type, :record_status, :record_status_id, :custom_value, :change_comment

  include AASM
  # include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  #Project has many module, module has many project
  has_many :module_projects, :dependent => :destroy
  has_many :projects, :through => :module_projects

  #Pemodule has many attribute, attribute has many pemodule
  has_many :attribute_modules, :dependent => :destroy
  has_many :pe_attributes, :source => :pe_attribute, :through => :attribute_modules

  #each module can have multiple associated views
  has_many :views

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  serialize :compliant_component_type

  validates_presence_of :description#, :record_status
  # validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :title, :alias, :presence => true#, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  # validates :custom_value, :presence => true, :if => :is_custom?

  #ASSM needs
  aasm :column => :with_activities do # defaults to aasm_state
    state :no, :initial => true
    state :yes_for_input
    state :yes_for_output_with_ratio
    state :yes_for_output_without_ratio
    state :yes_for_input_output_with_ratio
    state :yes_for_input_output_without_ratio
  end


  ##Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    #include_field [:attribute_modules, :pe_attributes]      #TODO Review relations
    #exclude_field [:projects, :module_projects]             #TODO Review relations

    ####include_field [:attribute_modules] #TODO Review relations
    ####exclude_field [:projects, :module_projects] #TODO Review relations


    ###include_association [:attribute_modules] #TODO Review relations
    ###include_association [:attribute_modules, :module_projects] #TODO Review relations
    ##include_association [:attribute_modules, :projects] #TODO Review relations
    include_association [:attribute_modules] #TODO Review relations

    # customize(lambda { |original_record, new_record|
      # new_record.reference_uuid = original_record.uuid
      # new_record.reference_id = original_record.id
      # new_record.record_status = RecordStatus.find_by_name('Proposed') #RecordStatus.first
    # })
  end

  #Search fields
  scoped_search :on => [:title, :alias, :description, :created_at, :updated_at]

  #Override
  def to_s
    self.nil? ? '' : self.title
  end
end
