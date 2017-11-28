class AddIndexesAndOrganizationIdToTables < ActiveRecord::Migration

  def up
    #==== PeAttribute
    add_index :pe_attributes, :alias

    #Projects
    add_index :projects, [:organization_id, :is_model]

    #===== ModuleProjects
    add_column :module_projects, :organization_id, :integer, :after => :id

    ModuleProject.all.each do |mp|
      begin
        project = Project.find(mp.project_id)
        mp.organization_id = project.organization_id
        mp.save
      rescue
        # ignored
      end
    end
    add_index :module_projects, [:organization_id, :pemodule_id, :project_id], name: "organization_module_projects"

    #==== EstimationValues
    add_column :estimation_values, :organization_id, :integer, after: :id

    EstimationValue.all.each do |ev|
      ev.organization_id = ev.module_project.organization_id
      ev.save
    end
    add_index :estimation_values, [:organization_id, :module_project_id, :pe_attribute_id, :in_out], name: "organization_estimation_values"

    #==== WbsActivity
    add_index :wbs_activities, [:organization_id], name: "organization_wbs_activities"

    #==== WbsActivityRatios
    add_column :wbs_activity_ratios, :organization_id, :integer, after: :id

    WbsActivityRatio.all.each do |ratio|
      ratio.organization_id = ratio.wbs_activity.organization_id
      ratio.save
    end
    add_index :wbs_activity_ratios, [:organization_id, :wbs_activity_id], name: "organization_wbs_activity_ratios"

    #=== WbsActivityElements
    add_column :wbs_activity_elements, :organization_id, :integer, after: :id

    WbsActivityElement.all.each do |element|
      begin
        element.organization_id = element.wbs_activity.organization_id
        element.save
      rescue
        # ignored
      end
    end
    add_index :wbs_activity_elements, [:organization_id, :wbs_activity_id, :ancestry], name: "organization_wbs_activity_elements"  ### ancestry ???

    #WbsActivityRatioElements
    add_column :wbs_activity_ratio_elements, :organization_id, :integer, after: :id
    add_column :wbs_activity_ratio_elements, :wbs_activity_id, :integer, after: :organization_id

    WbsActivityRatioElement.all.each do |element|
      element.organization_id = element.wbs_activity_ratio.organization_id rescue nil
      element.wbs_activity_id = element.wbs_activity_ratio.wbs_activity_id rescue nil
      element.save
    end
    add_index :wbs_activity_ratio_elements, [:organization_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_element_id], name: "organization_wbs_activity_ratio_elements"

    #WbsprojectElement ???

    #=== WbsActivityRatioVariables
    add_column :wbs_activity_ratio_variables, :organization_id, :integer, after: :id
    add_column :wbs_activity_ratio_variables, :wbs_activity_id, :integer, after: :organization_id

    WbsActivityRatioVariable.all.each do |ratio_variable|
      ratio_variable.organization_id = ratio_variable.wbs_activity_ratio.organization_id rescue nil
      ratio_variable.wbs_activity_id = ratio_variable.wbs_activity_ratio.wbs_activity_id rescue nil
      ratio_variable.save
    end
    add_index :wbs_activity_ratio_variables, [:organization_id, :wbs_activity_ratio_id], name: "organization_wbs_activity_ratio_variables"


    #=== ModuleProjectRatioVariables
    add_column :module_project_ratio_variables, :organization_id, :integer, after: :id
    add_column :module_project_ratio_variables, :wbs_activity_id, :integer, after: :organization_id

    ModuleProjectRatioVariable.all.each do |ratio_variable|
      ratio_variable.organization_id = ratio_variable.wbs_activity_ratio.organization_id rescue nil
      ratio_variable.wbs_activity_id = ratio_variable.wbs_activity_ratio.wbs_activity_id rescue nil
      ratio_variable.save
    end
    add_index :module_project_ratio_variables, [:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_ratio_variable_id],
              name: "organization_module_project_ratio_variables"

    #== ModuleProjectRatioElements
    add_column :module_project_ratio_elements, :organization_id, :integer, after: :id
    add_column :module_project_ratio_elements, :wbs_activity_id, :integer, after: :module_project_id

    ModuleProjectRatioElement.all.each do |ratio_elt|
      ratio_elt.organization_id = ratio_elt.wbs_activity_ratio.organization_id rescue nil
      ratio_elt.wbs_activity_id = ratio_elt.wbs_activity_ratio.wbs_activity_id rescue nil
      ratio_elt.save
    end
    add_index :module_project_ratio_elements, [:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_element_id],
              name: "organization_module_project_ratio_elements"

    #=== OrganizationProfiles
    add_index :organization_profiles, [:organization_id]

    #=== OrganizationProfiles_WbsActivities
    add_index :organization_profiles_wbs_activities, [:wbs_activity_id, :organization_profile_id], name: "wbs_activity_organization_profiles"



    #=====   Pour changement d'organisation impromptu   ==========

    #=== ViewWidgets
    # add_column :views_widgets, :organization_id, :integer, after: :id
    # add_column :views_widgets, :project_id, :integer, after: :organization_id
    #
    # add_index :views_widgets, [:organization_id, :project_id, :module_project_id, :pe_attribute_id, :estimation_value_id], name: "project_views_widgets"
    #
    # ViewsWidget.all.each do |vw|
    #   vw.organization_id = vw.module_project.organization_id
    #   vw.project_id = vw.module_project.project_id
    #   vw.save
    # end


    #=====   FIN Pour changement d'organisation impromptu ========
  end


  def down

    remove_index :pe_attributes, :alias

    #Projects
    remove_index :projects, [:organization_id, :is_model]

    #===== ModuleProjects
    remove_column :module_projects, :organization_id
    remove_index :module_projects, name: "organization_module_projects" #[:organization_id, :pemodule_id, :project_id]


    #==== EstimationValues
    remove_column :estimation_values, :organization_id
    remove_index :estimation_values, name: "organization_estimation_values" #[:organization_id, :module_project_id, :pe_attribute_id, :in_out]

    #==== WbsActivity
    remove_index :wbs_activities, name:"organization_wbs_activities" #[:organization_id]

    #==== WbsActivityRatios
    remove_column :wbs_activity_ratios, :organization_id
    remove_index :wbs_activity_ratios, name: "organization_wbs_activity_ratios" #[:organization_id, :wbs_activity_id]

    #=== WbsActivityElements
    remove_column :wbs_activity_elements, :organization_id
    remove_index :wbs_activity_elements, name: "organization_wbs_activity_elements" #[:wbs_activity_id, :ancestry]  ### ancestry ???


    #WbsActivityRatioElements
    remove_column :wbs_activity_ratio_elements, :organization_id
    remove_column :wbs_activity_ratio_elements, :wbs_activity_id
    remove_index :wbs_activity_ratio_elements, name: "organization_wbs_activity_ratio_elements" #[:wbs_activity_ratio_id, :wbs_activity_element_id]

    #WbsprojectElement ???

    #=== WbsActivityRatioVariables
    remove_column :wbs_activity_ratio_variables, :organization_id
    remove_column :wbs_activity_ratio_variables, :wbs_activity_id
    remove_index :wbs_activity_ratio_variables, name: "organization_wbs_activity_ratio_variables" #[:wbs_activity_ratio_id]


    #=== ModuleProjectRatioVariables
    remove_column :module_project_ratio_variables, :organization_id
    remove_column :module_project_ratio_variables, :wbs_activity_id
    remove_index :module_project_ratio_variables, name: "organization_module_project_ratio_variables" #[:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_ratio_variable_id]

    #== ModuleProjectRatioElements
    remove_column :module_project_ratio_elements, :organization_id
    remove_column :module_project_ratio_elements, :wbs_activity_id
    remove_index :module_project_ratio_elements, name: "organization_module_project_ratio_elements" #[:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_element_id]

    #=== OrganizationProfiles
    remove_index :organization_profiles, [:organization_id]

    #=== OrganizationProfiles_WbsActivities
    remove_index :organization_profiles_wbs_activities, name: "wbs_activity_organization_profiles" #[:wbs_activity_id, :organization_profile_id]

  end

end




# class AddIndexesAndOrganizationIdToTables < ActiveRecord::Migration
#
#   def up
#     #==== PeAttribute
#     add_index :pe_attributes, :alias
#
#     #Projects
#     add_index :projects, [:organization_id, :is_model]
#
#     #===== ModuleProjects
#     add_column :module_projects, :organization_id, :integer, :after => :id
#     add_index :module_projects, [:organization_id, :pemodule_id, :project_id], name: "organization_module_projects"
#
#     ModuleProject.all.each do |mp|
#       begin
#         project = Project.find(mp.project_id)
#         mp.organization_id = project.organization_id
#         mp.save
#       rescue
#       end
#     end
#
#     #==== EstimationValues
#     add_column :estimation_values, :organization_id, :integer, after: :id
#     add_index :estimation_values, [:organization_id, :module_project_id, :pe_attribute_id, :in_out], name: "organization_estimation_values"
#
#     EstimationValue.all.each do |ev|
#       ev.organization_id = ev.module_project.organization_id
#       ev.save
#     end
#
#     #==== WbsActivity
#     add_index :wbs_activities, [:organization_id], name: "organization_wbs_activities"
#
#     #==== WbsActivityRatios
#     add_column :wbs_activity_ratios, :organization_id, :integer, after: :id
#     add_index :wbs_activity_ratios, [:organization_id, :wbs_activity_id], name: "organization_wbs_activity_ratios"
#
#     WbsActivityRatio.all.each do |ratio|
#       ratio.organization_id = ratio.wbs_activity.organization_id
#       ratio.save
#     end
#
#     #=== WbsActivityElements
#     add_column :wbs_activity_elements, :organization_id, :integer, after: :id
#     add_index :wbs_activity_elements, [:wbs_activity_id, :ancestry], name: "organization_wbs_activity_elements"  ### ancestry ???
#
#     WbsActivityElement.all.each do |element|
#       begin
#         element.organization_id = element.wbs_activity.organization_id
#         element.save
#       rescue
#       end
#     end
#
#     #WbsActivityRatioElements
#     add_column :wbs_activity_ratio_elements, :organization_id, :integer, before: :wbs_activity_ratio_id
#     add_column :wbs_activity_ratio_elements, :wbs_activity_id, :integer, after: :organization_id
#     add_index :wbs_activity_ratio_elements, [:wbs_activity_ratio_id, :wbs_activity_element_id], name: "organization_wbs_activity_ratio_elements"
#
#     WbsActivityRatioElement.all.each do |element|
#       element.organization_id = element.wbs_activity_ratio.organization_id rescue nil
#       element.wbs_activity_id = element.wbs_activity_ratio.wbs_activity_id rescue nil
#       element.save
#     end
#
#     #WbsprojectElement ???
#
#     #=== WbsActivityRatioVariables
#     add_column :wbs_activity_ratio_variables, :organization_id, :integer, before: :wbs_activity_ratio_id
#     add_column :wbs_activity_ratio_variables, :wbs_activity_id, :integer, after: :organization_id
#     add_index :wbs_activity_ratio_variables, [:wbs_activity_ratio_id], name: "organization_wbs_activity_ratio_variables"
#
#     WbsActivityRatioVariable.all.each do |ratio_variable|
#       ratio_variable.organization_id = ratio_variable.wbs_activity_ratio.organization_id rescue nil
#       ratio_variable.wbs_activity_id = ratio_variable.wbs_activity_ratio.wbs_activity_id rescue nil
#       ratio_variable.save
#     end
#
#     #=== ModuleProjectRatioVariables
#     add_column :module_project_ratio_variables, :organization_id, :integer, before: :module_project_id
#     add_column :module_project_ratio_variables, :wbs_activity_id, :integer, after: :organization_id
#     add_index :module_project_ratio_variables, [:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_ratio_variable_id],
#               name: "organization_module_project_ratio_variables"
#
#     ModuleProjectRatioVariable.all.each do |ratio_variable|
#       ratio_variable.organization_id = ratio_variable.wbs_activity_ratio.organization_id rescue nil
#       ratio_variable.wbs_activity_id = ratio_variable.wbs_activity_ratio.wbs_activity_id rescue nil
#       ratio_variable.save
#     end
#
#     #== ModuleProjectRatioElements
#     add_column :module_project_ratio_elements, :organization_id, :integer, before: :pbs_project_element_id
#     add_column :module_project_ratio_elements, :wbs_activity_id, :integer, after: :module_project_id
#     add_index :module_project_ratio_elements, [:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_element_id],
#               name: "organization_module_project_ratio_elements"
#
#     ModuleProjectRatioElement.all.each do |ratio_elt|
#       ratio_elt.organization_id = ratio_elt.wbs_activity_ratio.organization_id rescue nil
#       ratio_elt.wbs_activity_id = ratio_elt.wbs_activity_ratio.wbs_activity_id rescue nil
#       ratio_elt.save
#     end
#
#
#     #=== OrganizationProfiles
#     add_index :organization_profiles, [:organization_id]
#
#     #=== OrganizationProfiles_WbsActivities
#     add_index :organization_profiles_wbs_activities, [:wbs_activity_id, :organization_profile_id], name: "wbs_activity_organization_profiles"
#   end
#
#
#   def down
#
#     #remove_index :pe_attributes, :alias
#
#     #Projects
#     #remove_index :projects, [:organization_id, :is_model]
#
#     #===== ModuleProjects
#     #remove_column :module_projects, :organization_id
#     remove_index :module_projects, "organization_module_projects" #[:organization_id, :pemodule_id, :project_id]
#
#
#     #==== EstimationValues
#     remove_column :estimation_values, :organization_id
#     remove_index :estimation_values, "organization_estimation_values" #[:organization_id, :module_project_id, :pe_attribute_id, :in_out]
#
#     #==== WbsActivity
#     remove_index :wbs_activities, "organization_wbs_activities" #[:organization_id]
#
#     #==== WbsActivityRatios
#     remove_column :wbs_activity_ratios, :organization_id
#     remove_index :wbs_activity_ratios, "organization_wbs_activity_ratios" #[:organization_id, :wbs_activity_id]
#
#     #=== WbsActivityElements
#     remove_column :wbs_activity_elements, :organization_id
#     remove_index :wbs_activity_elements, "organization_wbs_activity_elements" #[:wbs_activity_id, :ancestry]  ### ancestry ???
#
#
#     #WbsActivityRatioElements
#     remove_column :wbs_activity_ratio_elements, :organization_id
#     remove_column :wbs_activity_ratio_elements, :wbs_activity_id
#     remove_index :wbs_activity_ratio_elements, "organization_wbs_activity_ratio_elements" #[:wbs_activity_ratio_id, :wbs_activity_element_id]
#
#     #WbsprojectElement ???
#
#     #=== WbsActivityRatioVariables
#     remove_column :wbs_activity_ratio_variables, :organization_id
#     remove_column :wbs_activity_ratio_variables, :wbs_activity_id
#     remove_index :wbs_activity_ratio_variables, "organization_wbs_activity_ratio_variables" #[:wbs_activity_ratio_id]
#
#
#     #=== ModuleProjectRatioVariables
#     remove_column :module_project_ratio_variables, :organization_id
#     remove_column :module_project_ratio_variables, :wbs_activity_id
#     remove_index :module_project_ratio_variables, "organization_module_project_ratio_variables" #[:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_ratio_variable_id]
#
#     #== ModuleProjectRatioElements
#     remove_column :module_project_ratio_elements, :organization_id
#     remove_column :module_project_ratio_elements, :wbs_activity_id
#     remove_index :module_project_ratio_elements, "organization_module_project_ratio_elements" #[:organization_id, :module_project_id, :pbs_project_element_id, :wbs_activity_id, :wbs_activity_ratio_id, :wbs_activity_element_id]
#
#     #=== OrganizationProfiles
#     remove_index :organization_profiles, [:organization_id]
#
#     #=== OrganizationProfiles_WbsActivities
#     remove_index :organization_profiles_wbs_activities, "wbs_activity_organization_profiles" #[:wbs_activity_id, :organization_profile_id]
#
#   end
#
# end
