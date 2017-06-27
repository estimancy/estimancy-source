# encoding: UTF-8
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

module Kb
  class KbModel < ActiveRecord::Base
    validates :name, :presence => true, uniqueness: { :scope => :organization_id, :case_sensitive => false, message: "Une instance du module base de connaissance du même nom existe déjà" }

    validates :standard_unit_coefficient, :presence => true
    validates :effort_unit, :presence => true

    belongs_to :organization

    has_many :module_projects, :dependent => :destroy
    has_many :kb_datas, :dependent => :destroy
    has_many :kb_inputs, :dependent => :destroy

    serialize :selected_attributes, Array

    INPUT_ATTRIBUTES_ALIAS = ["effort", "retained_size"]

    amoeba do
      enable
      exclude_association [:module_projects]

      customize(lambda { |original_kb_model, new_kb_model|
        new_kb_model.copy_id = original_kb_model.id
        new_kb_model.standard_unit_coefficient = original_kb_model.standard_unit_coefficient
        new_kb_model.effort_unit= original_kb_model.effort_unit
      })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{mp.creation_order})"
      end
    end

    def self.display_size(p, c, level, component_id, kb_model=nil)
      if c.nil? || (kb_model != nil && !kb_model.enabled_input)
        begin
          p.send("string_data_#{level}")[component_id]
        rescue
          nil
        end
      else
        c_ev = c.send("string_data_#{level}")[component_id]
        if c_ev.nil?
          begin
            p.send("string_data_#{level}")[component_id]
          rescue
            nil
          end
        else
          c_ev
        end
      end
    end
  end
end
