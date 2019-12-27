namespace :change do
  desc "Changement de la valeur des dégressivités automatique (2019-2020)"

  task degressivite: :environment do

    #### Changement valeur automatique

    # Guw::GuwComplexityCoefficientElement.where(guw_complexity_id: nil).delete_all

    organizations = Organization.where(name: ["CDS AURORE", "CDS BOREALE", "CDS CASSIOPEE", "CDS GP", "CDS PROD TRAIN", "CDS VOYAGEURS", "CDS RH", "CDS MATERIEL"]).all

    organizations.each do |o|

      p " **** =========> #{o.name} <========== **** "

      o.guw_models.each do |guw_model|

        guw_model.default_display = "list"
        guw_model.save

        p " =====> #{guw_model.name} <===== "

        rtu_ris_outputs = Guw::GuwOutput.where(organization_id: o.id,
                                               guw_model_id: guw_model.id,
                                               name: ["Charge RIS (jh)", "Charge RTU (jh)", "Assiette Test (jh)", "Charge RTU Avec Dégr."])

        t_outputs = Guw::GuwOutput.where(organization_id: o.id,
                                         guw_model_id: guw_model.id,
                                         name: ["Charges T (jh)", "Charge T (jh)", "Charge Services (jh)", "Coût Services (€)"])

        guw_types = guw_model.guw_types

        guw_model.guw_coefficients.each do |guw_coefficient|
          guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
            if guw_coefficient_element.name == 'A3'

              guw_coefficient_element.default = true
              guw_coefficient_element.save

              guw_types.each do |guw_type|

                guw_type.guw_complexities.each do |guw_complexity|

                  if guw_type.name.include?("CF") || guw_type.name.include?("UO") || guw_type.name.include?("RTU") ||
                     guw_type.name == "DEMI INTERFACES" || guw_type.name == "ECRANS" || guw_type.name == "HABILITATIONS" ||
                     guw_type.name == "RAPPORTS" || guw_type.name == "REP. DON. CONTROLES" || guw_type.name == "REP. DON. DATASTAGE" ||
                     guw_type.name == "WEBSERVICES REST" || guw_type.name == "REP. DON. DEMI INTERFACES"
                     guw_type.name == "WEBSERVICES SOAP" || guw_type.name == "CUSTOMISATION JAVA"

                    if guw_coefficient.name == "Dégressivité Abaque"
                      rtu_ris_outputs.each do |guw_output|
                        Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
                                                                   guw_model_id: guw_model.id,
                                                                   guw_complexity_id: guw_complexity.id,
                                                                   guw_coefficient_element_id: guw_coefficient_element.id,
                                                                   guw_output_id: guw_output.id,
                                                                   guw_type_id: guw_type.id,
                                                                   value: 1).first_or_create
                      end
                    end
                  elsif guw_type.name.include?("MCO")
                    if guw_coefficient.name == "Dégressivité MCO"
                      t_outputs.each do |guw_output|
                        Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
                                                                   guw_model_id: guw_model.id,
                                                                   guw_complexity_id: guw_complexity.id,
                                                                   guw_coefficient_element_id: guw_coefficient_element.id,
                                                                   guw_output_id: guw_output.id,
                                                                   guw_type_id: guw_type.id,
                                                                   value: 1).first_or_create

                      end
                    end
                  else
                    if guw_coefficient.name == "Dégressivité Services"
                      t_outputs.each do |guw_output|
                        Guw::GuwComplexityCoefficientElement.where(organization_id: o.id,
                                                                   guw_model_id: guw_model.id,
                                                                   guw_complexity_id: guw_complexity.id,
                                                                   guw_coefficient_element_id: guw_coefficient_element.id,
                                                                   guw_output_id: guw_output.id,
                                                                   guw_type_id: guw_type.id,
                                                                   value: 1).first_or_create
                      end
                    end
                  end
                end

              end

            elsif guw_coefficient_element.name.in?(%w(A1 A2 A4 A5 A6 A7 A8))

              guw_coefficient_element.default = false
                guw_coefficient_element.save

                guw_coefficient_element.guw_complexity_coefficient_elements.each do |cce|
                  cce_guw_output = cce.guw_output
                  unless cce_guw_output.nil?
                      if cce.guw_output.name.in?(["Charge RIS (jh)", "Charge RTU Avec Dégr.", "Charge RTU (jh)", "Assiette Test (jh)", "Charges T (jh)", "Charge T (jh)", "Coût Services (€)", "Charge Services (jh)"])
                      cce.value = nil
                      cce.save
                    end
                  end
                end

            end
          end
        end
      end
    end

  end
end

