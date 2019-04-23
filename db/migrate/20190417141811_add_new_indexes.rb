class AddNewIndexes < ActiveRecord::Migration

  def up
    add_index :groups, [:organization_id, :name], name: "by_organization_name", unique: true unless index_exists?(:groups, [:organization_id, :name])

    add_index :groups_permissions, [:group_id, :permission_id], name: "by_group_permission"
    add_index :groups_permissions, [:permission_id, :group_id], name: "by_permission_group"

    add_index :groups_users, [:group_id, :user_id], name: "by_group_user"
    add_index :groups_users, [:user_id, :group_id], name: "by_user_group"

    add_index :module_projects, :project_id,  :name => "by_project"

    add_index :views, [:organization_id, :pemodule_id],  :name => "by_organization_pemodule"

    add_index :project_fields, [:project_id, :views_widget_id], :name => "by_project_viewsWidget"

    add_index :project_fields, [:project_id, :field_id], :name => "by_project_field"

    add_index :project_securities, :project_security_level_id, name: "by_psl"
    add_index :project_securities, :project_id, name: "by_project"
    add_index :project_securities, [:user_id, :is_model_permission, :is_estimation_permission], name: "by_user_is_permission"

    add_index :permissions_project_security_levels, [:project_security_level_id, :permission_id], name: "by_psl_permission"
    add_index :permissions_project_security_levels, [:permission_id, :project_security_level_id], name: "by_permission_psl"

    add_index :project_security_levels, [:organization_id, :name], name: "by_organization_name", unique: true unless index_exists?(:project_security_levels, [:organization_id, :name])

    add_index :kb_kb_inputs, [:organization_id, :kb_model_id, :module_project_id],  :name => "by_organization_kbModel_mp"

    add_index :skb_skb_inputs, [:organization_id, :skb_model_id, :module_project_id],  :name => "by_organization_skbModel_mp"

    add_index :ge_ge_inputs, [:organization_id, :ge_model_id, :module_project_id],  :name => "by_organization_geModel_mp"

    add_index :ge_ge_factors, [:ge_model_id, :scale_prod, :factor_type],  :name => "by_geModel_factorType"

    add_index :ge_ge_factor_values, [:ge_model_id, :factor_scale_prod, :factor_type, :ge_factor_id],  :name => "by_geModel_scaleProd_factorType_factor"

    add_index :ge_ge_model_factor_descriptions, [:organization_id, :ge_model_id, :ge_factor_id, :project_id, :module_project_id, :factor_alias],  :name => "by_organization_project_mp_gemodel_factor_alias"

    add_index :staffing_staffing_custom_data, [:staffing_model_id, :pbs_project_element_id, :module_project_id], name: "by_model_pbs_mp"

    add_index :organizations_users, [:user_id, :organization_id], name: "by_user_organization"

    add_index :estimation_statuses, :organization_id, name: "by_organization"

    add_index :estimation_status_group_roles, [:group_id, :project_security_level_id, :estimation_status_id ], name: "by_group_psl_status"

  end


  def down

    remove_index :groups, name: "by_organization_name"

    remove_index :groups_permissions, name: "by_group_permission"
    remove_index :groups_permissions, name: "by_permission_group"

    remove_index :groups_users, name: "by_group_user"
    remove_index :groups_users, name: "by_user_group"

    remove_index :module_projects, :name => "by_project"

    remove_index :views, :name => "by_organization_pemodule"

    remove_index :project_fields, :name => "by_project_viewsWidget"

    remove_index :project_fields, :name => "by_project_field"

    remove_index :project_securities, name: "by_psl"
    remove_index :project_securities, name: "by_project"
    remove_index :project_securities, name: "by_user_is_permission"
    remove_index :permissions_project_security_levels, name: "by_psl_permission"
    remove_index :permissions_project_security_levels, name: "by_permission_psl"

    remove_index :project_security_levels, name: "by_organization_name"

    remove_index :kb_kb_inputs, :name => "by_organization_kbModel_mp"

    remove_index :skb_skb_inputs, :name => "by_organization_skbModel_mp"

    remove_index :ge_ge_inputs, :name => "by_organization_geModel_mp"

    remove_index :ge_ge_factors, :name => "by_geModel_factorType"

    remove_index :ge_ge_factor_values, :name => "by_geModel_scaleProd_factorType_factor"

    remove_index :ge_ge_model_factor_descriptions, :name => "by_organization_project_mp_gemodel_factor_alias"

    remove_index :staffing_staffing_custom_data, name: "by_model_pbs_mp"

    remove_index :organizations_users, name: "by_user_organization"

    remove_index :estimation_statuses, name: "by_organization"

    remove_index :estimation_status_group_roles, name: "by_group_psl_status"

  end

end
