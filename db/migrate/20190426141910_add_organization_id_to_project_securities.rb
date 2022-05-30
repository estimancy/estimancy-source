class AddOrganizationIdToProjectSecurities < ActiveRecord::Migration
  def up
    add_column :project_securities, :organization_id, :integer, after: :id

    ProjectSecurity.all.each do |ps|
      unless ps.project_id.nil?
        ps.organization_id = ps.project.organization_id
        ps.save
      end
    end

    remove_index :project_securities, name: "by_user_is_permission"
    remove_index :project_securities, name: :ability_project_securities
    remove_index :project_securities, name: "by_project"
    remove_index :project_securities, name: "by_psl"

    add_index :project_securities, [:organization_id, :group_id, :is_model_permission, :is_estimation_permission], name: :by_organization_group_is_permission
    add_index :project_securities, [:organization_id, :user_id, :is_model_permission, :is_estimation_permission], name: :by_organization_user_is_permission

    add_index :project_securities, [:organization_id, :group_id, :project_id, :project_security_level_id, :is_model_permission, :is_estimation_permission], name: :by_organization_group_project_psl_is_permission
    add_index :project_securities, [:organization_id, :user_id, :project_id, :project_security_level_id, :is_model_permission, :is_estimation_permission], name: :by_organization_user_project_psl_is_permission

    add_index :permissions, [:alias, :object_associated], name: :by_alias_object_associated

    add_index :project_areas, [:organization_id, :name], name: "by_organization_area_name"
    add_index :project_categories, [:organization_id, :name], name: "by_organization_category_name"
    add_index :platform_categories, [:organization_id, :name], name: "by_organization_platform_name"
    add_index :acquisition_categories, [:organization_id, :name], name: "by_organization_acquisition_name"

    add_index :associated_module_projects, [:module_project_id], name: "by_module_project"
    add_index :associated_module_projects, [:associated_module_project_id], name: "by_associated_mp"
  end


  def down
    remove_column :project_securities, :organization_id

    remove_index :project_securities, name: :by_organization_group_is_permission
    remove_index :project_securities, name: :by_organization_user_is_permission

    remove_index :project_securities, name: :by_organization_group_project_psl_is_permission
    remove_index :project_securities, name: :by_organization_user_project_psl_is_permission

    add_index :project_securities, [:user_id, :is_model_permission, :is_estimation_permission], name: "by_user_is_permission"
    add_index :project_securities, [:group_id, :is_model_permission, :is_estimation_permission], name: :ability_project_securities
    add_index :project_securities, :project_id, name: "by_project"
    add_index :project_securities, :project_security_level_id, name: "by_psl"

    remove_index :permissions, name: :by_alias_object_associated

    remove_index :project_areas, name: "by_organization_area_name"
    remove_index :project_categories, name: "by_organization_category_name"
    remove_index :platform_categories, name: "by_organization_platform_name"
    remove_index :acquisition_categories, name: "by_organization_acquisition_name"

    remove_index :associated_module_projects, name: "by_module_project"
    remove_index :associated_module_projects, name: "by_associated_mp"
  end
end
