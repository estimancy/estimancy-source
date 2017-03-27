# Pour lancer la tache : rake ge_models:update_ge_modele_with_4_inputs_outputs
# rake ge_models:update_ge_modele_with_4_inputs_outputs
namespace :ge_models do

  desc "Prise en compte des modifications du module de Transformation avec l'ajout des 4 entrée et 4 sorties"
  task update_ge_modele_with_4_inputs_outputs: :environment do

    INPUT_FOR_RAKE = ["retained_size", "effort", "ent1", "ent2", "ent3", "ent4"]
    OUTPUT_FOR_RAKE = ["retained_size", "effort", "introduced_defects", "sort1", "sort2", "sort3", "sort4"]
    TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS_FOR_RAKE = ["retained_size", "effort", "sort1", "sort2", "sort3", "sort4"]

    input_attribute_ids = PeAttribute.where(alias: INPUT_FOR_RAKE).map(&:id).flatten
    output_attribute_ids = PeAttribute.where(alias: TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS_FOR_RAKE).map(&:id).flatten

    #update all ge_models
    Ge::GeModel.all.each do |ge_model|

      ActiveRecord::Base.transaction do

        input_size_unit = ge_model.input_size_unit
        input_effort_unit = ge_model.input_effort_unit
        input_effort_standard_unit_coeff = ge_model.input_effort_standard_unit_coefficient

        output_size_unit = ge_model.output_size_unit
        output_effort_unit = ge_model.output_effort_unit
        output_effort_standard_unit_coeff = ge_model.output_effort_standard_unit_coefficient

        ["ent1", "ent2", "ent3", "ent4"].each do |input|
          ge_model.send("#{input}_unit=", input_size_unit)
          #ge_model.send("#{input}_effort_unit=", input_effort_unit)
          ge_model.send("#{input}_unit_coefficient=", input_effort_standard_unit_coeff)
        end

        ["sort1", "sort2", "sort3", "sort4"].each do |output|
          ge_model.send("#{output}_unit=", output_size_unit)
          #ge_model.send("#{output}_effort_unit=", output_effort_unit)
          ge_model.send("#{output}_unit_coefficient=", output_effort_standard_unit_coeff)
        end

        ge_model.save
      end
    end



    #update all module_projects
    ModuleProject.where("ge_model_id IS NOT NULL").each do |module_project|

      ActiveRecord::Base.transaction do

        ge_model = module_project.ge_model

        current_inputs_evs = module_project.estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")
        current_outputs_evs = module_project.estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")

        if (input_attribute_ids.length != current_inputs_evs.length) || (output_attribute_ids.length != current_outputs_evs.length)
          # Get estimation_value of the input attribute to use
          all_estimation_values = module_project.get_mp_inputs_outputs_estimation_values(input_attribute_ids, output_attribute_ids)
        end

        #effort_input_ev = EstimationValue.includes(:pe_attribute).where(module_project_id: module_project.id, :pe_attributes => { alias: "effort"}, in_out: "input").first
        #effort_output_ev = EstimationValue.includes(:pe_attribute).where(module_project_id: module_project.id, :pe_attributes => { alias: "effort"}, in_out: "output").first

        effort_input_ev = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "effort"}, in_out: "input").first
        effort_output_ev = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "effort"}, in_out: "output").first

        size_input_ev = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "retained_size"}, in_out: "input").first
        size_output_ev = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "retained_size"}, in_out: "output").first

        ent1_evs = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "ent1"})
        ent2_evs = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "ent2"})
        sort1_evs = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "sort1"})
        sort2_evs = all_estimation_values.includes(:pe_attribute).where(:pe_attributes => { alias: "sort2"})

        if ge_model.input_pe_attribute_id.nil?
          ge_model.input_pe_attribute = PeAttribute.where(alias: "retained_size").first
          ge_model.save
        end

        if ge_model.output_pe_attribute_id.nil?
          ge_model.output_pe_attribute = PeAttribute.where(alias: "effort").first
          ge_model.save
        end

        input_attribute = ge_model.input_pe_attribute
        output_attribute = ge_model.output_pe_attribute

        # Pour l'attribut d'entree
        ev1_input = ent1_evs.where(in_out: "input").first
        ev2_input = ent2_evs.where(in_out: "input").first

        case input_attribute.alias
          when "retained_size"
            if ev1_input && ev2_input
              ev1_input.update_attributes(string_data_low: size_input_ev.string_data_low, string_data_most_likely: size_input_ev.string_data_most_likely,
                                          string_data_high: size_input_ev.string_data_high, string_data_probable: size_input_ev.string_data_probable,
                                          estimation_value_id: size_input_ev.estimation_value_id)

              ev2_input.update_attributes(string_data_low: effort_input_ev.string_data_low, string_data_most_likely: effort_input_ev.string_data_most_likely,
                                           string_data_high: effort_input_ev.string_data_high, string_data_probable: effort_input_ev.string_data_probable,
                                           estimation_value_id: effort_input_ev.estimation_value_id)
            end

          when "effort"
            if ev1_input && ev2_input
              ev1_in_out.update_attributes(string_data_low: effort_input_ev.string_data_low, string_data_most_likely: effort_input_ev.string_data_most_likely,
                                           string_data_high: effort_input_ev.string_data_high, string_data_probable: effort_input_ev.string_data_probable,
                                           estimation_value_id: effort_input_ev.estimation_value_id)

              ev2_in_out.update_attributes(string_data_low: size_input_ev.string_data_low, string_data_most_likely: size_input_ev.string_data_most_likely,
                                           string_data_high: size_input_ev.string_data_high, string_data_probable: size_input_ev.string_data_probable,
                                           estimation_value_id: size_input_ev.estimation_value_id)
            end
        end


        # Pour les sorties
        ev1_output = sort1_evs.where(in_out: "output").first
        ev2_output = sort2_evs.where(in_out: "output").first

        case output_attribute.alias
          when "retained_size"
            if ev1_output && ev2_output
              ev1_output.update_attributes(string_data_low: size_output_ev.string_data_low, string_data_most_likely: size_output_ev.string_data_most_likely,
                                           string_data_high: size_output_ev.string_data_high, string_data_probable: size_output_ev.string_data_probable,
                                           estimation_value_id: size_output_ev.estimation_value_id)

              ev2_output.update_attributes(string_data_low: effort_output_ev.string_data_low, string_data_most_likely: effort_output_ev.string_data_most_likely,
                                           string_data_high: effort_output_ev.string_data_high, string_data_probable: effort_output_ev.string_data_probable,
                                           estimation_value_id: effort_output_ev.estimation_value_id)
            end

          when "effort"
            if ev1_output && ev2_output
              ev1_output.update_attributes(string_data_low: effort_output_ev.string_data_low, string_data_most_likely: effort_output_ev.string_data_most_likely,
                                           string_data_high: effort_output_ev.string_data_high, string_data_probable: effort_output_ev.string_data_probable,
                                           estimation_value_id: effort_output_ev.estimation_value_id)

              ev2_output.update_attributes(string_data_low: size_output_ev.string_data_low, string_data_most_likely: size_output_ev.string_data_most_likely,
                                           string_data_high: size_output_ev.string_data_high, string_data_probable: size_output_ev.string_data_probable,
                                           estimation_value_id: size_output_ev.estimation_value_id)
            end
        end


        [ev1_input, ev2_input, ev1_output, ev2_output].each do |ev|
          ["low", "most_likely", "high"].each do |level|
            ev.send("string_data_#{level}")[:pe_attribute_name] = ev.pe_attribute.name
            ev.save
          end
        end


        # all_estimation_values.each do |ev|
        #
        #   case ev.pe_attribute.alias
        #
        #     when "retained_size"
        #
        #       if ev.in_out == "input"
        #         ev_in_out = ent1_evs.where(in_out: "input").first
        #
        #       elsif ev.in_out == "output"
        #         ev_in_out = sort1_evs.where(in_out: "output").first
        #       end
        #
        #     when "effort"
        #       if ev.in_out == "input"
        #         ev_in_out = ent2_evs.where(in_out: "input").first
        #       elsif ev.in_out == "output"
        #         ev_in_out = sort2_evs.where(in_out: "output").first
        #       end
        #   end
        #
        #
        #   if ev_in_out
        #     ev_in_out.update_attributes(string_data_low: ev.string_data_low, string_data_most_likely: ev.string_data_most_likely,
        #                                 string_data_high: ev.string_data_high, string_data_probable: ev.string_data_probable,
        #                                 estimation_value_id: ev.estimation_value_id)
        #   end
        # end

      end
    end
  end
end


