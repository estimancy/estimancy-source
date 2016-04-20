##########################################################################
#
# ProjEstimate, Open Source project estimation web application
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
########################################################################

# After each update of estimation value, this worker will be call to recompute estimation value for its parent component
class OrganizationDuplicateProjectWorker
  include Sidekiq::Worker

  def perform(est_model_id, new_organization_id, user_id)
    est_model = Project.find(est_model_id)
    new_organization = Organization.find(new_organization_id)
    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      new_template = execute_duplication(est_model.id, new_organization.id, user_id)
      unless new_template.nil?
        new_template.is_model = est_model.is_model
        new_template.save
      end
    end

  rescue ActiveRecord::RecordNotFound
  end


  # Method that execute the duplication: duplicate estimation model for organization
  def execute_duplication(project_id, new_organization_id, user_id)

    user = User.find(user_id)

    #begin
    old_prj = Project.find(project_id)
    new_organization = Organization.find(new_organization_id)

    new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
    new_prj.organization_id = new_organization_id
    new_prj.title = old_prj.title
    new_prj.description = old_prj.description
    new_estimation_status = new_organization.estimation_statuses.where(copy_id: new_prj.estimation_status_id).first
    new_estimation_status_id = new_estimation_status.nil? ? nil : new_estimation_status.id
    new_prj.estimation_status_id = new_estimation_status_id

    if old_prj.is_model
      new_prj.is_model = true
    else
      new_prj.is_model = false
    end

    if new_prj.save
      old_prj.save #Original project copy number will be incremented to 1

      #Managing the component tree : PBS
      pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

      # For PBS
      new_prj_components = pe_wbs_product.pbs_project_elements
      new_prj_components.each do |new_c|
        new_ancestor_ids_list = []
        new_c.ancestor_ids.each do |ancestor_id|
          ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
          new_ancestor_ids_list.push(ancestor_id)
        end
        new_c.ancestry = new_ancestor_ids_list.join('/')
        new_c.save
      end

      #Update the project securities for the current user who create the estimation from model
      #if params[:action_name] == "create_project_from_template"
      if old_prj.is_model
        creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
        unless creator_securities.nil?
          creator_securities.update_attribute(:user_id, user.id)
        end
      end
      #Other project securities for groups
      new_prj.project_securities.where('group_id IS NOT NULL').each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        new_group = new_organization.groups.where(copy_id: project_security.group_id).first
        if new_security_level.nil? || new_group.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id, group_id: new_group.id)
        end
      end

      #Other project securities for users
      new_prj.project_securities.where('user_id IS NOT NULL').each do |project_security|
        new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
        if new_security_level.nil?
          project_security.destroy
        else
          project_security.update_attributes(project_security_level_id: new_security_level.id)
        end
      end

      # For ModuleProject associations
      old_prj.module_projects.group(:id).each do |old_mp|
        new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

        # ModuleProject Associations for the new project
        old_mp.associated_module_projects.each do |associated_mp|
          new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
          new_mp.associated_module_projects << new_associated_mp
        end

        # if the module_project view is nil
        #if new_mp.view.nil?
        #  default_view = new_organization.views.where('pemodule_id = ? AND is_default_view = ?', new_mp.pemodule_id, true).first
        #  if default_view.nil?
        #    default_view = View.create(name: "#{new_mp} view", description: "", pemodule_id: new_mp.pemodule_id, organization_id: new_organization_id)
        #  end
        #  new_mp.update_attribute(:view_id, default_view.id)
        #end

        #Recreate view for all moduleproject as the projects are not is the same organization
        #Copy the views and widgets for the new project
        #mp_default_view =
        #if old_mp.view.nil?
        #
        #else
        #
        #end

        new_view = View.create(organization_id: new_organization_id, pemodule_id: new_mp.pemodule_id, name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "")
        # We have to copy all the selected view's widgets in a new view for the current module_project
        if old_mp.view
          old_mp_view_widgets = old_mp.view.views_widgets.all
          old_mp_view_widgets.each do |view_widget|
            new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
            new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
            widget_est_val = view_widget.estimation_value
            unless widget_est_val.nil?
              in_out = widget_est_val.in_out
              widget_pe_attribute_id = widget_est_val.pe_attribute_id
              unless new_view_widget_mp.nil?
                new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
                estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
                widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id, name: view_widget.name, show_name: view_widget.show_name,
                                                 icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                 width: view_widget.width, height: view_widget.height, position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)

                pf = ProjectField.where(project_id: new_prj.id, views_widget_id: view_widget.id).first
                unless pf.nil?
                  new_field = new_organization.fields.where(copy_id: pf.field_id).first
                  pf.views_widget_id = widget_copy.id
                  pf.field_id = new_field.nil? ? nil : new_field.id
                  pf.save
                end
              end
            end
          end
        end
        #update the new module_project view
        new_mp.update_attribute(:view_id, new_view.id)
        ###end

        #Update the Unit of works's groups
        new_mp.guw_unit_of_work_groups.each do |guw_group|
          new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
          new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id

          #technology
          new_technology = new_organization.organization_technologies.where(copy_id: guw_group.organization_technology_id).first
          new_technology_id = new_technology.nil? ? nil : new_technology.id

          guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id, organization_technology_id: new_technology_id)

          # Update the group unit of works and attributes
          guw_group.guw_unit_of_works.each do |guw_uow|
            new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
            new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

            #PBS
            new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
            new_pbs_id = new_pbs.nil? ? nil : new_pbs.id

            # GuwModel
            new_guw_model = new_organization.guw_models.where(copy_id: guw_uow.guw_model_id).first
            new_guw_model_id = new_guw_model.nil? ? nil : new_guw_model.id

            # guw_work_unit
            if !new_guw_model.nil?
              new_guw_work_unit = new_guw_model.guw_work_units.where(copy_id: guw_uow.guw_work_unit_id).first
              new_guw_work_unit_id = new_guw_work_unit.nil? ? nil : new_guw_work_unit.id

              #Type
              new_guw_type = new_guw_model.guw_types.where(copy_id: guw_uow.guw_type_id).first
              new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

              #Complexity
              if !guw_uow.guw_complexity_id.nil? && !new_guw_type.nil?
                new_complexity = new_guw_type.guw_complexities.where(copy_id: guw_uow.guw_complexity_id).first
                new_complexity_id = new_complexity.nil? ? nil : new_complexity.id
              else
                new_complexity_id = nil
              end

            else
              new_guw_work_unit_id = nil
              new_guw_type_id = nil
              new_complexity_id = nil
            end

            #Technology
            uow_new_technology = new_organization.organization_technologies.where(copy_id: guw_uow.organization_technology_id).first
            uow_new_technology_id = uow_new_technology.nil? ? nil : uow_new_technology.id

            guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id, guw_model_id: new_guw_model_id,
                                      guw_type_id: new_guw_type_id, guw_work_unit_id: new_guw_work_unit_id, guw_complexity_id: new_complexity_id,
                                      organization_technology_id: uow_new_technology_id)
          end
        end

        # UOW-INPUTS
        # new_mp.uow_inputs.each do |uo|
        #   new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
        #   new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
        #   uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
        # end

        #WBS-ACTIVITY-INPUTS
        new_mp.wbs_activity_inputs.each do |activity_input|
          new_wbs_activity = new_organization.wbs_activities.where(copy_id: activity_input.wbs_activity_id).first
          unless new_wbs_activity.nil?
            new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: activity_input.wbs_activity_ratio_id).first
            unless new_wbs_activity_ratio.nil?
              activity_input.update_attributes(wbs_activity_id: new_wbs_activity.id, wbs_activity_ratio_id: new_wbs_activity_ratio.id)
            end
          end
        end

        ["input", "output"].each do |io|
          new_mp.pemodule.pe_attributes.each do |attr|
            old_prj.pbs_project_elements.each do |old_component|
              new_prj_components.each do |new_component|
                ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                unless ev.nil?
                  ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
                  ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
                  ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
                  ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id
                  ev.save
                end
              end
            end
          end
        end
      end

    else
      new_prj = nil
    end

    #rescue
      #new_prj = nil
    #end

    new_prj
  end


  #def execute_duplication_SAVE(project_id, new_organization_id, user_id)
  #
  #  user = User.find(user_id)
  #
  #  #begin
  #  old_prj = Project.find(project_id)
  #  new_organization = Organization.find(new_organization_id)
  #
  #  new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
  #  new_prj.organization_id = new_organization_id
  #  new_prj.title = old_prj.title
  #
  #  new_prj.ancestry = nil
  #  if old_prj.is_model
  #    new_prj.is_model = true
  #  else
  #    new_prj.is_model = false
  #  end
  #
  #  if new_prj.save
  #    old_prj.save #Original project copy number will be incremented to 1
  #
  #    #Managing the component tree : PBS
  #    pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first
  #
  #    # For PBS
  #    new_prj_components = pe_wbs_product.pbs_project_elements
  #    new_prj_components.each do |new_c|
  #      new_ancestor_ids_list = []
  #      new_c.ancestor_ids.each do |ancestor_id|
  #        ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
  #        new_ancestor_ids_list.push(ancestor_id)
  #      end
  #      new_c.ancestry = new_ancestor_ids_list.join('/')
  #      new_c.save
  #    end
  #
  #    #Update the project securities for the current user who create the estimation from model
  #    #if params[:action_name] == "create_project_from_template"
  #    if old_prj.is_model
  #      creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
  #      unless creator_securities.nil?
  #        creator_securities.update_attribute(:user_id, user.id)
  #      end
  #    end
  #    #Other project securities for groups
  #    new_prj.project_securities.where('group_id IS NOT NULL').each do |project_security|
  #      new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
  #      new_group = new_organization.groups.where(copy_id: project_security.group_id).first
  #      if new_security_level.nil? || new_group.nil?
  #        project_security.destroy
  #      else
  #        project_security.update_attributes(project_security_level_id: new_security_level.id, group_id: new_group.id)
  #      end
  #    end
  #
  #    #Other project securities for users
  #    new_prj.project_securities.where('user_id IS NOT NULL').each do |project_security|
  #      new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
  #      if new_security_level.nil?
  #        project_security.destroy
  #      else
  #        project_security.update_attributes(project_security_level_id: new_security_level.id)
  #      end
  #    end
  #
  #    # For ModuleProject associations
  #    old_prj.module_projects.group(:id).each do |old_mp|
  #      new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)
  #
  #      # ModuleProject Associations for the new project
  #      old_mp.associated_module_projects.each do |associated_mp|
  #        new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
  #        new_mp.associated_module_projects << new_associated_mp
  #      end
  #
  #      # if the module_project view is nil
  #      if new_mp.view.nil?
  #        default_view = new_organization.views.where('pemodule_id = ? AND is_default_view = ?', new_mp.pemodule_id, true).first
  #        if default_view.nil?
  #          default_view = View.create(name: "#{new_prj.to_s} : #{new_mp} view", description: "", pemodule_id: new_mp.pemodule_id, organization_id: new_organization_id)
  #        end
  #        new_mp.update_attribute(:view_id, default_view.id)
  #      end
  #
  #      #Recreate view for all moduleproject as the projects are not is the same organization
  #      ###if old_mp.pemodule.alias == Projestimate::Application::INITIALIZATION
  #      #Copy the views and widgets for the new project
  #      new_view = View.create(organization_id: new_organization_id, pemodule_id: new_mp.pemodule_id,  name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "")
  #      ##We have to copy all the selected view's widgets in a new view for the current module_project
  #      if old_mp.view
  #        old_mp_view_widgets = old_mp.view.views_widgets.all
  #        old_mp_view_widgets.each do |view_widget|
  #          new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
  #          new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
  #          widget_est_val = view_widget.estimation_value
  #          unless widget_est_val.nil?
  #            in_out = widget_est_val.in_out
  #            widget_pe_attribute_id = widget_est_val.pe_attribute_id
  #            unless new_view_widget_mp.nil?
  #              new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
  #              estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
  #              widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id, name: view_widget.name, show_name: view_widget.show_name,
  #                                               icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
  #                                               width: view_widget.width, height: view_widget.height, position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)
  #
  #              pf = ProjectField.where(project_id: new_prj.id, views_widget_id: view_widget.id).first
  #              unless pf.nil?
  #                new_field = new_organization.fields.where(copy_id: pf.field_id).first
  #                pf.views_widget_id = widget_copy.id
  #                pf.field_id = new_field.nil? ? nil : new_field.id
  #                pf.save
  #              end
  #            end
  #          end
  #        end
  #      end
  #      #update the new module_project view
  #      new_mp.update_attribute(:view_id, new_view.id)
  #      ###end
  #
  #      #Update the Unit of works's groups
  #      new_mp.guw_unit_of_work_groups.each do |guw_group|
  #        new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
  #        new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
  #        guw_group.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
  #
  #        # Update the group unit of works and attributes
  #        guw_group.guw_unit_of_works.each do |guw_uow|
  #          new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
  #          new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id
  #
  #          new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
  #          new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
  #          guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id)
  #        end
  #      end
  #
  #      new_mp.uow_inputs.each do |uo|
  #        new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
  #        new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
  #
  #        uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
  #      end
  #
  #      ["input", "output"].each do |io|
  #        new_mp.pemodule.pe_attributes.each do |attr|
  #          old_prj.pbs_project_elements.each do |old_component|
  #            new_prj_components.each do |new_component|
  #              ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
  #              unless ev.nil?
  #                ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
  #                ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
  #                ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
  #                ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id
  #                ev.save
  #              end
  #            end
  #          end
  #        end
  #      end
  #    end
  #
  #  else
  #    new_prj = nil
  #  end
  #
  #  #rescue
  #  #new_prj = nil
  #  #end
  #
  #  new_prj
  #end
end