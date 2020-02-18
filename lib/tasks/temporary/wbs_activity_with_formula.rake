namespace :wbs_activities do
  desc "Prise en compte des modifications de la WBS avec les formules"
  task update_wbs_activity_with_formula: :environment do


      #Create 4 variables for each  Ratio created before
      ###Le RTU doit correspondre à la référence des wbs_activity_ratio_elements de chaque

      #update phase short name
    WbsActivity.all.each do |wbs_activity|

      ActiveRecord::Base.transaction do
        phases_short_name_number = 0 #wbs_activity.phases_short_name_number.to_i
        wbs_activity_elements = wbs_activity.wbs_activity_elements

        unless wbs_activity_elements.nil?
          wbs_activity_elements.each do |wbs_activity_element|
            phases_short_name_number = phases_short_name_number+1
            wbs_activity_element.phase_short_name = "P#{phases_short_name_number}"
            wbs_activity_element.save
          end
        end

        # Update Wbs-Activity
        wbs_activity.phases_short_name_number = phases_short_name_number
        wbs_activity.save

        #update wbs_activity_ratios
        wbs_activity_ratios = wbs_activity.wbs_activity_ratios

        unless wbs_activity_ratios.nil?
          wbs_activity_ratios.each do |ratio|

            # Create the module_project_ratio_variables
            [["RTU", "100%"], ["TEST", ""], ["", ""], ["", ""]].each do |var|
              ratio_variable = WbsActivityRatioVariable.where(wbs_activity_ratio_id: ratio.id, name: var[0],  percentage_of_input: var[1]).first_or_create
            end

            # Create Ratio variables
            ###if ratio.wbs_activity_ratio_variables.nil?

              wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements

              #Get the referenced wbs_activity_elt of the ratio
              referenced_ratio_elements = ratio.wbs_activity_ratio_elements.where('wbs_activity_ratio_id =? and multiple_references = ?', ratio.id, true)
              # If there is no referenced elements, all elements will be consider as references
              if referenced_ratio_elements.nil? || referenced_ratio_elements.empty?
                referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =?', ratio.id)
              end

              #The real ratio elements percentages will be use
              referenced_values_efforts = ""
              referenced_ratio_activity_element_ids = []

              # If using base-100 percentages
              if ratio.use_real_base_percentage == true
                referenced_ratio_elements.each do |reference_value|
                  wbs_activity_element = reference_value.wbs_activity_element
                  wbs_activity_ratio_element_id = reference_value.id
                  referenced_ratio_activity_element_ids << wbs_activity_ratio_element_id

                  #Update the referenced phase formula
                  corresponding_ratio_value = reference_value.ratio_value
                  unless corresponding_ratio_value.nil?
                    if reference_value.formula.nil?
                      ratio_elt_formula = "#{corresponding_ratio_value.to_f}% * RTU"
                      reference_value.update_attribute(:formula, "#{ratio_elt_formula}")
                    end
                  end

                  if referenced_values_efforts.blank?
                    referenced_values_efforts = "#{wbs_activity_element.phase_short_name}"
                  else
                    referenced_values_efforts = "#{referenced_values_efforts} + #{wbs_activity_element.phase_short_name}"
                  end
                end

                # Update Ratio-Elements with percentage_of_input
                wbs_activity_ratio_elements.each do |ratio_element|
                  unless ratio_element.id.in?(referenced_ratio_activity_element_ids)
                    if ratio_element.formula.nil?
                      ratio_element.update_attribute(:formula, "#{ratio_element.ratio_value}% * #{referenced_values_efforts}")
                    end
                  end
                end

              else
                # Utilise les valeurs des pourcentage en base 100
                referenced_values_efforts = 0.0
                referenced_ratio_elements.each do |reference_value|
                  referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
                end

                # Update Ratio-Elements with percentage_of_input
                wbs_activity_ratio_elements.each do |ratio_element|
                  corresponding_ratio_value = ratio_element.ratio_value
                  unless corresponding_ratio_value.nil? || referenced_values_efforts == 0.0
                    if ratio_element.formula.nil?
                      corresponding_formula = "(RTU * #{corresponding_ratio_value.to_f}) / #{referenced_values_efforts}"
                      ratio_element.update_attribute(:formula, corresponding_formula)
                    end
                  end
                end
              end


            ###end

          end
        end

      end

    end
  end
end


