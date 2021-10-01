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

#Ability for role management. See CanCan on github fore more information about Role.
class AbilityProject
  include CanCan::Ability

  #Initialize Ability then load permissions
  #def initialize(user, organization, projects, for_estimation_list = false, historized = 0, nb_project = 1, estimation_view = true)
  def initialize(user, organization, projects, min=0, max=10, object_per_page=10, nb_project = 1, estimation_view = true)

    #Uncomment in order to authorize everybody to manage all the app
    unless user.nil?
      owner ||= (@owner.nil? ? get_owner_user : @owner)

      if Rails.env == "test" || user.super_admin == true
        can :manage, :all
      else
        #Only the super-admin has the rights to manage the master-data
        if user.super_admin?
          can :manage_master_data, :all
        end

        if !organization.nil?

          #La gestion des paramètres se fait fait dans ApplicationController ==> current_ability
          #organization_projects = projects #.compact

          $all_projects_to_see = Array.new

          #======  will be added to a before_filter method
          $permissions_by_group_and_status ||= HashWithIndifferentAccess.new
          $organization_estimation_statuses = organization.estimation_statuses
          $user_groups = user.groups.includes(:permissions).where(organization_id: organization.id)
          $user_groups.each do |grp|
            $permissions_by_group_and_status[grp.id] = Hash.new
            #grp.estimation_status_group_roles.includes(:project_security_level).where(organization_id: organization.id).each do |esgr|
            grp.estimation_status_group_roles.where(organization_id: organization.id).each do |esgr|
              esgr_security_level =  ProjectSecurityLevel.includes([:permissions]).where(organization_id: organization.id, id: esgr.project_security_level_id).first  #esgr.project_security_level.includes([:permissions])
              esgr_estimation_status_id = esgr.estimation_status_id
              unless esgr_security_level.nil?
                $permissions_by_group_and_status[grp.id][esgr_estimation_status_id] = esgr_security_level.permissions.select{|i| i.is_permission_project }
              end
            end
          end
          # =====

          @permissions_by_group_and_status = $permissions_by_group_and_status #Hash.new
          organization_estimation_statuses = $organization_estimation_statuses #organization.estimation_statuses
          user_groups = $user_groups   #user.groups.where(organization_id: organization.id)
          # organization_project_securities = ProjectSecurity.includes(:project, :project_security_level)
          #                                                  .where(organization_id: organization.id, is_model_permission: false, is_estimation_permission: true)
          # Add Action Aliases, for example:  alias_action :edit, :to => :update
          #For organization and estimations permissions
          alias_action :show_estimations_permissions, :to => :manage_estimations_permissions
          alias_action :manage_estimations_permissions, :show_organization_permissions, :to => :manage_organization_permissions
          alias_action :show_global_permissions, :to => :manage_global_permissions

          # For projects selected columns
          alias_action :show_projects_selected_columns, :to => :manage_projects_selected_columns

          # Notice the edit action is aliased to update. This means if the user is able to update a record he also has permission to edit it.
          alias_action [:show_groups, Group], :to => [:manage, Group]

          #For organization
          alias_action :show_organizations, :to => :edit_organizations
          alias_action :edit_organizations, :to => :create_organizations

          # For estimation: when we can edit a project, we can also see and show it
          alias_action :see_project, :to => :show_project
          alias_action :show_project, :to => :edit_project
          alias_action  :alter_estimation_name, :alter_product_name, :alter_estimation_status, :alter_project_areas, :alter_acquisition_categories, :alter_platform_categories, :alter_project_categories, :alter_providers, :alter_request_number, :to => :edit_project
          alias_action :execute_estimation_plan, :manage_estimation_widgets, :alter_estimation_status, :alter_project_status_comment, :commit_project, :to => :alter_estimation_plan
          alias_action :alter_estimation_plan, :manage_project_security, :to => :edit_project

          #For instance modules
          alias_action :show_modules_instances, :to => :manage_modules_instances

          #Load user groups permissions
          if user && !user_groups.empty?
            #user_groups.includes(:permissions).map do |grp|
            user_groups.map do |grp|
              grp.permissions.map do |i|
                perm_alias = i.alias
                unless perm_alias.blank?
                  perm_object_associated = i.object_associated.blank? ? ":all" : i.object_associated.constantize
                  if perm_alias == :manage_estimation_models
                    can perm_alias.to_sym, perm_object_associated, :is_model => true
                  else
                    can perm_alias.to_sym, perm_object_associated
                  end
                end
              end
            end

            #For "manage_estimation_models", only models will be taken in account
            #When user can create a project template, he also can edit the model
            alias_action :edit_project, :is_model => true, :to => :manage_estimation_models
            alias_action :delete_project, :is_model => true, :to => :manage_estimation_models
            alias_action :create_project_from_template, :is_model => true, :to => :manage_estimation_models

            #projects.where(id: [31550, 31533]).includes(:project_securities).each do |op|
            # BETWEEN ((@PageNumber-1)*@RowsPerPage)+1 AND @RowsPerPage*(@PageNumber)
            # res[@min..@max-1]

            object_per_page = object_per_page.nil? ? 10 : object_per_page
            min = min.nil? ? 0 : min.to_i
            max = max.nil? ? object_per_page : max.to_i
            max_projects_number = max - min
            #max_projects_number = max.nil? ? object_per_page : (max.to_i+object_per_page.to_i)
            projects_size = projects.size

            #organization_projects = get_sorted_estimations(organization.id, all_projects, @sort_column, @sort_order, @search_hash)
            #organization_projects = ApplicationController.helpers.get_sorted_estimations(organization.id, projects, "", "")

            @nb_projects = 0
            projects.all[min..projects_size].each do |op|
              #projects.each do |op|
            #projects.includes(:project_securities).find_in_batches(batch_size: 10) do |organization_projects|
            nb_permissions_per_project = 0
            break op if @nb_projects > max_projects_number #max #if @nb_projects < max_projects_number #max #object_per_page
            #organization_projects.each do |op|
            project = op.is_a?(Project) ? op : op.project
            prj_scrts = project.project_securities.includes(:project_security_level).where(is_model_permission: false, is_estimation_permission: true)
            user_project_security_levels = prj_scrts.where(user_id: user.id).map(&:project_security_level)

            user_groups.each do |group|
              grp_project_security_levels = prj_scrts.where(group_id: group.id).map(&:project_security_level) + user_project_security_levels

              if project.creator_id == user.id
                owner_project_security_levels = prj_scrts.where(user_id: owner.id).map(&:project_security_level) rescue []
                grp_project_security_levels += owner_project_security_levels
              end

              grp_project_security_levels.uniq.each do |project_security_level|
                #set_abilities_for_project_security_level(project, op, group, project_security_level)

                if ["TOUT", "*ALL"].include?(project_security_level.name.to_s.upcase)
                  if project.private == true && project.is_model != true
                    #nothing to do
                  else
                    @permissions_by_group_and_status[group.id].each do |estimation_status_id, permissions|

                      permissions.each do |permission|
                        if permission.alias == "manage" and permission.category == "Project"
                          can :manage, [project, op], estimation_status_id: estimation_status_id
                          can :manage, [Project, OrganizationEstimation], id: project.id, estimation_status_id: estimation_status_id
                        else
                          can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
                          can permission.alias.to_sym, [Project, OrganizationEstimation], id: project.id,  estimation_status_id: estimation_status_id
                        end
                        nb_permissions_per_project += 1
                      end
                    end
                  end
                else
                  project_security_level_permissions = project_security_level.permissions.select{|i| i.is_permission_project }
                  @permissions_by_group_and_status[group.id].each do |estimation_status_id, permissions|
                    possible_permissions = [permissions, project_security_level_permissions].inject(:&)

                    possible_permissions.each do |permission|
                      if project.private == true && project.is_model != true
                        #nothing
                      else
                        if permission.alias == "manage" and permission.category == "Project"
                          can :manage, [project, op], estimation_status_id: estimation_status_id
                          can :manage, [Project, OrganizationEstimation], id: project.id, estimation_status_id: estimation_status_id
                        else
                          can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
                          can permission.alias.to_sym, [Project, OrganizationEstimation], id: project.id, estimation_status_id: estimation_status_id
                        end
                        nb_permissions_per_project += 1
                      end
                    end
                  end
                end
              end
            end

            if nb_permissions_per_project > 0
              $all_projects_to_see << project
              @nb_projects += 1
            end
            #end
            #end
            end
            #end
            puts "Finished"
            #end
          end
        end
      end
    end
  end


  def set_abilities_for_project_security_level(project, op, group, project_security_level)

    if ["TOUT", "*ALL"].include?(project_security_level.name.to_s.upcase)
      if project.private == true && project.is_model != true
        #nothing to do
      else
        @permissions_by_group_and_status[group.id].each do |estimation_status_id, permissions|
          permissions.each do |permission|
            if permission.alias == "manage" and permission.category == "Project"
              #can :manage, [project, op], estimation_status_id: estimation_status_id
              can :manage, project, estimation_status_id: estimation_status_id
              can :manage, op, estimation_status_id: estimation_status_id
            else
              #can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
              can permission.alias.to_sym, project, estimation_status_id: estimation_status_id
              can permission.alias.to_sym, op, estimation_status_id: estimation_status_id
            end
          end
        end
      end
    else
      project_security_level_permissions = project_security_level.permissions.select{|i| i.is_permission_project }

      @permissions_by_group_and_status[group.id].each do |estimation_status_id, permissions|
        possible_permissions = [permissions, project_security_level_permissions].inject(:&)

        possible_permissions.each do |permission|
          if project.private == true && project.is_model != true
            #nothing
          else
            if permission.alias == "manage" and permission.category == "Project"
              can :manage, [project, op], estimation_status_id: estimation_status_id
            else
              can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
            end
          end
        end
      end
    end
  end







  def set_project_abilities(projects)
  end



  def get_owner_user
    owner_key = AdminSetting.find_by_key("Estimation Owner")
    if owner_key.nil?
      owner_key = AdminSetting.create(key: "Estimation Owner", value: "*OWNER")
      owner = User.where(first_name: "*", last_name: "OWNER", login_name: "owner", initials: owner_key.value, email: "contact@estimancy.com").first
      if owner.nil?
        owner = User.new(first_name: "*", last_name: "OWNER", login_name: "owner", initials: owner_key.value, email: "contact@estimancy.com")
        owner.skip_confirmation_notification!
        owner.save(validate: false)
        Organization.all.each do |o|
          o.users << owner
          o.save
        end
      end
    else
      owner = User.where(first_name: "*", last_name: "OWNER", login_name: "owner", initials: owner_key.value, email: "contact@estimancy.com").first
      if owner.nil?
        owner = User.new(first_name: "*", last_name: "OWNER", login_name: "owner", initials: owner_key.value, email: "contact@estimancy.com")
        owner.skip_confirmation_notification!
        owner.save(validate: false)
      end
      owner = User.find_by_initials(owner_key.value)
    end
  end


  def initialize_save_13_09_2021_avant_eager_load(user, organization, projects, for_estimation_list = false, historized = 0, nb_project = 1, estimation_view = true)

    #Uncomment in order to authorize everybody to manage all the app
    unless user.nil?
      owner ||= (@owner.nil? ? get_owner_user : @owner)

      if Rails.env == "test" || user.super_admin == true
        can :manage, :all
      else
        #Only the super-admin has the rights to manage the master-data
        if user.super_admin?
          can :manage_master_data, :all
        end

        if !organization.nil?

          #La gestion des paramètres se fait fait dans ApplicationController ==> current_ability
          #organization_projects = projects #.compact

          @permissions_by_group_and_status = $permissions_by_group_and_status #Hash.new
          organization_estimation_statuses = organization.estimation_statuses
          user_groups = user.groups.where(organization_id: organization.id)
          organization_project_securities = ProjectSecurity.includes(:project, :project_security_level)
                                                           .where(organization_id: organization.id, is_model_permission: false, is_estimation_permission: true)
          users_array = [user.id]
          if owner
            users_array << owner.id
          end
          user_owner_prj_scrts = organization_project_securities.where(user_id: users_array)

          # Add Action Aliases, for example:  alias_action :edit, :to => :update
          #For organization and estimations permissions
          alias_action :show_estimations_permissions, :to => :manage_estimations_permissions
          alias_action :manage_estimations_permissions, :show_organization_permissions, :to => :manage_organization_permissions
          alias_action :show_global_permissions, :to => :manage_global_permissions

          # For projects selected columns
          alias_action :show_projects_selected_columns, :to => :manage_projects_selected_columns

          # Notice the edit action is aliased to update. This means if the user is able to update a record he also has permission to edit it.
          alias_action [:show_groups, Group], :to => [:manage, Group]

          #For organization
          alias_action :show_organizations, :to => :edit_organizations
          alias_action :edit_organizations, :to => :create_organizations

          # For estimation: when we can edit a project, we can also see and show it
          alias_action :see_project, :to => :show_project
          alias_action :show_project, :to => :edit_project
          alias_action  :alter_estimation_name, :alter_product_name, :alter_estimation_status, :alter_project_areas, :alter_acquisition_categories, :alter_platform_categories, :alter_project_categories, :alter_providers, :alter_request_number, :to => :edit_project
          alias_action :execute_estimation_plan, :manage_estimation_widgets, :alter_estimation_status, :alter_project_status_comment, :commit_project, :to => :alter_estimation_plan
          alias_action :alter_estimation_plan, :manage_project_security, :to => :edit_project

          #For instance modules
          alias_action :show_modules_instances, :to => :manage_modules_instances

          #Load user groups permissions
          if user && !user_groups.empty?
            user_groups.includes(:permissions).map do |grp|
              grp.permissions.map do |i|
                perm_alias = i.alias
                unless perm_alias.blank?
                  perm_object_associated = i.object_associated.blank? ? ":all" : i.object_associated.constantize
                  if perm_alias == :manage_estimation_models
                    can perm_alias.to_sym, perm_object_associated, :is_model => true
                  else
                    can perm_alias.to_sym, perm_object_associated
                  end
                end
              end
            end

            #For "manage_estimation_models", only models will be taken in account
            #When user can create a project template, he also can edit the model
            alias_action :edit_project, :is_model => true, :to => :manage_estimation_models
            alias_action :delete_project, :is_model => true, :to => :manage_estimation_models
            alias_action :create_project_from_template, :is_model => true, :to => :manage_estimation_models

            unless user_owner_prj_scrts.empty?
              user_owner_prj_scrts.each do |prj_scrt|
                prj_scrt_project_security_level = prj_scrt.project_security_level
                unless prj_scrt_project_security_level.nil?
                  prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

                  #project = prj_scrt.project
                  op = prj_scrt.project
                  project = op.is_a?(Project) ? op : op.project

                  unless project.nil?
                    if (prj_scrt.user_id == user.id) || ( prj_scrt.user_id == owner.id && user.id == project.creator_id)
                      organization_estimation_statuses.each do |es|
                        prj_scrt_project_security_level_permissions.each do |permission|
                          if permission.alias == "manage" and permission.category == "Project"
                            can :manage, [project, op], estimation_status_id: es.id
                          else
                            #@array_users << [permission.id, project.id, es.id]
                            can permission.alias.to_sym, [project, op], estimation_status_id: es.id
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            user_groups.each do |grp|

              # @permissions_by_group_and_status[grp.id] = Hash.new
              # #on recupere les permissions en fonction des statuts
              # grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status).where(organization_id: organization.id).each do |esgr|
              #
              #   esgr_security_level = esgr.project_security_level
              #   esgr_estimation_status_id = esgr.estimation_status_id
              #
              #   unless esgr_security_level.nil?
              #     @permissions_by_group_and_status[grp.id][esgr_estimation_status_id] = esgr_security_level.permissions.select{|i| i.is_permission_project }
              #   end
              # end

              prj_scrts = organization_project_securities.where(group_id: grp.id)

              #Project.uncached do
              #Project.where(id: projects).find_in_batches(batch_size: 100) do |organization_projects|
              #sleep(2)
              #ActiveRecord::Base.transaction do
              organization_projects.each do |project|
                #organization_projects.each do |op|
                #project = op.is_a?(Project) ? op : op.project
                prj_scrts.where(project_id: project.id).each do |prj_scrt|

                  prj_scrt_project_security_level = prj_scrt.project_security_level
                  unless prj_scrt_project_security_level.nil?

                    if ["TOUT", "*ALL"].include?(prj_scrt_project_security_level.name.to_s.upcase)
                      if project.private == true && project.is_model != true
                        #nothing to do
                      else
                        @permissions_by_group_and_status[grp.id].each do |estimation_status_id, permissions|
                          permissions.each do |permission|
                            if permission.alias == "manage" and permission.category == "Project"
                              can :manage, project, estimation_status_id: estimation_status_id
                            else
                              can permission.alias.to_sym, project, estimation_status_id: estimation_status_id
                            end
                          end
                        end
                      end

                    else
                      prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }
                      @permissions_by_group_and_status[grp.id].each do |estimation_status_id, permissions|
                        possible_permissions = [ permissions, prj_scrt_project_security_level_permissions ].inject(:&)

                        possible_permissions.each do |permission|
                          if project.private == true && project.is_model != true
                            #nothing
                          else
                            if permission.alias == "manage" and permission.category == "Project"
                              can :manage, [project, op], estimation_status_id: estimation_status_id
                            else
                              can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
              #end
              #end
              #end

              #puts "Finished"
            end
          end
        end
      end
    end
  end


end