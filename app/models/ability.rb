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
class Ability
  include CanCan::Ability

  #Initialize Ability then load permissions
  def initialize(user, organization)

    #Uncomment in order to authorize everybody to manage all the app
    if Rails.env == "test" || user.super_admin == true
      can :manage, :all
    end

    #Only the super-admin has the rights to manage the master-data
    if user.super_admin?
      can :manage_master_data, :all
    end

    #cannot :update, [Language, PeAttribute, Currency, AdminSetting, AuthMethod, Permission], :record_status => {:name => 'Retired'}

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
    alias_action :alter_project_areas, :alter_acquisition_categories, :alter_platform_categories, :alter_project_categories, :to => :edit_project
    alias_action :execute_estimation_plan, :manage_estimation_widgets, :alter_estimation_status, :alter_project_status_comment, :commit_project, :to => :alter_estimation_plan
    alias_action :alter_estimation_plan, :manage_project_security, :to => :edit_project

    #For instance modules
    alias_action :show_modules_instances, :to => :manage_modules_instances

    #Load user groups permissions
    if user && !user.groups.where(organization_id: organization.id).empty?
      permissions_array = []

      #user.groups.where(organization_id: organization.id).map do |grp|
      user.groups.where(organization_id: organization.id).includes(:permissions).map do |grp|
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

      @array_users = Array.new
      @array_status_groups = Array.new
      @array_groups = Array.new
      @array_owners = Array.new

      #Specfic project security loading
      prj_scrts = ProjectSecurity.includes(:project, :project_security_level).find_all_by_user_id_and_is_model_permission_and_is_estimation_permission(user.id, false, true)
      unless prj_scrts.empty?
        specific_permissions_array = []
        prj_scrts.each do |prj_scrt|
          unless prj_scrt.project_security_level.nil?
            project = prj_scrt.project
            unless project.nil?
              organization.estimation_statuses.each do |es|
                prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
                  if permission.alias == "manage" and permission.category == "Project"
                    can :manage, project, estimation_status_id: es.id
                  else
                    @array_users << [permission.id, project.id, es.id]
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
        prj_scrts = ProjectSecurity.includes(:project, :project_security_level).find_all_by_user_id_and_is_model_permission_and_is_estimation_permission(owner.id, false, true)
      end

      unless prj_scrts.empty?
        specific_permissions_array = []
        prj_scrts.each do |prj_scrt|
          unless prj_scrt.project_security_level.nil?
            project = prj_scrt.project
            unless project.nil?
              if user.id == project.creator_id
                unless project.nil?
                  organization.estimation_statuses.each do |es|
                    prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
                      if permission.alias == "manage" and permission.category == "Project"
                        can :manage, project, estimation_status_id: es.id
                        # @array_owners = []
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

      user.groups.where(organization_id: organization.id).each do |grp|
        prj_scrts = ProjectSecurity.includes(:project, :project_security_level).find_all_by_group_id_and_is_model_permission_and_is_estimation_permission(grp.id, false, true)
        unless prj_scrts.empty?
          specific_permissions_array = []
          prj_scrts.each do |prj_scrt|
            # Get the project/estimation permissions
            project = prj_scrt.project
            unless project.nil?
              unless prj_scrt.project_security_level.nil?
                organization.estimation_statuses.each do |es|
                  prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
                    if prj_scrt.project.private == true && project.is_model != true
                      @array_groups << []
                    else
                      if permission.alias == "manage" and permission.category == "Project"
                        can :manage, project, estimation_status_id: es.id
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

        grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status).each do |esgr|
          esgr_security_level = esgr.project_security_level
          unless esgr_security_level.nil?
            esgr_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
              organization.projects.each do |project|
                if permission.alias == "manage" and permission.category == "Project"
                  can :manage, project, estimation_status_id: esgr.estimation_status.id
                else
                  @array_status_groups << [permission.id, project.id, esgr.estimation_status.id]
                end
              end
            end
          end
        end
      end

      global = @array_users + @array_groups + @array_owners
      status = @array_status_groups

      pe = Permission.where(id: [status, global].inject(:&).map{|i| i[0]}).all
      pp = Project.where(id: [status, global].inject(:&).map{|i| i[1]}).all
      ss = EstimationStatus.where(id: [status, global].inject(:&).map{|i| i[2]}).all

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

      [status, global].inject(:&).each_with_index do |a, i|
        unless hash_project[a[1]].nil?
          # p "#{hash_permission[a[0]]}, #{hash_project[a[1]]}, #{hash_status[a[2]]}"
          can hash_permission[a[0]], hash_project[a[1]], estimation_status_id: hash_status[a[2]]
          # p "#{hash_permission[a[0]]}, #{hash_project[a[1]]}, estimation_status_id: #{hash_status[a[2]]} => #{organization}"
        end
      end

      #p "#{permission.alias} #{project} #{e}"
      #[status, global].inject(:&).each_with_index do |a, i|
      #  permission = Permission.find(a[0]).alias  permission_hash[a0]
      #  project = Project.find(a[1])
      #  status = EstimationStatus.find(a[2])
      #
      #  unless project.nil?
      #    unless project.is_model == true && (permission.start_with?("alter") || permission.include?("widget"))
      #      can permission.to_sym, project, estimation_status_id: status.id
      #    end
      #  end
      #end
    end
  end
end



