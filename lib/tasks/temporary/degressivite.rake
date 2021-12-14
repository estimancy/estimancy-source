# rake change:degressivite RAILS_ENV=production
# rake change:degressivite["CDS GP","A4","A5"] RAILS_ENV=production

namespace :change do

  desc "Changement de la valeur des dégressivités automatique (2021-2022)"
  #task :degressivite, [:organization_name, :annee_encours, :annee_suivante] => :environment do |task, args|
  task :degressivite => :environment do

    # annee1 = args[:annee_encours].to_s
    # annee2 = args[:annee_suivante].to_s
    # cds_name = args[:organization_name].to_s

    #organizations = Organization.where(name: cds_name)
    #organizations = Organization.where(name: ["CDS DISTRIBUTION TRANSPORTEUR", "CDS AURORE", "CDS BOREALE", "CDS CASSIOPEE", "CDS GP", "CDS PROD TRAIN", "CDS VOYAGEURS", "CDS RH", "CDS MATERIEL", "01_DSI FS_CdS Gestion Pluriel", "02_DSI FS_CdS RH", "04_DSI PF_CdS Production Train", "05_DSI PF_CdS Voyageurs", "06_DSI Voyage_CdS Distribution Transporteur", "07_DSI Matériel_CdS Matériel", "08_DSI Réseau_CdS Aurore", "09_DSI Réseau_CdS Boréale", "10_DSI Réseau_CdS Cassiopée", "11_DSI CdS ERP"]).all
    #Guw::GuwComplexityCoefficientElement.where(guw_complexity_id: nil).delete_all

    organizations = Organization.where.not(name: ["CDS ERP", "11_DSI CdS ERP"])

    organizations.each do |o|

        p " **** =========> #{o.name} <========== **** "

        if o.name.in? ["CDS VOYAGEURS", "05_DSI PF_CdS Voyageurs", "CDS ERP", "11_DSI CdS ERP"]
          annee1 = "A3"
          annee2 = "A4"
        else
          annee1 = "A4"
          annee2 = "A5"
        end

        o.guw_models.each do |guw_model|

          if guw_model.name.start_with?("P") #&& guw_model.name == "P3 - Dénombrement Evolution & Dire d'expert"

            p " =====> #{guw_model.name} <===== "

            guw_types = guw_model.guw_types#.where(name: "CF CUB_ANA")

            guw_model.guw_coefficients.each do |guw_coefficient|

              if guw_coefficient.name.include?("Dégressivité") #|| guw_coefficient.name.include?("dégressivité") || guw_coefficient.name.include?("Dégres")

                a1 = guw_coefficient.guw_coefficient_elements.where(name: annee1).first
                a2 = guw_coefficient.guw_coefficient_elements.where(name: annee2).first

                #guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|

                #if guw_coefficient_element.name == 'A4'
                if a1.nil? || a2.nil?
                  p " =====> l'année 1 ou 2 n'existe pas pour le coeff #{guw_coefficient.name} <===== "

                else
                  # p " =====> Année encours #{a1.name} <===== "
                  # p " =====> Année suivante #{a2.name} <===== "

                  a1_id = a1.id
                  a2_id = a2.id

                  a1.default = false
                  a2.default = true

                  a1.save
                  a2.save

                  guw_types.each do |guw_type|
                    #guw_coefficient_element.guw_complexity_coefficient_elements.each do |cce|
                    cces = Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
                                                                     guw_model_id: guw_model.id,
                                                                     guw_coefficient_element_id: a1_id,
                                                                     guw_type_id: guw_type.id).update_all(guw_coefficient_element_id: a2_id)
                    # if cces == 0
                    #   p " =====> Pas de degressivite #{a1.name} à remplacer pour #{guw_type.name} <===== "
                    # end
                  end
                end
              end
            end
          end
        end
      end

  end


  # desc "Changement de la valeur des dégressivités automatique (2019-2020)"
  # task degressivite_save: :environment do
  #
  #   #### Changement valeur automatique
  #
  #   # Guw::GuwComplexityCoefficientElement.where(guw_complexity_id: nil).delete_all
  #
  #   organizations = Organization.where(name: ["CDS DISTRIBUTION TRANSPORTEUR", "CDS AURORE", "CDS BOREALE", "CDS CASSIOPEE", "CDS GP", "CDS PROD TRAIN", "CDS VOYAGEURS", "CDS RH", "CDS MATERIEL", "01_DSI FS_CdS Gestion Pluriel", "02_DSI FS_CdS RH", "04_DSI PF_CdS Production Train", "05_DSI PF_CdS Voyageurs", "06_DSI Voyage_CdS Distribution Transporteur", "07_DSI Matériel_CdS Matériel", "08_DSI Réseau_CdS Aurore", "09_DSI Réseau_CdS Boréale", "10_DSI Réseau_CdS Cassiopée", "11_DSI CdS ERP"]).all
  #
  #   organizations.each do |o|
  #
  #     p " **** =========> #{o.name} <========== **** "
  #
  #     o.guw_models.each do |guw_model|
  #
  #       guw_model.default_display = "list"
  #       guw_model.save
  #
  #       p " =====> #{guw_model.name} <===== "
  #
  #       rtu_ris_outputs = Guw::GuwOutput.where(organization_id: o.id,
  #                                              guw_model_id: guw_model.id,
  #                                              name: ["Charge RIS (jh)", "Charge RTU (jh)", "Assiette Test (jh)", "Charge RTU Avec Dégr.", "Charge RTU avec prod. (jh)"])
  #
  #       t_outputs = Guw::GuwOutput.where(organization_id: o.id,
  #                                        guw_model_id: guw_model.id,
  #                                        name: ["Charges T (jh)", "Charge T (jh)", "Charge Services (jh)", "Coût Services (€)"])
  #
  #       guw_types = guw_model.guw_types
  #
  #       guw_model.guw_coefficients.each do |guw_coefficient|
  #         guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
  #           if guw_coefficient_element.name == 'A4'
  #
  #             guw_coefficient_element.default = true
  #             guw_coefficient_element.save
  #
  #             guw_types.each do |guw_type|
  #
  #               guw_type.guw_complexities.each do |guw_complexity|
  #
  #                 if guw_type.name.include?("CF") || guw_type.name.include?("UO") || guw_type.name.include?("RTU") ||
  #                    guw_type.name == "DEMI INTERFACES" || guw_type.name == "ECRANS" || guw_type.name == "HABILITATIONS" ||
  #                    guw_type.name == "RAPPORTS" || guw_type.name == "REP. DON. CONTROLES" || guw_type.name == "REP. DON. DATASTAGE" ||
  #                    guw_type.name == "WEBSERVICES REST" || guw_type.name == "REP. DON. DEMI INTERFACES"
  #                    guw_type.name == "WEBSERVICES SOAP" || guw_type.name == "CUSTOMISATION JAVA"
  #
  #                   if guw_coefficient.name == "Dégressivité Abaque" || guw_coefficient.name == "Dégréssivité Abaque"
  #                     rtu_ris_outputs.each do |guw_output|
  #                       Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
  #                                                                  guw_model_id: guw_model.id,
  #                                                                  guw_complexity_id: guw_complexity.id,
  #                                                                  guw_coefficient_element_id: guw_coefficient_element.id,
  #                                                                  guw_output_id: guw_output.id,
  #                                                                  guw_type_id: guw_type.id,
  #                                                                  value: 1).first_or_create
  #                     end
  #                   end
  #                 elsif guw_type.name.include?("MCO")
  #                   if guw_coefficient.name == "Dégressivité MCO" || guw_coefficient.name == "Dégréssivité MCO"
  #                     t_outputs.each do |guw_output|
  #                       Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
  #                                                                  guw_model_id: guw_model.id,
  #                                                                  guw_complexity_id: guw_complexity.id,
  #                                                                  guw_coefficient_element_id: guw_coefficient_element.id,
  #                                                                  guw_output_id: guw_output.id,
  #                                                                  guw_type_id: guw_type.id,
  #                                                                  value: 1).first_or_create
  #
  #                     end
  #                   end
  #                 else
  #                   if guw_coefficient.name == "Dégressivité Services" || guw_coefficient.name == "Dégréssivité Services"
  #                     t_outputs.each do |guw_output|
  #                       Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
  #                                                                  guw_model_id: guw_model.id,
  #                                                                  guw_complexity_id: guw_complexity.id,
  #                                                                  guw_coefficient_element_id: guw_coefficient_element.id,
  #                                                                  guw_output_id: guw_output.id,
  #                                                                  guw_type_id: guw_type.id,
  #                                                                  value: 1).first_or_create
  #                     end
  #                   end
  #                 end
  #               end
  #
  #             end
  #
  #           elsif guw_coefficient_element.name.in?(%w(A3 A4 A6 A7 A8 A9 A10))
  #
  #             guw_coefficient_element.default = false
  #               guw_coefficient_element.save
  #
  #               guw_coefficient_element.guw_complexity_coefficient_elements.each do |cce|
  #                 cce_guw_output = cce.guw_output
  #                 unless cce_guw_output.nil?
  #                     if cce.guw_output.name.in?(["Charge RIS (jh)", "Charge RTU Avec Dégr.", "Charge RTU (jh)", "Assiette Test (jh)", "Charges T (jh)", "Charge T (jh)", "Coût Services (€)", "Charge Services (jh)"])
  #                     cce.value = nil
  #                     cce.save
  #                   end
  #                 end
  #               end
  #
  #           end
  #         end
  #       end
  #     end
  #   end
  #
  # end
end

