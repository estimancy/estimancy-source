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
class AbilityView
  include CanCan::Ability

  def initialize(user, organization, projects, nb_project = 1, estimation_view = true)

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
          organization_projects = projects#.compact

          #remettre getsorted pour la liste complete des devis
          # organization_projects = get_sorted_estimations(organization.id, projects, sort_column, sort_order, search_hash, min, max, action)

          #@permissions_by_group_and_status = $permissions_by_group_and_status #Hash.new
          @permissions_by_group_and_status = Hash.new
          organization_estimation_statuses = organization.estimation_statuses
          user_groups = user.groups.where(organization_id: organization.id)
          organization_project_securities = ProjectSecurity.includes(:project, :project_security_level)
                                                           .where(organization_id: organization.id,
                                                                  is_model_permission: false,
                                                                  is_estimation_permission: true)
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
                    can perm_alias, perm_object_associated, :is_model => true
                  else
                    can perm_alias, perm_object_associated
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
                            #can :manage, op, estimation_status_id: es.id
                          else
                            #@array_users << [permission.id, project.id, es.id]
                            can permission.alias.to_sym, [project, op], estimation_status_id: es.id
                            #can permission.alias.to_sym, op, estimation_status_id: es.id
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
              # grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status)
              #                                  .where(organization_id: organization.id).each do |esgr|
              #   esgr_security_level = esgr.project_security_level
              #   esgr_estimation_status_id = esgr.estimation_status_id
              #
              #   unless esgr_security_level.nil?
              #     @permissions_by_group_and_status[grp.id][esgr_estimation_status_id] = esgr_security_level.permissions.select{|i| i.is_permission_project }
              #     # prj_scrt_project_security_level_permissions.each do |permission|
              #     #   #organization_projects.select{|p| p.id == 31533}.each do |op|
              #     #   organization_projects.each do |op|
              #     #     project = op.is_a?(Project) ? op : op.project
              #     #     if permission.alias == "manage" and permission.category == "Project"
              #     #       can :manage, project, estimation_status_id: esgr_estimation_status_id
              #     #     else
              #     #       unless project.nil?
              #     #         #@array_status_groups.push([permission.id, project.id, esgr_estimation_status_id])
              #     #         array_status_per_group.push([permission.id, project.id, esgr_estimation_status_id])
              #     #       end
              #     #     end
              #     #   end
              #     # end
              #
              #   end
              # end

              prj_scrts = organization_project_securities.where(group_id: grp.id)

              organization_projects.each do |op|
                #organization_projects.each do |project|
                project = op.is_a?(Project) ? op : op.project

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
                              can :manage, [project, op], estimation_status_id: estimation_status_id
                              #can :manage, op, estimation_status_id: estimation_status_id
                            else
                              can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
                              #can permission.alias.to_sym, op, estimation_status_id: estimation_status_id
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
                              #can :manage, op, estimation_status_id: estimation_status_id
                            else
                              can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
                              #can permission.alias.to_sym, op, estimation_status_id: estimation_status_id
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end

              #puts "Finished"
            end
          end
        end
      end
    end
  end

  #Initialize Ability then load permissions
  def initialize_13_09_2021_qui_marche(user, organization, projects, nb_project = 1, estimation_view = true)

    owner ||= (@owner.nil? ? get_owner_user : @owner)

    #Uncomment in order to authorize everybody to manage all the app
    unless user.nil?
      if Rails.env == "test" || user.super_admin == true
        can :manage, :all
      else
        #Only the super-admin has the rights to manage the master-data
        if user.super_admin?
          can :manage_master_data, :all
        end

        if !organization.nil?

          # if estimation_view == false
          #   organization_projects = projects
          # else
          #   organization_projects = organization.organization_estimations
          # end

          #La gestion des paramètres se fait fait dans ApplicationController ==> current_ability
          organization_projects = projects#.compact

          #remettre getsorted pour la liste complete des devis
          # organization_projects = get_sorted_estimations(organization.id, projects, sort_column, sort_order, search_hash, min, max, action)

          organization_estimation_statuses = organization.estimation_statuses
          user_groups = user.groups.where(organization_id: organization.id)
          organization_project_securities = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                                              is_model_permission: false,
                                                                                                              is_estimation_permission: true)
          users_array = [user.id]
          if owner
            users_array << owner.id
          end
          user_owner_prj_scrts = organization_project_securities.where(user_id: users_array).all

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
            permissions_array = []

            user_groups.includes(:permissions).map do |grp|
              grp.permissions.map do |i|
                if i.object_associated.blank?
                  permissions_array << [i.alias.to_sym, :all]
                else
                  permissions_array << [i.alias.to_sym, i.object_associated.constantize]
                end
              end
            end

            for perm in permissions_array
              unless perm[0].nil? or perm[1].nil?
                if perm[0] == :manage_estimation_models
                  can perm[0], perm[1], :is_model => true
                else
                  can perm[0], perm[1]
                end
              end
            end

            #For "manage_estimation_models", only models will be taken in account
            #When user can create a project template, he also can edit the model
            alias_action :edit_project, :is_model => true, :to => :manage_estimation_models
            alias_action :delete_project, :is_model => true, :to => :manage_estimation_models
            alias_action :create_project_from_template, :is_model => true, :to => :manage_estimation_models

            @array_users = Array.new
            @array_status_groups = Array.new
            @array_groups = Array.new
            @array_owners = Array.new
            @permissions_by_group_and_status = Hash.new

            unless user_owner_prj_scrts.empty?
              user_owner_prj_scrts.each do |prj_scrt|
                prj_scrt_project_security_level = prj_scrt.project_security_level
                unless prj_scrt_project_security_level.nil?
                  prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

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

              @permissions_by_group_and_status[grp.id] = Hash.new
              array_status_per_group = Array.new

              #on recupere les permissions en fonction des statuts
              grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status).where(organization_id: organization.id).each do |esgr|

                esgr_security_level = esgr.project_security_level
                esgr_estimation_status_id = esgr.estimation_status_id

                unless esgr_security_level.nil?
                  @permissions_by_group_and_status[grp.id][esgr_estimation_status_id] = esgr_security_level.permissions.select{|i| i.is_permission_project }

                  # prj_scrt_project_security_level_permissions.each do |permission|
                  #   #organization_projects.select{|p| p.id == 31533}.each do |op|
                  #   organization_projects.each do |op|
                  #     project = op.is_a?(Project) ? op : op.project
                  #     if permission.alias == "manage" and permission.category == "Project"
                  #       can :manage, project, estimation_status_id: esgr_estimation_status_id
                  #     else
                  #       unless project.nil?
                  #         #@array_status_groups.push([permission.id, project.id, esgr_estimation_status_id])
                  #         array_status_per_group.push([permission.id, project.id, esgr_estimation_status_id])
                  #       end
                  #     end
                  #   end
                  # end

                end
              end

              prj_scrts = organization_project_securities.where(group_id: grp.id)

              organization_projects.each do |op|
                #organization_projects.each do |project|
                project = op.is_a?(Project) ? op : op.project

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
                              can :manage, [project, op], estimation_status_id: estimation_status_id
                            else
                              can permission.alias.to_sym, [project, op], estimation_status_id: estimation_status_id
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

              #puts "Hello"

              # prj_scrts = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
              #                                                                               project_id: 31533,
              #                                                                               group_id: grp.id,
              #                                                                               is_model_permission: false,
              #                                                                               is_estimation_permission: true).all
              # unless prj_scrts.empty?
              #   specific_permissions_array = []
              #   prj_scrts.each do |prj_scrt|
              #     project = prj_scrt.project
              #     unless project.nil?
              #       prj_scrt_project_security_level = prj_scrt.project_security_level
              #       unless prj_scrt_project_security_level.nil?
              #         current_permissions = Array.new
              #         if ["TOUT", "*ALL"].include?(prj_scrt_project_security_level.name.to_s.upcase)
              #           if project.private == true && project.is_model != true
              #             @array_groups << []
              #           else
              #             #@array_groups = @array_groups + array_status_per_group
              #             project_estimation_status_id = project.estimation_status_id
              #             current_permissions = @permissions_by_group_and_status[grp.id][project_estimation_status_id]
              #
              #             # @permissions_by_group_and_status[grp.id][project_estimation_status_id].each do |permission|
              #             #   can permission.alias.to_sym, project, estimation_status_id: project_estimation_status_id
              #             # end
              #           end
              #         else
              #             prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }
              #             organization_estimation_statuses.each do |es|
              #
              #               possible_permissions = [ @permissions_by_group_and_status[grp.id][es.id], prj_scrt_project_security_level_permissions ].inject(:&)
              #
              #               possible_permissions.each do |permission|
              #                 if project.private == true && project.is_model != true
              #                   #@array_groups << []
              #                 else
              #                   if permission.alias == "manage" and permission.category == "Project"
              #                     can :manage, project, estimation_status_id: es.id
              #                   else
              #                     #@array_groups << [permission.id, project.id, es.id]
              #                     can permission.alias.to_sym, project, estimation_status_id: es.id
              #                   end
              #                 end
              #               end
              #             end
              #         end
              #       end
              #     end
              #   end
              # end

            end



            # global = @array_users + @array_groups + @array_owners
            # status = @array_status_groups
            #
            # status_global = [status, global].inject(:&)
            #
            # pe = Permission.where(id: status_global.map{|i| i[0]}.uniq).all
            # pp = Project.where(organization_id: organization.id, id: status_global.map{|i| i[1]}.uniq).all
            # ss = EstimationStatus.where(organization_id: organization.id, id: status_global.map{|i| i[2]}.uniq).all
            #
            # hash_permission = Hash.new
            # hash_project = Hash.new
            # hash_status = Hash.new
            #
            # pe.each do |permission|
            #   hash_permission[permission.id] = permission.alias.to_sym
            # end
            #
            # pp.each do |project|
            #   unless project.nil?
            #     hash_project[project.id] = project
            #   end
            # end
            #
            # ss.each do |e|
            #   hash_status[e.id] = e.id
            # end
            #
            # status_global.each_with_index do |a, i|
            #   unless hash_project[a[1]].nil?
            #     can hash_permission[a[0]], hash_project[a[1]], estimation_status_id: hash_status[a[2]]
            #   end
            # end
            #
          end
        end
      end
    end
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

  def initialize_SAVE_10_09_2021(user, organization, projects, nb_project = 1, estimation_view = true)

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
          organization_projects = projects#.compact

          @permissions_by_group_and_status = Hash.new
          organization_estimation_statuses = organization.estimation_statuses
          user_groups = user.groups.where(organization_id: organization.id)
          organization_project_securities = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                                              is_model_permission: false,
                                                                                                              is_estimation_permission: true)
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
            # permissions_array = []
            # user_groups.includes(:permissions).map do |grp|
            #   grp.permissions.map do |i|
            #     if i.object_associated.blank?
            #       permissions_array << [i.alias.to_sym, :all]
            #     else
            #       permissions_array << [i.alias.to_sym, i.object_associated.constantize]
            #     end
            #   end
            # end
            #
            # for perm in permissions_array
            #   unless perm[0].nil? or perm[1].nil?
            #     if perm[0] == :manage_estimation_models
            #       can perm[0], perm[1], :is_model => true
            #     else
            #       can perm[0], perm[1]
            #     end
            #   end
            # end
            #

            user_groups.includes(:permissions).map do |grp|
              grp.permissions.map do |i|
                perm_alias = i.alias
                unless perm_alias.blank?
                  perm_object_associated = i.object_associated.blank? ? ":all" : i.object_associated.constantize

                  if perm_alias == :manage_estimation_models
                    can perm_alias, perm_object_associated, :is_model => true
                  else
                    can perm_alias, perm_object_associated
                  end
                end
              end
            end

            #For "manage_estimation_models", only models will be taken in account
            #When user can create a project template, he also can edit the model
            alias_action :edit_project, :is_model => true, :to => :manage_estimation_models
            alias_action :delete_project, :is_model => true, :to => :manage_estimation_models
            alias_action :create_project_from_template, :is_model => true, :to => :manage_estimation_models

            @array_users = Array.new
            @array_status_groups = Array.new
            @array_groups = Array.new
            @array_owners = Array.new

            #User / Owner security loading
            unless user_owner_prj_scrts.empty?
              hash_organization_projects = Hash.new(Array.new())

              organization_projects.each do |op|
                hash_organization_projects[op.project_id] = op
              end

              user_owner_prj_scrts.each do |prj_scrt|
                prj_scrt_project_security_level = prj_scrt.project_security_level
                unless prj_scrt_project_security_level.nil?
                  prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

                  begin
                    organization_project = hash_organization_projects[prj_scrt.project_id]
                    project = prj_scrt.project
                  rescue
                    project = nil
                  end

                  unless project.nil?
                    if (prj_scrt.user_id == user.id) || ( prj_scrt.user_id == owner.id && user.id == project.creator_id)
                      organization_estimation_statuses.each do |es|
                        prj_scrt_project_security_level_permissions.each do |permission|
                          if permission.alias == "manage" and permission.category == "Project"
                            can :manage, project, estimation_status_id: es.id
                            can :manage, organization_project, estimation_status_id: es.id
                          else
                            @array_users << [permission.id, project.id, es.id]
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

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

            if owner
              prj_scrts = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                            user_id: owner.id,
                                                                                            is_model_permission: false,
                                                                                            is_estimation_permission: true).all
            end

            unless prj_scrts.empty?

              hash_organization_projects = Hash.new(Array.new())

              organization_projects.each do |op|
                hash_organization_projects[op.project_id] = op
              end

              prj_scrts.each do |prj_scrt|

                prj_scrt_project_security_level = prj_scrt.project_security_level

                unless prj_scrt_project_security_level.nil?

                  prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

                  begin
                    organization_project = hash_organization_projects[prj_scrt.project_id]
                    project = prj_scrt.project
                  rescue
                    project = nil
                  end

                  unless project.nil?
                    if user.id == project.creator_id
                      unless project.nil?
                        organization_estimation_statuses.each do |es|
                          prj_scrt_project_security_level_permissions.each do |permission|
                            if permission.alias == "manage" and permission.category == "Project"
                              can :manage, project, estimation_status_id: es.id
                              can :manage, organization_project, estimation_status_id: es.id
                            else
                              @array_owners << [permission.id, project.id, es.id]
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end

            user_groups.each do |grp|
              prj_scrts = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                            group_id: grp.id,
                                                                                            is_model_permission: false,
                                                                                            is_estimation_permission: true).all

              unless prj_scrts.empty?

                hash_organization_projects = Hash.new(Array.new())

                organization_projects.each do |op|
                  hash_organization_projects[op.project_id] = op
                end

                prj_scrts.each do |prj_scrt|

                  prj_scrt_project_security_level = ProjectSecurityLevel.includes([:permissions]).where(id: prj_scrt.project_security_level).first #prj_scrt.project_security_level

                  begin
                    organization_project = hash_organization_projects[prj_scrt.project_id]
                    project = prj_scrt.project
                  rescue
                    project = nil
                  end

                  unless project.nil?
                    unless prj_scrt_project_security_level.nil?

                      prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

                      organization_estimation_statuses.each do |es|
                        prj_scrt_project_security_level_permissions.each do |permission|
                          if project.private == true && project.is_model != true
                            @array_groups << []
                          else
                            if permission.alias == "manage" and permission.category == "Project"
                              can :manage, project, estimation_status_id: es.id
                              can :manage, organization_project, estimation_status_id: es.id
                            else
                              @array_groups << [permission.id, project.id, es.id]
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end

              #grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status).where(organization_id: organization.id).each do |esgr|
              grp.estimation_status_group_roles.where(organization_id: organization.id).each do |esgr|

                esgr_security_level = ProjectSecurityLevel.where(id: esgr.project_security_level_id).includes([:permissions]).first #esgr.project_security_level
                esgr_estimation_status_id = esgr.estimation_status_id

                unless esgr_security_level.nil?

                  prj_scrt_project_security_level_permissions = esgr_security_level.permissions.select{|i| i.is_permission_project }

                  prj_scrt_project_security_level_permissions.each do |permission|
                    organization_projects.each do |op|
                      project = op.is_a?(Project) ? op : op.project
                      if permission.alias == "manage" and permission.category == "Project"
                        can :manage, project, estimation_status_id: esgr_estimation_status_id
                        can :manage, op, estimation_status_id: esgr_estimation_status_id
                      else
                        unless project.nil?
                          @array_status_groups.push([permission.id, project.id, esgr_estimation_status_id])
                        end
                      end
                    end
                  end
                end
              end
            end

            global = @array_users + @array_groups + @array_owners
            status = @array_status_groups

            status_global = [status, global].inject(:&)

            pe = Permission.where(id: status_global.map{|i| i[0]}.uniq).all
            #pp = Project.where(organization_id: organization.id, id: status_global.map{|i| i[1]}.uniq).all
            pp = organization_projects.where(id: status_global.map{|i| i[1]}.uniq).all
            ss = EstimationStatus.where(organization_id: organization.id, id: status_global.map{|i| i[2]}.uniq).all

            hash_permission = Hash.new
            hash_project = Hash.new
            hash_status = Hash.new

            pe.each do |permission|
              hash_permission[permission.id] = permission.alias.to_sym
            end

            pp.each do |project|
              unless project.nil?
                hash_project[project.id] = project
              end
            end

            ss.each do |e|
              hash_status[e.id] = e.id
            end

            status_global.each_with_index do |a, i|
              unless hash_project[a[1]].nil?
                # can hash_permission[a[0]], hash_project[a[1]], estimation_status_id: hash_status[a[2]]
                # can hash_permission[a[0]], hash_project[a[1]].project, estimation_status_id: hash_status[a[2]]


                can hash_permission[a[0]], [Project, OrganizationEstimation], id: hash_project[a[1]].project.id, estimation_status_id: hash_status[a[2]]
              end
            end
          end
        end
      end
    end
  end

end