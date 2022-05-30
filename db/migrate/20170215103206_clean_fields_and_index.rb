class CleanFieldsAndIndex < ActiveRecord::Migration
  def change
    remove_column :admin_settings, :record_status_id
    remove_column :admin_settings, :reference_id
    remove_column :admin_settings, :uuid

    remove_column :acquisition_categories, :record_status_id
    remove_column :acquisition_categories, :reference_id
    remove_column :acquisition_categories, :uuid

    remove_column :attribute_modules, :record_status_id
    remove_column :attribute_modules, :reference_id
    remove_column :attribute_modules, :uuid

    remove_column :auth_methods, :record_status_id
    remove_column :auth_methods, :reference_id
    remove_column :auth_methods, :uuid

    remove_column :currencies, :record_status_id
    remove_column :currencies, :reference_id
    remove_column :currencies, :uuid

    remove_column :groups, :record_status_id
    remove_column :groups, :reference_id
    remove_column :groups, :uuid

    remove_column :languages, :record_status_id
    remove_column :languages, :reference_id
    remove_column :languages, :uuid

    remove_column :pe_attributes, :record_status_id
    remove_column :pe_attributes, :reference_id
    remove_column :pe_attributes, :uuid

    remove_column :pemodules, :record_status_id
    remove_column :pemodules, :reference_id
    remove_column :pemodules, :uuid

    remove_column :permissions, :record_status_id
    remove_column :permissions, :reference_id
    remove_column :permissions, :uuid

    remove_column :platform_categories, :record_status_id
    remove_column :platform_categories, :reference_id
    remove_column :platform_categories, :uuid

    remove_column :profiles, :record_status_id
    remove_column :profiles, :reference_id
    remove_column :profiles, :uuid

    remove_column :project_areas, :record_status_id
    remove_column :project_areas, :reference_id
    remove_column :project_areas, :uuid

    remove_column :project_categories, :record_status_id
    remove_column :project_categories, :reference_id
    remove_column :project_categories, :uuid

    remove_column :project_security_levels, :record_status_id
    remove_column :project_security_levels, :reference_id
    remove_column :project_security_levels, :uuid

    remove_column :work_element_types, :record_status_id
    remove_column :work_element_types, :reference_id
    remove_column :work_element_types, :uuid

    remove_column :wbs_activity_elements, :owner_id
    remove_column :wbs_activity_ratios, :owner_id
    remove_column :wbs_activity_ratio_elements, :owner_id
    remove_column :project_security_levels, :owner_id

    drop_table :master_settings if ActiveRecord::Base.connection.table_exists? 'master_settings'
    drop_table :peicons if ActiveRecord::Base.connection.table_exists? 'peicons'
    drop_table :record_statuses if ActiveRecord::Base.connection.table_exists? 'record_statuses'
    drop_table :event_types if ActiveRecord::Base.connection.table_exists? 'event_types'
  end
end
