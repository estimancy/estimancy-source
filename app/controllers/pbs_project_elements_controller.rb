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

class PbsProjectElementsController < ApplicationController


  def edit
    @pbs_project_element = PbsProjectElement.find(params[:id])
    set_page_title("Editing #{@pbs_project_element.name}")

    @project = Project.find(params[:project_id])
    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @project_wbs_activities = @pe_wbs_project_activity.wbs_activities(:id).uniq   # Select only Wbs-Activities affected to current project
    @pbs_wbs_activity_ratios = []

    unless @pbs_project_element.wbs_activity.nil?
      @pbs_wbs_activity_ratios = @pbs_project_element.wbs_activity.wbs_activity_ratios
    end


    #Select folders which could be a parent of a pbs_project_element
    #a pbs_project_element cannot be its own parent
    @folder_components = @project.pe_wbs_projects.products_wbs.first.pbs_project_elements.select{ |i| i.work_element_type.alias == "folder" }
  end

  def update
    @pbs_project_element = PbsProjectElement.find(params[:id])
    @project = @pbs_project_element.pe_wbs_project.project

    if @pbs_project_element.update_attributes(params[:pbs_project_element])
      # Another update attributes...
      if params[:pbs_project_element][:ancestry]
        @pbs_project_element.update_attribute :parent, PbsProjectElement.find(params[:pbs_project_element][:ancestry])
      else
        @pbs_project_element.update_attribute :parent, nil
      end
    else
      flash[:error] = I18n.t (:error_pbs_project_element_failed_update)
    end

    render :partial => "pbs_project_elements/refresh_tree"
  end

  def destroy
    #set somes variables
    pbs_project_element = PbsProjectElement.find(params[:id])
    @project = pbs_project_element.pe_wbs_project.project
    @pbs_project_element = @project.root_component
    @module_projects = @project.module_projects


    elements_to_up = pbs_project_element.siblings.where("position > ?", pbs_project_element.position ).all

    #Destroy the selected pbs_project_element
    pbs_project_element.destroy

    elements_to_up.each do |element|
      element.position = element.position - 1
      element.save
    end

    render :partial => "pbs_project_elements/refresh_tree"
  end

  #Select the current pbs_project_element and refresh the partial
  def selected_pbs_project_element
    session[:pbs_project_element_id] = params[:pbs_id]

    @user = current_user
    @project = current_project.nil? ? Project.find(params[:project_id]) : current_project    #@project = current_project
    @module_projects = @project.module_projects
    @pbs_project_element = current_component

    @module_positions = ModuleProject.where(:project_id => @project.id).sort_by{|i| i.position_y}.map(&:position_y).uniq.max || 1
    @results = nil

    render :partial => "pbs_project_elements/refresh"
  end


  #Create a new pbs_project_element and refresh the partials
  def new
    @pe_wbs_project = PeWbsProject.find(params[:pe_wbs_project_id])
    @project = @pe_wbs_project.project
    @module_positions = ModuleProject.where(:project_id => @project.id).sort_by{|i| i.position_y}.map(&:position_y).uniq.max || 1
    @pbs_project_element = PbsProjectElement.new
    @pbs_project_element.pe_wbs_project_id = params[:pe_wbs_project_id]
    @pbs_project_element.parent_id = params[:comp_parent_id]

    if params[:type_component] == "folder"
      @pbs_project_element.name = "New folder"
      @pbs_project_element.work_element_type_id = WorkElementType.find_by_alias("folder").id
    elsif params[:type_component] == "link"
      @pbs_project_element.name = "New link"
      @pbs_project_element.work_element_type_id = WorkElementType.find_by_alias("link").id
    else
      @pbs_project_element.name = "New pbs_project_element"
      @pbs_project_element.work_element_type_id = WorkElementType.find_by_alias("undefined").id
    end

    @pbs_project_element.position = @pbs_project_element.siblings.length + 1
    @pbs_project_element.save

    #Set current pbs_project_element
    session[:pbs_project_element_id] = @pbs_project_element.id

    @user = current_user

    @module_projects = @project.module_projects

    render :partial => "pbs_project_elements/refresh_tree"
  end

  #Pushed up the pbs_project_element
  def up
    @project = Project.find(params[:project_id])

    component_a = PbsProjectElement.find(params[:pbs_project_element_id])
    component_b = component_a.siblings.all.select{|i| i.position == component_a.position - 1 }.first

    if (component_a.parent.id == component_a.root.id and component_a.position == 1) or component_a.siblings.size == 1
      puts "nothing"
    else
      component_a.update_attribute("position", component_a.position - 1)
      component_b.update_attribute("position", component_b.position + 1)
    end

    @user = current_user

    render :partial => "pbs_project_elements/refresh_tree"
  end

  #Pushed down the pbs_project_element
  def down
    @project = Project.find(params[:project_id])

    component_a = PbsProjectElement.find(params[:pbs_project_element_id])
    component_b = component_a.siblings.all.select{|i| i.position == component_a.position + 1 }.first

    if component_b.nil? or component_a.siblings.size == 1
      puts "nothing"
    else
      component_a.update_attribute("position", component_a.position + 1)
      component_b.update_attribute("position", component_b.position - 1)
    end

    @user = current_user

    render :partial => "pbs_project_elements/refresh_tree"
  end

  def refresh_pbs_activity_ratios
    puts "Params_activity = #{params[:wbs_activity_id]}"
    if params[:wbs_activity_id].empty? || params[:wbs_activity_id].nil?
      @pbs_activity_ratios = []
    else
      @wbs_activity = WbsActivity.find(params[:wbs_activity_id])
      @pbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    end
  end
end
