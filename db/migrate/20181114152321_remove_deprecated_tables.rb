class RemoveDeprecatedTables < ActiveRecord::Migration
  def change
    begin
      drop_table :amoa_amoa_applications
      drop_table :amoa_amoa_context_types
      drop_table :amoa_amoa_contexts
      drop_table :amoa_amoa_criteria_services
      drop_table :amoa_amoa_criteria_unit_of_works
      drop_table :amoa_amoa_criterias
      drop_table :amoa_amoa_models
      drop_table :amoa_amoa_services
      drop_table :amoa_amoa_unit_of_works
      drop_table :amoa_amoa_weightings
      drop_table :amoa_amoa_weightings_unit_of_works
      drop_table :labor_categories_project_areas
      drop_table :uow_inputs
      drop_table :technology_size_units
      drop_table :technology_size_types
      drop_table :subcontractors
      drop_table :project_areas_work_element_types
      drop_table :project_areas_project_categories
      drop_table :platform_categories_project_areas
      drop_table :permissions_users
      drop_table :organization_uow_complexities
      drop_table :organization_technologies_unit_of_works
      drop_table :labor_categories_project_areas
      drop_table :events
      drop_table :attribute_organizations
      drop_table :attribute_categories
      drop_table :activity_profiles
      drop_table :abacus_organizations
    rescue

    end
  end
end
