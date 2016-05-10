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

class PemodulesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  #load_resource :only => [:index, :edit, :update, :create, :destroy]
  load_resource

  before_filter :get_record_statuses

  def index
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:projestimate_module)
    set_breadcrumbs I18n.t(:projestimate_module) => pemodules_path, I18n.t('modules_list') => ""

    @pemodules = Pemodule.all
    @attributes = PeAttribute.all
  end

  def new
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:projestimate_module_new)
    set_breadcrumbs I18n.t(:projestimate_module) => pemodules_path, I18n.t('projestimate_module_new') => ""

    @wets = WorkElementType.all.reject{|i| i.alias == 'link' || i.alias == 'folder'}
    @pemodule = Pemodule.new
    @attributes = PeAttribute.all
    @attribute_settings = []
  end

  def edit
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:projestimate_module_edit)
    set_breadcrumbs I18n.t(:projestimate_module) => pemodules_path, I18n.t('projestimate_module_edit') => ""

    @wets = WorkElementType.all.reject{|i| i.alias == 'link' || i.alias == 'folder'}
    @pemodule = Pemodule.find(params[:id])
    @attributes = PeAttribute.all
    @attribute_settings = AttributeModule.all(:conditions => {:pemodule_id => @pemodule.id})

    unless @pemodule.child_reference.nil?
      if @pemodule.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_pemodule_cant_be_edit)
        redirect_to pemodules_path
      end
    end
  end

  def update
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:projestimate_module_edit)
    set_breadcrumbs I18n.t(:projestimate_module) => pemodules_path, I18n.t('projestimate_module_edit') => ""

    @wets = WorkElementType.all.reject{|i| i.alias == 'link' || i.alias == 'folder'}
    @attributes = PeAttribute.all

    @pemodule = nil
    current_pemodule = Pemodule.find(params[:id])
    if current_pemodule.is_defined?
      @pemodule = current_pemodule.amoeba_dup
      @pemodule.owner_id = current_user.id
    else
      @pemodule = current_pemodule
    end

    @attribute_settings = AttributeModule.all(:conditions => {:pemodule_id => @pemodule.id})
    @pemodule.compliant_component_type = params[:compliant_wet]

    #if @pemodule.save#(:validate => false)
    params[:pemodule][:alias] = params[:pemodule][:alias].downcase
    if @pemodule.update_attributes(params[:pemodule])
      flash[:notice] =  I18n.t (:notice_pemodule_successful_updated)
      redirect_to redirect_apply(edit_pemodule_path(@pemodule, :anchor=>session[:anchor]), nil, pemodules_path), :notice => "#{I18n.t (:notice_module_project_successful_updated)}"
    else
      flash[:error] = "#{@pemodule.errors.full_messages.to_sentence}"
      render action: 'edit'
    end

  end

  def create
    authorize! :manage_master_data, :all

    set_page_title I18n.t(:projestimate_module_new)
    set_breadcrumbs I18n.t(:projestimate_module) => pemodules_path, I18n.t('projestimate_module_new') => ""

    @pemodule = Pemodule.new(params[:pemodule])
    @pemodule.alias =  params[:pemodule][:alias].downcase

    @pemodule.compliant_component_type = params[:compliant_wet]
    @wets = WorkElementType.all.reject{|i| i.alias == 'link'
    }
    @attributes = PeAttribute.all
    @attribute_settings = []

    if @pemodule.save
      redirect_to redirect_apply(edit_pemodule_path(@pemodule), new_pemodule_path(), pemodules_path)
    else
      render action: 'new'
    end
  end

  #Update attribute of the pemodule selected (2nd tabs)
  def update_selected_attributes
    authorize! :manage_master_data, :all

    @pemodule = Pemodule.find(params[:module_id])

    attributes_ids = params[:pemodule][:pe_attribute_ids]

    @pemodule.attribute_modules.each do |m|
      m.destroy unless attributes_ids.include?(m.pe_attribute_id.to_s)
      attributes_ids.delete(m.pe_attribute_id.to_s)
    end

    #Attribute module record_status is according to the Pemodule record_status
    attributes_ids.each do |g|
      #For Initialization module : all attributes are input/output (both)
      if @pemodule.alias == Projestimate::Application::INITIALIZATION
        @pemodule.attribute_modules.create(:pe_attribute_id => g, :in_out => 'both', :record_status_id => @pemodule.record_status_id) unless g.blank?
      else
        @pemodule.attribute_modules.create(:pe_attribute_id => g, :record_status_id => @pemodule.record_status_id) unless g.blank?
      end
    end
    @pemodule.pe_attributes(force_reload = true)

    if @pemodule.save
      flash[:notice] = I18n.t (:notice_pemodule_successful_updated)
    else
      flash[:notice] = I18n.t (:error_administration_setting_failed_update)
    end

    @attribute_settings = AttributeModule.all(:conditions => {:pemodule_id => params[:module_id]})
    redirect_to redirect_apply(edit_pemodule_path(@pemodule, :anchor=>'tabs-2'), nil, pemodules_path), :notice => "#{I18n.t (:notice_module_project_successful_updated)}"
  end


  #Update attribute settings (3th tabs)
  def set_attributes_module
    authorize! :manage_master_data, :all

    @pemodule = Pemodule.find(params[:module_id])

    selected_attributes = params[:attributes]
    selected_attributes.each_with_index do |attr, i|
      conditions = {:pe_attribute_id => attr.to_i, :pemodule_id => params[:module_id]}
      attribute_module = AttributeModule.first(:conditions => conditions)

      # project_value = nil
      # unless params[:custom_attribute][i] == 'user'
      #   project_value = params[:project_value][i]
      # end

      attribute_module.update_attributes(:in_out => params[:in_out][i],                                           
                                         :default_low =>  params[:default_low][i],
                                         :default_most_likely =>  params[:default_most_likely][i],
                                         :default_high =>  params[:default_high][i])
    end
    redirect_to redirect_apply(edit_pemodule_path(@pemodule, :anchor=>'tabs-3'), nil, pemodules_path), :notice => "#{I18n.t (:notice_module_project_successful_updated)}"
  end

  def destroy
    authorize! :manage_master_data, :all

    @pemodule = Pemodule.find(params[:id])
    if @pemodule.is_defined? || @pemodule.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @pemodule.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @pemodule.destroy
    end
    redirect_to pemodules_url, :notice => "#{I18n.t (:notice_pemodule_successful_deleted)}"
  end

  # redefine the links between estimation plan's modules
  def update_link_between_modules(project, module_project, last_position_x=nil)
    authorize! :alter_estimation_plan, project

    return if @initialization_module.nil?
    initialization_mod_proj = project.module_projects.find_by_pemodule_id(@initialization_module.id)

    unless initialization_mod_proj.nil?
      #We have to get first module in each col
      if last_position_x.nil?
        mps = project.module_projects.where('position_x = ?', module_project.position_x)
        mps.each do |mp|
          ActiveRecord::Base.connection.execute("DELETE FROM associated_module_projects WHERE module_project_id = #{mp.id} AND associated_module_project_id = #{initialization_mod_proj.id}")
        end
        mp = project.module_projects.where('position_x = ?', module_project.position_x).order('position_y ASC').first
        mp.update_attribute('associated_module_project_ids', initialization_mod_proj.id) unless mp.nil?
      else
        positions_x = [last_position_x, module_project.position_x]
        positions_x.each do |pos_x|
          mps = project.module_projects.where('position_x = ?', pos_x).order('position_y ASC')
          mps.each do |mp|
            #Delete association for the Initialization module
            ActiveRecord::Base.connection.execute("DELETE FROM associated_module_projects WHERE module_project_id = #{mp.id} AND associated_module_project_id = #{initialization_mod_proj.id}")
          end
          first_mp = mps.first
          first_mp.update_attribute('associated_module_project_ids', initialization_mod_proj.id) unless first_mp.nil?
        end
      end

    end
  end

  def pemodules_up
    @project_module = ModuleProject.find(params[:module_id])
    @project = @project_module.project

    authorize! :alter_estimation_plan, @project

    if @project_module.position_y > 1
      current_pmodule = @project.module_projects.where('position_x =? AND position_y =?', @project_module.position_x, @project_module.position_y.to_i-1).first
      if current_pmodule
        current_pmodule.update_attribute('position_y', @project_module.position_y.to_i)
      end
      @project_module.update_attribute('position_y', @project_module.position_y.to_i - 1)

      @module_positions = ModuleProject.where(:project_id => @project.id).all.map(&:position_y).uniq.max || 1

      #Remove existing links between modules (for impacted modules only)
      ActiveRecord::Base.connection.execute("DELETE FROM associated_module_projects WHERE module_project_id = #{@project_module.id} OR associated_module_project_id = #{@project_module.id}")

      #Update column module_projects link with initialization module
      update_link_between_modules(@project, @project_module)
    end
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end


  def pemodules_down
    @project_module = ModuleProject.find(params[:module_id])
    @project = @project_module.project

    authorize! :alter_estimation_plan, @project

    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1

    current_pmodule = @project.module_projects.where('position_x =? AND position_y =?', @project_module.position_x, @project_module.position_y+1).first
    if current_pmodule
      current_pmodule.update_attribute('position_y', @project_module.position_y.to_i)
    end

    @project_module.update_attribute('position_y', @project_module.position_y.to_i + 1 )

    #Remove existing links between modules (for impacted modules only)
    ActiveRecord::Base.connection.execute("DELETE FROM associated_module_projects WHERE module_project_id = #{@project_module.id} OR associated_module_project_id = #{@project_module.id} ")

    #Update column module_projects link with initialization module
    update_link_between_modules(@project, @project_module)
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end


  def pemodules_left
    @project_module = ModuleProject.find(params[:module_id])
    @project = @project_module.project

    authorize! :alter_estimation_plan, @project

    last_position_x = nil
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    if @project_module.position_x.to_i > 1
      current_pmodule = @project.module_projects.where('position_x =? AND position_y =?', @project_module.position_x.to_i-1, @project_module.position_y).first
      if current_pmodule
        current_pmodule.update_attribute('position_x', @project_module.position_x.to_i)
      end
      last_position_x = @project_module.position_x

      @project_module.update_attribute('position_x', @project_module.position_x.to_i - 1 )
    end

    #Update Current module_project links
    update_link_between_modules(@project, @project_module, last_position_x)
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end


  def pemodules_right
    @project_module = ModuleProject.find(params[:module_id])
    @project = @project_module.project
    last_position_x = nil

    authorize! :alter_estimation_plan, @project

    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    current_pmodule = @project.module_projects.where('position_x =? AND position_y =?', @project_module.position_x.to_i+1, @project_module.position_y.to_i).first

    if current_pmodule
      current_pmodule.update_attribute('position_x', @project_module.position_x.to_i)
    end
    last_position_x = @project_module.position_x
    @project_module.update_attribute('position_x', @project_module.position_x.to_i + 1 )
    update_link_between_modules(@project, @project_module, last_position_x)

    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end


  def find_use_pemodule
    #TODO Authorize #saly
    authorize! :manage_master_data, :all

    pemodule_id = params[:pemodule_id].nil? ? params[:pemodule_instance_id] : params[:pemodule_id]

    if params[:pemodule_id]
      @pemodule = Pemodule.find(params[:pemodule_id])
      @pemodule_title = @pemodule.title
      @related_projects = ModuleProject.find_all_by_pemodule_id(@pemodule.id)

    #elsif params[:guw_model_id]
    #  @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    #  @pemodule_title = @guw_model.name
    #  @organization = @guw_model.organization
    #  @related_projects = ModuleProject.where(guw_model_id: params[:guw_model_id]).uniq
    else
      if !params[:instance_model_name].nil?
        case params[:instance_model_name]
          when "guw_model_id"
            @instance_model = Guw::GuwModel.find(params[:instance_model_id])
          when "ge_model_id"
            @instance_model = Ge::GeModel.find(params[:instance_model_id])
          when "wbs_activity_id"
            @instance_model = WbsActivity.find(params[:instance_model_id])
          when "expert_judgement_instance_id"
            @instance_model = ExpertJudgement::Instance.find(params[:instance_model_id])
        end

        @pemodule_title = @instance_model.name
        @organization = @instance_model.organization
        @related_projects = ModuleProject.where("#{params[:instance_model_name]}" => params[:instance_model_id]).uniq
      end
    end
  end

  def find_use_pemodule_save
    #TODO Authorize #saly
    authorize! :manage_master_data, :all

    @pemodule = Pemodule.find(params[:pemodule_id])
    @related_projects = ModuleProject.find_all_by_pemodule_id(@pemodule.id)
  end

end
