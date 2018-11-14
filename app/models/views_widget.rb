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
                  :show_name, :show_wbs_activity_ratio, :from_initial_view, :is_label_widget, :comment, :formula, :kpi_unit,
                  :is_kpi_widget, :use_organization_effort_unit, :equation, :show_tjm

  serialize :equation, Hash

  WIDGETS_COLORS = ['#7b7f96', '#e5e4e2', '#96857b', '#7b9693', 'gold', '#C5A5CF', '#b87333', 'silver', '#76A7FA', '#703593', '#871B47', '#BC5679', 'D59931', 'teal', '#00B3FF', '#3399FF']

  #after_create :update_widget_pe_attribute

  belongs_to :view
  belongs_to :widget
  belongs_to :estimation_value
  belongs_to :pe_attribute
  belongs_to :pbs_project_element
  belongs_to :module_project

  has_many :project_fields, dependent: :delete_all

  validates :name, :module_project_id, :estimation_value_id, :presence => { :unless => lambda { self.is_label_widget? || self.is_kpi_widget? }}
  validates :max_value, numericality: {:greater_than => :min_value}

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


  def self.reset_nexts_mp_estimation_values(module_project, pbs_project_element)
    @mpids ||= []
    module_project.all_nexts_mp_with_links.each do |mp|

      if !@mpids.include?(mp.id)

        @mpids << mp.id

        mp.estimation_values.where(in_out: "output").each do |ev|
          ["low", "most_likely", "high"].each do |level|
            ev.send("string_data_#{level}=", { pbs_project_element.id => nil })
          end
          ev.send("string_data_probable=", { pbs_project_element.id => nil })
          # unless ev.changed?
          ev.save
          # end
        end

        # reset module_project_ratio_elements for EffortBreakdown module
        if mp.pemodule.alias == "effort_breakdown"
          mp.module_project_ratio_elements.each do |mp_ratio_elt|
            ["theoretical_effort", "theoretical_cost", "retained_effort", "retained_cost"].each do |attribute|
              ["low", "most_likely", "high", "probable"].each do |level|
                mp_ratio_elt.send("#{attribute}_#{level}=", nil)
              end
            end
            # unless mp_ratio_elt.changed?
            mp_ratio_elt.save
            # end
          end
        end
      end
    end
  end


  def self.update_field(module_project, organization, project, component, set_to_nil = false)
    organization_fields = organization.fields

    ###module_project.views_widgets.each do |view_widget|
    project_view_widgets =  project.views_widgets.where('module_project_id = ? OR is_kpi_widget = ?', module_project.id, true).all.sort_by{ |w| w.is_kpi_widget ? 1 : 0 }

    project_view_widgets.each do |view_widget|

      pfs = {}
      ProjectField.where(project_id: project.id, views_widget_id: view_widget.id).all.each do |pf|
        pfs[pf.field_id] = pf
      end

      view_widget_estimation_value = view_widget.estimation_value
      organization_fields.each do |field|

        pf = pfs[field.id]

        begin #unless view_widget_estimation_value.nil?
          if set_to_nil == true
            if view_widget.is_kpi_widget?
              @value = ApplicationController.helpers.get_kpi_value_without_unit(view_widget, component)
            else
              @value = nil
            end

          else
            if !view_widget_estimation_value.nil?
              if view_widget_estimation_value.module_project.pemodule.alias == "effort_breakdown"
                begin
                  @value = view_widget_estimation_value.string_data_probable[component.id][view_widget_estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                rescue
                  @value = view_widget_estimation_value.string_data_probable[project.root_component.id]
                end
              else
                @value = view_widget_estimation_value.string_data_probable[component.id]
              end
            else
              if view_widget.is_kpi_widget?
                @value = ApplicationController.helpers.get_kpi_value_without_unit(view_widget, component)  # get_kpi_value_without_unit
              end
            end

          end

          unless pf.nil?
            pf.value = @value
            pf.views_widget_id = view_widget.id
            pf.field_id = field.id
            pf.project_id = project.id

            # pf ce sont les ProjectField, ce sont les valeurs qui remontent au niveau de la lise des estimations
            # Il faut sauvegarder cet objet (pf) sous 2 conditions :
            # si la vignette contient une borne et max
            # si la valeur @valeur est comprise entre les bornes de la vignette view_widget (min et max)
            # Donc je te laisse réflchir, ya juste 2 test à faire.

            pf.save

          end
        rescue
          # nothing
        end
      end
    end
  end

end

