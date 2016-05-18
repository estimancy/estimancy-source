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

class EstimationStatus < ActiveRecord::Base
  attr_accessible :description, :status_alias, :name, :organization_id, :status_number, :status_color, :is_archive_status, :is_new_status

  belongs_to :organization

  has_many :from_transitions, :foreign_key => 'from_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :to_transition_statuses, :through => :from_transitions


  has_many :to_transitions, :foreign_key => 'to_transition_status_id', :class_name => 'StatusTransition', :dependent => :destroy
  has_many :from_transition_statuses, :through => :to_transitions

  #Status of Estimation Management as state machine
  # Relation between estimations for setting statuses
  has_many :projects

  #Estimations permissions on Group according to the estimation status
  has_many :estimation_status_group_roles, dependent: :delete_all

  #validates :organization_id, presence: true
  validates :name, presence: true
  validates :status_number, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :status_alias, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :is_archive_status, uniqueness: { scope: :organization_id, case_sensitive: false, message: I18n.t(:only_one_archive_status_possible), :if => Proc.new { |status| status.is_archive_status == true} }
  validate  :check_status_alias

  default_scope order('status_number ASC')

  #Search fields
  scoped_search :on => [:name, :description, :status_alias]

  # Add the amoeba gem for the copy
  amoeba do
    enable
    #exclude_field [:projects, :estimation_status_group_roles]
    #include_association [:estimation_status_group_roles, :to_transition_statuses, :from_transition_statuses]
    include_association [:to_transition_statuses, :from_transition_statuses]
    customize(lambda { |original_estimation_status, new_estimation_status|
      new_estimation_status.copy_id = original_estimation_status.id
    })
  end

  # Status alias validation
  def check_status_alias
    if self.status_alias.match(/\s+/) #|| self.status_alias.match(/\w+/)
      errors.add(:status_alias, I18n.t(:text_invalid_status_alias))
    end
  end

  def libelle
    "#{status_number} - #{name}"
  end

  def to_s
    self.nil? ? '' : self.libelle
  end

end
