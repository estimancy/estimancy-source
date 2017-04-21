# Pour lancer la tache : rake ge_models:update_ge_modele_with_4_inputs_outputs
# rake projects:copy_multiple_estimations RAILS_ENV=production

include CanCan::Ability

namespace :projects do

  desc "Prise en compte des modifications du module de Transformation avec l'ajout des 4 entrée et 4 sorties"

  #task copy_multiple_estimations: :environment do
  task :copy_multiple_estimations, [:counters] => :environment do |t, args|


    @current_user = User.where(login_name: "admin").first
    #current_user = sign_in(@user)
    #can :manage, :all

    project_ctlr = ProjectsController.new


    begin
      # Organization:  CDC AMOA INFRA
      referenced_estimation = Project.where(title: "PG-462").first
      @organization = referenced_estimation.organization
    rescue
      @organization = Organization.where(name: "TEST_EBE").first
      referenced_estimation = Project.where(organization_id: @organization.id).first
    end

    number_of_copy = 5

    if args[:counters]
      number_of_copy = args[:counters].to_i
    end

    # ActiveRecord::Base.transaction do
    #   ###referenced_estimation = Project.where(name: "PG462").first
    #
    #
    #   referenced_estimation = Project.where(organization_id: @organization.id).first
    #
    #
    #   if referenced_estimation
    #     @organization = referenced_estimation.organization
    #
    #     # project_controller_obj = ProjectsController.new
    #     # project_controller_obj.duplicate_path(referenced_estimation, organization_id: @organization, action_name: "duplication")
    #     #
    #     # referenced_estimation = Project.first
    #     # session = ActionDispatch::Integration::Session.new(Rails.application)
    #     # session.post "projects/#{referenced_estimation.id}/duplicate", {project_id: referenced_estimation.id, action_name: "duplicate"}
    #
    #     app = ActionDispatch::Integration::Session.new(Rails.application)
    #     app.get "projects/#{referenced_estimation.id}/duplicate",
    #             params: { project_id: referenced_estimation.id, action_name: "duplicate", organization_id: @organization.id, current_user: current_user }
    #
    #     puts "ok"
    #
    #   end
    # end

    number_of_copy.times.each do |counter|

      ActiveRecord::Base.transaction do

        current_user = @current_user

        old_prj = referenced_estimation #Project.where(organization_id: @organization.id).first

        new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
        new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:estimation_created_from_estimation_by, estimation_name: old_prj, username: current_user.name)} \r\n"
        new_prj.ancestry = nil
        new_prj.creator_id = current_user.id

        new_prj.is_model = false

        new_prj.original_model_id = old_prj.id

        #Update some params with the form input data
        new_prj.status_comment = "#{I18n.l(Time.now)} : #{I18n.t(:estimation_created_from_model_by, model_name: old_prj, username: current_user.name)} \r\n"

        # if params['project']['application_id'].present?
        #   new_prj.application_id = params['project']['application_id']
        # else
        #   new_prj.application_name = params['project']['application_name']
        # end

        # new_prj.title = params['project']['title']
        # new_prj.version_number = params['project']['version_number']
        # new_prj.description = params['project']['description']
        # # start_date = (params['project']['start_date'].nil? || params['project']['start_date'].blank?) ? Time.now.to_date : params['project']['start_date']
        # new_prj.start_date = Time.now

        #Only the securities for the generated project will be taken in account
        # new_prj.project_securities = new_prj.project_securities.reject{|i| i.is_model_permission == true }

        if new_prj.save
          old_prj.save #Original project copy number will be incremented to 1

          #Update the project securities for the current user who create the estimation from model
          #if params[:action_name] == "create_project_from_template"
          owner = User.find_by_initials(AdminSetting.find_by_key("Estimation Owner").value)
          #if !params[:create_project_from_template].nil?
            creator_securities = new_prj.project_securities
            creator_securities.each do |ps|
              if ps.is_model_permission == true
                ps.update_attribute(:is_model_permission, false)
                ps.update_attribute(:is_estimation_permission, true)
                if ps.user_id == owner.id
                  ps.update_attribute(:user_id, owner.id)
                end
              else
                ps.destroy
              end
            end
          #end

          #Managing the component tree : PBS
          pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

          # For PBS
          new_prj_components = pe_wbs_product.pbs_project_elements
          new_prj_components.each do |new_c|
            if new_c.is_root == true
              #if !params[:create_project_from_template].nil?
                if new_prj.application.nil?
                  new_c.name = new_prj.application_name
                else
                  new_c.name = new_prj.application.name
                end
                new_c.save
              #end
            end

            new_ancestor_ids_list = []
            new_c.ancestor_ids.each do |ancestor_id|
              ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
              new_ancestor_ids_list.push(ancestor_id)
            end
            new_c.ancestry = new_ancestor_ids_list.join('/')
            new_c.save
          end

          #For applications
          old_prj.applications.each do |application|
            app = Application.where(name: application.name, organization_id: @organization.id).first
            ap = ApplicationsProjects.create(application_id: app.id,
                                             project_id: new_prj.id)
            ap.save
          end

          # For ModuleProject associations
          old_prj.module_projects.group(:id).each do |old_mp|
            new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

            # ModuleProject Associations for the new project
            old_mp.associated_module_projects.each do |associated_mp|
              new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
              new_mp.associated_module_projects << new_associated_mp
            end

            ### Wbs activity
            #create module_project ratio elements
            old_mp.module_project_ratio_elements.each do |old_mp_ratio_elt|
              mp_ratio_element = old_mp_ratio_elt.dup
              mp_ratio_element.module_project_id = new_mp.id
              mp_ratio_element.copy_id = old_mp_ratio_elt.id

              pbs_id = new_prj_components.where(copy_id: old_mp_ratio_elt.pbs_project_element_id).first.id
              mp_ratio_element.pbs_project_element_id = pbs_id
              mp_ratio_element.save
            end

            new_mp_ratio_elements = new_mp.module_project_ratio_elements
            new_mp_ratio_elements.each do |mp_ratio_element|
              #mp_ratio_element.pbs_project_element_id = new_prj_components.where(copy_id: mp_ratio_element.pbs_project_element_id).first.id

              #unless mp_ratio_element.is_root?
              new_ancestor_ids_list = []
              mp_ratio_element.ancestor_ids.each do |ancestor_id|
                ancestor = new_mp_ratio_elements.where(copy_id: ancestor_id).first
                if ancestor
                  ancestor_id = ancestor.id
                  new_ancestor_ids_list.push(ancestor_id)
                end
              end
              mp_ratio_element.ancestry = new_ancestor_ids_list.join('/')
              #end
              mp_ratio_element.save
            end

            ### End wbs_activity

            # For SKB-Input
            old_mp.skb_inputs.each do |skbi|
              Skb::SkbInput.create(data: skbi.data, processing: skbi.processing, retained_size: skbi.retained_size,
                                   organization_id: @organization.id, module_project_id: new_mp.id)
            end

            #For ge_model_factor_descriptions
            old_mp.ge_model_factor_descriptions.each do |factor_description|
              Ge::GeModelFactorDescription.create(ge_model_id: factor_description.ge_model_id, ge_factor_id: factor_description.ge_factor_id,
                                                  factor_alias: factor_description.factor_alias, description: factor_description.description,
                                                  module_project_id: new_mp.id, project_id: new_prj.id, organization_id: @organization.id)
            end

            # if the module_project is nil
            unless old_mp.view.nil?
              #Update the new project/estimation views and widgets
              project_ctlr.update_views_and_widgets(new_prj, old_mp, new_mp)
            end

            #Update the Unit of works's groups
            new_mp.guw_unit_of_work_groups.each do |guw_group|
              new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
              new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
              guw_group.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)

              # Update the group unit of works and attributes
              guw_group.guw_unit_of_works.each do |guw_uow|
                new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
                new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

                new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
                new_pbs_id = new_pbs.nil? ? nil : new_pbs.id
                guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id)
              end
            end

            ["input", "output"].each do |io|
              new_mp.pemodule.pe_attributes.each do |attr|
                old_prj.pbs_project_elements.each do |old_component|
                  new_prj_components.each do |new_component|
                    ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                    unless ev.nil?
                      ev.string_data_low[new_component.id.to_i] = ev.string_data_low[old_component.id]
                      ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely[old_component.id]
                      ev.string_data_high[new_component.id.to_i] = ev.string_data_high[old_component.id]
                      ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable[old_component.id]

                      # update ev attribute links
                      unless ev.estimation_value_id.nil?
                        project_id = new_prj.id
                        new_evs = EstimationValue.where(copy_id: ev.estimation_value_id).all
                        new_ev = new_evs.select { |est_v| est_v.module_project.project_id == project_id}.first
                        if new_ev
                          ev.estimation_value_id = new_ev.id
                        end
                      end

                      ev.save
                    end
                  end
                end
              end
            end
          end

          # Update project's organization estimations counter
          # if new_prj.is_model != true
          #   unless @organization.estimations_counter.nil?
          #     @organization.estimations_counter -= 1
          #     @organization.save
          #   end
          # end

          unless new_prj.is_model == true || @current_user.super_admin == true
            unless @organization.estimations_counter.nil? || @organization.estimations_counter == 0
              @organization.estimations_counter -= 1
              @organization.save
            end
          end

          # flash[:success] = I18n.t(:notice_project_successful_duplicated)
          # redirect_to edit_project_path(new_prj) and return
        else
          #if params[:action_name] == "create_project_from_template"
          # if !params[:create_project_from_template].nil?
          #   flash[:error] = I18n.t(:project_already_exist, value: old_prj.title)
          #   redirect_to projects_from_path(organization_id: @organization.id) and return
          # else
          #   flash[:error] = I18n.t(:error_project_failed_duplicate)
          #   redirect_to organization_estimations_path(@current_organization)
          # end
        end
      end   # Fin transaction
    end

  end
end


