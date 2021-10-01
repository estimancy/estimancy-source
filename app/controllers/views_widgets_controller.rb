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
#############################################################################

class ViewsWidgetsController < ApplicationController

  require 'rubyXL'
  include ViewsWidgetsHelper
  include ProjectsHelper
  before_filter :load_current_project_data, only: [:create, :update, :destroy]

  def load_current_project_data
    #@project = Project.find(params[:project_id])
    #if @project
    @project_organization = @project.organization
    @module_projects ||= @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where(organization_id: @project_organization.id, pemodule_id: @initialization_module.id, project_id: @project.id).first unless @initialization_module.nil?
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    #end
  end

  #nom de la fonction utilisé pour faire des test de Ability
  def recalculate_abaque_migrations_position
    #include CanCan::Ability

    super_admin = User.where(login_name: "admin").first
    user = User.where(login_name: "SGAYE").first
    organization = Organization.where(id: 75).first
    projects = organization.projects

    Organization.where(id: 75).all.each do |organization|

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

      # can :update, Group do |group|
      #   group.owners.include?(user)
      # end

      # can permission.alias.to_sym, Project do |project|
      # end

      #begin
      path = "#{Rails.root}/app/models/ability_files/ability_#{organization.name.gsub(" ", "_")}.txt"

      File.open(path, "w+") do |f|
        content = "test"; f << content; f << "\n \n"


        f << "group_names = #{organization.groups.map(&:name)} \n"
        f << "project_security_levels = #{organization.project_security_levels.map(&:name)} \n"

        ###==========================================

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

              #La gestion des paramètres se fait fait dans ApplicationController ==> current_ability
              organization_projects = projects.compact

              #remettre getsorted pour la liste complete des devis
              # organization_projects = get_sorted_estimations(organization.id, projects, sort_column, sort_order, search_hash, min, max, action)

              organization_estimation_statuses = organization.estimation_statuses
              user_groups = user.groups.where(organization_id: organization.id)

              # Add Action Aliases, for example:  alias_action :edit, :to => :update



              #Load user groups permissions
              f << "#Load user groups permissions \n"
              puts "#Load user groups permissions \n"

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

                f << "def ability_for_user_group \n \n"

                for perm in permissions_array
                  unless perm[0].nil? or perm[1].nil?
                    if perm[0] == :manage_estimation_models
                      #can perm[0], perm[1], :is_model => true
                      f << "can #{perm[0]}, #{perm[1]}, :is_model => true \n"
                    else
                      f << "can #{perm[0]}, #{perm[1]} \n"
                    end
                  end
                end

                f << "end \n \n"


                #For "manage_estimation_models", only models will be taken in account
                #When user can create a project template, he also can edit the model

                @array_users = Array.new
                @array_status_groups = Array.new
                @array_groups = Array.new
                @array_owners = Array.new

                #Specfic project security loading
                prj_scrts = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                              user_id: [user.id, owner.id],
                                                                                              is_model_permission: false,
                                                                                              is_estimation_permission: true).all
                f << "def ability_for_project_by_status \n"
                puts "def ability_for_project_by_status \n"

                unless prj_scrts.empty?
                  specific_permissions_array = []
                  prj_scrts.each do |prj_scrt|
                    prj_scrt_project_security_level = prj_scrt.project_security_level
                    unless prj_scrt_project_security_level.nil?
                      prj_scrt_project_security_level_permissions = prj_scrt_project_security_level.permissions.select{|i| i.is_permission_project }

                      project = prj_scrt.project
                      unless project.nil?
                        if (prj_scrt.user_id == user.id) || ( prj_scrt.user_id == owner.id && user.id == project.creator_id)
                          organization_estimation_statuses.each do |es|
                            prj_scrt_project_security_level_permissions.each do |permission|

                              if permission.alias == "manage" and permission.category == "Project"
                                can :manage, project, estimation_status_id: es.id
                                f << "can :manage, #{project}, estimation_status_id: #{es.id}"
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

                f << "end \n \n"


                user_groups.each do |grp|

                  prj_scrts = ProjectSecurity.includes(:project, :project_security_level).where(organization_id: organization.id,
                                                                                                group_id: grp.id,
                                                                                                is_model_permission: false,
                                                                                                is_estimation_permission: true).all
                  unless prj_scrts.empty?
                    specific_permissions_array = []
                    prj_scrts.each do |prj_scrt|

                      prj_scrt_project_security_level = prj_scrt.project_security_level
                      project = prj_scrt.project

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
                                  f << "can :manage, #{project}, estimation_status_id: #{es.id} \n "
                                  #puts "can :manage, #{project}, estimation_status_id: #{es.id} \n "
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

                  puts "Estimation status group role"
                  grp.estimation_status_group_roles.includes(:project_security_level, :estimation_status).where(organization_id: organization.id).each do |esgr|

                    puts "esgr : #{esgr}"

                    esgr_security_level = esgr.project_security_level
                    esgr_estimation_status_id = esgr.estimation_status_id

                    unless esgr_security_level.nil?

                      prj_scrt_project_security_level_permissions = esgr_security_level.permissions.select{|i| i.is_permission_project }

                      puts "Get array_status_groups fo #{esgr}"

                      prj_scrt_project_security_level_permissions.each do |permission|

                        if permission.alias == "manage" and permission.category == "Project"
                          can :manage, Project do |project|
                            project.estimation_status_id == esgr_estimation_status_id
                            #  can :manage, project, estimation_status_id: esgr_estimation_status_id
                            f << "can :manage, #{project}, estimation_status_id: #{esgr_estimation_status_id} \n"
                          end
                        else

                          can permission.alias.to_sym, Project do |project|
                            project.estimation_status_id == esgr_estimation_status_id
                            f << "can #{permission.alias.to_sym}, #{project}, estimation_status_id: #{esgr_estimation_status_id} \n"
                            #@array_status_groups.push([permission.id, project.id, esgr_estimation_status_id])
                          end
                        end


                        # organization_projects.select{ |p| p.id == 31083 }.each do |op|
                        #   project = op.is_a?(Project) ? op : op.project
                        #   if permission.alias == "manage" and permission.category == "Project"
                        #     can :manage, project, estimation_status_id: esgr_estimation_status_id
                        #     f << "can :manage, #{project}, estimation_status_id: #{esgr_estimation_status_id} \n"
                        #   else
                        #     unless project.nil?
                        #       @array_status_groups.push([permission.id, project.id, esgr_estimation_status_id])
                        #     end
                        #   end
                        # end

                      end
                      puts "Get final status"
                      #puts "array_status_groups = #{@array_status_groups}"
                    end
                  end
                end

                global = @array_users + @array_groups + @array_owners
                status = @array_status_groups

                status_global = [status, global].inject(:&)

                pe = Permission.where(id: status_global.map{|i| i[0]}.uniq).all
                pp = Project.where(organization_id: organization.id, id: status_global.map{|i| i[1]}.uniq).all
                ss = EstimationStatus.where(organization_id: organization.id, id: status_global.map{|i| i[2]}.uniq).all

                puts "PE - PP - SS"

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
                    #can hash_permission[a[0]], hash_project[a[1]], estimation_status_id: hash_status[a[2]]
                    f << "can #{hash_permission[a[0]]}, #{hash_project[a[1]]}, estimation_status_id: #{hash_status[a[2]]} \n"
                  end
                end
              end
            end
          end
        end

        ###==========================================


        f.close
      end

      #rescue
      #nothing
      #end
    end
    redirect_to :back
  end





  #Ci-dessous la vraie fonction, j'ai juste utilisé le nom plus haut pour faire des test
  # remettre le vrai nom en enlevant le "_save" à la fin
  def recalculate_abaque_migrations_position_save

    ViewsWidget.where(is_label_widget: true).all.each do |view_widget|
      if view_widget.comment.blank?
        view_widget.comment = view_widget.name
        view_widget.save(validate: false)
      end
    end


    # Cette portion de code corrige les doublons qui existent dans le nom des vignettes
    Project.all.each do |project|
      project_vew_widget_names = project.views_widgets.map(&:name)
      counts = Hash.new(0)
      project_vew_widget_names.each { |name| counts[name] += 1 }
      counts.each do |widget_name, nb|
        if nb >= 2
          i = 0
          project.views_widgets.where(name: widget_name).each do |view_widget|
            #if i > 0
              case view_widget.color
              when "#d5debc"  #Synthese devis
                if widget_name.to_s.downcase.include?("charge")
                  view_widget.name = "Charge Totale (jh)"
                elsif widget_name.to_s.downcase.include?("coût") || widget_name.to_s.downcase.include?("cout")
                  view_widget.name = "Coût Total (€)"
                else
                  view_widget.name = "#{widget_name} (#{i})"
                end

              when "#aa8ab8"  #Dire d'expert
                if widget_name.to_s.downcase.include?("charge")
                  view_widget.name = "Charge Services (jh)"
                elsif widget_name.to_s.downcase.include?("coût") || widget_name.to_s.downcase.include?("cout")
                  view_widget.name = "Coût Services (€)"
                else
                  view_widget.name = "#{widget_name} (#{i})"
                end

              when "blanchedalmond" #Abaque
=begin
                if widget_name.to_s.downcase.include?("charge")
                  view_widget.name = "Charge (jh)"
                elsif widget_name.to_s.downcase.include?("coût") || widget_name.to_s.downcase.include?("cout")
                  view_widget.name = "Coût (€)"
                else
                  view_widget.name = "#{widget_name} (#{i})"
                end
=end
              end
              #view_widget.name = "#{widget_name} (#{i})"
              view_widget.save(validate: false)
              puts "Vignette : #{widget_name}"
              #end
            i = i+1
          end
        end
      end
    end


    data = []
    estimation_models_name = ["Abaque Migration Lift&Shift", "Abaque Migration Rehost", "Abaque Migration Replatform", "Abaque Travaux Ponctuels liés à la migration"]
    #estimation_models = Project.where(title: estimation_models_name, id: 15409).all
    estimation_models = Project.where(title: estimation_models_name).all

    estimation_models.each do |estimation_model|

      projects_from_models = Project.where(original_model_id: estimation_model.id).all
      projects_from_models << estimation_model

      projects_from_models.each do |project|

        #test = project.views_widgets.map(&:name)
        charge_vw = project.views_widgets.where(name: "Charge Totale (jh)").first
        project_view = View.find(charge_vw.view_id)
        synthese_devis = ViewsWidget.where(view_id: charge_vw.view_id, name: "Synthèse devis").first_or_create(view_id: charge_vw.view_id, name: "Synthèse devis", is_label_widget: true, comment: "Synthèse devis", color: "#d5debc", position_x: 0, position_y: 4, width: 6, height: 1)
          #project.views_widgets.each do |view_widget|
        project_view.views_widgets.each do |view_widget|

          puts "#{view_widget.id}"
          case view_widget.name.to_s#.downcase

            #groupe 1
          when "Service Lift & Shift (Prix Service : 561,51 €/j",
               "Service Lift & Shift (Prix Service : 604,70 €/j)",
               "Service Lift & Shift (Prix Service : 561,51 €/j)",
               "Service Lift & Shift (Prix Service : 600,42 €/j)",
               "Service Rehost (Prix Service : 620,94 €/j)",
               "Service Rehost (Prix Service : 563,28 €/j",
               "Service Rehost (Prix Service : 563.28 €/j)",
               "Service Rehost (Prix Service : 563,28 €/j)",
               "Service Rehost (Prix Service : 600,42 €/j)",
               "Service Rehost (Prix Service : 563,28  €/j)"
            #"service lift & shift (prix service : 561,51 €/j)",
            #"service rehost (prix service : 563.28 €/j)",
            #"service rehost (prix service : 620,94 €/j)"

            data = [0,0,6,1]

          when "Charge Lift & Shift", "Charge Rehost"
            #"charge lift & shift", "charge rehost"
            data = [0,1,3,1]

          when "Coût Lift & Shift", "Coût Rehost", "Coût Rehost (€)"
            #"coût lift & shift", "coût rehost"
            data = [3,1,2,1]


            #groupe 2
          when "Service Tests Fonct. Proc. (Prix Service : 507,68  €/j)",
            "Service Tests Fonct. Proc. (Prix Service : 526.55 €/j)",
            "Service Tests Fonct. Proc. (Prix Service : 562,94 €/j)"
            #"service tests fonct. proc. (prix service : 526.55 €/j)",
            #"service tests fonct. proc. (prix service : 507,68  €/j)"
            data = [6,0,6,1]

          when "Charge Tests Proc.", "charge tests proc."
            data = [6,1,3,1]

          when "Coût Tests Proc.", "coût tests proc."
            data = [9,1,3,1]


            #groupe 3
          when "Service Tests Fonc. Surf. (Prix Service : 507,68  €/j)",
            "Service Tests Fonc. Surf. (Prix Service : 526,55 €/j)",
            "Service Tests Fonc. Surf. (Prix Service : 562,94 €/j)"
            #"service tests fonc. surf. (prix service : 526,55 €/j)",
            #"service tests fonc. surf. (prix service : 507,68  €/j)"
            data = [0,2,6,1]

          when "Charge Tests Surf.", "charge tests surf."
            data = [0,3,3,1]

          when "Coût Tests Surf.", "coût tests surf."
            data = [3,3,2,1]

            #groupe 4
          when "Service Travaux Ponct. (Prix Service : 620,94 €/j)",
               "Service Travaux Ponct. (Prix Service : 537,56 €/j",
               "Service Travaux Ponct. (Prix Service : 537,56 €/j)",
               "Service Travaux Ponct. (Prix Service : 559,36 €/j)"
            #"service travaux ponct. (prix service : 537,56 €/j)",
            #"service travaux ponct. (prix service : 620,94 €/j)"
            data = [6,2,6,1]

          when "Charge Trav. Ponct.", "charge trav. ponct."
            data = [6,3,3,1]

          when "Coût Trav. Ponct.", "coût trav. ponct."
            data = [9,3,3,1]

            #groupe 5
          when "Synthèse devis", "synthèse devis"
            data = [0,4,6,1]

          when "Charge Totale (jh)", "charge totale (jh)"
            data = [0,5,3,1]

          when "Coût Total (€)", "coût total (€)"
            data = [3,5,2,1]

          when "PMP (Prix Moyen Pondéré) (€/j)", "Prix Moyen Pondéré (€/jh)"
            #"prix moyen pondéré (€/jh)", "pmp (prix moyen pondéré) (€/j)"
            data = [0,6,4,1]


          #groupe 6
          when "Service Opti. Serv.Web/Ap. (Prix Service : 620,94 €/j)",
               "Service Opti. Serv.Web/Ap. (Prix Service : 588,59 €/j",
               "Service Opti. Serv.Web/Ap. (Prix Service : 588,59 €/j)"
            #"service opti. serv.web/ap. (prix service : 588,59 €/j)",
            #"service opti. serv.web/ap. (prix service : 620,94 €/j)"
            data = [6,4,6,1]

          when "Charge Opti. Serv.Web/Ap.", "charge opti. serv.web/ap."
            data = [6,5,3,1]

          when "Coût Opti. serv.Web/Ap.", "coût opti. serv.web/ap."
            data = [9,5,3,1]

          #groupe 7
          when "Service Opti. BdeD (Prix Service : 620,94 €/j)",
               "Service Opti. BdeD (Prix Service : 592,60 €/j)"
            #"service opti. bded (prix service : 592,60 €/j)",
            #"service opti. bdeD (prix service : 620,94 €/j)"
            data = [6,6,6,1]

          when "Charge Opti. BdD", "charge opti. bdd"
            data = [6,7,3,1]

          when "Coût Opti. BdD", "coût opti. bdd"
            data = [9,7,3,1]

          end

          unless data.empty?
            #view_widget.update_attributes(position_x: data[0], position_y: data[1], width: data[2], height: data[3])
            view_widget.position_x = data[0]
            view_widget.position_y = data[1]
            view_widget.width = data[2]
            view_widget.height = data[3]

            if view_widget.save(validate: false)
              puts "#{view_widget} MAJ"
            else
              puts "#{view_widget} échec MAJ"
            end
          end

          puts "Project : #{project.title}"
        end
      end
    end
    puts "Fini..."

    redirect_to :back and return
  end

  def recalculate_position
    widgets_name = ["Abaque", "Localisation", "Charge RTU (jh)", "Charge RIS (jh)", "Coût (€)", "Répartition des Charges", "Dire d'expert", "Charge (jh)", "Coût services (€)", "Synthèse devis", "Synthese devis", "Charge totale", "coût total", "Prix Moyen Pondéré (€/jh)", "prix moyen pondéré"]
    data = []
    #ViewsWidget.first do |view_widget|
    ViewsWidget.all.each do |view_widget|

      puts "#{view_widget.id}"
      case view_widget.name.to_s.downcase

        when "abaque"
          data = [0,0,5,1]

        when ""
          data = [0,0,5,1]
          if view_widget.name.blank? && view_widget.is_label_widget?
            view_widget.name = view_widget.comment.to_s.humanize
            view_widget.save(validate: false)
          end

        when "localisation"
          data = [0,1,5,1]

        when "charge rtu (jh)"
          data = [0,2,3,1] #[0,2,2,1]

        when "charge ris (jh)"
          data = [0,2,3,1]

        when "coût (€)"
          data = [3,2,2,1]

        when "répartition des charges", "répartion des charges", "repartion des charges"
          data = [0,3,5,6]

        when "dire d'expert"
          data = [6,0,6,1]

        when "charge (jh)"
          data = [6,1,3,1]

        when "coût services (€)"
          data = [9,1,3,1]

        when "synthèse devis", "synthese devis"
          data = [6,2,6,1]

        when "charge totale (jh)"
          data = [6,3,3,1]

        when "coût total (€)"
          data = [9,3,3,1]

        when "prix moyen pondéré (€/jh)"
          data = [7,4,4,1]
      end

      unless data.empty?
        view_widget.update_attributes(position_x: data[0], position_y: data[1], width: data[2], height: data[3])
      end
    end
    puts "Fini..."

  end

  def new
    authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.new(params[:views_widget])
    @min_value = @views_widget.min_value
    @max_value = @views_widget.max_value
    @view_id = params[:view_id]
    @position_x = 1; @position_y = 1
    @module_project = ModuleProject.find(params[:module_project_id])
    @module_project_box = @module_project
    @pbs_project_element_id = current_component.id rescue nil
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # estimation_values = module_project.estimation_values.group_by{ |attr| attr.in_out }.sort()

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
  end

  def edit
    authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.find(params[:id])

    @min_value = @views_widget.min_value
    @max_value = @views_widget.max_value

    @view_id = @views_widget.view_id
    @position_x = (@views_widget.position_x.nil? || @views_widget.position_x.downcase.eql?("nan")) ? 1 : @views_widget.position_x
    @position_y = (@views_widget.position_y.nil? || @views_widget.position_y.downcase.eql?("nan")) ? 1 : @views_widget.position_y

    @module_project = @views_widget.module_project_id.nil? ? ModuleProject.find(params[:module_project_id]) : @views_widget.module_project
    @module_project_box = ModuleProject.find(params[:module_project_id])

    ###@pbs_project_element_id = @views_widget.pbs_project_element_id.nil? ? current_component.id : @views_widget.pbs_project_element_id
    @pbs_project_element_id = current_component.id
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    @views_widget_types = show_widget_effort_display_unit(@module_project.id, @views_widget.estimation_value_id)

  end

  def create
    authorize! :manage_estimation_widgets, @project

    @module_project = ModuleProject.find(params[:current_module_project_id]) ###ModuleProject.find(params[:views_widget][:module_project_id])
    @module_project_box = @module_project
    @pemodule = @module_project.pemodule

    if @module_project.view.nil?
      current_view = View.create(organization_id: @project.organization_id,
                                 pemodule_id: @pemodule.id,
                                 name: "#{@project.title} - #{@module_project} view")
      @view_id = current_view.id
      @module_project.update_attribute(:view_id, @view_id)
    else
      @view_id = params[:views_widget][:view_id]
      #get the current view
      current_view = View.find(params[:views_widget][:view_id])
    end


    # Add the position_x and position_y to params
    position_x = 1
    position_y = 1

    # Get the max (width, height) of the view's widgets : then add the widget in last positions
    unless current_view.nil? || current_view.views_widgets.empty?
      current_view_widgets = current_view.views_widgets
      y_positions = current_view.views_widgets.map(&:position_y).map(&:to_i)
      y_max = y_positions.max
      widgets_on_ymax = current_view_widgets.where(position_y: y_max.to_s)
      x_positions = widgets_on_ymax.map(&:position_x).map(&:to_i)
      x_max = x_positions.max
      view_widget_max_position = widgets_on_ymax.where(position_x: x_max.to_s).first

      position_x = view_widget_max_position.position_x.to_i+view_widget_max_position.width.to_i+1
      position_y = y_max ###view_widget_max_position.position_y.to_i+view_widget_max_position.height.to_i+1
    end

    #new widget with the default positions
    @views_widget = ViewsWidget.new(params[:views_widget].merge(:view_id => current_view.id,
                                                                :position_x => position_x,
                                                                :position_y => position_y,
                                                                :width => 3,
                                                                :height => 3))
    # if params[:views_widget][:is_kpi_widget].present?
    #   equation = Hash.new
    #   equation["formula"] = params[:formula].upcase
    #   ["A", "B", "C", "D", "E"].each do |letter|
    #     unless params[letter.to_sym].nil?
    #       equation[letter] = [params[letter.to_sym].upcase, params["module_project"][letter]]
    #     end
    #     equation[letter] = params[letter.to_sym].to_s.upcase
    #   end
    #   @views_widget.equation = equation
    #   @views_widget.kpi_unit = params[:views_widget][:kpi_unit]
    #   @views_widget.is_kpi_widget = true
    #   ###@views_widget.module_project_id = @module_project.id
    #   ###end
    #
    #   begin
    #     @views_widget.module_project_id = @module_project.id
    #   rescue
    #   end
    # end
    #

    @views_widget.min_value = params[:views_widget][:min_value].blank? ? nil : params[:views_widget][:min_value].to_f
    @views_widget.max_value = params[:views_widget][:max_value].blank? ? nil : params[:views_widget][:max_value].to_f

    if params[:views_widget][:is_kpi_widget].present?
      equation = Hash.new
      equation["formula"] = params[:formula].upcase
      ["A", "B", "C", "D", "E"].each do |letter|
        unless params[letter.to_sym].nil?
          equation[letter] = [params[letter.to_sym].upcase, params["module_project"][letter]]
        end
        ###equation[letter] = params[letter.to_sym].to_s.upcase
      end
      @views_widget.equation = equation
      @views_widget.kpi_unit = params[:views_widget][:kpi_unit]
      @views_widget.is_kpi_widget = true

      ###@views_widget.module_project_id = @module_project.id
      ###end

      begin
        @views_widget.module_project_id = @module_project.id
      rescue
        # ignored
      end
    end

    if params[:views_widget][:is_project_data_widget].present?
      @views_widget.module_project_id = @module_project.id
      @views_widget.is_project_data_widget = true
    end

    #is_organization_kpi_widget
    respond_to do |format|
      if @views_widget.save
        unless params["field"].blank?# && @views_widget.min_value < @views_widget.max_value
          ProjectField.create( project_id: @project.id,
                               field_id: params["field"],
                               views_widget_id: @views_widget.id,
                               value: get_view_widget_data(@views_widget.module_project, @views_widget.id)[:value_to_show])
        end


        begin
          format.js { render(:js => "window.location.replace('#{dashboard_path(@module_project.project)}');")}
          format.html { redirect_to dashboard_path(@module_project.project) and return }
        rescue
          format.js { render :js => "window.location.reload();"}
          format.html { redirect_to :back and return }
        end

      else
        flash[:error] = "Erreur d'ajout de Vignette"
        @position_x = 1; @position_y = 1
        @pbs_project_element_id = params[:views_widget][:pbs_project_element_id].nil? ? current_component.id : params[:views_widget][:pbs_project_element_id]
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        begin
          @views_widget_types = show_widget_effort_display_unit(@module_project.id, @views_widget.estimation_value_id)
        rescue
          @views_widget_types = []
        end

        flash.keep(:error)

        format.html { render action: :new }
        format.js   { render action: :new }
      end
    end
  end

  def update
    # authorize! :manage_estimation_widgets, @project

    @views_widget = ViewsWidget.find(params[:id])
    @view_id = @views_widget.view_id

    @views_widget.min_value = params[:views_widget][:min_value].blank? ? nil : params[:views_widget][:min_value].to_f
    @views_widget.max_value = params[:views_widget][:max_value].blank? ? nil : params[:views_widget][:max_value].to_f

    project = @project

    if params[:views_widget][:is_kpi_widget].present?
      @views_widget.is_kpi_widget = true
      equation = Hash.new
      equation["formula"] = params[:formula].upcase

      ["A", "B", "C", "D", "E"].each do |letter|
        unless params[letter.to_sym].nil?
          equation[letter] = [params[letter.to_sym].upcase, params["module_project"][letter]]
        end
      end

      @views_widget.equation = equation
      @views_widget.kpi_unit = params[:views_widget][:kpi_unit]
      @views_widget.is_kpi_widget = true
    end

    respond_to do |format|

      if @views_widget.update_attributes(params[:views_widget])

        #Update the widget's pe_attribute
        #widget_attribute_id = @views_widget.estimation_value.pe_attribute_id
        #if  widget_attribute_id != @views_widget.pe_attribute_id
        #  @views_widget.update_attribute(:pe_attribute_id, widget_attribute_id)
        #end

        if params["field"].blank?
          pfs = @views_widget.project_fields
          pfs.destroy_all
        else
          #pf = ProjectField.where(views_widget_id: @views_widget.id).last
          pf = ProjectField.where(project_id: project.id, field_id: params["field"].to_i).last
          pfs_to_destroy = @views_widget.project_fields.where.not(field_id: params["field"].to_i)
          pfs_to_destroy.destroy_all

          if params[:views_widget][:is_kpi_widget].present?
            @value = get_kpi_value_without_unit(@views_widget)    #@value = get_kpi_value(@views_widget)
          else
            unless @views_widget.estimation_value.nil?
              if @views_widget.estimation_value.module_project.pemodule.alias == "effort_breakdown"
                begin
                  @value = @views_widget.estimation_value.string_data_probable[current_component.id][@views_widget.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
                rescue
                  begin
                    @value = @views_widget.estimation_value.string_data_probable[current_component.id]
                  rescue
                    @value = 0
                  end
                end
              else
                @value = @views_widget.estimation_value.string_data_probable[current_component.id]
              end
            end
          end

          if pf.nil?
            pf = ProjectField.new(project_id: project.id,
                                  field_id: params["field"].to_i,
                                  views_widget_id: @views_widget.id,
                                  value: @value)
            if !pf.save
              flash[:error] = "Erreur lors de la mise à jour du champs personnalisé"
            end
          elsif pf.views_widget_id == @views_widget.id
              pf.value = @value
              pf.save
          else
            flash[:error] = I18n.t(:identical_project_field_exists)
          end
        end

        if @views_widget.module_project
          format.js { render :js => "window.location.replace('#{dashboard_path(@views_widget.module_project.project)}');"}
          format.html { redirect_to dashboard_path(@views_widget.module_project.project) and return }
        else
          format.js { render :js => "window.location.reload();"}
          format.html { redirect_to :back and return }
        end
      else
        flash[:error] = "Erreur lors de la mise à jour du Widget dans la vue"

        @position_x = (@views_widget.position_x.nil? || @views_widget.position_x.downcase.eql?("nan")) ? 1 : @views_widget.position_x
        @position_y = (@views_widget.position_y.nil? || @views_widget.position_y.downcase.eql?("nan")) ? 1 : @views_widget.position_y



        @module_project = ModuleProject.find(params[:views_widget][:module_project_id])
        @module_project_box = @module_project

        @pbs_project_element_id = current_component.id
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        begin
          @views_widget_types = show_widget_effort_display_unit(@module_project.id, @views_widget.estimation_value_id)
        rescue
          @views_widget_types = []
        end

        format.js { render action: :edit }
      end
    end
  end

  def destroy
    @views_widget = ViewsWidget.find(params[:id])
    @module_project = @views_widget.module_project

    if can?(:alter_estimation_plan, @project) || ( can?(:manage_estimation_widgets, @project) && @views_widget.project_fields.empty? )
      @views_widget.destroy
    else
      flash[:warning] = I18n.t(:notice_cannot_delete_widgets)
    end

    redirect_to dashboard_path(@project)
  end


  #update the view_widget position (x,y)
  def update_view_widget_positions

    dragged_widget_id = params[:view_widget_id]
    view_widget_items = params[:view_widget_items]

    unless view_widget_items.empty?
      view_widget_items.each_with_index do |item, index|

        view_widget_item = item[1]
        view_widget_id = view_widget_item[:view_widget_id]

        unless view_widget_id.blank?
          view_widget = ViewsWidget.find(view_widget_id)
          if view_widget
            # Update the View Widget positions (left = position_x, top = position_y)
            if view_widget.id == dragged_widget_id.to_i

              view_widget.update_attributes(position_x: params[:x_position],
                                            position_y: params[:y_position],
                                            width: params[:item_width],
                                            height: params[:item_height])
            else
              view_widget.update_attributes(position_x: view_widget_item[:x_position],
                                          position_y: view_widget_item[:y_position],
                                          width: view_widget_item[:item_width],
                                          height: view_widget_item[:item_height])
            end
          end
        end
      end
    end
  end

  def update_view_widget_positions_save_old
    views_widgets = params[:views_widgets]
    unless views_widgets.empty?
      views_widgets.each_with_index do |element, index|
        view_widget_hash = element.last
        view_widget_id = view_widget_hash[:view_widget_id].to_i
        if view_widget_id != 0
          view_widget = ViewsWidget.find(view_widget_id)
          if view_widget
            # Update the View Widget positions (left = position_x, top = position_y)
            view_widget.update_attributes(position_x: view_widget_hash[:col], position_y: view_widget_hash[:row], position: index+1)
          end
        end
      end
    end
  end

  def update_view_widget_sizes
    view_widget_id = params[:view_widget_id]
    if view_widget_id != "" && view_widget_id!= "indefined"
      view_widget = ViewsWidget.find(view_widget_id)
      if view_widget
        view_widget.update_attributes(width: params[:sizex], height: params[:sizey])
      end
    end
  end

  #Update the module_project corresponding data of view
  def update_widget_module_project_data
    module_project_id = params['module_project_id']
    @show_ratio_name = false

    if !module_project_id.nil? && module_project_id != 'undefined'
      @module_project = ModuleProject.find(module_project_id)
      if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
        @show_ratio_name = true
      end

      #@module_project_attributes_input = @module_project.estimation_values.where(in_out: 'input').map{|i| [i, i.id]}
      #@module_project_attributes_output = @module_project.estimation_values.where(in_out: 'output').map{|i| [i, i.id]}

      # A tester  Get the possible attribute grouped by type (input, output)
      @module_project_attributes = get_module_project_attributes_input_output(@module_project)

      begin
       @inputs_array = @module_project_attributes[0].last
       @module_project_attributes_input = @inputs_array.map{|i| [i, i.id]}
      rescue
        @inputs_array = []
        @module_project_attributes_input = []
      end

      begin
       @outputs_array = @module_project_attributes[1].last
       @module_project_attributes_output = @outputs_array.map{|i| [i, i.id]}
      rescue
        @outputs_array = []
        @module_project_attributes_output = []
      end


      @letter = params[:letter]
      if @letter.nil?
        @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
      end
    end
  end

  # Show the effort display unit if the attribute alias is part of Effort attributes
  def show_widget_effort_display_unit(module_project_id=nil, estimation_value_id=nil)

    if estimation_value_id.nil?
      estimation_value_id = params['estimation_value_id']
    end

    begin
      if module_project_id.nil?
        @module_project = ModuleProject.find(params['module_project_id'])
      else
        @module_project = ModuleProject.find(module_project_id)
      end

      if estimation_value_id.nil? || estimation_value_id == 'undefined'
        @views_widget_types = []
      else
        @estimation_value = EstimationValue.find(estimation_value_id)
        @pe_attribute = @estimation_value.pe_attribute

        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          if @pe_attribute.alias.in?(Projestimate::Application::EFFORT_ATTRIBUTES_ALIAS.reject{|e| e == "retained_size"})
            @views_widget_types = Projestimate::Application::BREAKDOWN_EFFORT_WIDGETS_TYPE
          elsif @pe_attribute.alias.in?(["cost", "retained_cost", "theoretical_cost"])
            @views_widget_types = Projestimate::Application::BREAKDOWN_COST_WIDGETS_TYPE
          else
            @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
          end
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end
      end
    rescue
      @views_widget_types = []
    end

    @views_widget_types
  end


  def export_vignette
    workbook = RubyXL::Workbook.new
    widget = ViewsWidget.find(params[:view_widget_id])
    ind_x = 4
    ind_y = 1
    my_len = I18n.t(:profile).length
    my_len_2 = I18n.t(:phases).length
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, I18n.t(:Project_name))
    worksheet.add_cell(0, 1, I18n.t(:version_number))
    worksheet.add_cell(0, 2, I18n.t(:start_date))
    worksheet.add_cell(0, 3, I18n.t(:Product_Name))
    worksheet.change_column_width(0, @project.title.to_s.length < I18n.t(:Project_name).length ? I18n.t(:Project_name).length : @project.title.to_s.length)
    worksheet.change_column_width(1, @project.version_number.to_s.length < I18n.t(:version_number).length ? I18n.t(:version_number).length : @project.version_number.to_s.length)
    worksheet.change_column_width(2, I18n.t(:start_date).length)
    worksheet.change_column_width(3, current_component.to_s.length < I18n.t(:Product_Name).length ? I18n.t(:Product_Name).length : current_component.to_s.length)
    worksheet.add_cell(0, 4, I18n.t(:phases))

    if widget.widget_type.in?(["table_effort_per_phase", "table_effort_per_phase_without_zero"])
      unless widget.estimation_value.string_data_probable.empty?
        worksheet.add_cell(0, 5, I18n.t(:effort_import))
        widget.module_project.wbs_activity.wbs_activity_elements.each  do |element|
          worksheet.add_cell(ind_y, 0, @project.title)
          worksheet.add_cell(ind_y, 1, @project.version_number)
          #worksheet.add_cell(ind_y, 2, I18n.l(@project.start_date))
          tab_date = @project.start_date.to_s.split("-")
          worksheet.add_cell(ind_y, 2, '', "DATE(#{tab_date[0]},#{tab_date[1]},#{tab_date[2]})").set_number_format 'dd/mm/yy'
          worksheet.add_cell(ind_y, 3, current_component)
          worksheet.add_cell(ind_y, 4, element.name)
          my_len_2 = element.name.length < my_len_2 ? my_len_2 : element.name.length
          worksheet.change_column_width(4, my_len_2)

          begin
            worksheet.add_cell(ind_y, 5, widget.estimation_value.string_data_probable[current_component.id][element.id][:value].to_f).set_number_format('.##')
          rescue
            worksheet.add_cell(ind_y, 5, '').set_number_format('.##')
          end

          begin
            worksheet.add_cell(ind_y, 6, convert_label(widget.estimation_value.string_data_probable[current_component.id][element.id][:value], @project.organization))
          rescue
            worksheet.add_cell(ind_y, 6, '')
          end

          ind_y += 1
        end
      end
    elsif widget.widget_type.in?(["effort_per_phases_profiles_table", "effort_per_phases_profiles_table_without_zero"])
      unless widget.estimation_value.string_data_probable.empty?
        worksheet.add_cell(0, 5, I18n.t(:profile))
        worksheet.add_cell(0, 6, I18n.t(:effort_import))
        attribute = widget.pe_attribute
        activity = widget.module_project.wbs_activity
        ratio = widget.module_project.wbs_activity_ratio

        # wbs_activity_input = WbsActivityInput.where(wbs_activity_id: activity.id, wbs_activity_ratio_id: ratio.id, module_project_id: widget.module_project.id, pbs_project_element_id: current_component.id).first
        # if wbs_activity_input.nil?
        #   ratio = nil
        # else
        #   ratio = wbs_activity_input.wbs_activity_ratio
        # end

        unless ratio.nil?
          activity.wbs_activity_elements.each do |element|
            my_len_2 = element.name.length < my_len_2 ? my_len_2 : element.name.length
            worksheet.change_column_width(4, my_len_2)
            element.wbs_activity_ratio_elements.where(wbs_activity_ratio_id: ratio.id).each do |ware|
              ware.organization_profiles.each do |profil|
                worksheet.add_cell(ind_y, 0, @project.title)
                worksheet.add_cell(ind_y, 1, @project.version_number)
                #worksheet.add_cell(ind_y, 2, I18n.l(@project.start_date))
                tab_date = @project.start_date.to_s.split("-")
                worksheet.add_cell(ind_y, 2, '', "DATE(#{tab_date[0]},#{tab_date[1]},#{tab_date[2]})").set_number_format 'dd/mm/yy'
                worksheet.add_cell(ind_y, 3, current_component)
                worksheet.add_cell(ind_y, 4, element.name)
                worksheet.add_cell(ind_y, 5, profil.name)
                my_len = profil.name.length < my_len ? my_len : profil.name.length
                worksheet.change_column_width(5, my_len)

                begin
                  worksheet.add_cell(ind_y, 6, widget.estimation_value.string_data_probable[current_component.id][element.id]["profiles"]["profile_id_#{profil.id}"]["ratio_id_#{ratio.id}"][:value]).set_number_format('.##')
                rescue
                  #worksheet.add_cell(ind_y, 6, "".set_number_format('.##'))
                  worksheet.add_cell(ind_y, 6, "")
                  worksheet.add_cell(ind_y, 7, "")
                end
                ind_y += 1
             end
            end
          end
        end
      end
    end

    send_data(workbook.stream.string, filename: "#{@project.organization.name[0..4]}-#{@project.title}-#{@project.version_number}(#{("A".."B").to_a[widget.module_project.position_x - 1]},#{widget.module_project.position_y})-Effort-Phases-Profils-#{widget.name.gsub(" ", "_")}-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")

  end

  # Get the module_project attributes grouped by Input and Ouput
  def get_module_project_attributes_input_output(module_project)
    estimation_values = module_project.get_module_project_estimation_values.group_by{ |attr| attr.in_out }.sort()
  end

  # def vw_pf_script
  #   include ProjectsHelper
  #   include ViewsWidgetsHelper
  #
  #   o = Organization.find(69)
  #   o.projects.where(original_model_id: [4067, 7827, 7828]).each do |project|
  #     # effort
  #     pf = ProjectField.where(project_id: project.id, field_id: 96).first_or_create
  #     vw = ViewsWidget.where(name: "Charge Totale (jh)", module_project_id: project.module_project_ids).first
  #     pf.views_widget_id = vw.id
  #     value = get_kpi_value_without_unit(vw, project.root_component)
  #
  #     unless value.nil?
  #       pf.value = value
  #     end
  #     pf.save
  #   end
  #
  #   include ProjectsHelper
  #   include ViewsWidgetsHelper
  #   o.projects.where(original_model_id: [4067, 7827, 7828]).each do |project|
  #     # cost
  #     pf = ProjectField.where(project_id: project.id, field_id: 97).first_or_create
  #     vw = ViewsWidget.where(name: "Coût Total (€)", module_project_id: project.module_project_ids).first
  #     begin
  #       pf.views_widget_id = vw.id
  #       value = get_kpi_value_without_unit(vw, project.root_component)
  #       unless value.nil?
  #         pf.value = value
  #       end
  #       pf.save
  #     rescue
  #     end
  #   end
  #
  #   # include ProjectsHelper
  #   # include ViewsWidgetsHelper
  #   # o.projects.where(original_model_id: [4067, 7827, 7828]).each do |project|
  #     # localisation
  #     # pf = ProjectField.where(project_id: project.id, field_id: 119).first_or_create
  #     # vw = ViewsWidget.where(name: "Localisation", module_project_id: project.module_project_ids).first
  #     # begin
  #     #   pf.views_widget_id = vw.id
  #     #   value = get_ev_value(vw.estimation_value.id, project.root_component)
  #     #   unless value.nil? || value == 0
  #     #     pf.value = value
  #     #   end
  #     #   pf.save
  #     # rescue
  #     # end
  #   # end
  #
  # end

end




