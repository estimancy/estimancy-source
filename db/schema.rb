# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130917145201) do

  create_table "abacus_organizations", :force => true do |t|
    t.float    "value"
    t.integer  "unit_of_work_id"
    t.integer  "organization_uow_complexity_id"
    t.integer  "organization_technology_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "organization_id"
  end

  create_table "acquisition_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acquisition_categories", ["record_status_id"], :name => "index_acquisition_categories_on_record_status_id"
  add_index "acquisition_categories", ["reference_id"], :name => "index_acquisition_categories_on_parent_id"
  add_index "acquisition_categories", ["uuid"], :name => "index_acquisition_categories_on_uuid", :unique => true

  create_table "acquisition_categories_project_areas", :id => false, :force => true do |t|
    t.integer  "acquisition_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_settings", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_settings", ["record_status_id"], :name => "index_admin_settings_on_record_status_id"
  add_index "admin_settings", ["reference_id"], :name => "index_admin_settings_on_parent_id"
  add_index "admin_settings", ["uuid"], :name => "index_admin_settings_on_uuid", :unique => true

  create_table "associated_module_projects", :id => false, :force => true do |t|
    t.integer "associated_module_project_id"
    t.integer "module_project_id"
  end

  create_table "attribute_categories", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
  end

  create_table "attribute_modules", :force => true do |t|
    t.integer  "pe_attribute_id"
    t.integer  "pemodule_id"
    t.boolean  "is_mandatory",        :default => false
    t.string   "in_out"
    t.text     "description"
    t.string   "default_low"
    t.string   "default_most_likely"
    t.string   "default_high"
    t.integer  "dimensions"
    t.string   "custom_attribute"
    t.string   "project_value"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
  end

  add_index "attribute_modules", ["record_status_id"], :name => "index_attribute_modules_on_record_status_id"
  add_index "attribute_modules", ["reference_id"], :name => "index_attribute_modules_on_parent_id"
  add_index "attribute_modules", ["uuid"], :name => "index_attribute_modules_on_uuid", :unique => true

  create_table "attribute_organizations", :force => true do |t|
    t.integer  "pe_attribute_id"
    t.integer  "organization_id"
    t.boolean  "is_mandatory"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "auth_methods", :force => true do |t|
    t.string   "name"
    t.string   "server_name"
    t.integer  "port"
    t.string   "base_dn"
    t.string   "user_name_attribute"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.boolean  "on_the_fly_user_creation",     :default => false
    t.string   "ldap_bind_dn"
    t.string   "ldap_bind_encrypted_password"
    t.string   "ldap_bind_salt"
    t.integer  "priority_order",               :default => 1
    t.string   "first_name_attribute"
    t.string   "last_name_attribute"
    t.string   "email_attribute"
    t.string   "initials_attribute"
    t.string   "encryption"
  end

  add_index "auth_methods", ["record_status_id"], :name => "index_auth_methods_on_record_status_id"
  add_index "auth_methods", ["reference_id"], :name => "index_auth_methods_on_parent_id"
  add_index "auth_methods", ["uuid"], :name => "index_auth_methods_on_uuid", :unique => true

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["record_status_id"], :name => "index_currencies_on_record_status_id"
  add_index "currencies", ["reference_id"], :name => "index_currencies_on_parent_id"
  add_index "currencies", ["uuid"], :name => "index_currencies_on_uuid", :unique => true

  create_table "estimation_values", :force => true do |t|
    t.integer  "module_project_id"
    t.integer  "pe_attribute_id"
    t.text     "string_data_low"
    t.text     "string_data_most_likely"
    t.text     "string_data_high"
    t.text     "string_data_probable"
    t.date     "date_data_probable"
    t.string   "links"
    t.boolean  "is_mandatory"
    t.string   "in_out"
    t.text     "description"
    t.string   "custom_attribute"
    t.string   "project_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
  end

  add_index "estimation_values", ["links"], :name => "index_attribute_projects_on_links"

  create_table "event_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "icon_url"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_types", ["record_status_id"], :name => "index_event_types_on_record_status_id"
  add_index "event_types", ["reference_id"], :name => "index_event_types_on_parent_id"
  add_index "event_types", ["uuid"], :name => "index_event_types_on_uuid", :unique => true

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "event_type_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "code_group"
    t.boolean  "for_global_permission"
    t.boolean  "for_project_security"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["record_status_id"], :name => "index_groups_on_record_status_id"
  add_index "groups", ["reference_id"], :name => "index_groups_on_parent_id"
  add_index "groups", ["uuid"], :name => "index_groups_on_uuid", :unique => true

  create_table "groups_permissions", :id => false, :force => true do |t|
    t.integer  "group_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_projects", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "project_id"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labor_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "labor_categories", ["record_status_id"], :name => "index_labor_categories_on_record_status_id"
  add_index "labor_categories", ["reference_id"], :name => "index_labor_categories_on_parent_id"
  add_index "labor_categories", ["uuid"], :name => "index_labor_categories_on_uuid", :unique => true

  create_table "labor_categories_project_areas", :id => false, :force => true do |t|
    t.integer  "labor_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "locale"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["record_status_id"], :name => "index_languages_on_record_status_id"
  add_index "languages", ["reference_id"], :name => "index_languages_on_parent_id"
  add_index "languages", ["uuid"], :name => "index_languages_on_uuid", :unique => true

  create_table "master_settings", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_settings", ["record_status_id"], :name => "index_master_settings_on_record_status_id"
  add_index "master_settings", ["reference_id"], :name => "index_master_settings_on_parent_id"
  add_index "master_settings", ["uuid"], :name => "index_master_settings_on_uuid", :unique => true

  create_table "module_projects", :force => true do |t|
    t.integer  "pemodule_id"
    t.integer  "project_id"
    t.integer  "position_x"
    t.integer  "position_y"
    t.integer  "nb_input_attr"
    t.integer  "nb_output_attr"
    t.integer  "copy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "module_projects_pbs_project_elements", :id => false, :force => true do |t|
    t.integer "module_project_id"
    t.integer "pbs_project_element_id"
    t.integer "copy_id"
  end

  create_table "organization_labor_categories", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "labor_category_id"
    t.string   "level"
    t.string   "name"
    t.text     "description"
    t.float    "cost_per_hour"
    t.integer  "base_year"
    t.integer  "currency_id"
    t.float    "hour_per_day"
    t.integer  "days_per_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_technologies", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.float    "productivity_ratio"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "organization_technologies_unit_of_works", :id => false, :force => true do |t|
    t.integer  "organization_technology_id"
    t.integer  "unit_of_work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_uow_complexities", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "display_order"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "pbs_project_elements", :force => true do |t|
    t.integer  "pe_wbs_project_id"
    t.string   "ancestry"
    t.boolean  "is_root"
    t.integer  "work_element_type_id"
    t.string   "name"
    t.integer  "project_link"
    t.integer  "position"
    t.integer  "copy_id"
    t.integer  "wbs_activity_id"
    t.integer  "wbs_activity_ratio_id"
    t.boolean  "is_completed"
    t.boolean  "is_validated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pbs_project_elements", ["ancestry"], :name => "index_components_on_ancestry"

  create_table "pe_attributes", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.string   "attr_type"
    t.text     "options"
    t.text     "aggregation"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "precision"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attribute_category_id"
  end

  add_index "pe_attributes", ["record_status_id"], :name => "index_attributes_on_record_status_id"
  add_index "pe_attributes", ["reference_id"], :name => "index_attributes_on_parent_id"
  add_index "pe_attributes", ["uuid"], :name => "index_attributes_on_uuid", :unique => true

  create_table "pe_wbs_projects", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.string   "wbs_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "peicons", :force => true do |t|
    t.string   "name"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "peicons", ["record_status_id"], :name => "index_peicons_on_record_status_id"
  add_index "peicons", ["reference_id"], :name => "index_peicons_on_parent_id"
  add_index "peicons", ["uuid"], :name => "index_peicons_on_uuid", :unique => true

  create_table "pemodules", :force => true do |t|
    t.string   "title"
    t.string   "alias"
    t.text     "description"
    t.string   "with_activities",          :default => "0"
    t.integer  "type_id"
    t.text     "compliant_component_type"
    t.boolean  "is_typed"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pemodules", ["record_status_id"], :name => "index_pemodules_on_record_status_id"
  add_index "pemodules", ["reference_id"], :name => "index_pemodules_on_parent_id"
  add_index "pemodules", ["uuid"], :name => "index_pemodules_on_uuid", :unique => true

  create_table "permissions", :force => true do |t|
    t.string   "object_associated"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_permission_project"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["record_status_id"], :name => "index_permissions_on_record_status_id"
  add_index "permissions", ["reference_id"], :name => "index_permissions_on_parent_id"
  add_index "permissions", ["uuid"], :name => "index_permissions_on_uuid", :unique => true

  create_table "permissions_project_security_levels", :id => false, :force => true do |t|
    t.integer  "permission_id"
    t.integer  "project_security_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_users", :id => false, :force => true do |t|
    t.integer  "permission_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "platform_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "platform_categories", ["record_status_id"], :name => "index_platform_categories_on_record_status_id"
  add_index "platform_categories", ["reference_id"], :name => "index_platform_categories_on_parent_id"
  add_index "platform_categories", ["uuid"], :name => "index_platform_categories_on_uuid", :unique => true

  create_table "platform_categories_project_areas", :id => false, :force => true do |t|
    t.integer  "platform_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_areas", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_areas", ["record_status_id"], :name => "index_project_areas_on_record_status_id"
  add_index "project_areas", ["reference_id"], :name => "index_project_areas_on_parent_id"
  add_index "project_areas", ["uuid"], :name => "index_project_areas_on_uuid", :unique => true

  create_table "project_areas_project_categories", :id => false, :force => true do |t|
    t.integer  "project_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_areas_work_element_types", :id => false, :force => true do |t|
    t.integer  "project_area_id"
    t.integer  "work_element_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_categories", ["record_status_id"], :name => "index_project_categories_on_record_status_id"
  add_index "project_categories", ["reference_id"], :name => "index_project_categories_on_parent_id"
  add_index "project_categories", ["uuid"], :name => "index_project_categories_on_uuid", :unique => true

  create_table "project_ressources", :force => true do |t|
    t.string "name"
  end

  create_table "project_securities", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "project_security_level_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_security_levels", :force => true do |t|
    t.string   "name"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "project_security_levels", ["record_status_id"], :name => "index_project_security_levels_on_record_status_id"
  add_index "project_security_levels", ["reference_id"], :name => "index_project_security_levels_on_parent_id"
  add_index "project_security_levels", ["uuid"], :name => "index_project_security_levels_on_uuid", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.string   "version",                 :default => "1.0"
    t.string   "alias"
    t.text     "description"
    t.string   "state"
    t.date     "start_date"
    t.integer  "organization_id"
    t.integer  "project_area_id"
    t.integer  "project_category_id"
    t.integer  "platform_category_id"
    t.integer  "acquisition_category_id"
    t.boolean  "is_model"
    t.integer  "version_ancestry"
    t.integer  "master_anscestry"
    t.integer  "owner"
    t.text     "purpose"
    t.text     "level_of_detail"
    t.text     "scope"
    t.integer  "copy_number"
    t.text     "included_wbs_activities"
    t.boolean  "is_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "record_statuses", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.integer  "status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "record_statuses", ["record_status_id"], :name => "index_record_statuses_on_record_status_id"
  add_index "record_statuses", ["reference_id"], :name => "index_record_statuses_on_parent_id"
  add_index "record_statuses", ["uuid"], :name => "index_record_statuses_on_uuid", :unique => true

  create_table "subcontractors", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "unit_of_works", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "login_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "initials"
    t.datetime "last_login"
    t.datetime "previous_login"
    t.string   "time_zone"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.integer  "language_id"
    t.integer  "auth_type"
    t.string   "user_status"
    t.text     "ten_latest_projects"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "object_per_page"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login_name"], :name => "index_users_on_login_name", :unique => true

  create_table "versions", :force => true do |t|
    t.datetime "local_latest_update"
    t.datetime "repository_latest_update"
    t.text     "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "wbs_activities", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.string   "state"
    t.text     "description"
    t.integer  "organization_id"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "copy_number",      :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "wbs_activities", ["owner_id"], :name => "index_wbs_activities_on_owner_id"
  add_index "wbs_activities", ["record_status_id"], :name => "index_wbs_activities_on_record_status_id"
  add_index "wbs_activities", ["reference_id"], :name => "index_wbs_activities_on_reference_id"
  add_index "wbs_activities", ["uuid"], :name => "index_wbs_activities_on_uuid", :unique => true

  create_table "wbs_activity_elements", :force => true do |t|
    t.string   "uuid"
    t.integer  "wbs_activity_id"
    t.string   "name"
    t.text     "description"
    t.string   "ancestry"
    t.integer  "ancestry_depth",   :default => 0
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "copy_id"
    t.string   "dotted_id"
    t.boolean  "is_root"
    t.string   "master_ancestry"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "wbs_activity_elements", ["ancestry"], :name => "index_wbs_activity_elements_on_ancestry"
  add_index "wbs_activity_elements", ["owner_id"], :name => "index_wbs_activity_elements_on_owner_id"
  add_index "wbs_activity_elements", ["record_status_id"], :name => "index_wbs_activity_elements_on_record_status_id"
  add_index "wbs_activity_elements", ["reference_id"], :name => "index_wbs_activity_elements_on_reference_id"
  add_index "wbs_activity_elements", ["uuid"], :name => "index_wbs_activity_elements_on_uuid", :unique => true
  add_index "wbs_activity_elements", ["wbs_activity_id"], :name => "index_wbs_activity_elements_on_wbs_activity_id"

  create_table "wbs_activity_ratio_elements", :force => true do |t|
    t.string   "uuid"
    t.integer  "wbs_activity_ratio_id"
    t.integer  "wbs_activity_element_id"
    t.float    "ratio_value"
    t.boolean  "simple_reference"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.boolean  "multiple_references"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "wbs_activity_ratio_elements", ["owner_id"], :name => "index_wbs_activity_ratio_elements_on_owner_id"
  add_index "wbs_activity_ratio_elements", ["record_status_id"], :name => "index_wbs_activity_ratio_elements_on_record_status_id"
  add_index "wbs_activity_ratio_elements", ["reference_id"], :name => "index_wbs_activity_ratio_elements_on_reference_id"
  add_index "wbs_activity_ratio_elements", ["uuid"], :name => "index_wbs_activity_ratio_elements_on_uuid", :unique => true

  create_table "wbs_activity_ratios", :force => true do |t|
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.integer  "wbs_activity_id"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "copy_number",      :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "wbs_activity_ratios", ["owner_id"], :name => "index_wbs_activity_ratios_on_owner_id"
  add_index "wbs_activity_ratios", ["record_status_id"], :name => "index_wbs_activity_ratios_on_record_status_id"
  add_index "wbs_activity_ratios", ["reference_id"], :name => "index_wbs_activity_ratios_on_reference_id"
  add_index "wbs_activity_ratios", ["uuid"], :name => "index_wbs_activity_ratios_on_uuid", :unique => true

  create_table "wbs_project_elements", :force => true do |t|
    t.integer  "pe_wbs_project_id"
    t.integer  "wbs_activity_element_id"
    t.integer  "wbs_activity_id"
    t.string   "name"
    t.text     "description"
    t.text     "additional_description"
    t.boolean  "exclude",                 :default => false
    t.string   "ancestry"
    t.integer  "ancestry_depth",          :default => 0
    t.integer  "author_id"
    t.integer  "copy_id"
    t.integer  "copy_number",             :default => 0
    t.boolean  "is_root"
    t.boolean  "can_get_new_child"
    t.integer  "wbs_activity_ratio_id"
    t.boolean  "is_added_wbs_root"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "work_element_types", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.integer  "project_area_id"
    t.integer  "peicon_id"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_element_types", ["record_status_id"], :name => "index_work_element_types_on_record_status_id"
  add_index "work_element_types", ["reference_id"], :name => "index_work_element_types_on_parent_id"
  add_index "work_element_types", ["uuid"], :name => "index_work_element_types_on_uuid", :unique => true

end
