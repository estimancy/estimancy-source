class AddNewIndexesToGuw < ActiveRecord::Migration

  def up

    #guw_guw_unit_of_work_attributes
    add_column :guw_guw_coefficient_element_unit_of_works, :organization_id, :integer, after: :id
    add_column :guw_guw_coefficient_element_unit_of_works, :guw_model_id, :integer, after: :organization_id
    add_column :guw_guw_coefficient_element_unit_of_works, :project_id, :integer, after: :guw_model_id
    change_column :guw_guw_coefficient_element_unit_of_works, :module_project_id, :integer, :after => :project_id
    remove_index :guw_guw_coefficient_element_unit_of_works, name: "guw_unit_of_work_guw_coefficient_elements"

    add_index :guw_guw_coefficient_element_unit_of_works, [:organization_id, :guw_model_id, :guw_coefficient_id, :guw_coefficient_element_id, :project_id, :module_project_id, :guw_unit_of_work_id], name: "by_organization_guw_model_coeff_coeffElement_project_mp_uow"
    add_index :guw_guw_coefficient_element_unit_of_works, [:organization_id, :guw_model_id, :guw_coefficient_id, :project_id, :module_project_id, :guw_unit_of_work_id], name: "by_organization_guw_model_coeff_project_mp_uow"
    add_index :guw_guw_coefficient_element_unit_of_works, [:organization_id, :guw_model_id, :project_id, :module_project_id, :guw_unit_of_work_id], name: "by_organization_guw_model_project_mp_uow"

    ## guw_guw_unit_of_work_attributes
    add_column :guw_guw_unit_of_work_attributes, :organization_id, :integer, after: :id
    add_column :guw_guw_unit_of_work_attributes, :guw_model_id, :integer, after: :organization_id
    add_column :guw_guw_unit_of_work_attributes, :project_id, :integer, after: :guw_model_id
    add_column :guw_guw_unit_of_work_attributes, :module_project_id, :integer, after: :project_id
    add_index :guw_guw_unit_of_work_attributes, [:organization_id, :guw_model_id, :guw_attribute_id, :guw_type_id, :project_id, :module_project_id, :guw_unit_of_work_id], name: "by_organization_guw_model_attr_type_project_mp_uow"

    #Guw::GuwUnitOfWorkGroup
    add_column :guw_guw_unit_of_work_groups, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_unit_of_work_groups, name: "module_project_guw_groups"
    add_index :guw_guw_unit_of_work_groups, [:organization_id, :guw_model_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: "by_organization_guw_model_project_mp_pbs_name"


    #Guw::GuwUnitOfWork
    remove_index :guw_guw_unit_of_works, name: :module_project_guw_unit_of_works
    add_index :guw_guw_unit_of_works, [:organization_id, :guw_model_id, :project_id, :module_project_id, :pbs_project_element_id,  :guw_unit_of_work_group_id, :guw_type_id, :selected], name: "by_organization_guw_model_project_mp_pbs_uowGroup_type_selected"

    ## guw_guw_coefficients
    add_column :guw_guw_coefficients, :organization_id, :integer, after: :id
    remove_index :guw_guw_coefficients, name: "guw_model_guw_coefficients"
    add_index :guw_guw_coefficients, [:organization_id, :guw_model_id, :name], name: :"by_organization_guw_model_name"

    ## CoefficientElements
    add_column :guw_guw_coefficient_elements, :organization_id, :integer, after: :id
    change_column :guw_guw_coefficient_elements, :guw_model_id, :integer, :after => :organization_id
    remove_index :guw_guw_coefficient_elements, name: "guw_coefficient_elements"
    add_index :guw_guw_coefficient_elements, [:organization_id, :guw_model_id, :guw_coefficient_id, :default], name: "by_organization_guw_coeff_default"

    ## GuwType
    add_column :guw_guw_types, :organization_id, :integer, after: :id
    change_column :guw_guw_types, :guw_model_id, :integer, :after => :organization_id
    remove_index :guw_guw_types, name: "guw_model_guw_types"
    remove_index :guw_guw_types, name: "guw_model_default_guw_types"
    add_index :guw_guw_types, [:organization_id, :guw_model_id, :name], name: "by_organization_guw_model_name"
    add_index :guw_guw_types, [:organization_id, :guw_model_id, :is_default], name: "by_organization_guw_model_default"

    ## GuwOutput
    add_column :guw_guw_outputs, :organization_id, :integer, after: :id
    change_column :guw_guw_outputs, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_outputs,  name: "guw_model_guw_outputs"
    add_index :guw_guw_outputs, [:organization_id, :guw_model_id, :name], name: "by_organization_guw_model_name"

    #GuwOutputType
    add_column :guw_guw_output_types, :organization_id, :integer, after: :id
    add_index :guw_guw_output_types, [:organization_id, :guw_model_id, :guw_output_id, :guw_type_id], name: "by_organization_guw_model_output_type"

    ##guw_guw_output_associations
    add_column :guw_guw_output_associations, :organization_id, :integer, after: :id
    add_column :guw_guw_output_associations, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_output_associations, [:organization_id, :guw_model_id, :guw_output_id, :guw_complexity_id, :guw_output_associated_id], name: "by_organization_guw_model_output_cplx_association"

    ##guw_guw_work_units
    add_column :guw_guw_work_units, :organization_id, :integer, after: :id
    change_column :guw_guw_work_units, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_work_units, [:organization_id, :guw_model_id, :name], name: "by_organization_guw_model_name"

    #GuwComplexities  (guw_model_id est à remplir dans le tache)
    add_column :guw_guw_complexities, :organization_id, :integer, after: :id
    change_column :guw_guw_complexities, :guw_model_id, :integer, :after => :organization_id
    remove_index :guw_guw_complexities, name: "guw_type_complexities"
    add_index :guw_guw_complexities, [:organization_id, :guw_model_id, :guw_type_id, :name], name: "by_organization_guw_model_type_name"

    #GuwComplexityTechnology
    add_column :guw_guw_complexity_technologies, :organization_id, :integer, after: :id
    add_column :guw_guw_complexity_technologies, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_complexity_technologies, [:organization_id, :guw_model_id, :organization_technology_id, :guw_complexity_id, :guw_type_id], name: "by_organization_guw_model_techno_cplx_type"

    #GuwComplexityWorkUnit
    add_column :guw_guw_complexity_work_units, :organization_id, :integer, after: :id
    add_column :guw_guw_complexity_work_units, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_complexity_work_units, [:organization_id, :guw_model_id, :guw_work_unit_id, :guw_complexity_id], name: "by_organization_guw_model_name"

    #guw_guw_output_complexities
    add_column :guw_guw_output_complexities, :organization_id, :integer, after: :id
    add_column :guw_guw_output_complexities, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_output_complexities, name: "guw_output_complexities"
    add_index :guw_guw_output_complexities, [:organization_id, :guw_model_id, :guw_output_id, :guw_complexity_id], name: "by_organization_guw_model_output_cplx"

    #guw_guw_output_complexity_initialization
    add_column :guw_guw_output_complexity_initializations, :organization_id, :integer, after: :id
    add_column :guw_guw_output_complexity_initializations, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_output_complexity_initializations, name: "guw_output_complexity_initializations"
    add_index :guw_guw_output_complexity_initializations, [:organization_id, :guw_model_id, :guw_output_id, :guw_complexity_id], name: "by_organization_guw_model_output_cplx"

    #guw_guw_complexity_coefficient_elements
    add_column :guw_guw_complexity_coefficient_elements, :organization_id, :integer, after: :id
    add_column :guw_guw_complexity_coefficient_elements, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_complexity_coefficient_elements, name: "guw_complexity_coefficient_elements"
    add_index :guw_guw_complexity_coefficient_elements, [:organization_id, :guw_model_id, :guw_output_id, :guw_type_id, :guw_complexity_id, :guw_coefficient_element_id], name: "by_organization_guw_model_output_type_cplx_coeffElt"
    add_index :guw_guw_complexity_coefficient_elements, [:organization_id, :guw_model_id, :guw_output_id, :guw_complexity_id, :guw_coefficient_element_id], name: "by_organization_guw_model_output_cplx_coeffElt"

    #Guw_attributes
    add_column :guw_guw_attributes, :organization_id, :integer, after: :id
    change_column :guw_guw_attributes, :guw_model_id, :integer, :after => :organization_id
    add_index :guw_guw_attributes, [:organization_id, :guw_model_id, :name], name: "by_organization_guw_model_name"

    ##GuwAttributeType
    add_column :guw_guw_attribute_types, :organization_id, :integer, after: :id
    add_column :guw_guw_attribute_types, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_attribute_types, [:organization_id, :guw_model_id, :guw_attribute_id, :guw_type_id], name: "by_organization_guw_model_attribute_type"

    ##guw_guw_attribute_complexities
    add_column :guw_guw_attribute_complexities, :organization_id, :integer, after: :id
    add_column :guw_guw_attribute_complexities, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_attribute_complexities, name: "guw_attribute_complexities"
    add_index :guw_guw_attribute_complexities, [:organization_id, :guw_model_id, :guw_attribute_id, :guw_type_id, :guw_type_complexity_id], name: "by_organization_guw_model_attribute_type"

    #guw_guw_type_complexities
    add_column :guw_guw_type_complexities, :organization_id, :integer, after: :id
    add_column :guw_guw_type_complexities, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_type_complexities, [:organization_id, :guw_model_id, :guw_type_id, :name], name: "by_organization_guw_model_type_name"

    #guw_guw_scale_module_attributes
    remove_index :guw_guw_scale_module_attributes, name: "guw_scale_module_attributes"
  end


  def down

    #guw_guw_unit_of_work_attributes
    remove_column :guw_guw_coefficient_element_unit_of_works, :organization_id
    remove_column :guw_guw_coefficient_element_unit_of_works, :guw_model_id
    remove_column :guw_guw_coefficient_element_unit_of_works, :project_id
    add_index :guw_guw_coefficient_element_unit_of_works, [:module_project_id, :guw_unit_of_work_id, :guw_coefficient_id, :guw_coefficient_element_id], name: :guw_unit_of_work_guw_coefficient_elements unless index_exists?(:guw_guw_coefficient_element_unit_of_works, [:guw_unit_of_work_id, :guw_coefficient_id, :guw_coefficient_element_id], name: :guw_unit_of_work_guw_coefficient_elements)
    remove_index :guw_guw_coefficient_element_unit_of_works, name: "by_organization_guw_model_coeff_coeffElement_project_mp_uow"
    remove_index :guw_guw_coefficient_element_unit_of_works, name: "by_organization_guw_model_coeff_project_mp_uow"
    remove_index :guw_guw_coefficient_element_unit_of_works, name: "by_organization_guw_model_project_mp_uow"

    # ## guw_guw_unit_of_work_attributes
    remove_column :guw_guw_unit_of_work_attributes, :organization_id
    remove_column :guw_guw_unit_of_work_attributes, :guw_model_id
    remove_column :guw_guw_unit_of_work_attributes, :project_id
    remove_column :guw_guw_unit_of_work_attributes, :module_project_id
    remove_index :guw_guw_unit_of_work_attributes, name: "by_organization_guw_model_attr_type_project_mp_uow"

    ##Guw::GuwUnitOfWorkGroup
    remove_column :guw_guw_unit_of_work_groups, :guw_model_id
    add_index :guw_guw_unit_of_work_groups, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: :module_project_guw_groups unless index_exists?(:guw_guw_unit_of_work_groups, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :name], name: :module_project_guw_groups)
    remove_index :guw_guw_unit_of_work_groups, name: "by_organization_guw_model_project_mp_pbs_name"

    ##Guw::GuwUnitOfWork
    add_index :guw_guw_unit_of_works, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :guw_model_id, :guw_unit_of_work_group_id, :guw_type_id, :selected], name: :module_project_guw_unit_of_works unless index_exists?(:guw_guw_unit_of_works, [:organization_id, :project_id, :module_project_id, :pbs_project_element_id, :guw_model_id, :guw_unit_of_work_group_id, :guw_type_id, :selected], name: :module_project_guw_unit_of_works)
    remove_index :guw_guw_unit_of_works, name: "by_organization_guw_model_project_mp_pbs_uowGroup_type_selected"

    ## guw_guw_coefficients
    remove_column :guw_guw_coefficients, :organization_id
    add_index :guw_guw_coefficients, [:guw_model_id, :name], name: :guw_model_guw_coefficients unless index_exists?(:guw_guw_coefficients, [:guw_model_id, :name], name: :guw_model_guw_coefficients)
    remove_index :guw_guw_coefficients, name: :"by_organization_guw_model_name"

    ## CoefficientElements
    remove_column :guw_guw_coefficient_elements, :organization_id
    add_index :guw_guw_coefficient_elements, [:guw_model_id, :guw_coefficient_id, :default], name: :guw_coefficient_elements unless index_exists?(:guw_guw_coefficient_elements, [:guw_model_id, :guw_coefficient_id, :default], name: :guw_coefficient_elements)
    remove_index :guw_guw_coefficient_elements, name: "by_organization_guw_coeff_default"

    ## GuwType
    remove_column :guw_guw_types, :organization_id
    add_index :guw_guw_types, [:guw_model_id, :name], name: :guw_model_guw_types unless index_exists?(:guw_guw_types, [:guw_model_id, :name], name: :guw_model_guw_types)
    add_index :guw_guw_types, [:guw_model_id, :is_default], name: :guw_model_default_guw_types unless index_exists?(:guw_guw_types, [:guw_model_id, :is_default], name: :guw_model_default_guw_types)
    remove_index :guw_guw_types, name: "by_organization_guw_model_name"
    remove_index :guw_guw_types, name: "by_organization_guw_model_default"

    ## GuwOutput
    remove_column :guw_guw_outputs, :organization_id
    add_index :guw_guw_outputs, [:guw_model_id, :name], name: :guw_model_guw_outputs unless index_exists?(:guw_guw_outputs, [:guw_model_id, :name], name: :guw_model_guw_outputs)
    remove_index :guw_guw_outputs, name: "by_organization_guw_model_name"

    #GuwOutputType
    remove_column :guw_guw_output_types, :organization_id, :integer, after: :id
    remove_index :guw_guw_output_types, name: "by_organization_guw_model_output_type"

    ##guw_guw_output_associations
    remove_column :guw_guw_output_associations, :organization_id, :integer, after: :id
    remove_column :guw_guw_output_associations, :guw_model_id, :integer
    remove_index :guw_guw_output_associations, name: "by_organization_guw_model_output_cplx_association"

    ##guw_guw_work_units
    remove_column :guw_guw_work_units, :organization_id
    remove_index :guw_guw_work_units, name: "by_organization_guw_model_name"

    #GuwComplexities  (guw_model_id est à remplir dans le tache)
    remove_column :guw_guw_complexities, :organization_id
    add_index :guw_guw_complexities, [:guw_type_id, :name], name: :guw_type_complexities unless index_exists?(:guw_guw_complexities, [:guw_type_id, :name], name: :guw_type_complexities)
    remove_index :guw_guw_complexities, name: "by_organization_guw_model_type_name"

    #GuwComplexityTechnology
    remove_column :guw_guw_complexity_technologies, :organization_id, :integer
    remove_column :guw_guw_complexity_technologies, :guw_model_id, :integer
    remove_index :guw_guw_complexity_technologies, name: "by_organization_guw_model_techno_cplx_type"

    #GuwComplexityWorkUnit
    remove_column :guw_guw_complexity_work_units, :organization_id, :integer
    remove_column :guw_guw_complexity_work_units, :guw_model_id, :integer
    remove_index :guw_guw_complexity_work_units, name: "by_organization_guw_model_name"

    #guw_guw_output_complexities
    remove_column :guw_guw_output_complexities, :organization_id, :integer, after: :id
    remove_column :guw_guw_output_complexities, :guw_model_id, :integer
    add_index :guw_guw_output_complexities, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexities unless index_exists?(:guw_guw_output_complexities, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexities)
    remove_index :guw_guw_output_complexities, name: "by_organization_guw_model_output_cplx"

    #guw_guw_output_complexity_initialization
    remove_column :guw_guw_output_complexity_initializations, :organization_id, :integer, after: :id
    remove_column :guw_guw_output_complexity_initializations, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_output_complexity_initializations, [:guw_complexity_id, :guw_output_id], name: :guw_output_complexity_initializations unless index_exists?(:guw_guw_output_complexity_initializations, [ :guw_complexity_id, :guw_output_id], name: :guw_output_complexity_initializations)
    remove_index :guw_guw_output_complexity_initializations, name: "by_organization_guw_model_output_cplx"

    #guw_guw_complexity_coefficient_elements
    remove_column :guw_guw_complexity_coefficient_elements, :organization_id, :integer, after: :id
    remove_column :guw_guw_complexity_coefficient_elements, :guw_model_id, :integer, after: :organization_id
    add_index :guw_guw_complexity_coefficient_elements, [:guw_complexity_id, :guw_coefficient_element_id, :guw_output_id], name: :guw_complexity_coefficient_elements unless index_exists?(:guw_guw_complexity_coefficient_elements, [:guw_complexity_id, :guw_coefficient_element_id, :guw_output_id], name: :guw_complexity_coefficient_elements)
    remove_index :guw_guw_complexity_coefficient_elements, name: "by_organization_guw_model_output_type_cplx_coeffElt"
    remove_index :guw_guw_complexity_coefficient_elements, name: "by_organization_guw_model_output_cplx_coeffElt"

    #Guw_attributes
    remove_column :guw_guw_attributes, :organization_id, :integer, after: :id
    remove_index :guw_guw_attributes, name: "by_organization_guw_model_name"

    ##GuwAttributeType
    remove_column :guw_guw_attribute_types, :organization_id, :integer, after: :id
    remove_column :guw_guw_attribute_types, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_attribute_types, name: "by_organization_guw_model_attribute_type"

    ##guw_guw_attribute_complexities
    remove_column :guw_guw_attribute_complexities, :organization_id, :integer, after: :id
    remove_column :guw_guw_attribute_complexities, :guw_model_id, :integer
    add_index :guw_guw_attribute_complexities, [:guw_type_id, :guw_attribute_id], name: :guw_attribute_complexities unless index_exists?(:guw_guw_attribute_complexities, [:guw_type_id, :guw_attribute_id], name: :guw_attribute_complexities)
    remove_index :guw_guw_attribute_complexities, name: "by_organization_guw_model_attribute_type"

    #guw_guw_type_complexities
    remove_column :guw_guw_type_complexities, :organization_id, :integer, after: :id
    remove_column :guw_guw_type_complexities, :guw_model_id, :integer, after: :organization_id
    remove_index :guw_guw_type_complexities, name: "by_organization_guw_model_type_name"

    #guw_guw_scale_module_attributes
    add_index :guw_guw_scale_module_attributes, [:guw_model_id, :type_attribute], name: :guw_scale_module_attributes unless index_exists?(:guw_guw_scale_module_attributes, [:guw_model_id, :type_attribute], name: :guw_scale_module_attributes)
  end

end