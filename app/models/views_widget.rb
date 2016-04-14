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

class ViewsWidget < ActiveRecord::Base
  attr_accessible :color, :icon_class, :module_project_id, :name, :pbs_project_element_id, :estimation_value_id, :pe_attribute_id,
                  :show_min_max, :view_id, :widget_id, :position, :position_x, :position_y, :width, :height, :widget_type,
                  :show_name, :show_wbs_activity_ratio, :from_initial_view, :is_label_widget, :comment, :formula

  serialize :equation, Hash

  #after_create :update_widget_pe_attribute

  belongs_to :view
  belongs_to :widget
  belongs_to :estimation_value
  belongs_to :pe_attribute
  belongs_to :pbs_project_element
  belongs_to :module_project

  has_many :project_fields, dependent: :delete_all

  validates :name, :module_project_id, :estimation_value_id, :presence => { :unless => lambda { self.is_label_widget? || self.is_kpi_widget? }}

  amoeba do
    enable
    include_association [:project_fields]
  end


  #Update the pe_attribute from estimation_value
  def update_widget_pe_attribute
    widget_estimation_value = EstimationValue.find(self.estimation_value_id)
    if widget_estimation_value
      self.update_attribute(:pe_attribute_id, widget_estimation_value.pe_attribute_id)
    end
  end


  def to_s
    self.nil? ? '' : self.name
  end

  def self.update_field(view_widget, organization, project, component)

    organization.fields.each do |field|

      pf = ProjectField.where(field_id: field.id,
                              project_id: project.id,
                              views_widget_id: view_widget.id).first

      if view_widget.estimation_value.module_project.pemodule.alias == "effort_breakdown"
        begin
          @value = view_widget.estimation_value.string_data_probable[component.id][view_widget.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
        rescue
          #begin
            @value = view_widget.estimation_value.string_data_probable[project.root_component.id]
          #rescue
          #  @value = 0
          #end
        end
      else
        @value = view_widget.estimation_value.string_data_probable[component.id]
      end

      unless pf.nil?
      #  ProjectField.create(project_id: project.id,
      #                      field_id: field.id,
      #                      views_widget_id: view_widget.id,
      #                      value: @value)
      #else
        pf.value = @value
        pf.views_widget_id = view_widget.id
        pf.field_id = field.id
        pf.project_id = project.id
        pf.save
      end
    end
  end

end

