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

ActiveRecord::Schema.define(:version => 20180207164257) do

  create_table "abacus_organizations", :force => true do |t|
    t.float    "value"
    t.integer  "unit_of_work_id"
    t.integer  "organization_uow_complexity_id"
    t.integer  "organization_technology_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "organization_id"
    t.integer  "factor_id"
  end

  create_table "acquisition_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "copy_id"
  end

  create_table "acquisition_categories_project_areas", :id => false, :force => true do |t|
    t.integer  "acquisition_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_profiles", :force => true do |t|
    t.integer  "project_id"
    t.integer  "wbs_project_element_id"
    t.integer  "organization_profile_id"
    t.float    "ratio_percentage"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "admin_settings", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "category"
  end

  create_table "amoa_amoa_applications", :force => true do |t|
    t.string  "name"
    t.integer "amoa_model_id"
  end

  create_table "amoa_amoa_context_types", :force => true do |t|
    t.string "name"
  end

  create_table "amoa_amoa_contexts", :force => true do |t|
    t.string  "name"
    t.float   "weight"
    t.integer "amoa_application_id"
    t.integer "amoa_amoa_context_type_id"
  end

  create_table "amoa_amoa_criteria_services", :force => true do |t|
    t.integer "amoa_amoa_criteria_id"
    t.integer "amoa_amoa_service_id"
    t.float   "weight"
  end

  create_table "amoa_amoa_criteria_unit_of_works", :force => true do |t|
    t.integer "amoa_amoa_criteria_id"
    t.integer "amoa_amoa_unit_of_work_id"
    t.integer "quantity"
  end

  create_table "amoa_amoa_criterias", :force => true do |t|
    t.string "name"
  end

  create_table "amoa_amoa_models", :force => true do |t|
    t.string  "name"
    t.float   "three_points_estimation"
    t.integer "organization_id"
  end

  create_table "amoa_amoa_services", :force => true do |t|
    t.string "name"
  end

  create_table "amoa_amoa_unit_of_works", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "tracability"
    t.float   "result"
    t.integer "amoa_amoa_service_id"
  end

  create_table "amoa_amoa_weightings", :force => true do |t|
    t.string  "name"
    t.float   "weight"
    t.integer "amoa_amoa_service_id"
  end

  create_table "amoa_amoa_weightings_unit_of_works", :force => true do |t|
    t.integer "amoa_amoa_weighting_id"
    t.integer "amoa_amoa_unit_of_work_id"
  end

  create_table "applications", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "applications_projects", :id => false, :force => true do |t|
    t.integer "application_id"
    t.integer "project_id"
  end

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
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order"
    t.integer  "guw_model_id"
    t.integer  "operation_model_id"
  end

  create_table "attribute_organizations", :force => true do |t|
    t.integer  "pe_attribute_id"
    t.integer  "organization_id"
    t.boolean  "is_mandatory"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "auth_methods", :force => true do |t|
    t.string   "name"
    t.string   "server_name"
    t.integer  "port"
    t.string   "base_dn"
    t.string   "user_name_attribute"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
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

  create_table "autorization_log_events", :force => true do |t|
    t.integer  "event_organization_id"
    t.integer  "author_id"
    t.string   "item_type"
    t.integer  "item_id"
    t.string   "association_class_name"
    t.string   "event"
    t.text     "object"
    t.string   "object_class_name"
    t.datetime "created_at"
    t.text     "transaction_id"
    t.text     "object_changes"
    t.text     "associations_before_changes"
    t.text     "associations_after_changes"
    t.boolean  "is_estimation_permission"
    t.boolean  "is_model_permission"
    t.boolean  "is_group_security"
    t.boolean  "is_security_on_created_from_model"
    t.integer  "organization_id"
    t.integer  "project_id"
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "estimation_status_id"
    t.integer  "permission_id"
    t.integer  "project_security_id"
    t.integer  "project_security_level_id"
    t.integer  "permissions_project_security_level_id"
    t.integer  "estimation_status_group_role_id"
    t.boolean  "from_direct_trigger"
  end

  create_table "currencies", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.string   "iso_code"
    t.string   "iso_code_number"
    t.string   "sign"
    t.float    "conversion_rate"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimation_status_group_roles", :force => true do |t|
    t.integer  "estimation_status_id"
    t.integer  "group_id"
    t.integer  "project_security_level_id"
    t.integer  "organization_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "estimation_statuses", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "status_number"
    t.string   "status_alias"
    t.string   "name"
    t.string   "status_color"
    t.boolean  "is_archive_status"
    t.text     "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "copy_id"
    t.boolean  "is_new_status"
    t.text     "transaction_id"
  end

  create_table "estimation_values", :force => true do |t|
    t.integer  "organization_id"
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
    t.text     "notes"
    t.integer  "estimation_value_id"
    t.integer  "copy_id"
  end

  add_index "estimation_values", ["links"], :name => "index_attribute_projects_on_links"
  add_index "estimation_values", ["organization_id", "module_project_id", "pe_attribute_id", "in_out"], :name => "organization_estimation_values"

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

  create_table "expert_judgement_instance_estimates", :force => true do |t|
    t.integer "pbs_project_element_id"
    t.integer "module_project_id"
    t.integer "pe_attribute_id"
    t.integer "expert_judgement_instance_id"
    t.float   "low_input"
    t.float   "most_likely_input"
    t.float   "high_input"
    t.float   "low_output"
    t.float   "most_likely_output"
    t.float   "high_output"
    t.text    "description"
    t.text    "comments"
    t.text    "tracking"
  end

  create_table "expert_judgement_instances", :force => true do |t|
    t.string  "name"
    t.integer "organization_id"
    t.text    "description"
    t.string  "cost_unit"
    t.string  "effort_unit"
    t.string  "retained_size_unit"
    t.float   "effort_unit_coefficient"
    t.float   "cost_unit_coefficient"
    t.boolean "three_points_estimation"
    t.boolean "enabled_input"
    t.boolean "enabled_cost"
    t.boolean "enabled_effort"
    t.boolean "enabled_size"
    t.integer "copy_id"
  end

  add_index "expert_judgement_instances", ["organization_id", "name"], :name => "index_expert_judgement_instances_on_organization_id_and_name", :unique => true

  create_table "factor_translations", :force => true do |t|
    t.integer  "factor_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "helps"
  end

  add_index "factor_translations", ["factor_id"], :name => "index_factor_translations_on_factor_id"
  add_index "factor_translations", ["locale"], :name => "index_factor_translations_on_locale"

  create_table "factors", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.string   "state"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.string   "factor_type"
    t.text     "fr_helps"
    t.text     "en_helps"
  end

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.float    "coefficient"
    t.integer  "copy_id"
  end

  create_table "ge_ge_factor_values", :force => true do |t|
    t.string   "factor_name"
    t.string   "factor_alias"
    t.string   "value_text"
    t.float    "value_number"
    t.string   "default"
    t.string   "factor_scale_prod"
    t.string   "factor_type"
    t.integer  "ge_factor_id"
    t.integer  "ge_model_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ge_ge_factors", :force => true do |t|
    t.integer  "ge_model_id"
    t.string   "alias"
    t.string   "scale_prod"
    t.string   "factor_type"
    t.string   "short_name"
    t.string   "long_name"
    t.text     "description"
    t.string   "data_filename"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "copy_id"
  end

  create_table "ge_ge_inputs", :force => true do |t|
    t.string   "formula"
    t.float    "s_factors_value"
    t.float    "p_factors_value"
    t.float    "c_factors_value"
    t.text     "values"
    t.integer  "ge_model_id"
    t.integer  "module_project_id"
    t.integer  "organization_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ge_ge_model_factor_descriptions", :force => true do |t|
    t.integer  "ge_model_id"
    t.integer  "ge_factor_id"
    t.string   "factor_alias"
    t.text     "description"
    t.integer  "organization_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "project_id"
    t.integer  "module_project_id"
  end

  create_table "ge_ge_models", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "coeff_a"
    t.float    "coeff_b"
    t.integer  "organization_id"
    t.string   "input_size_unit"
    t.string   "output_size_unit"
    t.string   "input_effort_unit"
    t.string   "output_effort_unit"
    t.boolean  "three_points_estimation"
    t.float    "output_effort_standard_unit_coefficient"
    t.float    "input_effort_standard_unit_coefficient"
    t.boolean  "enabled_input"
    t.boolean  "modify_theorical_effort"
    t.integer  "copy_id"
    t.integer  "copy_number",                             :default => 0
    t.string   "p_calculation_method"
    t.string   "s_calculation_method"
    t.string   "c_calculation_method"
    t.integer  "input_pe_attribute_id"
    t.integer  "output_pe_attribute_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ent1_unit"
    t.float    "ent1_unit_coefficient",                   :default => 1.0
    t.string   "ent2_unit"
    t.float    "ent2_unit_coefficient",                   :default => 1.0
    t.string   "ent3_unit"
    t.float    "ent3_unit_coefficient",                   :default => 1.0
    t.string   "ent4_unit"
    t.float    "ent4_unit_coefficient",                   :default => 1.0
    t.string   "sort1_unit"
    t.float    "sort1_unit_coefficient",                  :default => 1.0
    t.string   "sort2_unit"
    t.float    "sort2_unit_coefficient",                  :default => 1.0
    t.string   "sort3_unit"
    t.float    "sort3_unit_coefficient",                  :default => 1.0
    t.string   "sort4_unit"
    t.float    "sort4_unit_coefficient",                  :default => 1.0
    t.string   "ge_model_instance_mode",                  :default => "standard"
    t.boolean  "ent1_is_modifiable"
    t.boolean  "ent2_is_modifiable"
    t.boolean  "ent3_is_modifiable"
    t.boolean  "ent4_is_modifiable"
    t.boolean  "sort1_is_modifiable"
    t.boolean  "sort2_is_modifiable"
    t.boolean  "sort3_is_modifiable"
    t.boolean  "sort4_is_modifiable"
  end

  add_index "ge_ge_models", ["organization_id", "name"], :name => "index_ge_ge_models_on_organization_id_and_name", :unique => true

  create_table "groups", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "description"
    t.string   "code_group"
    t.boolean  "for_global_permission"
    t.boolean  "for_project_security"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "copy_id"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "groups_permissions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "groups_projects", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "project_id"
    t.integer "originator_id"
    t.integer "event_organization_id"
    t.text    "transaction_id"
  end

  create_table "groups_users", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "guw_guw_attribute_complexities", :force => true do |t|
    t.string   "name"
    t.integer  "bottom_range"
    t.integer  "top_range"
    t.float    "value"
    t.integer  "guw_type_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "guw_attribute_id"
    t.integer  "guw_type_complexity_id"
    t.boolean  "enable_value"
    t.float    "value_b"
  end

  add_index "guw_guw_attribute_complexities", ["guw_type_id", "guw_attribute_id"], :name => "guw_attribute_complexities"

  create_table "guw_guw_attribute_types", :force => true do |t|
    t.integer  "guw_type_id"
    t.integer  "guw_attribute_id"
    t.float    "default_value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "guw_guw_attributes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "guw_model_id"
    t.integer  "copy_id"
  end

  create_table "guw_guw_coefficient_element_unit_of_works", :force => true do |t|
    t.integer  "guw_unit_of_work_id"
    t.integer  "guw_coefficient_element_id"
    t.integer  "guw_coefficient_id"
    t.float    "percent"
    t.float    "intermediate_value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "module_project_id"
    t.text     "comments"
  end

  add_index "guw_guw_coefficient_element_unit_of_works", ["guw_unit_of_work_id", "guw_coefficient_id", "guw_coefficient_element_id"], :name => "guw_unit_of_work_guw_coefficient_elements"

  create_table "guw_guw_coefficient_elements", :force => true do |t|
    t.string   "name"
    t.integer  "guw_coefficient_id"
    t.float    "value"
    t.integer  "display_order"
    t.integer  "guw_model_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.float    "min_value"
    t.float    "max_value"
    t.float    "default_value"
    t.text     "description"
    t.boolean  "default"
    t.string   "color_code"
    t.integer  "color_priority"
  end

  add_index "guw_guw_coefficient_elements", ["guw_model_id", "guw_coefficient_id", "default"], :name => "guw_coefficient_elements"

  create_table "guw_guw_coefficient_elements_outputs", :force => true do |t|
    t.integer  "guw_coefficient_id"
    t.integer  "guw_guw_coefficient_element_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "guw_guw_coefficients", :force => true do |t|
    t.string   "name"
    t.string   "coefficient_type"
    t.integer  "guw_model_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "coefficient_calc"
    t.boolean  "allow_intermediate_value"
    t.boolean  "deported",                 :default => false
    t.text     "description"
    t.boolean  "allow_comments"
  end

  add_index "guw_guw_coefficients", ["guw_model_id", "name"], :name => "guw_model_guw_coefficients"

  create_table "guw_guw_complexities", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.decimal  "weight",        :precision => 20, :scale => 7
    t.integer  "bottom_range"
    t.integer  "top_range"
    t.integer  "guw_type_id"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "copy_id"
    t.boolean  "enable_value"
    t.integer  "display_order",                                :default => 0
    t.boolean  "default_value"
    t.float    "weight_b"
  end

  add_index "guw_guw_complexities", ["guw_type_id", "name"], :name => "guw_type_complexities"

  create_table "guw_guw_complexity_coefficient_elements", :force => true do |t|
    t.integer  "guw_complexity_id"
    t.integer  "guw_coefficient_element_id"
    t.integer  "guw_output_id"
    t.integer  "guw_type_id"
    t.float    "value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "guw_guw_complexity_coefficient_elements", ["guw_complexity_id", "guw_coefficient_element_id", "guw_output_id"], :name => "guw_complexity_coefficient_elements"

  create_table "guw_guw_complexity_factors", :force => true do |t|
    t.integer  "guw_complexity_id"
    t.integer  "guw_factor_id"
    t.float    "value"
    t.integer  "guw_type_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "guw_output_id"
  end

  create_table "guw_guw_complexity_technologies", :force => true do |t|
    t.integer  "guw_complexity_id"
    t.integer  "organization_technology_id"
    t.float    "coefficient"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "guw_type_id"
  end

  create_table "guw_guw_complexity_weightings", :force => true do |t|
    t.integer  "guw_complexity_id"
    t.integer  "guw_weighting_id"
    t.float    "value"
    t.integer  "guw_type_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "guw_output_id"
  end

  create_table "guw_guw_complexity_work_units", :force => true do |t|
    t.integer  "guw_complexity_id"
    t.integer  "guw_work_unit_id"
    t.float    "value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "guw_type_id"
    t.integer  "guw_output_id"
  end

  create_table "guw_guw_factors", :force => true do |t|
    t.integer  "guw_model_id"
    t.integer  "copy_id"
    t.string   "name"
    t.float    "value"
    t.integer  "display_order"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "guw_guw_models", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "organization_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.boolean  "three_points_estimation"
    t.string   "retained_size_unit"
    t.boolean  "one_level_model"
    t.integer  "copy_id"
    t.integer  "copy_number",                 :default => 0
    t.string   "coefficient_label"
    t.float    "hour_coefficient_conversion"
    t.string   "default_display"
    t.string   "weightings_label"
    t.string   "factors_label"
    t.string   "effort_unit"
    t.string   "cost_unit"
    t.boolean  "allow_technology",            :default => true
    t.string   "work_unit_type"
    t.string   "weighting_type"
    t.string   "factor_type"
    t.float    "work_unit_min"
    t.float    "work_unit_max"
    t.float    "factor_min"
    t.float    "factor_max"
    t.float    "weighting_min"
    t.float    "weighting_max"
    t.text     "orders"
    t.string   "config_type",                 :default => "old"
    t.boolean  "allow_ml"
    t.boolean  "allow_excel"
    t.boolean  "allow_jira"
    t.boolean  "allow_redmine"
    t.string   "excel_ml_server"
    t.string   "jira_ml_server"
    t.string   "redmine_ml_server"
    t.boolean  "allow_ml_excel"
    t.boolean  "allow_ml_jira"
    t.boolean  "allow_ml_redmine"
    t.boolean  "view_data"
  end

  add_index "guw_guw_models", ["organization_id", "name"], :name => "index_guw_guw_models_on_organization_id_and_name", :unique => true

  create_table "guw_guw_output_associations", :force => true do |t|
    t.integer  "guw_output_id"
    t.integer  "guw_output_associated_id"
    t.integer  "guw_complexity_id"
    t.float    "value"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "guw_guw_output_complexities", :force => true do |t|
    t.integer  "guw_output_id"
    t.integer  "guw_complexity_id"
    t.float    "value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "guw_guw_output_complexities", ["guw_complexity_id", "guw_output_id"], :name => "guw_output_complexities"

  create_table "guw_guw_output_complexity_initializations", :force => true do |t|
    t.integer  "guw_output_id"
    t.integer  "guw_complexity_id"
    t.float    "init_value"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "guw_guw_output_complexity_initializations", ["guw_complexity_id", "guw_output_id"], :name => "guw_output_complexity_initializations"

  create_table "guw_guw_output_types", :force => true do |t|
    t.integer  "guw_model_id"
    t.integer  "guw_output_id"
    t.integer  "guw_type_id"
    t.string   "display_type",  :default => "display"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "guw_guw_outputs", :force => true do |t|
    t.string   "name"
    t.string   "output_type"
    t.integer  "guw_model_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.boolean  "allow_intermediate_value"
    t.boolean  "allow_subtotal"
    t.float    "standard_coefficient"
    t.integer  "copy_id"
    t.string   "unit"
    t.integer  "display_order"
    t.string   "color_code"
    t.integer  "color_priority"
  end

  add_index "guw_guw_outputs", ["guw_model_id", "name"], :name => "guw_model_guw_outputs"

  create_table "guw_guw_scale_module_attributes", :force => true do |t|
    t.integer  "guw_model_id"
    t.string   "type_attribute"
    t.string   "type_scale"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "guw_output_id"
    t.integer  "guw_coefficient_id"
  end

  add_index "guw_guw_scale_module_attributes", ["guw_model_id", "type_attribute"], :name => "guw_scale_module_attributes"

  create_table "guw_guw_type_complexities", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "value"
    t.integer  "guw_type_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "copy_id"
    t.integer  "display_order", :default => 0
  end

  create_table "guw_guw_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "organization_technology_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "guw_model_id"
    t.integer  "copy_id"
    t.boolean  "allow_quantity"
    t.boolean  "allow_retained",             :default => true
    t.boolean  "allow_complexity"
    t.boolean  "allow_criteria",             :default => true
    t.boolean  "display_threshold"
    t.string   "attribute_type"
    t.boolean  "is_default"
    t.string   "color_code"
    t.integer  "color_priority"
    t.boolean  "allow_line_color"
  end

  add_index "guw_guw_types", ["guw_model_id", "is_default"], :name => "guw_model_default_guw_types"
  add_index "guw_guw_types", ["guw_model_id", "name"], :name => "guw_model_guw_types"

  create_table "guw_guw_unit_of_work_attributes", :force => true do |t|
    t.integer  "low"
    t.integer  "most_likely"
    t.integer  "high"
    t.integer  "guw_type_id"
    t.integer  "guw_unit_of_work_id"
    t.integer  "guw_attribute_id"
    t.integer  "guw_attribute_complexity_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "comments"
  end

  add_index "guw_guw_unit_of_work_attributes", ["guw_type_id", "guw_attribute_id", "guw_unit_of_work_id"], :name => "guw_unit_of_work_attributes"

  create_table "guw_guw_unit_of_work_groups", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "comments"
    t.integer  "module_project_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "pbs_project_element_id"
    t.string   "notes"
    t.integer  "organization_technology_id"
  end

  add_index "guw_guw_unit_of_work_groups", ["module_project_id", "pbs_project_element_id", "name"], :name => "module_project_guw_groups"

  create_table "guw_guw_unit_of_works", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "comments"
    t.float    "result_low"
    t.float    "result_most_likely"
    t.float    "result_high"
    t.integer  "guw_type_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "guw_complexity_id"
    t.text     "effort"
    t.text     "ajusted_size"
    t.integer  "guw_model_id"
    t.integer  "module_project_id"
    t.integer  "pbs_project_element_id"
    t.integer  "guw_unit_of_work_group_id"
    t.integer  "guw_work_unit_id"
    t.text     "tracking"
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order"
    t.integer  "organization_technology_id"
    t.boolean  "off_line_uo"
    t.float    "quantity"
    t.integer  "guw_weighting_id"
    t.integer  "guw_factor_id"
    t.text     "size"
    t.text     "cost"
    t.integer  "guw_original_complexity_id"
    t.boolean  "missing_value",                 :default => false
    t.float    "intermediate_work_unit_values"
    t.float    "intermediate_weighting_values"
    t.float    "intermediate_factor_values"
    t.float    "work_unit_value"
    t.float    "weighting_value"
    t.float    "factor_value"
    t.float    "intermediate_weight"
    t.float    "intermediate_percent"
    t.string   "url"
    t.text     "cplx_comments"
  end

  add_index "guw_guw_unit_of_works", ["guw_model_id", "module_project_id", "pbs_project_element_id", "guw_unit_of_work_group_id", "guw_type_id", "selected"], :name => "module_project_guw_unit_of_works"

  create_table "guw_guw_weightings", :force => true do |t|
    t.integer  "guw_model_id"
    t.integer  "copy_id"
    t.string   "name"
    t.float    "value"
    t.integer  "display_order"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "guw_guw_work_units", :force => true do |t|
    t.string   "name"
    t.float    "value"
    t.integer  "guw_model_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "copy_id"
    t.integer  "display_order", :default => 0
  end

  create_table "guw_unit_of_work_lines", :id => false, :force => true do |t|
    t.integer  "uow_organization_id",           :default => 0,     :null => false
    t.string   "organization_name"
    t.integer  "uow_project_id",                :default => 0,     :null => false
    t.string   "project_name"
    t.integer  "uow_module_project_id",         :default => 0,     :null => false
    t.integer  "uow_pbs_project_element_id"
    t.integer  "uow_guw_model_id",              :default => 0,     :null => false
    t.string   "uow_guw_model_name"
    t.integer  "guw_uow_group_id"
    t.string   "guw_uow_group_name"
    t.boolean  "uow_selected"
    t.integer  "guw_unit_of_work_id",           :default => 0,     :null => false
    t.integer  "id",                            :default => 0,     :null => false
    t.integer  "organization_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "comments"
    t.float    "result_low"
    t.float    "result_most_likely"
    t.float    "result_high"
    t.integer  "guw_type_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "guw_complexity_id"
    t.text     "effort"
    t.text     "ajusted_size"
    t.integer  "guw_model_id"
    t.integer  "module_project_id"
    t.integer  "pbs_project_element_id"
    t.integer  "guw_unit_of_work_group_id"
    t.integer  "guw_work_unit_id"
    t.text     "tracking"
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order"
    t.integer  "organization_technology_id"
    t.boolean  "off_line_uo"
    t.float    "quantity"
    t.integer  "guw_weighting_id"
    t.integer  "guw_factor_id"
    t.text     "size"
    t.text     "cost"
    t.integer  "guw_original_complexity_id"
    t.boolean  "missing_value",                 :default => false
    t.float    "intermediate_work_unit_values"
    t.float    "intermediate_weighting_values"
    t.float    "intermediate_factor_values"
    t.float    "work_unit_value"
    t.float    "weighting_value"
    t.float    "factor_value"
    t.float    "intermediate_weight"
    t.float    "intermediate_percent"
    t.string   "url"
    t.text     "cplx_comments"
    t.integer  "guw_coefficient_element_id"
    t.integer  "guw_coefficient_id"
    t.float    "percent"
    t.text     "ceuw_comments"
  end

  create_table "input_cocomos", :force => true do |t|
    t.integer  "factor_id"
    t.integer  "organization_uow_complexity_id"
    t.integer  "pbs_project_element_id"
    t.integer  "project_id"
    t.integer  "module_project_id"
    t.float    "coefficient"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.text     "notes"
  end

  create_table "kb_kb_datas", :force => true do |t|
    t.string  "name"
    t.float   "size"
    t.float   "effort"
    t.string  "unit"
    t.text    "custom_attributes"
    t.integer "kb_model_id"
    t.date    "project_date"
  end

  create_table "kb_kb_inputs", :force => true do |t|
    t.string  "formula"
    t.text    "values"
    t.text    "regression"
    t.integer "organization_id"
    t.integer "module_project_id"
    t.integer "kb_model_id"
    t.text    "filters"
  end

  create_table "kb_kb_models", :force => true do |t|
    t.string   "name"
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id"
    t.float    "standard_unit_coefficient"
    t.string   "effort_unit"
    t.text     "selected_attributes"
    t.integer  "copy_number"
    t.integer  "copy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "n_max"
    t.date     "date_max"
    t.date     "date_min"
    t.string   "filter_a"
    t.string   "filter_b"
    t.string   "filter_c"
    t.string   "filter_d"
  end

  add_index "kb_kb_models", ["organization_id", "name"], :name => "index_kb_kb_models_on_organization_id_and_name", :unique => true

  create_table "labor_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
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
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "machine_learnings", :force => true do |t|
    t.string   "username"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "module_project_guw_unit_of_work_groups", :id => false, :force => true do |t|
    t.integer  "uow_organization_id",                           :default => 0, :null => false
    t.string   "organization_name"
    t.integer  "uow_project_id",                                :default => 0, :null => false
    t.string   "project_name"
    t.integer  "uow_group_module_project_id",                   :default => 0, :null => false
    t.integer  "uow_group_pbs_project_element_id"
    t.integer  "guw_unit_of_work_group_id",                     :default => 0, :null => false
    t.integer  "number_of_uow_lines",              :limit => 8
    t.integer  "number_of_uow_selected_lines",     :limit => 8
    t.integer  "id",                                            :default => 0, :null => false
    t.integer  "organization_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "comments"
    t.integer  "module_project_id"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "pbs_project_element_id"
    t.string   "notes"
    t.integer  "organization_technology_id"
  end

  create_table "module_project_guw_unit_of_works", :id => false, :force => true do |t|
    t.integer  "uow_organization_id",           :default => 0,     :null => false
    t.string   "organization_name"
    t.integer  "uow_project_id",                :default => 0,     :null => false
    t.string   "project_name"
    t.integer  "uow_module_project_id",         :default => 0,     :null => false
    t.integer  "uow_pbs_project_element_id"
    t.integer  "uow_guw_model_id",              :default => 0,     :null => false
    t.string   "uow_guw_model_name"
    t.integer  "guw_uow_group_id"
    t.string   "guw_uow_group_name"
    t.boolean  "uow_selected"
    t.integer  "guw_unit_of_work_id",           :default => 0,     :null => false
    t.integer  "id",                            :default => 0,     :null => false
    t.integer  "organization_id"
    t.integer  "project_id"
    t.string   "name"
    t.text     "comments"
    t.float    "result_low"
    t.float    "result_most_likely"
    t.float    "result_high"
    t.integer  "guw_type_id"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "guw_complexity_id"
    t.text     "effort"
    t.text     "ajusted_size"
    t.integer  "guw_model_id"
    t.integer  "module_project_id"
    t.integer  "pbs_project_element_id"
    t.integer  "guw_unit_of_work_group_id"
    t.integer  "guw_work_unit_id"
    t.text     "tracking"
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order"
    t.integer  "organization_technology_id"
    t.boolean  "off_line_uo"
    t.float    "quantity"
    t.integer  "guw_weighting_id"
    t.integer  "guw_factor_id"
    t.text     "size"
    t.text     "cost"
    t.integer  "guw_original_complexity_id"
    t.boolean  "missing_value",                 :default => false
    t.float    "intermediate_work_unit_values"
    t.float    "intermediate_weighting_values"
    t.float    "intermediate_factor_values"
    t.float    "work_unit_value"
    t.float    "weighting_value"
    t.float    "factor_value"
    t.float    "intermediate_weight"
    t.float    "intermediate_percent"
    t.string   "url"
    t.text     "cplx_comments"
  end

  create_table "module_project_ratio_elements", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "pbs_project_element_id"
    t.integer  "module_project_id"
    t.integer  "wbs_activity_id"
    t.integer  "wbs_activity_ratio_id"
    t.integer  "wbs_activity_ratio_element_id"
    t.integer  "wbs_activity_element_id"
    t.boolean  "multiple_references"
    t.string   "name"
    t.boolean  "name_is_modified"
    t.text     "description"
    t.float    "ratio_value"
    t.float    "tjm"
    t.decimal  "theoretical_effort_probable",    :precision => 15, :scale => 5
    t.decimal  "theoretical_cost_probable",      :precision => 20, :scale => 6
    t.decimal  "retained_effort_probable",       :precision => 15, :scale => 5
    t.decimal  "retained_cost_probable",         :precision => 20, :scale => 6
    t.text     "comments"
    t.decimal  "theoretical_effort_low",         :precision => 15, :scale => 5
    t.decimal  "theoretical_effort_high",        :precision => 15, :scale => 5
    t.decimal  "theoretical_effort_most_likely", :precision => 15, :scale => 5
    t.decimal  "theoretical_cost_low",           :precision => 20, :scale => 6
    t.decimal  "theoretical_cost_high",          :precision => 20, :scale => 6
    t.decimal  "theoretical_cost_most_likely",   :precision => 20, :scale => 6
    t.decimal  "retained_effort_low",            :precision => 15, :scale => 5
    t.decimal  "retained_effort_high",           :precision => 15, :scale => 5
    t.decimal  "retained_effort_most_likely",    :precision => 15, :scale => 5
    t.decimal  "retained_cost_low",              :precision => 20, :scale => 6
    t.decimal  "retained_cost_high",             :precision => 20, :scale => 6
    t.decimal  "retained_cost_most_likely",      :precision => 20, :scale => 6
    t.integer  "copy_id"
    t.float    "position"
    t.boolean  "flagged"
    t.boolean  "selected"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.boolean  "is_optional"
    t.string   "ancestry"
    t.string   "phase_short_name"
    t.boolean  "is_just_changed"
  end

  add_index "module_project_ratio_elements", ["ancestry"], :name => "index_module_project_ratio_elements_on_ancestry"
  add_index "module_project_ratio_elements", ["organization_id", "module_project_id", "pbs_project_element_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_element_id"], :name => "organization_module_project_ratio_elements"

  create_table "module_project_ratio_variables", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "wbs_activity_id"
    t.integer  "module_project_id"
    t.integer  "pbs_project_element_id"
    t.integer  "wbs_activity_ratio_id"
    t.integer  "wbs_activity_ratio_variable_id"
    t.string   "name"
    t.text     "description"
    t.string   "percentage_of_input"
    t.float    "value_from_percentage"
    t.boolean  "is_modifiable",                  :default => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.boolean  "is_used_in_ratio_calculation"
  end

  add_index "module_project_ratio_variables", ["organization_id", "module_project_id", "pbs_project_element_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_ratio_variable_id"], :name => "organization_module_project_ratio_variables"

  create_table "module_projects", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "pemodule_id"
    t.integer  "project_id"
    t.integer  "position_x"
    t.integer  "position_y"
    t.float    "top_position"
    t.float    "left_position"
    t.integer  "creation_order"
    t.integer  "nb_input_attr"
    t.integer  "nb_output_attr"
    t.integer  "copy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "view_id"
    t.boolean  "show_results_view",            :default => true
    t.string   "color"
    t.integer  "guw_model_id"
    t.integer  "ge_model_id"
    t.integer  "expert_judgement_instance_id"
    t.integer  "wbs_activity_id"
    t.integer  "wbs_activity_ratio_id"
    t.integer  "staffing_model_id"
    t.integer  "kb_model_id"
    t.integer  "operation_model_id"
    t.integer  "skb_model_id"
  end

  add_index "module_projects", ["organization_id", "pemodule_id", "project_id"], :name => "organization_module_projects"

  create_table "module_projects_pbs_project_elements", :id => false, :force => true do |t|
    t.integer "module_project_id"
    t.integer "pbs_project_element_id"
    t.integer "copy_id"
  end

  create_table "operation_operation_inputs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "in_out"
    t.integer  "operation_model_id"
    t.boolean  "is_modifiable"
    t.float    "standard_unit_coefficient"
    t.string   "standard_unit"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "operation_operation_models", :force => true do |t|
    t.string   "name"
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id"
    t.string   "output_unit"
    t.integer  "standard_unit_coefficient"
    t.string   "operation_type"
    t.integer  "copy_id"
    t.integer  "copy_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "modify_output"
  end

  add_index "operation_operation_models", ["organization_id", "name"], :name => "index_operation_operation_models_on_organization_id_and_name", :unique => true

  create_table "organization_estimations", :id => false, :force => true do |t|
    t.integer  "current_organization_id",               :default => 0,     :null => false
    t.string   "organization_name"
    t.datetime "project_created_date"
    t.integer  "project_id",                            :default => 0,     :null => false
    t.integer  "id",                                    :default => 0,     :null => false
    t.string   "title"
    t.string   "version_number",          :limit => 64, :default => "1.0"
    t.string   "alias"
    t.string   "ancestry"
    t.text     "description"
    t.integer  "estimation_status_id"
    t.string   "state"
    t.date     "start_date"
    t.integer  "organization_id"
    t.integer  "original_model_id"
    t.integer  "project_area_id"
    t.integer  "project_category_id"
    t.integer  "platform_category_id"
    t.integer  "acquisition_category_id"
    t.boolean  "is_model"
    t.integer  "master_anscestry"
    t.integer  "creator_id"
    t.text     "purpose"
    t.text     "level_of_detail"
    t.text     "scope"
    t.integer  "copy_number"
    t.integer  "copy_id"
    t.text     "included_wbs_activities"
    t.boolean  "is_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status_comment"
    t.integer  "application_id"
    t.string   "application_name"
    t.boolean  "private",                               :default => false
    t.boolean  "is_historicized"
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

  create_table "organization_profiles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "description"
    t.float    "cost_per_hour"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "copy_id"
  end

  add_index "organization_profiles", ["organization_id"], :name => "index_organization_profiles_on_organization_id"

  create_table "organization_profiles_wbs_activities", :id => false, :force => true do |t|
    t.integer  "organization_profile_id"
    t.integer  "wbs_activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_profiles_wbs_activities", ["organization_profile_id", "wbs_activity_id"], :name => "wbs_activity_profiles_index", :unique => true
  add_index "organization_profiles_wbs_activities", ["wbs_activity_id", "organization_profile_id"], :name => "wbs_activity_organization_profiles"

  create_table "organization_technologies", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.float    "productivity_ratio"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "state",              :limit => 20
    t.integer  "copy_id"
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
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "display_order"
    t.string   "state",                      :limit => 20
    t.integer  "factor_id"
    t.integer  "unit_of_work_id"
    t.float    "value"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.boolean  "is_default",                               :default => false
    t.integer  "organization_technology_id"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "headband_title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "number_hours_per_day"
    t.float    "number_hours_per_month"
    t.integer  "currency_id"
    t.float    "cost_per_hour"
    t.float    "inflation_rate"
    t.integer  "limit1"
    t.integer  "limit2"
    t.integer  "limit3"
    t.integer  "copy_number",                 :default => 0
    t.integer  "limit4"
    t.float    "limit1_coef"
    t.float    "limit2_coef"
    t.float    "limit3_coef"
    t.float    "limit4_coef"
    t.string   "limit1_unit"
    t.string   "limit2_unit"
    t.string   "limit3_unit"
    t.string   "limit4_unit"
    t.boolean  "is_image_organization"
    t.text     "project_selected_columns"
    t.integer  "estimations_counter"
    t.text     "estimations_counter_history"
    t.boolean  "copy_in_progress"
    t.string   "automatic_quotation_number",  :default => "0"
  end

  create_table "organizations_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.datetime "created_at"
    t.datetime "update_at"
    t.text     "transaction_id"
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
    t.integer  "organization_technology_id"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "pbs_project_elements", ["ancestry"], :name => "index_components_on_ancestry"

  create_table "pe_attributes", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.string   "attr_type"
    t.text     "options"
    t.text     "aggregation"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.integer  "precision"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attribute_category_id"
    t.boolean  "single_entry_attribute"
    t.integer  "guw_model_id"
    t.integer  "operation_model_id"
    t.integer  "operation_input_id"
  end

  add_index "pe_attributes", ["alias"], :name => "index_pe_attributes_on_alias"

  create_table "pe_wbs_projects", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.string   "wbs_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pemodules", :force => true do |t|
    t.string   "title"
    t.string   "alias"
    t.text     "description"
    t.string   "with_activities",          :default => "0"
    t.integer  "type_id"
    t.text     "compliant_component_type"
    t.boolean  "is_typed"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "object_associated"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_permission_project"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias"
    t.boolean  "is_master_permission"
    t.string   "category",              :default => "Admin"
    t.string   "object_type"
    t.text     "transaction_id"
  end

  create_table "permissions_project_security_levels", :force => true do |t|
    t.integer  "permission_id"
    t.integer  "project_security_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
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
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "copy_id"
  end

  create_table "platform_categories_project_areas", :id => false, :force => true do |t|
    t.integer  "platform_category_id"
    t.integer  "project_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "organization_id"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "profiles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "cost_per_hour"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "project_areas", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "copy_id"
  end

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
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "copy_id"
  end

  create_table "project_fields", :force => true do |t|
    t.integer  "project_id"
    t.integer  "field_id"
    t.integer  "views_widget_id"
    t.string   "value"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "project_ressources", :force => true do |t|
    t.string "name"
  end

  create_table "project_securities", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "project_security_level_id"
    t.integer  "group_id"
    t.boolean  "is_model_permission"
    t.boolean  "is_estimation_permission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "project_security_levels", :force => true do |t|
    t.string   "name"
    t.string   "custom_value"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "organization_id"
    t.integer  "copy_id"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  create_table "projects", :force => true do |t|
    t.string   "title"
    t.string   "version_number",                 :limit => 64, :default => "1.0"
    t.string   "alias"
    t.string   "ancestry"
    t.text     "description"
    t.integer  "estimation_status_id"
    t.string   "state"
    t.date     "start_date"
    t.integer  "organization_id"
    t.integer  "original_model_id"
    t.integer  "project_area_id"
    t.integer  "project_category_id"
    t.integer  "platform_category_id"
    t.integer  "acquisition_category_id"
    t.boolean  "is_model"
    t.integer  "master_anscestry"
    t.integer  "creator_id"
    t.text     "purpose"
    t.text     "level_of_detail"
    t.text     "scope"
    t.integer  "copy_number"
    t.integer  "copy_id"
    t.text     "included_wbs_activities"
    t.boolean  "is_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status_comment"
    t.integer  "application_id"
    t.string   "application_name"
    t.boolean  "private",                                      :default => false
    t.boolean  "is_historicized"
    t.integer  "provider_id"
    t.string   "request_number"
    t.boolean  "use_automatic_quotation_number"
    t.string   "business_need"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  add_index "projects", ["ancestry"], :name => "index_projects_on_ancestry"
  add_index "projects", ["organization_id", "is_model", "version_number", "title"], :name => "organization_projects_title_uniqueness", :unique => true
  add_index "projects", ["organization_id", "is_model"], :name => "index_projects_on_organization_id_and_is_model"
  add_index "projects", ["organization_id", "is_model"], :name => "organization_estimation_models"

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "real_size_inputs", :force => true do |t|
    t.integer  "pbs_project_element_id"
    t.integer  "module_project_id"
    t.integer  "size_unit_id"
    t.integer  "size_unit_type_id"
    t.integer  "project_id"
    t.float    "value_low"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.float    "value_most_likely"
    t.float    "value_high"
  end

  create_table "size_unit_type_complexities", :force => true do |t|
    t.integer  "size_unit_type_id"
    t.integer  "organization_uow_complexity_id"
    t.float    "value"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "size_unit_types", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "organization_id"
  end

  create_table "size_units", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
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

  create_table "skb_skb_datas", :force => true do |t|
    t.string  "name"
    t.float   "data"
    t.float   "processing"
    t.integer "skb_model_id"
    t.text    "description"
    t.text    "custom_attributes"
    t.date    "project_date"
  end

  create_table "skb_skb_inputs", :force => true do |t|
    t.float   "data"
    t.float   "processing"
    t.float   "retained_size"
    t.integer "organization_id"
    t.integer "module_project_id"
    t.integer "skb_model_id"
    t.text    "filters"
  end

  create_table "skb_skb_models", :force => true do |t|
    t.string   "name"
    t.string   "size_unit"
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id"
    t.integer  "copy_number"
    t.integer  "copy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "label_x"
    t.string   "label_y"
    t.string   "filter_a"
    t.string   "filter_b"
    t.string   "filter_c"
    t.string   "filter_d"
    t.text     "selected_attributes"
    t.date     "date_min"
    t.date     "date_max"
    t.integer  "n_max"
  end

  add_index "skb_skb_models", ["organization_id", "name"], :name => "index_skb_skb_models_on_organization_id_and_name", :unique => true

  create_table "staffing_staffing_custom_data", :force => true do |t|
    t.integer  "staffing_model_id"
    t.integer  "module_project_id"
    t.integer  "pbs_project_element_id"
    t.string   "staffing_method"
    t.string   "period_unit"
    t.decimal  "standard_effort",                        :precision => 20, :scale => 6
    t.string   "global_effort_type"
    t.decimal  "global_effort_value",                    :precision => 20, :scale => 6
    t.string   "staffing_constraint"
    t.float    "duration"
    t.float    "max_staffing"
    t.float    "t_max_staffing"
    t.float    "mc_donell_coef"
    t.float    "puissance_n"
    t.text     "trapeze_default_values"
    t.text     "trapeze_parameter_values"
    t.float    "form_coef"
    t.float    "difficulty_coef"
    t.float    "coef_a"
    t.float    "coef_b"
    t.float    "coef_a_prime"
    t.float    "coef_b_prime"
    t.float    "calculated_effort"
    t.float    "theoretical_staffing"
    t.float    "calculated_staffing"
    t.text     "chart_actual_coordinates"
    t.integer  "copy_id"
    t.integer  "copy_number"
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.text     "trapeze_chart_theoretical_coordinates"
    t.text     "rayleigh_chart_theoretical_coordinates"
    t.float    "rayleigh_duration"
    t.string   "actuals_based_on"
    t.text     "mcdonnell_chart_theorical_coordinates"
    t.float    "max_staffing_rayleigh"
    t.float    "percent"
  end

  create_table "staffing_staffing_models", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "description"
    t.float    "mc_donell_coef"
    t.float    "puissance_n"
    t.text     "trapeze_default_values"
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "copy_id"
    t.integer  "copy_number"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.float    "standard_unit_coefficient"
    t.string   "effort_unit"
    t.string   "staffing_method"
    t.integer  "effort_week_unit"
    t.string   "config_type"
  end

  add_index "staffing_staffing_models", ["organization_id", "name"], :name => "index_staffing_staffing_models_on_organization_id_and_name", :unique => true

  create_table "status_transitions", :force => true do |t|
    t.integer  "from_transition_status_id"
    t.integer  "to_transition_status_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "subcontractors", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "state",           :limit => 20
  end

  create_table "technologies", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "uuid"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "technology_size_types", :force => true do |t|
    t.integer  "organization_technology_id"
    t.integer  "size_unit_id"
    t.integer  "size_unit_type_id"
    t.integer  "organization_id"
    t.float    "value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "technology_size_units", :force => true do |t|
    t.integer  "size_unit_id"
    t.integer  "organization_technology_id"
    t.integer  "organization_id"
    t.float    "value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "unit_of_works", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "state",           :limit => 20
    t.integer  "display_order"
  end

  create_table "uow_inputs", :force => true do |t|
    t.integer  "module_project_id"
    t.integer  "technology_id"
    t.integer  "unit_of_work_id"
    t.integer  "complexity_id"
    t.string   "flag"
    t.string   "name"
    t.float    "weight"
    t.float    "size_low"
    t.float    "size_most_likely"
    t.float    "size_high"
    t.float    "gross_low"
    t.float    "gross_most_likely"
    t.float    "gross_high"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "pbs_project_element_id"
    t.integer  "size_unit_type_id"
    t.integer  "display_order"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
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
    t.text     "ten_latest_projects"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "object_per_page"
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,     :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        :default => 0,     :null => false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
    t.integer  "number_precision"
    t.boolean  "super_admin",            :default => false
    t.boolean  "password_changed"
    t.text     "description"
    t.datetime "subscription_end_date"
    t.integer  "originator_id"
    t.integer  "event_organization_id"
    t.text     "transaction_id"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["login_name"], :name => "index_users_on_login_name", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "version_associations", :force => true do |t|
    t.integer "version_id"
    t.string  "foreign_key_name", :null => false
    t.integer "foreign_key_id"
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], :name => "index_version_associations_on_foreign_key"
  add_index "version_associations", ["version_id"], :name => "index_version_associations_on_version_id"

  create_table "versions", :force => true do |t|
    t.integer  "organization_id"
    t.boolean  "is_model"
    t.string   "item_type",                         :limit => 191,        :null => false
    t.integer  "item_id",                                                 :null => false
    t.string   "event",                                                   :null => false
    t.string   "whodunnit"
    t.text     "object",                            :limit => 2147483647
    t.datetime "created_at"
    t.integer  "transaction_id"
    t.text     "object_changes",                    :limit => 2147483647
    t.boolean  "is_group_security"
    t.boolean  "is_user_security"
    t.boolean  "is_security_on_model"
    t.boolean  "is_security_on_created_from_model"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["organization_id"], :name => "organization_audit_versions"
  add_index "versions", ["transaction_id"], :name => "index_versions_on_transaction_id"

  create_table "views", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "organization_id"
    t.integer  "pemodule_id"
    t.boolean  "is_reference_view"
    t.boolean  "is_default_view"
    t.integer  "initial_view_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "views_widgets", :force => true do |t|
    t.integer  "view_id"
    t.integer  "widget_id"
    t.string   "name"
    t.integer  "module_project_id"
    t.integer  "estimation_value_id"
    t.integer  "pe_attribute_id"
    t.integer  "pbs_project_element_id"
    t.string   "icon_class"
    t.string   "color"
    t.string   "position_x"
    t.string   "position_y"
    t.string   "width"
    t.string   "height"
    t.string   "widget_type"
    t.boolean  "show_min_max"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "position"
    t.boolean  "show_name"
    t.boolean  "show_wbs_activity_ratio"
    t.boolean  "from_initial_view"
    t.boolean  "is_label_widget"
    t.text     "comment"
    t.boolean  "is_kpi_widget"
    t.text     "equation"
    t.string   "kpi_unit"
    t.boolean  "use_organization_effort_unit"
    t.boolean  "show_tjm"
  end

  add_index "views_widgets", ["module_project_id", "pe_attribute_id", "estimation_value_id"], :name => "module_project_views_widgets"

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
    t.integer  "copy_number",              :default => 0
    t.integer  "copy_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "three_points_estimation"
    t.string   "cost_unit"
    t.float    "cost_unit_coefficient"
    t.string   "effort_unit"
    t.float    "effort_unit_coefficient"
    t.boolean  "enabled_input"
    t.integer  "phases_short_name_number", :default => 0
    t.boolean  "hide_wbs_header"
    t.string   "average_rate_wording"
  end

  add_index "wbs_activities", ["organization_id", "name"], :name => "index_wbs_activities_on_organization_id_and_name", :unique => true
  add_index "wbs_activities", ["organization_id"], :name => "organization_wbs_activities"
  add_index "wbs_activities", ["owner_id"], :name => "index_wbs_activities_on_owner_id"

  create_table "wbs_activity_elements", :force => true do |t|
    t.integer  "organization_id"
    t.string   "uuid"
    t.integer  "wbs_activity_id"
    t.string   "name"
    t.text     "description"
    t.string   "ancestry"
    t.integer  "ancestry_depth",     :default => 0
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "copy_id"
    t.string   "dotted_id"
    t.boolean  "is_root"
    t.string   "master_ancestry"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.float    "position"
    t.string   "phase_short_name"
    t.boolean  "allow_modif_effort"
    t.boolean  "allow_modif_cost"
  end

  add_index "wbs_activity_elements", ["ancestry"], :name => "index_wbs_activity_elements_on_ancestry"
  add_index "wbs_activity_elements", ["organization_id", "wbs_activity_id", "ancestry"], :name => "organization_wbs_activity_elements"
  add_index "wbs_activity_elements", ["wbs_activity_id"], :name => "index_wbs_activity_elements_on_wbs_activity_id"

  create_table "wbs_activity_inputs", :force => true do |t|
    t.integer "wbs_activity_ratio_id"
    t.integer "wbs_activity_id"
    t.integer "module_project_id"
    t.integer "pbs_project_element_id"
    t.text    "comment"
  end

  create_table "wbs_activity_ratio_elements", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "wbs_activity_id"
    t.string   "uuid"
    t.integer  "wbs_activity_ratio_id"
    t.integer  "wbs_activity_element_id"
    t.float    "ratio_value"
    t.boolean  "simple_reference"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.boolean  "multiple_references"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "ancestry"
    t.boolean  "is_optional"
    t.string   "formula"
    t.boolean  "is_modifiable",           :default => false
    t.integer  "copy_id"
    t.boolean  "effort_is_modifiable"
    t.boolean  "cost_is_modifiable"
  end

  add_index "wbs_activity_ratio_elements", ["ancestry"], :name => "index_wbs_activity_ratio_elements_on_ancestry"
  add_index "wbs_activity_ratio_elements", ["organization_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_element_id"], :name => "organization_wbs_activity_ratio_elements"

  create_table "wbs_activity_ratio_profiles", :force => true do |t|
    t.integer  "wbs_activity_ratio_element_id"
    t.integer  "organization_profile_id"
    t.float    "ratio_value"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "ancestry"
  end

  add_index "wbs_activity_ratio_profiles", ["ancestry"], :name => "index_wbs_activity_ratio_profiles_on_ancestry"

  create_table "wbs_activity_ratio_variables", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "wbs_activity_id"
    t.integer  "wbs_activity_ratio_id"
    t.string   "name"
    t.text     "description"
    t.string   "percentage_of_input"
    t.boolean  "is_modifiable",                :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.boolean  "is_used_in_ratio_calculation"
  end

  add_index "wbs_activity_ratio_variables", ["organization_id", "wbs_activity_ratio_id"], :name => "organization_wbs_activity_ratio_variables"

  create_table "wbs_activity_ratios", :force => true do |t|
    t.integer  "organization_id"
    t.string   "uuid"
    t.string   "name"
    t.text     "description"
    t.integer  "wbs_activity_id"
    t.boolean  "do_not_show_cost"
    t.integer  "record_status_id"
    t.string   "custom_value"
    t.text     "change_comment"
    t.integer  "reference_id"
    t.string   "reference_uuid"
    t.integer  "copy_number",                        :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "copy_id"
    t.boolean  "allow_modify_retained_effort"
    t.boolean  "do_not_show_phases_with_zero_value"
    t.boolean  "allow_modify_ratio_reference"
    t.boolean  "allow_add_new_phase"
    t.boolean  "comment_required_if_modifiable"
  end

  add_index "wbs_activity_ratios", ["organization_id", "wbs_activity_id"], :name => "organization_wbs_activity_ratios"

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

  create_table "widgets", :force => true do |t|
    t.string   "name"
    t.string   "icon_class"
    t.string   "color"
    t.integer  "pe_attribute_id"
    t.string   "width"
    t.string   "height"
    t.string   "widget_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "work_element_types", :force => true do |t|
    t.string   "name"
    t.string   "alias"
    t.text     "description"
    t.integer  "project_area_id"
    t.integer  "peicon_id"
    t.string   "custom_value"
    t.integer  "owner_id"
    t.text     "change_comment"
    t.string   "reference_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-TRIGGERSQL)
CREATE TRIGGER user_events AFTER UPDATE ON `users`
FOR EACH ROW
BEGIN
          DECLARE old_value varchar(255);
          DECLARE new_value varchar(255);
          SET
            old_value = OLD.id,
            new_value = NEW.id;

          -- Pour le super_admin
          IF (OLD.super_admin != NEW.super_admin) THEN
            INSERT INTO autorization_log_events SET
              event_organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = CONCAT('{ "super_admin": ', '["', OLD.super_admin, '", "', NEW.super_admin, '"]}'),
              created_at = UTC_TIMESTAMP() ;
          END IF;

          -- Pour le mot de passe
          IF (OLD.encrypted_password != NEW.encrypted_password) THEN
            INSERT INTO autorization_log_events SET
              event_organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = CONCAT('{ "password": ', '["', '...', '", "', 'changement de mot de passe', '"]}'),
              created_at = UTC_TIMESTAMP() ;
          END IF;

          -- Pour le mot de passe
          IF (OLD.email != NEW.email) THEN
            INSERT INTO autorization_log_events SET
              event_organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'User',
              item_id = OLD.id,
              object_class_name = 'User',
              event = 'update',
              object_changes = CONCAT('{ "Email": ', '["', OLD.email, '", "', NEW.email, '"]}'),
              created_at = UTC_TIMESTAMP() ;
          END IF;
        END
  TRIGGERSQL

  create_trigger("groups_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("groups").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          author_id = NEW.originator_id,
          item_type = 'Group',
          item_id = NEW.id,
          object_class_name = 'Group',
          event = 'create',
          object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', ' "description": ', '["', '', '", "', NEW.description, '"]}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_after_update_of_name_description_row_tr", :generated => true, :compatibility => 1).
      on("groups").
      after(:update).
      of(:name, :description) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("groups").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'Group',
        item_id = OLD.id,
        object_class_name = 'Group',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("project_securities_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("project_securities").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM projects WHERE id = NEW.project_id),
          author_id = NEW.originator_id,
          item_type = 'ProjectSecurity',
          item_id = NEW.project_id,
          project_id = NEW.project_id,
          group_id = NEW.group_id,
          user_id = NEW.user_id,
          project_security_level_id = NEW.project_security_level_id,
          is_model_permission = NEW.is_model_permission,
          is_estimation_permission = NEW.is_estimation_permission,
          object_class_name = 'Project',
          association_class_name = 'EstimationStatusGroupRole',
          event = 'create',
          object_changes = CONCAT('{ "project_id": ', NEW.project_id, ',', ' "project_security_level_id": ', NEW.project_security_level_id,
                                      ' "group_id": ', NEW.group_id,
                                      ' "user_id": ', NEW.user_id,
                                      ' "is_model_permission": ', NEW.is_model_permission,
                                      ' "is_estimation_permission": ', NEW.is_estimation_permission,
                                 '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("project_securities_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("project_securities").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM projects WHERE id = OLD.project_id),
        transaction_id = (SELECT transaction_id FROM projects WHERE id = OLD.project_id),
        author_id = OLD.originator_id,
        item_type = 'ProjectSecurity',
        item_id = OLD.project_id,
        project_id = OLD.project_id,
        group_id = OLD.group_id,
        user_id = OLD.user_id,
        project_security_level_id = OLD.project_security_level_id,
        is_model_permission = OLD.is_model_permission,
        is_estimation_permission = OLD.is_estimation_permission,
        object_class_name = 'Project',
        association_class_name = 'EstimationStatusGroupRole',
        event = 'delete',
        object_changes = CONCAT('{ "project_id": ', OLD.project_id, ',', ' "project_security_level_id": ', OLD.project_security_level_id,
                                    ' "group_id": ', OLD.group_id,
                                    ' "user_id": ', OLD.user_id,
                                    ' "is_model_permission": ', OLD.is_model_permission,
                                    ' "is_estimation_permission": ', OLD.is_estimation_permission,
                          '}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("project_security_levels_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("project_security_levels").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = NEW.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'create',
        object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', '"description": ', '["', '', '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("project_security_levels_after_update_of_name_description_row_tr", :generated => true, :compatibility => 1).
      on("project_security_levels").
      after(:update).
      of(:name, :description) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = NEW.event_organization_id,
        author_id = NEW.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'update',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("project_security_levels_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("project_security_levels").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.event_organization_id,
        author_id = OLD.originator_id,
        item_type = 'ProjectSecurityLevel',
        item_id = OLD.id,
        object_class_name = 'ProjectSecurityLevel',
        event = 'delete',
        object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("estimation_status_group_roles_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("estimation_status_group_roles").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM estimation_statuses WHERE id = NEW.estimation_status_id),
          author_id = NEW.originator_id,
          item_type = 'EstimationStatusGroupRole',
          item_id = NEW.estimation_status_id,
          estimation_status_id = NEW.estimation_status_id,
          group_id = NEW.group_id,
          project_security_level_id = NEW.project_security_level_id,
          object_class_name = 'EstimationStatus',
          association_class_name = 'EstimationStatusGroupRole',
          event = 'create',
          object_changes = CONCAT('{ "estimation_status_id": ', NEW.estimation_status_id, ',',
                                      ' "project_security_level_id": ', NEW.project_security_level_id,
                                      ' "group_id": ', NEW.group_id,
                               '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("estimation_status_group_roles_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("estimation_status_group_roles").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM estimation_statuses WHERE id = OLD.estimation_status_id),
        transaction_id = (SELECT transaction_id FROM estimation_statuses WHERE id = OLD.estimation_status_id),
        author_id = OLD.originator_id,
        item_type = 'EstimationStatusGroupRole',
        item_id = OLD.estimation_status_id,
        group_id = OLD.group_id,
        project_security_level_id = OLD.project_security_level_id,
        object_class_name = 'EstimationStatus',
        association_class_name = 'EstimationStatusGroupRole',
        event = 'delete',
          object_changes = CONCAT('{ "estimation_status_id": ', OLD.estimation_status_id, ',',
                                      ' "project_security_level_id": ', OLD.project_security_level_id,
                                      ' "group_id": ', OLD.group_id,
                               '}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_permissions_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("groups_permissions").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM groups WHERE id = NEW.group_id),
          author_id = NEW.originator_id,
          item_type = 'GroupPermission',
          item_id = NEW.group_id,
          group_id = NEW.group_id,
          permission_id = NEW.permission_id,
          object_class_name = 'Group',
          association_class_name = 'Permission',
          event = 'create',
          object_changes = CONCAT('{ "group_id": ', NEW.group_id, ',', ' "permission_id": ', NEW.permission_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_permissions_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("groups_permissions").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM groups WHERE id = OLD.group_id),
        transaction_id = (SELECT transaction_id FROM groups WHERE id = OLD.group_id),
        author_id = OLD.originator_id,
        item_type = 'GroupPermission',
        item_id = OLD.group_id,
        group_id = OLD.group_id,
        permission_id = OLD.permission_id,
        object_class_name = 'Group',
        association_class_name = 'Permission',
        event = 'delete',
        object_changes = CONCAT('{ "group_id": ', OLD.group_id, ',', ' "permission_id": ', OLD.permission_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_users_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("groups_users").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM users WHERE id = NEW.user_id),
          author_id = NEW.originator_id,
          item_type = 'GroupUser',
          item_id = NEW.user_id,
          user_id = NEW.user_id,
          group_id = NEW.group_id,
          object_class_name = 'User',
          association_class_name = 'Group',
          event = 'create',
          object_changes = CONCAT('{ "user_id": ', NEW.user_id, ',', ' "group_id": ', NEW.group_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("groups_users_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("groups_users").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM groups WHERE id = OLD.group_id),
        transaction_id = (SELECT transaction_id FROM users WHERE id = OLD.user_id),
        author_id = OLD.originator_id,
        item_type = 'GroupUser',
        item_id = OLD.user_id,
        user_id = OLD.user_id,
        group_id = OLD.group_id,
        object_class_name = 'User',
        association_class_name = 'Group',
        event = 'delete',
        object_changes = CONCAT('{ "user_id": ', OLD.user_id, ',', ' "group_id": ', OLD.group_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("organizations_users_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("organizations_users").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM users WHERE id = NEW.user_id),
          author_id = NEW.originator_id,
          item_type = 'OrganizationUser',
          item_id = NEW.user_id,
          user_id = NEW.user_id,
          organization_id = NEW.organization_id,
          object_class_name = 'User',
          association_class_name = 'Organization',
          event = 'create',
          object_changes = CONCAT('{ "user_id": ', NEW.user_id, ',', ' "organization_id": ', NEW.organization_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("organizations_users_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("organizations_users").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = OLD.organization_id,
          transaction_id = (SELECT transaction_id FROM users WHERE id = OLD.user_id),
          author_id = OLD.originator_id,
          item_type = 'OrganizationUser',
          item_id = OLD.user_id,
          user_id = OLD.user_id,
          organization_id = OLD.organization_id,
          object_class_name = 'User',
          association_class_name = 'Organization',
          event = 'delete',
          object_changes = CONCAT('{ "user_id": ', OLD.user_id, ',', ' "organization_id": ', OLD.organization_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("permissions_project_security_levels_after_insert_row_tr", :generated => true, :compatibility => 1).
      on("permissions_project_security_levels").
      after(:insert) do
    <<-SQL_ACTIONS

      INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          transaction_id = (SELECT transaction_id FROM project_security_levels WHERE id = NEW.project_security_level_id),
          author_id = NEW.originator_id,
          item_type = 'PermissionProjectSecurityLevel',
          item_id = NEW.project_security_level_id,
          project_security_level_id = NEW.project_security_level_id,
          permission_id = NEW.permission_id,
          object_class_name = 'ProjectSecurityLevel',
          association_class_name = 'Permission',
          event = 'create',
          object_changes = CONCAT('{ "permission_id": ', NEW.permission_id, ',', ' "project_security_level_id": ', NEW.project_security_level_id, '}'),
          created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

  create_trigger("permissions_project_security_levels_after_delete_row_tr", :generated => true, :compatibility => 1).
      on("permissions_project_security_levels").
      after(:delete) do
    <<-SQL_ACTIONS
      INSERT INTO autorization_log_events SET
        event_organization_id = (SELECT organization_id FROM project_security_levels WHERE id = OLD.project_security_level_id),
        transaction_id = (SELECT transaction_id FROM project_security_levels WHERE id = OLD.project_security_level_id),
        author_id = OLD.originator_id,
        item_type = 'PermissionProjectSecurityLevel',
        item_id = OLD.project_security_level_id,
        project_security_level_id = OLD.project_security_level_id,
        permission_id = OLD.permission_id,
        object_class_name = 'ProjectSecurityLevel',
        association_class_name = 'Permission',
        event = 'delete',
        object_changes = CONCAT('{ "permission_id": ', OLD.permission_id, ',', ' "project_security_level_id": ', OLD.project_security_level_id, '}'),
        created_at = UTC_TIMESTAMP();
    SQL_ACTIONS
  end

end
