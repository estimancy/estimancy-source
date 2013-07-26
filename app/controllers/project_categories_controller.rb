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

class ProjectCategoriesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_and_authorize_resource

  before_filter :get_record_statuses

  def new
    set_page_title 'Project Category'
    @project_category = ProjectCategory.new
  end

  def edit
    set_page_title 'Project Category'
    @project_category = ProjectCategory.find(params[:id])

    unless @project_category.child_reference.nil?
      if @project_category.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_project_categories_cant_be_edit)
        redirect_to redirect(projects_global_params_path(:anchor => 'tabs-2'))
      end
    end
  end

  def create
    @project_category = ProjectCategory.new(params[:project_category])

    if @project_category.save
      flash[:notice] = I18n.t (:notice_project_categories_successful_created)
      redirect_to redirect_apply(nil,new_project_category_path(),  projects_global_params_path(:anchor => 'tabs-2') )
    else
      render action: 'new'
    end
  end

  def update
    @project_category = nil
    current_project_category = ProjectCategory.find(params[:id])
    if current_project_category.is_defined?
      @project_category = current_project_category.amoeba_dup
      @project_category.owner_id = current_user.id
    else
      @project_category = current_project_category
    end

    if @project_category.update_attributes(params[:project_category])
      flash[:notice] = I18n.t (:notice_project_categories_successful_updated)
      redirect_to redirect_apply(edit_project_category_path(@project_category), nil, projects_global_params_path(:anchor => 'tabs-2'), )
    else
      render action: 'edit'
    end
  end

  def destroy
    @project_category = ProjectCategory.find(params[:id])
    if @project_category.is_defined? || @project_category.is_custom?
      #logical deletion: delete don't have to suppress records anymore on defined record
      @project_category.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @project_category.destroy
    end

    flash[:notice] = I18n.t (:notice_project_categories_successful_deleted)
    redirect_to projects_global_params_path(:anchor => 'tabs-2')
  end
end
