class AddIndexesToGuwModels < ActiveRecord::Migration
  def up
    #Guw::GuwUnitOfWorkGroup
    add_index :guw_guw_unit_of_work_groups, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: :module_project_guw_groups unless index_exists?(:guw_guw_unit_of_work_groups, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: :module_project_guw_groups)

    #Guw::GuwUnitOfWork
    add_index :guw_guw_unit_of_works, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :guw_model_id, :guw_unit_of_work_group_id, :guw_type_id, :selected], name: :module_project_guw_unit_of_works unless index_exists?(:guw_guw_unit_of_works, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :guw_model_id, :guw_unit_of_work_group_id, :guw_type_id, :selected], name: :module_project_guw_unit_of_works)

    #Guw::GuwType
    add_index :guw_guw_types, [:guw_model_id, :name], name: :guw_model_guw_types unless index_exists?(:guw_guw_types, [:guw_model_id, :name], name: :guw_model_guw_types)
    add_index :guw_guw_types, [:guw_model_id, :is_default], name: :guw_model_default_guw_types unless index_exists?(:guw_guw_types, [:guw_model_id, :is_default], name: :guw_model_default_guw_types)

    #Guw::GuwComplexity
    add_index :guw_guw_complexities, [:guw_type_id, :name], name: :guw_type_complexities unless index_exists?(:guw_guw_complexities, [:guw_type_id, :name], name: :guw_type_complexities)

    #Guw::GuwCoefficient
    add_index :guw_guw_coefficients, [:guw_model_id, :name], name: :guw_model_guw_coefficients unless index_exists?(:guw_guw_coefficients, [:guw_model_id, :name], name: :guw_model_guw_coefficients)

    #Guw::GuwOutput
    add_index :guw_guw_outputs, [:guw_model_id, :name], name: :guw_model_guw_outputs unless index_exists?(:guw_guw_outputs, [:guw_model_id, :name], name: :guw_model_guw_outputs)

    #Guw::GuwUnitOfWorkAttribute index important car plusieurs requetes
    add_index :guw_guw_unit_of_work_attributes, [:guw_type_id, :guw_attribute_id, :guw_unit_of_work_id], name: :guw_unit_of_work_attributes unless index_exists?(:guw_guw_unit_of_work_attributes, [:guw_type_id, :guw_attribute_id, :guw_unit_of_work_id], name: :guw_unit_of_work_attributes)

    #Guw::GuwCoefficientElementUnitOfWork
    add_index :guw_guw_coefficient_element_unit_of_works, [:guw_unit_of_work_id, :guw_coefficient_id, :guw_coefficient_element_id], name: :guw_unit_of_work_guw_coefficient_elements unless index_exists?(:guw_guw_coefficient_element_unit_of_works, [:guw_unit_of_work_id, :guw_coefficient_id, :guw_coefficient_element_id], name: :guw_unit_of_work_guw_coefficient_elements)

    #Guw::GuwOutputComplexity
    add_index :guw_guw_output_complexities, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexities unless index_exists?(:guw_guw_output_complexities, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexities)

    #Guw::GuwOutputComplexityInitialization
    add_index :guw_guw_output_complexity_initializations, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexity_initializations unless index_exists?(:guw_guw_output_complexity_initializations, [ :guw_complexity_id, :guw_output_id], name: :guw_output_complexity_initializations)

    #Guw::GuwScaleModuleAttribute
    add_index :guw_guw_scale_module_attributes, [:guw_model_id, :type_attribute], name: :guw_scale_module_attributes unless index_exists?(:guw_guw_scale_module_attributes, [:guw_model_id, :type_attribute], name: :guw_scale_module_attributes)

    #Guw::GuwAttributeComplexity
    add_index :guw_guw_attribute_complexities, [:guw_type_id, :guw_attribute_id], name: :guw_attribute_complexities unless index_exists?(:guw_guw_attribute_complexities, [:guw_type_id, :guw_attribute_id], name: :guw_attribute_complexities)

    #Guw::GuwCoefficientElement
    add_index :guw_guw_coefficient_elements, [:guw_model_id, :guw_coefficient_id, :default], name: :guw_coefficient_elements unless index_exists?(:guw_guw_coefficient_elements, [:guw_model_id, :guw_coefficient_id, :default], name: :guw_coefficient_elements)

    #Guw::GuwComplexityCoefficientElement
    add_index :guw_guw_complexity_coefficient_elements, [:guw_complexity_id, :guw_coefficient_element_id, :guw_output_id], name: :guw_complexity_coefficient_elements unless index_exists?(:guw_guw_complexity_coefficient_elements, [:guw_complexity_id, :guw_coefficient_element_id, :guw_output_id], name: :guw_complexity_coefficient_elements)




    #TODO : delete after
    # Guw::GuwComplexityTechnology
    # add_index :guw_guw_complexity_technologies, [:guw_complexity_id, :organization_technology_id, :guw_type_id], name: :guw_complexity_organization_technologies unless index_exists?(:guw_guw_complexity_technologies, [:guw_complexity_id, :organization_technology_id, :guw_type_id], name: :guw_complexity_organization_technologies)

    # #Guw::GuwComplexityWorkUnit
    # add_index :guw_guw_complexity_work_units, [:guw_complexity_id, :guw_work_unit_id], name: :guw_complexity_work_units unless index_exists?(:guw_guw_complexity_work_units, [:guw_complexity_id, :guw_work_unit_id], name: :guw_complexity_work_units)
    #
    # #Guw::GuwComplexityWeighting
    # add_index :guw_guw_complexity_weightings, [:guw_complexity_id, :guw_weighting_id], name: :guw_complexity_weightings unless index_exists?(:guw_guw_complexity_weightings, [:guw_complexity_id, :guw_weighting_id], name: :guw_complexity_weightings)
    #
    # #Guw::GuwComplexityFactor
    # add_index :guw_guw_complexity_factors, [:guw_complexity_id, :guw_factor_id], name: :guw_complexity_factors unless index_exists?(:guw_guw_complexity_factors, [:guw_complexity_id, :guw_factor_id], name: :guw_complexity_factors)

  end



  def down
    #Guw::GuwUnitOfWorkGroup
    remove_index :guw_guw_unit_of_work_groups, name: :module_project_guw_groups #if index_exists?(:guw_guw_unit_of_work_groups, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: :module_project_guw_groups)

    #Guw::GuwUnitOfWork
    remove_index :guw_guw_unit_of_works, name: :module_project_guw_unit_of_works #if index_exists?(:guw_guw_unit_of_works, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :guw_model_id, :guw_unit_of_work_group_id, :guw_type_id, :selected], name: :module_project_guw_unit_of_works)

    #Guw::GuwType
    remove_index :guw_guw_types, name: :guw_model_guw_types #if index_exists?(:guw_guw_types, [:guw_model_id, :name], name: :guw_model_guw_types)
    remove_index :guw_guw_types,  name: :guw_model_default_guw_types #if index_exists?(:guw_guw_types, [:guw_model_id, :is_default], name: :guw_model_default_guw_types)

    #Guw::GuwComplexity
    remove_index :guw_guw_complexities, name: :guw_type_complexities #if index_exists?(:guw_guw_complexities, [:guw_type_id, :name], name: :guw_type_complexities)

    #Guw::GuwCoefficient
    remove_index :guw_guw_coefficients, name: :guw_model_guw_coefficients #if index_exists?(:guw_guw_coefficients, [:guw_model_id, :name], name: :guw_model_guw_coefficients)

    #Guw::GuwOutput
    remove_index :guw_guw_outputs, name: :guw_model_guw_outputs #if index_exists?(:guw_guw_outputs, [:guw_model_id, :name], name: :guw_model_guw_outputs)

    #Guw::GuwUnitOfWorkAttribute index important car plusieurs requetes
    remove_index :guw_guw_unit_of_work_attributes, name: :guw_unit_of_work_attributes #if index_exists?(:guw_guw_unit_of_work_attributes, [:guw_type_id, :guw_attribute_id, :guw_unit_of_work_id], name: :guw_unit_of_work_attributes)

    #Guw::GuwCoefficientElementUnitOfWork
    remove_index :guw_guw_coefficient_element_unit_of_works, name: :guw_unit_of_work_guw_coefficient_elements #if index_exists?(:guw_guw_coefficient_element_unit_of_works, [:guw_unit_of_work_id, :guw_coefficient_id, :guw_coefficient_element_id], name: :guw_unit_of_work_guw_coefficient_elements)

    #Guw::GuwOutputComplexity
    remove_index :guw_guw_output_complexities, name: :guw_output_complexities #if index_exists?(:guw_guw_output_complexities, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexities)

    #Guw::GuwOutputComplexityInitialization
    remove_index :guw_guw_output_complexity_initializations, name: :guw_output_complexity_initializations #if index_exists?(:guw_guw_output_complexity_initializations, [ :guw_complexity_id, :guw_output_id], name: :guw_output_complexity_initializations)

    #Guw::GuwScaleModuleAttribute
    remove_index :guw_guw_scale_module_attributes, name: :guw_scale_module_attributes #if index_exists?(:guw_guw_scale_module_attributes, [:guw_model_id, :type_attribute], name: :guw_scale_module_attributes)

    #Guw::GuwAttributeComplexity
    remove_index :guw_guw_attribute_complexities, name: :guw_attribute_complexities #if index_exists?(:guw_guw_attribute_complexities, [:guw_type_id, :guw_attribute_id], name: :guw_attribute_complexities)

    #Guw::GuwCoefficientElement
    remove_index :guw_guw_coefficient_elements, name: :guw_coefficient_elements #if index_exists?(:guw_guw_coefficient_elements, [:guw_model_id, :guw_coefficient_id, :default], name: :guw_coefficient_elements)

    #Guw::GuwComplexityCoefficientElement
    remove_index :guw_guw_complexity_coefficient_elements, name: :guw_complexity_coefficient_elements #if index_exists?(:guw_guw_complexity_coefficient_elements, [:guw_complexity_id, :guw_coefficient_element_id, :guw_output_id], name: :guw_complexity_coefficient_elements)

  end
end
