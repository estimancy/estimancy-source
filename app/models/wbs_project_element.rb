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

class WbsProjectElement < ActiveRecord::Base
  attr_accessible :pe_wbs_project_id, :wbs_activity_element_id, :wbs_activity_id, :name, :description, :additional_description, :exclude, :is_root, :author_id, :ancestry, :copy_number,:wbs_activity_ratio_id, :is_added_wbs_root, :parent_id

  has_ancestry :cache_depth => true

  belongs_to :pe_wbs_project, :touch => true
  belongs_to :wbs_activity_element
  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio #Default Wbs-Activity-Ratio
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  scope :elements_root, -> { where(:is_root => true) }

  validates :name, :presence => true, :uniqueness => {:scope => [:pe_wbs_project_id,:ancestry], :case_sensitive => false}

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable

    customize(lambda { |original_wbs_project_elt, new_wbs_project_elt|
      new_wbs_project_elt.copy_id = original_wbs_project_elt.id
      new_wbs_project_elt.copy_number = 0
      original_wbs_project_elt.copy_number = original_wbs_project_elt.copy_number.to_i+1
    })

    propagate
  end

  # Sort tree in an ordered List accordingly to the tree structure (for example to represent the children in a sorted out list in a select)
  def self.arrange_as_array(options={}, hash=nil)
    hash ||= arrange(options)

    arr = []
    hash.each do |node, children|
      arr << node
      arr += arrange_as_array(options, children) unless children.empty?
    end
    arr
  end

  #  !! looks to be used only on the /spec/unit/wbs_project_element_spec.rb
  #def is_from_library_and_is_leaf?
  #  unless self.is_root
  #    if self.wbs_activity.nil? && self.wbs_activity_element.nil? && self.parent.can_get_new_child.nil?
  #      false
  #    else
  #      if self.has_children?
  #        true
  #      else
  #        if self.parent.can_get_new_child?
  #          true
  #        else
  #          false
  #        end
  #      end
  #    end
  #  end
  #end

  # Test if element can have another children
  def update_can_get_new_child
    unless self.is_root
      if !self.parent.can_get_new_child.nil? && self.parent.can_get_new_child?
        self.can_get_new_child = false
        self.save
      end
    end
  end

  def cannot_get_new_child_link?
    !self.can_get_new_child.nil? && !self.can_get_new_child?
  end

  def destroy_leaf
    unless self.is_root
      if self.wbs_activity.nil? && self.wbs_activity_element.nil?
        return true
      else
        if self.is_added_wbs_root?
          return true
        else
          return false
        end
      end
    end
    false
  end

  # This method return all complement child of given node
  def get_all_complement_children
    children_tab = []
    if self.has_children?
      self.descendants.each do |child|
        if child.wbs_activity_element.nil? && child.wbs_activity.nil?
          children_tab << child.id
        end
      end
    end
    children_tab
  end

end
