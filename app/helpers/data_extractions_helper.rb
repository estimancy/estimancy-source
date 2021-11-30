#############################################################################
# CONTAINS ALL DATA EXTRACTIONS METHODS
#############################################################################

module DataExtractionsHelper
  def raw_data_extraction_synthese(organization, organization_projects)
    #sleep(0.010)
    @organization = organization
    @organization_projects = organization_projects

    workbook = RubyXL::Workbook.new

    worksheet_synt = workbook.worksheets[0]
    worksheet_synt.sheet_name = 'Synthèse'

    i = 1

    @total_cost = Hash.new {|h,k| h[k] = [] }
    @total_effort = Hash.new {|h,k| h[k] = [] }
    @guow_guw_coefficient_element_unit_of_works = Hash.new {|h,k| h[k] = [] }
    @project_guw_coefficient_element_unit_of_works = Hash.new {|h,k| h[k] = [] }
    @guow_guw_unit_of_work_attributes = Hash.new {|h,k| h[k] = [] }
    @pfs = Hash.new {|h,k| h[k] = [] }
    @pf_hash = Hash.new
    @app_hash = Hash.new
    @ac_hash = Hash.new
    @pa_hash = Hash.new
    @plc_hash = Hash.new
    @a_hash = Hash.new
    @p_hash = Hash.new
    @pf_hash_2 = Hash.new
    @statuses_hash = Hash.new
    @guw_hash = Hash.new {|h,k| h[k] = [] }
    @max_guw_model_attributes_size = 1

    field = Field.where(organization_id: @organization.id, name: "Localisation").first

    @organization_projects.each do |project|
      project.project_fields.each do |pf|
        @pfs["#{pf.project_id}_#{pf.field_id}"] << pf
      end

      #on calcule la taille maximale des attributs de tous les projets
      pmp = project.module_projects.select{|i| i.guw_model_id != nil }.first
      unless pmp.nil?
        guw_model = pmp.guw_model
        guw_model_attributes_size = guw_model.guw_attributes.all.size
        if guw_model_attributes_size > @max_guw_model_attributes_size
          @max_guw_model_attributes_size = guw_model_attributes_size
        end
      end
    end

    fe = Field.where(organization_id: @organization.id,
                     name: ["Charge Totale (jh)", "Effort Total (UC)", "Effort Total (jh)", "Charge totale (j)"]).first

    fc = Field.where(organization_id: @organization.id,
                     name: ["Coût (k€)", "Coût total (k€)"]).first

    @total_cost = Hash.new {|h,k| h[k] = [] }
    @total_effort = Hash.new {|h,k| h[k] = [] }


    @organization_projects.each do |project|
      if @total_effort[project.id].sum.to_f == 0 || @total_effort[project.id].sum.to_f == 0
        unless fe.nil?
          @pfs["#{project.id}_#{fe.id}"].each do |pf|
            @total_effort[project.id] << pf.value.to_f
          end
        end

        unless fc.nil?
          @pfs["#{project.id}_#{fc.id}"].each do |pf|
            fc_coefficient = fc.coefficient
            unless fc_coefficient.nil?
              @total_cost[project.id] << pf.value.to_f
            end
          end
        end
      end
    end

    worksheet_synt.add_cell(0, 0, "Devis")
    worksheet_synt.add_cell(0, 1, "Application")
    worksheet_synt.add_cell(0, 2, "Besoin Métier")
    worksheet_synt.add_cell(0, 3, "Numero de demande")
    worksheet_synt.add_cell(0, 4, "Domaine")
    worksheet_synt.add_cell(0, 5, "Service")
    worksheet_synt.add_cell(0, 6, "Localisation WBS")

    if "cds voyageurs".in?(@organization.name.to_s.downcase)
      worksheet_synt.add_cell(0, 7, "Urgence Devis")
    else
      worksheet_synt.add_cell(0, 7, "Localisation Devis")
    end

    worksheet_synt.add_cell(0, 8, "Catégorie")
    worksheet_synt.add_cell(0, 9, "Fournisseur")
    worksheet_synt.add_cell(0, 10, "Date")
    worksheet_synt.add_cell(0, 11, "Statut")
    worksheet_synt.add_cell(0, 12, "Charge totale")
    worksheet_synt.add_cell(0, 13, "Coût total (€)")
    worksheet_synt.add_cell(0, 14, "Prix moyen pondéré")

    pi = 1

    @organization_projects.each do |project|
      # project = Project.find(k)
      unless project.is_model == true

        project_application = project.application.nil? ? nil : project.application.name
        project_project_area = project.project_area.nil? ? nil : project.project_area.name
        project_acquisition_category = project.acquisition_category.nil? ? nil : project.acquisition_category.name
        project_project_category = project.project_category.nil? ? nil : project.project_category.name
        project_platform_category = project.platform_category.nil? ? nil : project.platform_category.name
        project_provider = project.provider.nil? ? nil : project.provider.name
        project_estimation_status = project.estimation_status.nil? ? nil : project.estimation_status.name

        worksheet_synt.add_cell(pi, 0, project.title)
        worksheet_synt.add_cell(pi, 1, project_application)
        worksheet_synt.add_cell(pi, 2, project.business_need)
        worksheet_synt.add_cell(pi, 3, project.request_number)
        worksheet_synt.add_cell(pi, 4, project_project_area)
        worksheet_synt.add_cell(pi, 5, project_acquisition_category)

        unless field.nil?
          pf = project.project_fields.select{ |i| i.field_id == field.id }.first
          value = pf.nil? ? nil : pf.value
          worksheet_synt.add_cell(pi, 6, value)
        end

        worksheet_synt.add_cell(pi, 7, project_platform_category.to_s)

        worksheet_synt.add_cell(pi, 8, project_project_category.to_s)
        worksheet_synt.add_cell(pi, 9, project_provider)
        worksheet_synt.add_cell(pi, 10, project.start_date.to_s)
        worksheet_synt.add_cell(pi, 11, project_estimation_status)

        worksheet_synt.add_cell(pi, 12, @total_effort[project.id].sum.to_f.round(2))
        worksheet_synt.add_cell(pi, 13, @total_cost[project.id].sum.to_f.round(2))

        unless @total_effort[project.id].sum == 0
          worksheet_synt.add_cell(pi, 14, (@total_cost[project.id].sum.to_f / @total_effort[project.id].sum.to_f).round(2) )
        end

        pi = pi + 1
      end

      #sleep(0.010)
    end

    workbook
  end

  #raw_data_extract_cf
  def raw_data_extract_abaques_services_DE(organization, organization_projects)
    @organization = organization
    @organization_projects = organization_projects

    workbook = RubyXL::Workbook.new

    worksheet_cf = workbook.worksheets[0]
    worksheet_cf.sheet_name = 'Comp. Abaques & Serv. Dire Exp'

    worksheet_cf.add_cell(0, 0, "Devis")
    worksheet_cf.add_cell(0, 1, "Application")
    worksheet_cf.add_cell(0, 2, "Besoin Métier")
    worksheet_cf.add_cell(0, 3, "Numero de demande")
    worksheet_cf.add_cell(0, 4, "Domaine")
    worksheet_cf.add_cell(0, 5, "Service")
    worksheet_cf.add_cell(0, 6, "Localisation WBS")

    #unless @organization.name == "CDS VOYAGEURS"
    if "cds voyageurs".in?(@organization.name.to_s.downcase)
      worksheet_cf.add_cell(0, 7, "Urgence Devis")
    else
      worksheet_cf.add_cell(0, 7, "Localisation Devis")
    end

    worksheet_cf.add_cell(0, 8, "Catégorie")
    worksheet_cf.add_cell(0, 9, "Fournisseur")
    worksheet_cf.add_cell(0, 10, "Date")
    worksheet_cf.add_cell(0, 11, "Statut")
    worksheet_cf.add_cell(0, 12, "Composant fonctionnel")
    worksheet_cf.add_cell(0, 13, "Type de composant")
    worksheet_cf.add_cell(0, 14, "Complexité théorique")
    worksheet_cf.add_cell(0, 15, "Complexité calculée")
    worksheet_cf.add_cell(0, 16, "% DEV théorique")
    worksheet_cf.add_cell(0, 17, "% DEV calculé")
    worksheet_cf.add_cell(0, 18, "% TEST théorique")
    worksheet_cf.add_cell(0, 19, "% TEST calculé")

    i = 1

    @total_cost = Hash.new {|h,k| h[k] = [] }
    @total_effort = Hash.new {|h,k| h[k] = [] }
    @guow_guw_coefficient_element_unit_of_works = Hash.new {|h,k| h[k] = [] }
    @project_guw_coefficient_element_unit_of_works = Hash.new {|h,k| h[k] = [] }
    @guow_guw_unit_of_work_attributes = Hash.new {|h,k| h[k] = [] }
    @pfs = Hash.new {|h,k| h[k] = [] }
    @pf_hash = Hash.new
    @app_hash = Hash.new
    @ac_hash = Hash.new
    @pa_hash = Hash.new
    @plc_hash = Hash.new
    @a_hash = Hash.new
    @p_hash = Hash.new
    @pf_hash_2 = Hash.new
    @statuses_hash = Hash.new
    @guw_hash = Hash.new {|h,k| h[k] = [] }
    @max_guw_model_attributes_size = 1

    field = Field.where(organization_id: @organization.id, name: "Localisation").first

    @organization_projects.each do |project|

      project.project_fields.each do |pf|
        @pfs["#{pf.project_id}_#{pf.field_id}"] << pf
      end

      #on calcule la taille maximale des attributs de tous les projets
      pmp = project.module_projects.select{|i| i.guw_model_id != nil }.first
      unless pmp.nil?
        guw_model = pmp.guw_model
        guw_model_attributes_size = guw_model.guw_attributes.all.size
        if guw_model_attributes_size > @max_guw_model_attributes_size
          @max_guw_model_attributes_size = guw_model_attributes_size
        end
      end
    end


    @organization_projects.each do |project|

      pmp = project.module_projects.select{|i| i.guw_model_id != nil }.first

      @project_guw_coefficient_element_unit_of_works = project.guw_coefficient_element_unit_of_works

      unless pmp.nil?
        @guw_model = pmp.guw_model

        ### Localisation ###
        guw_coefficient_localisation = Guw::GuwCoefficient.where( organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  name: "Localisation").first

        ### Métrique ###
        guw_coefficient_metrique_migration = Guw::GuwCoefficient.where(organization_id: @organization.id,
                                                                       guw_model_id: @guw_model.id,
                                                                       name: "Métrique Quantité").first

        guw_coefficient_nbj_migration = Guw::GuwCoefficient.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  name: "Nb de jours").first

        guw_coefficient_quantite_migration = Guw::GuwCoefficient.where(organization_id: @organization.id,
                                                                       guw_model_id: @guw_model.id,
                                                                       name: "Quantité").first

        guw_coefficient_service_migration = Guw::GuwCoefficient.where(organization_id: @organization.id,
                                                                      guw_model_id: @guw_model.id,
                                                                      name: "Service").first

        @guow_guw_coefficient_element_unit_of_works_with_coefficients = {}

        coeff_elt_uow = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                   guw_model_id: @guw_model.id,
                                                                   project_id: project.id,
                                                                   module_project_id: pmp.id)

        coeff_elt_uow.order("updated_at ASC").each do |gceuw|
          @guow_guw_coefficient_element_unit_of_works_with_coefficients["#{gceuw.guw_unit_of_work_id}_#{gceuw.guw_coefficient_id}"] = gceuw
        end

        @guw_model_guw_attributes = @guw_model.guw_attributes
        @guw_coefficients = @guw_model.guw_coefficients.includes(:guw_coefficient_elements)
        @guw_coefficient_elements = @guw_coefficients.flat_map(&:guw_coefficient_elements)
        guw_charge_ss_prod_coefficient = @guw_coefficients.where(coefficient_type: "Coefficient", name: ["Charge Services (jh)", "Charge ss prod. (jh)", "Charge ss productivité (jh)", "Charge (jh)", "Charge sans prod. (jh)", "Charge sans productivité (jh)"]).first

        guw_output_effort = Guw::GuwOutput.where(name: ["Charges T (jh)", "Charge Services (jh)", "Charge (jh)"], guw_model_id: @guw_model.id).first

        guw_output_charge_ss_prod = Guw::GuwOutput.where(output_type: "Effort",
                                                         name: ["Charge Services (jh)",
                                                                "Charge ss prod. (jh)",
                                                                "Charge ss productivité (jh)",
                                                                "Charge (jh)",
                                                                "Charge sans prod. (jh)",
                                                                "Charge sans productivité (jh)"], guw_model_id: @guw_model.id).first

        guw_output_cost = Guw::GuwOutput.where(name: ["Coût Services (€)", "Coût (€)"], guw_model_id: @guw_model.id).first

        unless field.nil?
          pf = project.project_fields.select{ |i| i.field_id == field.id }.first
        end

        project_application = project.application.nil? ? nil : project.application.name
        project_project_area = project.project_area.nil? ? nil : project.project_area.name
        project_acquisition_category = project.acquisition_category.nil? ? nil : project.acquisition_category.name
        project_project_category = project.project_category.nil? ? nil : project.project_category.name
        project_platform_category = project.platform_category.nil? ? nil : project.platform_category.name
        project_provider = project.provider.nil? ? nil : project.provider.name
        project_estimation_status = project.estimation_status.nil? ? nil : project.estimation_status.name

        @guow_guw_types = Hash.new

        project_guw_unit_of_works = project.guw_unit_of_works
        project_guw_unit_of_works.each do |guow|
          @guow_guw_coefficient_element_unit_of_works[guow.id] << @project_guw_coefficient_element_unit_of_works[project.id]
        end

        project.guw_unit_of_work_attributes.each do |guowa|
          @guow_guw_unit_of_work_attributes[guowa.guw_unit_of_work_id] << guowa
        end

        project_guw_unit_of_works.includes(:guw_coefficient_element_unit_of_works).each do |guow|

          guow_guw_type = guow.guw_type
          guow_guw_coefficient_element_unit_of_works = @guow_guw_coefficient_element_unit_of_works[guow.id]
          # guow.guw_coefficient_element_unit_of_works

          worksheet_cf.add_cell(i, 0, project.title)
          worksheet_cf.add_cell(i, 1, project_application.to_s)
          worksheet_cf.add_cell(i, 2, project.business_need)
          worksheet_cf.add_cell(i, 3, project.request_number)
          worksheet_cf.add_cell(i, 4, project_project_area.to_s)
          worksheet_cf.add_cell(i, 5, project_acquisition_category.to_s)

          unless field.nil?
            value = pf.nil? ? nil : pf.value
            worksheet_cf.add_cell(i, 6, value)
          end

          worksheet_cf.add_cell(i, 7, project_platform_category.to_s)

          worksheet_cf.add_cell(i, 8, project_project_category.to_s)
          worksheet_cf.add_cell(i, 9, project_provider.to_s)
          worksheet_cf.add_cell(i, 10, project.start_date.to_s)
          worksheet_cf.add_cell(i, 11, project_estimation_status.to_s)
          worksheet_cf.add_cell(i, 12, guow.name)

          worksheet_cf.add_cell(i, 13, guow.guw_type.nil? ? nil : guow.guw_type.name)

          if guow.intermediate_percent.nil? && guow.intermediate_weight.nil?
            @guw_coefficients.each do |gc|
              if gc.coefficient_type == "Liste" && gc.name == "Taille"
                ceuw = @project_guw_coefficient_element_unit_of_works.select{|i| i.guw_coefficient_id == gc.id && i.module_project_id == guow.module_project_id && i.guw_unit_of_work_id == guow.id }.last

                unless ceuw.nil?
                  guw_coefficient_element_name = ceuw.guw_coefficient_element.nil? ? nil : ceuw.guw_coefficient_element.name
                end

                worksheet_cf.add_cell(i, 14, guw_coefficient_element_name.blank? ? '--' : guw_coefficient_element_name)
                worksheet_cf.add_cell(i, 15, guw_coefficient_element_name.blank? ? '--' : guw_coefficient_element_name)
              end
            end
          else
            worksheet_cf.add_cell(i, 14, guow.intermediate_percent)
            worksheet_cf.add_cell(i, 15, guow.intermediate_weight)
          end

          j = 0
          @guw_coefficients.each do |gc|
            if gc.coefficient_type == "Pourcentage"
              unless guow_guw_type.nil?
                unless guow_guw_type.name.include?("SRV") || guow_guw_type.name.include?("MCO")

                  default = @guw_coefficient_elements.select{ |i| (i.default == true && i.guw_coefficient_id == gc.id ) }.first
                  ceuw = @project_guw_coefficient_element_unit_of_works.select{ |i| i.guw_coefficient_id == gc.id }.select{|i| i.module_project_id == guow.module_project_id }.last

                  worksheet_cf.add_cell(i, 16 + j, default.nil? ? 100 : default.value.to_f)
                  worksheet_cf.add_cell(i, 16 + j + 1, ceuw.nil? ? nil : ceuw.percent.to_f)
                  j = j + 2
                end
              end

              # Charge sans prod en colonne AI
            elsif guw_charge_ss_prod_coefficient
              if gc.id == guw_charge_ss_prod_coefficient.id
                #=== Test ====
                #results = []
                #results = @guw_coefficient_elements.map{|i| i.guw_complexity_coefficient_elements
                # .includes(:guw_coefficient_element)
                # .where(organization_id: @organization.id, guw_model_id: @guw_model.id, guw_type_id: guow.guw_type_id)
                # .select{|ct| ct.value != nil }
                # .map{|i| i.guw_coefficient_element }.uniq }.flatten.compact.sort! { |a, b|  a.display_order.to_i <=> b.display_order.to_i }
                #=== Test ====

                #unless results.empty?
                begin
                  ceuw = @guow_guw_coefficient_element_unit_of_works_with_coefficients["#{guow.id}_#{gc.id}"]
                rescue
                  ceuw = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                    guw_model_id: @guw_model.id,
                                                                    guw_coefficient_id: gc.id,
                                                                    project_id: project.id,
                                                                    module_project_id: pmp.id,
                                                                    guw_unit_of_work_id: guow.id).order("updated_at ASC").last
                end

                worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size, (ceuw.nil? ? nil : ceuw.percent))  # « Charge ss prod. (jh) » en colonne AI
                #end
              end
            end
          end

          # guow.guw_unit_of_work_attributes.each_with_index do |uowa, j|
          @guow_guw_unit_of_work_attributes[guow.id].each_with_index do |uowa, j|
            worksheet_cf.add_cell(i, 20 + j, uowa.most_likely)
          end

          @guw_model_guw_attributes.each_with_index do |guw_attribute, ii|
            worksheet_cf.add_cell(0, 20+ii, guw_attribute.name)
          end

          worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size, "Charge ss prod. (jh)")
          worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 1, "Charge avec prod. (jh)")
          worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 2, "Coût Services (€)")


          #On recuperer les sorties "Charge ss prod. (jh)"
          unless guw_output_charge_ss_prod.nil?
            guw_output_charge_ss_prod_value_tmp = guow.ajusted_size.nil? ? nil : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_charge_ss_prod.id}"])
            guw_output_charge_ss_prod_value = (guw_output_charge_ss_prod_value_tmp.blank? ? nil : guw_output_charge_ss_prod_value_tmp.to_f)
            guw_output_charge_ss_prod_value_rounded = (guw_output_charge_ss_prod_value.nil? || guw_output_charge_ss_prod_value == 0) ? nil : guw_output_charge_ss_prod_value.round(2)
            worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size, guw_output_charge_ss_prod_value_rounded)  # « Charge ss prod. (jh) » en colonne AI
          end

          #On recuperer les sorties avec "Charge (jh)" avec productivité
          unless guw_output_effort.nil?
            guw_output_effort_value_tmp = guow.ajusted_size.nil? ? nil : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_effort.id}"])
            guw_output_effort_value = (guw_output_effort_value_tmp.blank? ? nil : guw_output_effort_value_tmp.to_f)
            guw_output_charge_ss_prod_value_rounded = (guw_output_effort_value.nil? || guw_output_effort_value == 0) ? nil : guw_output_effort_value.round(2)
          end

          #On recuperer les sorties avec " Coût Services (€) "
          unless guw_output_cost.nil?
            guw_output_cost_value_tmp = guow.ajusted_size.nil? ? nil : guow.ajusted_size["#{guw_output_cost.id}"]#.to_f.round(2)
            guw_output_cost_value = (guw_output_cost_value_tmp.blank? ? nil : guw_output_cost_value_tmp.to_f)
            guw_output_cost_value_rounded = ((guw_output_cost_value.nil? || guw_output_cost_value == 0) ? nil : guw_output_cost_value.round(2))
          end

          worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 1, guw_output_effort_value)  # « Charge avec prod. (jh) » en colonne AJ
          worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 2, guw_output_cost_value_rounded)  # « Coût Services (€) » en colonne AK

          @total_effort[project.id] << guw_output_effort_value.to_f
          @total_cost[project.id] << guw_output_cost_value.to_f


          begin
            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 3, "Service")

            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 4, "Quantité")
            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 5, "Nb de jours")

            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 6, "Métrique Quantité")

            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 7, "Charge (j.h)")
            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 8, "Coût (€)")

            worksheet_cf.add_cell(0, 20 + @max_guw_model_attributes_size + 9, "Localisation SRV")

            unless guw_coefficient_service_migration.nil?
              service_migration = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                             guw_model_id: @guw_model.id,
                                                                             guw_coefficient_id: guw_coefficient_service_migration.id,
                                                                             project_id: project.id,
                                                                             module_project_id: pmp.id,
                                                                             guw_unit_of_work_id: guow.id).order("updated_at ASC").last

              unless service_migration.guw_coefficient_element.nil?
                worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 3, service_migration.guw_coefficient_element.name) # Service
              end

            end

          rescue
          end


          begin
            unless guw_coefficient_quantite_migration.nil?
              nbj_migration = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                         guw_model_id: @guw_model.id,
                                                                         guw_coefficient_id: guw_coefficient_quantite_migration.id,
                                                                         project_id: project.id,
                                                                         module_project_id: pmp.id,
                                                                         guw_unit_of_work_id: guow.id).order("updated_at ASC").last

              ce = guw_coefficient_quantite_migration.guw_coefficient_elements.first

              unless ce.nil?
                cces = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_type_id: guow.guw_type_id,
                                                                  guw_coefficient_element_id: ce.id)

                if !cces.map(&:value).empty?
                  worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 4, nbj_migration.percent) # Nb de jours
                end

              end

            end
          rescue
          end


          begin
            unless guw_coefficient_nbj_migration.nil?
              nbj_migration = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                         guw_model_id: @guw_model.id,
                                                                         guw_coefficient_id: guw_coefficient_nbj_migration.id,
                                                                         project_id: project.id,
                                                                         module_project_id: pmp.id,
                                                                         guw_unit_of_work_id: guow.id).order("updated_at ASC").last

              ce = guw_coefficient_nbj_migration.guw_coefficient_elements.first

              unless ce.nil?
                cces = Guw::GuwComplexityCoefficientElement.where(organization_id: @organization.id,
                                                                  guw_model_id: @guw_model.id,
                                                                  guw_type_id: guow.guw_type_id,
                                                                  guw_coefficient_element_id: ce.id)

                if !cces.map(&:value).empty?
                  worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 5, nbj_migration.percent) # Nb de jours
                end

              end

            end
          rescue
          end

          begin
            unless guw_coefficient_metrique_migration.nil?
              metrique_migration = Guw::GuwCoefficientElementUnitOfWork.where(organization_id: @organization.id,
                                                                              guw_model_id: @guw_model.id,
                                                                              guw_coefficient_id: guw_coefficient_metrique_migration.id,
                                                                              project_id: project.id,
                                                                              module_project_id: pmp.id,
                                                                              guw_unit_of_work_id: guow.id).order("updated_at ASC").last

              metrique_migration_guw_coefficient_element = metrique_migration.guw_coefficient_element
              unless metrique_migration_guw_coefficient_element.nil?
                worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 6, metrique_migration_guw_coefficient_element.name) # Métrique
              end
            end
          rescue
          end

          begin
            ### Charge ###
            guw_output_charge_migration = Guw::GuwOutput.where( organization_id: @organization.id,
                                                                guw_model_id: @guw_model.id,
                                                                name: "Charge (j.h)").first

            guw_output_cout_migration = Guw::GuwOutput.where( organization_id: @organization.id,
                                                              guw_model_id: @guw_model.id,
                                                              name: "Coût (€)").first



            worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 7, guow.ajusted_size.nil? ? nil : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_charge_migration.id}"].to_f.round(2))) # Charge
            worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 8, guow.ajusted_size.nil? ? nil : (guow.ajusted_size.is_a?(Numeric) ? guow.ajusted_size : guow.ajusted_size["#{guw_output_cout_migration.id}"])) # Cout
          rescue
          end

          begin
            unless guw_coefficient_localisation.nil?
              # gceuw_localisation = Guw::GuwCoefficientElementUnitOfWork.where( organization_id: @organization.id,
              #                                                                  guw_model_id: @guw_model.id,
              #                                                                  guw_coefficient_id: guw_coefficient_localisation.id,
              #                                                                  project_id: project.id,
              #                                                                  module_project_id: pmp.id,
              #                                                                  guw_unit_of_work_id: guow.id).first

              gceuw_localisation = guow_guw_coefficient_element_unit_of_works.select{ |i| i.guw_coefficient_id == guw_coefficient_localisation.id }.first
              gceuw_localisation_guw_coefficient_element = gceuw_localisation.guw_coefficient_element

              unless gceuw_localisation_guw_coefficient_element.nil?
                gceuw_name = gceuw_localisation_guw_coefficient_element.name
              end

              worksheet_cf.add_cell(i, 20 + @max_guw_model_attributes_size + 9, gceuw_name) # Localisation
            end

          rescue
          end

          i = i + 1
        end

      end
      #sleep(0.10)
    end

    workbook
  end


  def raw_data_extract_services_ratio(organization, organization_projects)

    @organization = organization
    @organization_projects = organization_projects

    workbook = RubyXL::Workbook.new
    worksheet_wbs = workbook.worksheets[0]
    worksheet_wbs.sheet_name = 'Services avec ratio'

    field = Field.where(organization_id: @organization.id, name: "Localisation").first
    i = 1

    worksheet_wbs.add_cell(0, 0, "Devis")
    worksheet_wbs.add_cell(0, 1, "Application")
    worksheet_wbs.add_cell(0, 2, "Besoin Métier")
    worksheet_wbs.add_cell(0, 3, "Numero de demande")
    worksheet_wbs.add_cell(0, 4, "Domaine")
    worksheet_wbs.add_cell(0, 5, "Service")
    worksheet_wbs.add_cell(0, 6, "Localisation WBS")

    if "cds voyageurs".in?(@organization.name.to_s.downcase)
      worksheet_wbs.add_cell(0, 7, "Urgence Devis")
    else
      worksheet_wbs.add_cell(0, 7, "Localisation Modèle")
    end

    worksheet_wbs.add_cell(0, 8, "Catégorie")
    worksheet_wbs.add_cell(0, 9, "Fournisseur")
    worksheet_wbs.add_cell(0, 10, "Date")
    worksheet_wbs.add_cell(0, 11, "Statut")
    worksheet_wbs.add_cell(0, 12, "Ratio")
    worksheet_wbs.add_cell(0, 13, "Phase")
    worksheet_wbs.add_cell(0, 14, "TJM")
    worksheet_wbs.add_cell(0, 15, "Charge calculée")
    worksheet_wbs.add_cell(0, 16, "Charge retenue")
    worksheet_wbs.add_cell(0, 17, "Coût calculé (€)")
    worksheet_wbs.add_cell(0, 18, "Coût retenu (€)")

    # if params[:date_min].present? && params[:date_min].present?
    #   mpres = ModuleProjectRatioElement.where(organization_id: @organization.id).where("created_at > ?", timeago).where("theoretical_effort_most_likely IS NOT NULL").includes(:module_project, :wbs_activity_ratio)
    # else
    #mpres = ModuleProjectRatioElement.where(organization_id: @organization.id).where("theoretical_effort_most_likely IS NOT NULL").includes(:module_project, :wbs_activity_ratio)
    # end

    #mpres = ModuleProjectRatioElement.where(organization_id: @organization.id).where("theoretical_effort_most_likely IS NOT NULL").includes(:module_project, :wbs_activity_ratio)

    wbs_iii = 0
    @organization_projects.each do |organization_project|

      mpres = organization_project.module_project_ratio_elements.where(organization_id: @organization.id).where("theoretical_effort_most_likely IS NOT NULL").includes(:module_project, :wbs_activity_ratio)

      mpres.each do |mpre|

        mpre_project = mpre.module_project&.project
        module_project = mpre.module_project
        mpre_wbs_activity_ratio = mpre.wbs_activity_ratio

        unless mpre_project.nil?
          if module_project.wbs_activity_ratio_id == mpre.wbs_activity_ratio_id

            project_application = mpre_project.application.nil? ? nil : mpre_project.application.name
            project_project_area = mpre_project.project_area.nil? ? nil : mpre_project.project_area.name
            project_acquisition_category = mpre_project.acquisition_category.nil? ? nil : mpre_project.acquisition_category.name
            project_project_category = mpre_project.project_category.nil? ? nil : mpre_project.project_category.name
            project_platform_category = mpre_project.platform_category.nil? ? nil : mpre_project.platform_category.name
            project_provider = mpre_project.provider.nil? ? nil : mpre_project.provider.name
            project_estimation_status = mpre_project.estimation_status.nil? ? nil : mpre_project.estimation_status.name

            unless mpre_project.is_model == true

              wbs_iii = wbs_iii+1
              worksheet_wbs.add_cell(wbs_iii, 0, mpre_project.title)
              worksheet_wbs.add_cell(wbs_iii, 1, project_application.nil? ? mpre_project.application_name : project_application)
              worksheet_wbs.add_cell(wbs_iii, 2, mpre_project.business_need)
              worksheet_wbs.add_cell(wbs_iii, 3, mpre_project.request_number)
              worksheet_wbs.add_cell(wbs_iii, 4, project_project_area.nil? ? '' : project_project_area)
              worksheet_wbs.add_cell(wbs_iii, 5, project_acquisition_category.nil? ? '' : project_acquisition_category)

              unless field.nil?
                pf = mpre_project.project_fields.select{ |i| i.field_id == field.id }.first

                unless field.nil?
                  value = pf.nil? ? nil : pf.value
                  worksheet_wbs.add_cell(wbs_iii, 6, value)
                end
              end

              worksheet_wbs.add_cell(wbs_iii, 7, project_platform_category.nil? ? '' : project_platform_category.to_s)

              worksheet_wbs.add_cell(wbs_iii, 8, project_project_category.to_s)
              worksheet_wbs.add_cell(wbs_iii, 9, project_provider.nil? ? '' : project_provider)
              worksheet_wbs.add_cell(wbs_iii, 10, mpre_project.start_date.to_s)
              worksheet_wbs.add_cell(wbs_iii, 11, project_estimation_status.to_s)
              worksheet_wbs.add_cell(wbs_iii, 12, mpre_wbs_activity_ratio.nil? ? nil : mpre_wbs_activity_ratio.name)
              worksheet_wbs.add_cell(wbs_iii, 13, mpre.name)
              worksheet_wbs.add_cell(wbs_iii, 14, mpre.tjm)

              worksheet_wbs.add_cell(wbs_iii, 15, mpre.theoretical_effort_most_likely.blank? ? 0 : mpre.theoretical_effort_most_likely.round(2))
              worksheet_wbs.add_cell(wbs_iii, 16, mpre.retained_effort_most_likely.blank? ? 0 : mpre.retained_effort_most_likely.round(2))
              worksheet_wbs.add_cell(wbs_iii, 17, mpre.theoretical_cost_most_likely.blank? ? 0 : mpre.theoretical_cost_most_likely.round(2))
              worksheet_wbs.add_cell(wbs_iii, 18, mpre.retained_cost_most_likely.blank? ? 0 : mpre.retained_cost_most_likely.round(2))

              # worksheet_wbs.add_cell(wbs_iii, 15, mpre.theoretical_effort_most_likely.blank? ? 0 : mpre.theoretical_effort_most_likely.round(user_number_precision))
              # worksheet_wbs.add_cell(wbs_iii, 16, mpre.retained_effort_most_likely.blank? ? 0 : mpre.retained_effort_most_likely.round(user_number_precision))
              # worksheet_wbs.add_cell(wbs_iii, 17, mpre.theoretical_cost_most_likely.blank? ? 0 : mpre.theoretical_cost_most_likely.round(user_number_precision))
              # worksheet_wbs.add_cell(wbs_iii, 18, mpre.retained_cost_most_likely.blank? ? 0 : mpre.retained_cost_most_likely.round(user_number_precision))
            end
          end
        end
        #sleep(0.010)
      end
    end

    workbook
  end

  def user_number_precision(user)
    if user && !user.number_precision.nil?
      user.number_precision
    else
      2
    end
  end

end
