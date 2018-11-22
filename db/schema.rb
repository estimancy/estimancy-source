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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181120144254) do

  create_table "abacus_organizations", force: :cascade do |t|
    t.float    "value",                          limit: 24
    t.integer  "unit_of_work_id",                limit: 4
    t.integer  "organization_uow_complexity_id", limit: 4
    t.integer  "organization_technology_id",     limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "organization_id",                limit: 4
    t.integer  "factor_id",                      limit: 4
  end

  create_table "acquisition_categories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.integer  "copy_id",         limit: 4
  end

  create_table "acquisition_categories_project_areas", id: false, force: :cascade do |t|
    t.integer  "acquisition_category_id", limit: 4
    t.integer  "project_area_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_settings", force: :cascade do |t|
    t.string   "key",            limit: 255
    t.text     "value",          limit: 65535
    t.string   "custom_value",   limit: 255
    t.integer  "owner_id",       limit: 4
    t.text     "change_comment", limit: 65535
    t.string   "reference_uuid", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",    limit: 65535
    t.string   "category",       limit: 255
  end

  create_table "applications", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_ignored"
  end

  create_table "applications_projects", id: false, force: :cascade do |t|
    t.integer "application_id", limit: 4
    t.integer "project_id",     limit: 4
  end

  create_table "associated_module_projects", id: false, force: :cascade do |t|
    t.integer "associated_module_project_id", limit: 4
    t.integer "module_project_id",            limit: 4
  end

  create_table "attribute_categories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "alias",            limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
  end

  create_table "attribute_modules", force: :cascade do |t|
    t.integer  "pe_attribute_id",     limit: 4
    t.integer  "pemodule_id",         limit: 4
    t.boolean  "is_mandatory",                      default: false
    t.string   "in_out",              limit: 255
    t.text     "description",         limit: 65535
    t.string   "default_low",         limit: 255
    t.string   "default_most_likely", limit: 255
    t.string   "default_high",        limit: 255
    t.integer  "dimensions",          limit: 4
    t.string   "custom_attribute",    limit: 255
    t.string   "project_value",       limit: 255
    t.string   "custom_value",        limit: 255
    t.integer  "owner_id",            limit: 4
    t.text     "change_comment",      limit: 65535
    t.string   "reference_uuid",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",       limit: 4
    t.integer  "guw_model_id",        limit: 4
    t.integer  "operation_model_id",  limit: 4
  end

  create_table "attribute_organizations", force: :cascade do |t|
    t.integer  "pe_attribute_id", limit: 4
    t.integer  "organization_id", limit: 4
    t.boolean  "is_mandatory"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "auth_methods", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.string   "server_name",                  limit: 255
    t.integer  "port",                         limit: 4
    t.string   "base_dn",                      limit: 255
    t.string   "user_name_attribute",          limit: 255
    t.string   "custom_value",                 limit: 255
    t.integer  "owner_id",                     limit: 4
    t.text     "change_comment",               limit: 65535
    t.string   "reference_uuid",               limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.boolean  "on_the_fly_user_creation",                   default: false
    t.string   "ldap_bind_dn",                 limit: 255
    t.string   "ldap_bind_encrypted_password", limit: 255
    t.string   "ldap_bind_salt",               limit: 255
    t.integer  "priority_order",               limit: 4,     default: 1
    t.string   "first_name_attribute",         limit: 255
    t.string   "last_name_attribute",          limit: 255
    t.string   "email_attribute",              limit: 255
    t.string   "initials_attribute",           limit: 255
    t.string   "encryption",                   limit: 255
  end

  create_table "autorization_log_events", force: :cascade do |t|
    t.integer  "event_organization_id",                 limit: 4
    t.integer  "author_id",                             limit: 4
    t.string   "item_type",                             limit: 255
    t.integer  "item_id",                               limit: 4
    t.string   "association_class_name",                limit: 255
    t.string   "event",                                 limit: 255
    t.text     "object",                                limit: 65535
    t.string   "object_class_name",                     limit: 255
    t.datetime "created_at"
    t.text     "transaction_id",                        limit: 65535
    t.text     "object_changes",                        limit: 65535
    t.text     "associations_before_changes",           limit: 65535
    t.text     "associations_after_changes",            limit: 65535
    t.boolean  "is_estimation_permission"
    t.boolean  "is_model_permission"
    t.boolean  "is_group_security"
    t.boolean  "is_security_on_created_from_model"
    t.integer  "organization_id",                       limit: 4
    t.integer  "project_id",                            limit: 4
    t.boolean  "is_model"
    t.integer  "group_id",                              limit: 4
    t.integer  "user_id",                               limit: 4
    t.integer  "estimation_status_id",                  limit: 4
    t.integer  "permission_id",                         limit: 4
    t.integer  "project_security_id",                   limit: 4
    t.integer  "project_security_level_id",             limit: 4
    t.integer  "permissions_project_security_level_id", limit: 4
    t.integer  "estimation_status_group_role_id",       limit: 4
    t.boolean  "from_direct_trigger"
  end

  create_table "budgets", force: :cascade do |t|
    t.integer  "organization_id",         limit: 4
    t.integer  "application_id",          limit: 4
    t.integer  "project_area_id",         limit: 4
    t.integer  "acquisition_category_id", limit: 4
    t.integer  "platform_category_id",    limit: 4
    t.integer  "project_category_id",     limit: 4
    t.integer  "provider_id",             limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "alias",           limit: 255
    t.text     "description",     limit: 65535
    t.string   "iso_code",        limit: 255
    t.string   "iso_code_number", limit: 255
    t.string   "sign",            limit: 255
    t.float    "conversion_rate", limit: 24
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimation_status_group_roles", force: :cascade do |t|
    t.integer  "estimation_status_id",      limit: 4
    t.integer  "group_id",                  limit: 4
    t.integer  "project_security_level_id", limit: 4
    t.integer  "organization_id",           limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "originator_id",             limit: 4
    t.integer  "event_organization_id",     limit: 4
    t.text     "transaction_id",            limit: 65535
  end

  create_table "estimation_statuses", force: :cascade do |t|
    t.integer  "organization_id",                         limit: 4
    t.integer  "status_number",                           limit: 4
    t.string   "status_alias",                            limit: 255
    t.string   "name",                                    limit: 255
    t.string   "status_color",                            limit: 255
    t.boolean  "is_archive_status"
    t.text     "description",                             limit: 65535
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "copy_id",                                 limit: 4
    t.boolean  "is_new_status"
    t.text     "transaction_id",                          limit: 65535
    t.boolean  "create_new_version_when_changing_status"
  end

  create_table "estimation_values", force: :cascade do |t|
    t.integer  "organization_id",         limit: 4
    t.integer  "module_project_id",       limit: 4
    t.integer  "pe_attribute_id",         limit: 4
    t.text     "string_data_low",         limit: 65535
    t.text     "string_data_most_likely", limit: 65535
    t.text     "string_data_high",        limit: 65535
    t.text     "string_data_probable",    limit: 65535
    t.date     "date_data_probable"
    t.string   "links",                   limit: 255
    t.boolean  "is_mandatory"
    t.string   "in_out",                  limit: 255
    t.text     "description",             limit: 65535
    t.string   "custom_attribute",        limit: 255
    t.string   "project_value",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",           limit: 4
    t.text     "notes",                   limit: 65535
    t.integer  "estimation_value_id",     limit: 4
    t.integer  "copy_id",                 limit: 4
  end

  add_index "estimation_values", ["links"], name: "index_attribute_projects_on_links", using: :btree
  add_index "estimation_values", ["organization_id", "module_project_id", "pe_attribute_id", "in_out"], name: "organization_estimation_values", using: :btree

  create_table "expert_judgement_instance_estimates", force: :cascade do |t|
    t.integer "pbs_project_element_id",       limit: 4
    t.integer "module_project_id",            limit: 4
    t.integer "pe_attribute_id",              limit: 4
    t.integer "expert_judgement_instance_id", limit: 4
    t.float   "low_input",                    limit: 24
    t.float   "most_likely_input",            limit: 24
    t.float   "high_input",                   limit: 24
    t.float   "low_output",                   limit: 24
    t.float   "most_likely_output",           limit: 24
    t.float   "high_output",                  limit: 24
    t.text    "description",                  limit: 65535
    t.text    "comments",                     limit: 65535
    t.text    "tracking",                     limit: 65535
  end

  create_table "expert_judgement_instances", force: :cascade do |t|
    t.string  "name",                    limit: 255
    t.integer "organization_id",         limit: 4
    t.text    "description",             limit: 65535
    t.string  "cost_unit",               limit: 255
    t.string  "effort_unit",             limit: 255
    t.string  "retained_size_unit",      limit: 255
    t.float   "effort_unit_coefficient", limit: 24
    t.float   "cost_unit_coefficient",   limit: 24
    t.boolean "three_points_estimation"
    t.boolean "enabled_input"
    t.boolean "enabled_cost"
    t.boolean "enabled_effort"
    t.boolean "enabled_size"
    t.integer "copy_id",                 limit: 4
  end

  add_index "expert_judgement_instances", ["organization_id", "name"], name: "index_expert_judgement_instances_on_organization_id_and_name", unique: true, using: :btree

  create_table "factors", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "alias",            limit: 255
    t.text     "description",      limit: 65535
    t.string   "state",            limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
    t.string   "factor_type",      limit: 255
    t.text     "fr_helps",         limit: 65535
    t.text     "en_helps",         limit: 65535
  end

  create_table "fields", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.float    "coefficient",     limit: 24
    t.integer  "copy_id",         limit: 4
  end

  create_table "ge_ge_factor_values", force: :cascade do |t|
    t.string   "factor_name",       limit: 255
    t.string   "factor_alias",      limit: 255
    t.string   "value_text",        limit: 255
    t.float    "value_number",      limit: 24
    t.string   "default",           limit: 255
    t.string   "factor_scale_prod", limit: 255
    t.string   "factor_type",       limit: 255
    t.integer  "ge_factor_id",      limit: 4
    t.integer  "ge_model_id",       limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "ge_ge_factors", force: :cascade do |t|
    t.integer  "ge_model_id",   limit: 4
    t.string   "alias",         limit: 255
    t.string   "scale_prod",    limit: 255
    t.string   "factor_type",   limit: 255
    t.string   "short_name",    limit: 255
    t.string   "long_name",     limit: 255
    t.text     "description",   limit: 65535
    t.string   "data_filename", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "copy_id",       limit: 4
  end

  create_table "ge_ge_inputs", force: :cascade do |t|
    t.string   "formula",           limit: 255
    t.float    "s_factors_value",   limit: 24
    t.float    "p_factors_value",   limit: 24
    t.float    "c_factors_value",   limit: 24
    t.text     "values",            limit: 65535
    t.integer  "ge_model_id",       limit: 4
    t.integer  "module_project_id", limit: 4
    t.integer  "organization_id",   limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "ge_ge_model_factor_descriptions", force: :cascade do |t|
    t.integer  "ge_model_id",       limit: 4
    t.integer  "ge_factor_id",      limit: 4
    t.string   "factor_alias",      limit: 255
    t.text     "description",       limit: 65535
    t.integer  "organization_id",   limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "project_id",        limit: 4
    t.integer  "module_project_id", limit: 4
  end

  create_table "ge_ge_models", force: :cascade do |t|
    t.string   "name",                                    limit: 255
    t.text     "description",                             limit: 65535
    t.float    "coeff_a",                                 limit: 24
    t.float    "coeff_b",                                 limit: 24
    t.integer  "organization_id",                         limit: 4
    t.string   "input_size_unit",                         limit: 255
    t.string   "output_size_unit",                        limit: 255
    t.string   "input_effort_unit",                       limit: 255
    t.string   "output_effort_unit",                      limit: 255
    t.boolean  "three_points_estimation"
    t.float    "output_effort_standard_unit_coefficient", limit: 24
    t.float    "input_effort_standard_unit_coefficient",  limit: 24
    t.boolean  "enabled_input"
    t.boolean  "modify_theorical_effort"
    t.integer  "copy_id",                                 limit: 4
    t.integer  "copy_number",                             limit: 4,     default: 0
    t.string   "p_calculation_method",                    limit: 255
    t.string   "s_calculation_method",                    limit: 255
    t.string   "c_calculation_method",                    limit: 255
    t.integer  "input_pe_attribute_id",                   limit: 4
    t.integer  "output_pe_attribute_id",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ent1_unit",                               limit: 255
    t.float    "ent1_unit_coefficient",                   limit: 24,    default: 1.0
    t.string   "ent2_unit",                               limit: 255
    t.float    "ent2_unit_coefficient",                   limit: 24,    default: 1.0
    t.string   "ent3_unit",                               limit: 255
    t.float    "ent3_unit_coefficient",                   limit: 24,    default: 1.0
    t.string   "ent4_unit",                               limit: 255
    t.float    "ent4_unit_coefficient",                   limit: 24,    default: 1.0
    t.string   "sort1_unit",                              limit: 255
    t.float    "sort1_unit_coefficient",                  limit: 24,    default: 1.0
    t.string   "sort2_unit",                              limit: 255
    t.float    "sort2_unit_coefficient",                  limit: 24,    default: 1.0
    t.string   "sort3_unit",                              limit: 255
    t.float    "sort3_unit_coefficient",                  limit: 24,    default: 1.0
    t.string   "sort4_unit",                              limit: 255
    t.float    "sort4_unit_coefficient",                  limit: 24,    default: 1.0
    t.string   "ge_model_instance_mode",                  limit: 255,   default: "standard"
    t.boolean  "ent1_is_modifiable"
    t.boolean  "ent2_is_modifiable"
    t.boolean  "ent3_is_modifiable"
    t.boolean  "ent4_is_modifiable"
    t.boolean  "sort1_is_modifiable"
    t.boolean  "sort2_is_modifiable"
    t.boolean  "sort3_is_modifiable"
    t.boolean  "sort4_is_modifiable"
  end

  add_index "ge_ge_models", ["organization_id", "name"], name: "index_ge_ge_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "organization_id",       limit: 4
    t.string   "name",                  limit: 255
    t.text     "description",           limit: 65535
    t.string   "code_group",            limit: 255
    t.boolean  "for_global_permission"
    t.boolean  "for_project_security"
    t.string   "custom_value",          limit: 255
    t.integer  "owner_id",              limit: 4
    t.text     "change_comment",        limit: 65535
    t.string   "reference_uuid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "copy_id",               limit: 4
    t.integer  "originator_id",         limit: 4
    t.integer  "event_organization_id", limit: 4
    t.text     "transaction_id",        limit: 65535
    t.boolean  "is_protected_group"
  end

  create_table "groups_permissions", force: :cascade do |t|
    t.integer  "group_id",              limit: 4
    t.integer  "permission_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id",         limit: 4
    t.integer  "event_organization_id", limit: 4
    t.text     "transaction_id",        limit: 65535
  end

  create_table "groups_projects", id: false, force: :cascade do |t|
    t.integer "group_id",              limit: 4
    t.integer "project_id",            limit: 4
    t.integer "originator_id",         limit: 4
    t.integer "event_organization_id", limit: 4
    t.text    "transaction_id",        limit: 65535
  end

  create_table "groups_users", force: :cascade do |t|
    t.integer  "group_id",              limit: 4
    t.integer  "user_id",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id",         limit: 4
    t.integer  "event_organization_id", limit: 4
    t.text     "transaction_id",        limit: 65535
  end

  create_table "guw_guw_attribute_complexities", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.integer  "bottom_range",           limit: 4
    t.integer  "top_range",              limit: 4
    t.float    "value",                  limit: 24
    t.integer  "guw_type_id",            limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "guw_attribute_id",       limit: 4
    t.integer  "guw_type_complexity_id", limit: 4
    t.boolean  "enable_value"
    t.float    "value_b",                limit: 24
  end

  add_index "guw_guw_attribute_complexities", ["guw_type_id", "guw_attribute_id"], name: "guw_attribute_complexities", using: :btree

  create_table "guw_guw_attribute_types", force: :cascade do |t|
    t.integer  "guw_type_id",      limit: 4
    t.integer  "guw_attribute_id", limit: 4
    t.float    "default_value",    limit: 24
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "guw_guw_attributes", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description",  limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "guw_model_id", limit: 4
    t.integer  "copy_id",      limit: 4
  end

  create_table "guw_guw_coefficient_element_unit_of_works", force: :cascade do |t|
    t.integer  "guw_unit_of_work_id",        limit: 4
    t.integer  "guw_coefficient_element_id", limit: 4
    t.integer  "guw_coefficient_id",         limit: 4
    t.float    "percent",                    limit: 24
    t.float    "intermediate_value",         limit: 24
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "module_project_id",          limit: 4
    t.text     "comments",                   limit: 65535
    t.integer  "copy_id",                    limit: 4
  end

  add_index "guw_guw_coefficient_element_unit_of_works", ["guw_unit_of_work_id", "guw_coefficient_id", "guw_coefficient_element_id"], name: "guw_unit_of_work_guw_coefficient_elements", using: :btree

  create_table "guw_guw_coefficient_elements", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.integer  "guw_coefficient_id",    limit: 4
    t.float    "value",                 limit: 24
    t.integer  "display_order",         limit: 4
    t.integer  "guw_model_id",          limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.float    "min_value",             limit: 24
    t.float    "max_value",             limit: 24
    t.float    "default_value",         limit: 24
    t.text     "description",           limit: 65535
    t.boolean  "default"
    t.string   "color_code",            limit: 255
    t.integer  "color_priority",        limit: 4
    t.float    "default_display_value", limit: 24
  end

  add_index "guw_guw_coefficient_elements", ["guw_model_id", "guw_coefficient_id", "default"], name: "guw_coefficient_elements", using: :btree

  create_table "guw_guw_coefficient_elements_outputs", force: :cascade do |t|
    t.integer  "guw_coefficient_id",             limit: 4
    t.integer  "guw_guw_coefficient_element_id", limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "guw_guw_coefficients", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.string   "coefficient_type",         limit: 255
    t.integer  "guw_model_id",             limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "coefficient_calc",         limit: 255
    t.boolean  "allow_intermediate_value"
    t.boolean  "deported",                               default: false
    t.text     "description",              limit: 65535
    t.boolean  "allow_comments"
  end

  add_index "guw_guw_coefficients", ["guw_model_id", "name"], name: "guw_model_guw_coefficients", using: :btree

  create_table "guw_guw_complexities", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "alias",         limit: 255
    t.decimal  "weight",                    precision: 20, scale: 7
    t.integer  "bottom_range",  limit: 4
    t.integer  "top_range",     limit: 4
    t.integer  "guw_type_id",   limit: 4
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "copy_id",       limit: 4
    t.boolean  "enable_value"
    t.integer  "display_order", limit: 4,                            default: 0
    t.boolean  "default_value"
    t.float    "weight_b",      limit: 24
  end

  add_index "guw_guw_complexities", ["guw_type_id", "name"], name: "guw_type_complexities", using: :btree

  create_table "guw_guw_complexity_coefficient_elements", force: :cascade do |t|
    t.integer  "guw_complexity_id",          limit: 4
    t.integer  "guw_coefficient_element_id", limit: 4
    t.integer  "guw_output_id",              limit: 4
    t.integer  "guw_type_id",                limit: 4
    t.float    "value",                      limit: 24
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "guw_guw_complexity_coefficient_elements", ["guw_complexity_id", "guw_coefficient_element_id", "guw_output_id"], name: "guw_complexity_coefficient_elements", using: :btree

  create_table "guw_guw_complexity_factors", force: :cascade do |t|
    t.integer  "guw_complexity_id", limit: 4
    t.integer  "guw_factor_id",     limit: 4
    t.float    "value",             limit: 24
    t.integer  "guw_type_id",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "guw_output_id",     limit: 4
  end

  create_table "guw_guw_complexity_technologies", force: :cascade do |t|
    t.integer  "guw_complexity_id",          limit: 4
    t.integer  "organization_technology_id", limit: 4
    t.float    "coefficient",                limit: 24
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "guw_type_id",                limit: 4
  end

  create_table "guw_guw_complexity_weightings", force: :cascade do |t|
    t.integer  "guw_complexity_id", limit: 4
    t.integer  "guw_weighting_id",  limit: 4
    t.float    "value",             limit: 24
    t.integer  "guw_type_id",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "guw_output_id",     limit: 4
  end

  create_table "guw_guw_complexity_work_units", force: :cascade do |t|
    t.integer  "guw_complexity_id", limit: 4
    t.integer  "guw_work_unit_id",  limit: 4
    t.float    "value",             limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "guw_type_id",       limit: 4
    t.integer  "guw_output_id",     limit: 4
  end

  create_table "guw_guw_factors", force: :cascade do |t|
    t.integer  "guw_model_id",  limit: 4
    t.integer  "copy_id",       limit: 4
    t.string   "name",          limit: 255
    t.float    "value",         limit: 24
    t.integer  "display_order", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "guw_guw_models", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.text     "description",                 limit: 65535
    t.integer  "organization_id",             limit: 4
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "three_points_estimation"
    t.string   "retained_size_unit",          limit: 255
    t.boolean  "one_level_model"
    t.integer  "copy_id",                     limit: 4
    t.integer  "copy_number",                 limit: 4,     default: 0
    t.string   "coefficient_label",           limit: 255
    t.float    "hour_coefficient_conversion", limit: 24
    t.string   "default_display",             limit: 255
    t.string   "weightings_label",            limit: 255
    t.string   "factors_label",               limit: 255
    t.string   "effort_unit",                 limit: 255
    t.string   "cost_unit",                   limit: 255
    t.boolean  "allow_technology",                          default: true
    t.string   "work_unit_type",              limit: 255
    t.string   "weighting_type",              limit: 255
    t.string   "factor_type",                 limit: 255
    t.float    "work_unit_min",               limit: 24
    t.float    "work_unit_max",               limit: 24
    t.float    "factor_min",                  limit: 24
    t.float    "factor_max",                  limit: 24
    t.float    "weighting_min",               limit: 24
    t.float    "weighting_max",               limit: 24
    t.text     "orders",                      limit: 65535
    t.string   "config_type",                 limit: 255,   default: "old"
    t.boolean  "allow_ml"
    t.boolean  "allow_excel"
    t.boolean  "allow_jira"
    t.boolean  "allow_redmine"
    t.string   "excel_ml_server",             limit: 255
    t.string   "jira_ml_server",              limit: 255
    t.string   "redmine_ml_server",           limit: 255
    t.boolean  "allow_ml_excel"
    t.boolean  "allow_ml_jira"
    t.boolean  "allow_ml_redmine"
    t.boolean  "view_data"
  end

  add_index "guw_guw_models", ["organization_id", "name"], name: "index_guw_guw_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "guw_guw_output_associations", force: :cascade do |t|
    t.integer  "guw_output_id",            limit: 4
    t.integer  "guw_output_associated_id", limit: 4
    t.integer  "guw_complexity_id",        limit: 4
    t.float    "value",                    limit: 24
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "guw_guw_output_complexities", force: :cascade do |t|
    t.integer  "guw_output_id",     limit: 4
    t.integer  "guw_complexity_id", limit: 4
    t.float    "value",             limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "guw_guw_output_complexities", ["guw_complexity_id", "guw_output_id"], name: "guw_output_complexities", using: :btree

  create_table "guw_guw_output_complexity_initializations", force: :cascade do |t|
    t.integer  "guw_output_id",     limit: 4
    t.integer  "guw_complexity_id", limit: 4
    t.float    "init_value",        limit: 24
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "guw_guw_output_complexity_initializations", ["guw_complexity_id", "guw_output_id"], name: "guw_output_complexity_initializations", using: :btree

  create_table "guw_guw_output_types", force: :cascade do |t|
    t.integer  "guw_model_id",  limit: 4
    t.integer  "guw_output_id", limit: 4
    t.integer  "guw_type_id",   limit: 4
    t.string   "display_type",  limit: 255, default: "display"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "guw_guw_outputs", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.string   "output_type",              limit: 255
    t.integer  "guw_model_id",             limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "allow_intermediate_value"
    t.boolean  "allow_subtotal"
    t.float    "standard_coefficient",     limit: 24
    t.integer  "copy_id",                  limit: 4
    t.string   "unit",                     limit: 255
    t.integer  "display_order",            limit: 4
    t.string   "color_code",               limit: 255
    t.integer  "color_priority",           limit: 4
  end

  add_index "guw_guw_outputs", ["guw_model_id", "name"], name: "guw_model_guw_outputs", using: :btree

  create_table "guw_guw_scale_module_attributes", force: :cascade do |t|
    t.integer  "guw_model_id",       limit: 4
    t.string   "type_attribute",     limit: 255
    t.string   "type_scale",         limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "guw_output_id",      limit: 4
    t.integer  "guw_coefficient_id", limit: 4
  end

  add_index "guw_guw_scale_module_attributes", ["guw_model_id", "type_attribute"], name: "guw_scale_module_attributes", using: :btree

  create_table "guw_guw_type_complexities", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.text     "description",   limit: 65535
    t.float    "value",         limit: 24
    t.integer  "guw_type_id",   limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "copy_id",       limit: 4
    t.integer  "display_order", limit: 4,     default: 0
  end

  create_table "guw_guw_types", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.text     "description",                limit: 65535
    t.integer  "organization_technology_id", limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "guw_model_id",               limit: 4
    t.integer  "copy_id",                    limit: 4
    t.boolean  "allow_quantity"
    t.boolean  "allow_retained",                           default: true
    t.boolean  "allow_complexity"
    t.boolean  "allow_criteria",                           default: true
    t.boolean  "display_threshold"
    t.string   "attribute_type",             limit: 255
    t.boolean  "is_default"
    t.string   "color_code",                 limit: 255
    t.integer  "color_priority",             limit: 4
    t.boolean  "allow_line_color"
    t.boolean  "mandatory_comments",                       default: true
  end

  add_index "guw_guw_types", ["guw_model_id", "is_default"], name: "guw_model_default_guw_types", using: :btree
  add_index "guw_guw_types", ["guw_model_id", "name"], name: "guw_model_guw_types", using: :btree

  create_table "guw_guw_unit_of_work_attributes", force: :cascade do |t|
    t.integer  "low",                         limit: 4
    t.integer  "most_likely",                 limit: 4
    t.integer  "high",                        limit: 4
    t.integer  "guw_type_id",                 limit: 4
    t.integer  "guw_unit_of_work_id",         limit: 4
    t.integer  "guw_attribute_id",            limit: 4
    t.integer  "guw_attribute_complexity_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.text     "comments",                    limit: 65535
  end

  add_index "guw_guw_unit_of_work_attributes", ["guw_type_id", "guw_attribute_id", "guw_unit_of_work_id"], name: "guw_unit_of_work_attributes", using: :btree

  create_table "guw_guw_unit_of_work_groups", force: :cascade do |t|
    t.integer  "organization_id",            limit: 4
    t.integer  "project_id",                 limit: 4
    t.string   "name",                       limit: 255
    t.text     "comments",                   limit: 65535
    t.integer  "module_project_id",          limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "pbs_project_element_id",     limit: 4
    t.string   "notes",                      limit: 255
    t.integer  "organization_technology_id", limit: 4
  end

  add_index "guw_guw_unit_of_work_groups", ["module_project_id", "pbs_project_element_id", "name"], name: "module_project_guw_groups", using: :btree

  create_table "guw_guw_unit_of_works", force: :cascade do |t|
    t.integer  "organization_id",               limit: 4
    t.integer  "project_id",                    limit: 4
    t.string   "name",                          limit: 255
    t.text     "comments",                      limit: 65535
    t.float    "result_low",                    limit: 24
    t.float    "result_most_likely",            limit: 24
    t.float    "result_high",                   limit: 24
    t.integer  "guw_type_id",                   limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "guw_complexity_id",             limit: 4
    t.text     "effort",                        limit: 65535
    t.text     "ajusted_size",                  limit: 65535
    t.integer  "guw_model_id",                  limit: 4
    t.integer  "module_project_id",             limit: 4
    t.integer  "pbs_project_element_id",        limit: 4
    t.integer  "guw_unit_of_work_group_id",     limit: 4
    t.integer  "guw_work_unit_id",              limit: 4
    t.text     "tracking",                      limit: 65535
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order",                 limit: 4
    t.integer  "organization_technology_id",    limit: 4
    t.boolean  "off_line_uo"
    t.float    "quantity",                      limit: 24
    t.integer  "guw_weighting_id",              limit: 4
    t.integer  "guw_factor_id",                 limit: 4
    t.text     "size",                          limit: 65535
    t.text     "cost",                          limit: 65535
    t.integer  "guw_original_complexity_id",    limit: 4
    t.boolean  "missing_value",                               default: false
    t.float    "intermediate_work_unit_values", limit: 24
    t.float    "intermediate_weighting_values", limit: 24
    t.float    "intermediate_factor_values",    limit: 24
    t.float    "work_unit_value",               limit: 24
    t.float    "weighting_value",               limit: 24
    t.float    "factor_value",                  limit: 24
    t.float    "intermediate_weight",           limit: 24
    t.float    "intermediate_percent",          limit: 24
    t.string   "url",                           limit: 255
    t.text     "cplx_comments",                 limit: 65535
  end

  add_index "guw_guw_unit_of_works", ["guw_model_id", "module_project_id", "pbs_project_element_id", "guw_unit_of_work_group_id", "guw_type_id", "selected"], name: "module_project_guw_unit_of_works", using: :btree

  create_table "guw_guw_weightings", force: :cascade do |t|
    t.integer  "guw_model_id",  limit: 4
    t.integer  "copy_id",       limit: 4
    t.string   "name",          limit: 255
    t.float    "value",         limit: 24
    t.integer  "display_order", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "guw_guw_work_units", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.float    "value",         limit: 24
    t.integer  "guw_model_id",  limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "copy_id",       limit: 4
    t.integer  "display_order", limit: 4,   default: 0
  end

  create_table "guw_unit_of_work_lines", id: false, force: :cascade do |t|
    t.integer  "uow_organization_id",           limit: 4,     default: 0,     null: false
    t.string   "organization_name",             limit: 255
    t.integer  "uow_project_id",                limit: 4,     default: 0,     null: false
    t.string   "project_name",                  limit: 255
    t.integer  "uow_module_project_id",         limit: 4,     default: 0,     null: false
    t.integer  "uow_pbs_project_element_id",    limit: 4
    t.integer  "uow_guw_model_id",              limit: 4,     default: 0,     null: false
    t.string   "uow_guw_model_name",            limit: 255
    t.integer  "guw_uow_group_id",              limit: 4
    t.string   "guw_uow_group_name",            limit: 255
    t.boolean  "uow_selected"
    t.integer  "guw_unit_of_work_id",           limit: 4,     default: 0,     null: false
    t.integer  "id",                            limit: 4,     default: 0,     null: false
    t.integer  "organization_id",               limit: 4
    t.integer  "project_id",                    limit: 4
    t.string   "name",                          limit: 255
    t.text     "comments",                      limit: 65535
    t.float    "result_low",                    limit: 24
    t.float    "result_most_likely",            limit: 24
    t.float    "result_high",                   limit: 24
    t.integer  "guw_type_id",                   limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "guw_complexity_id",             limit: 4
    t.text     "effort",                        limit: 65535
    t.text     "ajusted_size",                  limit: 65535
    t.integer  "guw_model_id",                  limit: 4
    t.integer  "module_project_id",             limit: 4
    t.integer  "pbs_project_element_id",        limit: 4
    t.integer  "guw_unit_of_work_group_id",     limit: 4
    t.integer  "guw_work_unit_id",              limit: 4
    t.text     "tracking",                      limit: 65535
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order",                 limit: 4
    t.integer  "organization_technology_id",    limit: 4
    t.boolean  "off_line_uo"
    t.float    "quantity",                      limit: 24
    t.integer  "guw_weighting_id",              limit: 4
    t.integer  "guw_factor_id",                 limit: 4
    t.text     "size",                          limit: 65535
    t.text     "cost",                          limit: 65535
    t.integer  "guw_original_complexity_id",    limit: 4
    t.boolean  "missing_value",                               default: false
    t.float    "intermediate_work_unit_values", limit: 24
    t.float    "intermediate_weighting_values", limit: 24
    t.float    "intermediate_factor_values",    limit: 24
    t.float    "work_unit_value",               limit: 24
    t.float    "weighting_value",               limit: 24
    t.float    "factor_value",                  limit: 24
    t.float    "intermediate_weight",           limit: 24
    t.float    "intermediate_percent",          limit: 24
    t.string   "url",                           limit: 255
    t.text     "cplx_comments",                 limit: 65535
    t.integer  "guw_coefficient_element_id",    limit: 4
    t.integer  "guw_coefficient_id",            limit: 4
    t.float    "percent",                       limit: 24
    t.text     "ceuw_comments",                 limit: 65535
  end

  create_table "input_cocomos", force: :cascade do |t|
    t.integer  "factor_id",                      limit: 4
    t.integer  "organization_uow_complexity_id", limit: 4
    t.integer  "pbs_project_element_id",         limit: 4
    t.integer  "project_id",                     limit: 4
    t.integer  "module_project_id",              limit: 4
    t.float    "coefficient",                    limit: 24
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "notes",                          limit: 65535
  end

  create_table "kb_kb_datas", force: :cascade do |t|
    t.string  "name",              limit: 255
    t.float   "size",              limit: 24
    t.float   "effort",            limit: 24
    t.string  "unit",              limit: 255
    t.text    "custom_attributes", limit: 65535
    t.integer "kb_model_id",       limit: 4
    t.date    "project_date"
  end

  create_table "kb_kb_inputs", force: :cascade do |t|
    t.string  "formula",           limit: 255
    t.text    "values",            limit: 65535
    t.text    "regression",        limit: 65535
    t.integer "organization_id",   limit: 4
    t.integer "module_project_id", limit: 4
    t.integer "kb_model_id",       limit: 4
    t.text    "filters",           limit: 65535
  end

  create_table "kb_kb_models", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id",           limit: 4
    t.float    "standard_unit_coefficient", limit: 24
    t.string   "effort_unit",               limit: 255
    t.text     "selected_attributes",       limit: 65535
    t.integer  "copy_number",               limit: 4
    t.integer  "copy_id",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "n_max",                     limit: 4
    t.date     "date_max"
    t.date     "date_min"
    t.string   "filter_a",                  limit: 255
    t.string   "filter_b",                  limit: 255
    t.string   "filter_c",                  limit: 255
    t.string   "filter_d",                  limit: 255
  end

  add_index "kb_kb_models", ["organization_id", "name"], name: "index_kb_kb_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "locale",         limit: 255
    t.string   "custom_value",   limit: 255
    t.integer  "owner_id",       limit: 4
    t.text     "change_comment", limit: 65535
    t.string   "reference_uuid", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "module_project_guw_unit_of_work_groups", id: false, force: :cascade do |t|
    t.integer  "uow_organization_id",              limit: 4,     default: 0, null: false
    t.string   "organization_name",                limit: 255
    t.integer  "uow_project_id",                   limit: 4,     default: 0, null: false
    t.string   "project_name",                     limit: 255
    t.integer  "uow_group_module_project_id",      limit: 4,     default: 0, null: false
    t.integer  "uow_group_pbs_project_element_id", limit: 4
    t.integer  "guw_unit_of_work_group_id",        limit: 4,     default: 0, null: false
    t.integer  "number_of_uow_lines",              limit: 8
    t.integer  "number_of_uow_selected_lines",     limit: 8
    t.integer  "id",                               limit: 4,     default: 0, null: false
    t.integer  "organization_id",                  limit: 4
    t.integer  "project_id",                       limit: 4
    t.string   "name",                             limit: 255
    t.text     "comments",                         limit: 65535
    t.integer  "module_project_id",                limit: 4
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "pbs_project_element_id",           limit: 4
    t.string   "notes",                            limit: 255
    t.integer  "organization_technology_id",       limit: 4
  end

  create_table "module_project_guw_unit_of_works", id: false, force: :cascade do |t|
    t.integer  "uow_organization_id",           limit: 4,     default: 0,     null: false
    t.string   "organization_name",             limit: 255
    t.integer  "uow_project_id",                limit: 4,     default: 0,     null: false
    t.string   "project_name",                  limit: 255
    t.integer  "uow_module_project_id",         limit: 4,     default: 0,     null: false
    t.integer  "uow_pbs_project_element_id",    limit: 4
    t.integer  "uow_guw_model_id",              limit: 4,     default: 0,     null: false
    t.string   "uow_guw_model_name",            limit: 255
    t.integer  "guw_uow_group_id",              limit: 4
    t.string   "guw_uow_group_name",            limit: 255
    t.boolean  "uow_selected"
    t.integer  "guw_unit_of_work_id",           limit: 4,     default: 0,     null: false
    t.integer  "id",                            limit: 4,     default: 0,     null: false
    t.integer  "organization_id",               limit: 4
    t.integer  "project_id",                    limit: 4
    t.string   "name",                          limit: 255
    t.text     "comments",                      limit: 65535
    t.float    "result_low",                    limit: 24
    t.float    "result_most_likely",            limit: 24
    t.float    "result_high",                   limit: 24
    t.integer  "guw_type_id",                   limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "guw_complexity_id",             limit: 4
    t.text     "effort",                        limit: 65535
    t.text     "ajusted_size",                  limit: 65535
    t.integer  "guw_model_id",                  limit: 4
    t.integer  "module_project_id",             limit: 4
    t.integer  "pbs_project_element_id",        limit: 4
    t.integer  "guw_unit_of_work_group_id",     limit: 4
    t.integer  "guw_work_unit_id",              limit: 4
    t.text     "tracking",                      limit: 65535
    t.boolean  "off_line"
    t.boolean  "selected"
    t.boolean  "flagged"
    t.integer  "display_order",                 limit: 4
    t.integer  "organization_technology_id",    limit: 4
    t.boolean  "off_line_uo"
    t.float    "quantity",                      limit: 24
    t.integer  "guw_weighting_id",              limit: 4
    t.integer  "guw_factor_id",                 limit: 4
    t.text     "size",                          limit: 65535
    t.text     "cost",                          limit: 65535
    t.integer  "guw_original_complexity_id",    limit: 4
    t.boolean  "missing_value",                               default: false
    t.float    "intermediate_work_unit_values", limit: 24
    t.float    "intermediate_weighting_values", limit: 24
    t.float    "intermediate_factor_values",    limit: 24
    t.float    "work_unit_value",               limit: 24
    t.float    "weighting_value",               limit: 24
    t.float    "factor_value",                  limit: 24
    t.float    "intermediate_weight",           limit: 24
    t.float    "intermediate_percent",          limit: 24
    t.string   "url",                           limit: 255
    t.text     "cplx_comments",                 limit: 65535
  end

  create_table "module_project_ratio_elements", force: :cascade do |t|
    t.integer  "organization_id",                limit: 4
    t.integer  "pbs_project_element_id",         limit: 4
    t.integer  "module_project_id",              limit: 4
    t.integer  "wbs_activity_id",                limit: 4
    t.integer  "wbs_activity_ratio_id",          limit: 4
    t.integer  "wbs_activity_ratio_element_id",  limit: 4
    t.integer  "wbs_activity_element_id",        limit: 4
    t.boolean  "multiple_references"
    t.string   "name",                           limit: 255
    t.boolean  "name_is_modified"
    t.text     "description",                    limit: 65535
    t.float    "ratio_value",                    limit: 24
    t.float    "tjm",                            limit: 24
    t.decimal  "theoretical_effort_probable",                  precision: 25, scale: 10
    t.decimal  "theoretical_cost_probable",                    precision: 25, scale: 10
    t.decimal  "retained_effort_probable",                     precision: 25, scale: 10
    t.decimal  "retained_cost_probable",                       precision: 25, scale: 10
    t.text     "comments",                       limit: 65535
    t.decimal  "theoretical_effort_low",                       precision: 25, scale: 10
    t.decimal  "theoretical_effort_high",                      precision: 25, scale: 10
    t.decimal  "theoretical_effort_most_likely",               precision: 25, scale: 10
    t.decimal  "theoretical_cost_low",                         precision: 25, scale: 10
    t.decimal  "theoretical_cost_high",                        precision: 25, scale: 10
    t.decimal  "theoretical_cost_most_likely",                 precision: 25, scale: 10
    t.decimal  "retained_effort_low",                          precision: 25, scale: 10
    t.decimal  "retained_effort_high",                         precision: 25, scale: 10
    t.decimal  "retained_effort_most_likely",                  precision: 25, scale: 10
    t.decimal  "retained_cost_low",                            precision: 25, scale: 10
    t.decimal  "retained_cost_high",                           precision: 25, scale: 10
    t.decimal  "retained_cost_most_likely",                    precision: 25, scale: 10
    t.integer  "copy_id",                        limit: 4
    t.float    "position",                       limit: 24
    t.boolean  "flagged"
    t.boolean  "selected"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.boolean  "is_optional"
    t.string   "ancestry",                       limit: 255
    t.string   "phase_short_name",               limit: 255
    t.boolean  "is_just_changed"
  end

  add_index "module_project_ratio_elements", ["ancestry"], name: "index_module_project_ratio_elements_on_ancestry", using: :btree
  add_index "module_project_ratio_elements", ["organization_id", "module_project_id", "pbs_project_element_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_element_id"], name: "organization_module_project_ratio_elements", using: :btree

  create_table "module_project_ratio_variables", force: :cascade do |t|
    t.integer  "organization_id",                limit: 4
    t.integer  "wbs_activity_id",                limit: 4
    t.integer  "module_project_id",              limit: 4
    t.integer  "pbs_project_element_id",         limit: 4
    t.integer  "wbs_activity_ratio_id",          limit: 4
    t.integer  "wbs_activity_ratio_variable_id", limit: 4
    t.string   "name",                           limit: 255
    t.text     "description",                    limit: 65535
    t.string   "percentage_of_input",            limit: 255
    t.decimal  "value_from_percentage",                        precision: 25, scale: 10
    t.boolean  "is_modifiable",                                                          default: false
    t.datetime "created_at",                                                                             null: false
    t.datetime "updated_at",                                                                             null: false
    t.boolean  "is_used_in_ratio_calculation"
  end

  add_index "module_project_ratio_variables", ["organization_id", "module_project_id", "pbs_project_element_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_ratio_variable_id"], name: "organization_module_project_ratio_variables", using: :btree

  create_table "module_projects", force: :cascade do |t|
    t.integer  "organization_id",              limit: 4
    t.integer  "pemodule_id",                  limit: 4
    t.integer  "project_id",                   limit: 4
    t.integer  "position_x",                   limit: 4
    t.integer  "position_y",                   limit: 4
    t.float    "top_position",                 limit: 24
    t.float    "left_position",                limit: 24
    t.integer  "creation_order",               limit: 4
    t.integer  "nb_input_attr",                limit: 4
    t.integer  "nb_output_attr",               limit: 4
    t.integer  "copy_id",                      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "view_id",                      limit: 4
    t.boolean  "show_results_view",                        default: true
    t.string   "color",                        limit: 255
    t.integer  "guw_model_id",                 limit: 4
    t.integer  "ge_model_id",                  limit: 4
    t.integer  "expert_judgement_instance_id", limit: 4
    t.integer  "wbs_activity_id",              limit: 4
    t.integer  "wbs_activity_ratio_id",        limit: 4
    t.integer  "staffing_model_id",            limit: 4
    t.integer  "kb_model_id",                  limit: 4
    t.integer  "operation_model_id",           limit: 4
    t.integer  "skb_model_id",                 limit: 4
  end

  add_index "module_projects", ["organization_id", "pemodule_id", "project_id"], name: "organization_module_projects", using: :btree

  create_table "module_projects_pbs_project_elements", id: false, force: :cascade do |t|
    t.integer "module_project_id",      limit: 4
    t.integer "pbs_project_element_id", limit: 4
    t.integer "copy_id",                limit: 4
  end

  create_table "operation_operation_inputs", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.text     "description",               limit: 65535
    t.string   "in_out",                    limit: 255
    t.integer  "operation_model_id",        limit: 4
    t.boolean  "is_modifiable"
    t.float    "standard_unit_coefficient", limit: 24
    t.string   "standard_unit",             limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "operation_operation_models", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id",           limit: 4
    t.string   "output_unit",               limit: 255
    t.integer  "standard_unit_coefficient", limit: 4
    t.string   "operation_type",            limit: 255
    t.integer  "copy_id",                   limit: 4
    t.integer  "copy_number",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "modify_output"
  end

  add_index "operation_operation_models", ["organization_id", "name"], name: "index_operation_operation_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "organization_estimations", id: false, force: :cascade do |t|
    t.integer  "current_organization_id", limit: 4,     default: 0,     null: false
    t.string   "organization_name",       limit: 255
    t.datetime "project_created_date"
    t.integer  "project_id",              limit: 4,     default: 0,     null: false
    t.integer  "id",                      limit: 4,     default: 0,     null: false
    t.string   "title",                   limit: 255
    t.string   "version_number",          limit: 64,    default: "1.0"
    t.string   "alias",                   limit: 255
    t.string   "ancestry",                limit: 255
    t.text     "description",             limit: 65535
    t.integer  "estimation_status_id",    limit: 4
    t.string   "state",                   limit: 255
    t.date     "start_date"
    t.integer  "organization_id",         limit: 4
    t.integer  "original_model_id",       limit: 4
    t.integer  "project_area_id",         limit: 4
    t.integer  "project_category_id",     limit: 4
    t.integer  "platform_category_id",    limit: 4
    t.integer  "acquisition_category_id", limit: 4
    t.boolean  "is_model"
    t.integer  "master_anscestry",        limit: 4
    t.integer  "creator_id",              limit: 4
    t.text     "purpose",                 limit: 65535
    t.text     "level_of_detail",         limit: 65535
    t.text     "scope",                   limit: 65535
    t.integer  "copy_number",             limit: 4
    t.integer  "copy_id",                 limit: 4
    t.text     "included_wbs_activities", limit: 65535
    t.boolean  "is_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status_comment",          limit: 65535
    t.integer  "application_id",          limit: 4
    t.string   "application_name",        limit: 255
    t.boolean  "private",                               default: false
    t.boolean  "is_historicized"
  end

  create_table "organization_profiles", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.float    "cost_per_hour",   limit: 24
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "copy_id",         limit: 4
  end

  add_index "organization_profiles", ["organization_id"], name: "index_organization_profiles_on_organization_id", using: :btree

  create_table "organization_profiles_wbs_activities", id: false, force: :cascade do |t|
    t.integer  "organization_profile_id", limit: 4
    t.integer  "wbs_activity_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_profiles_wbs_activities", ["organization_profile_id", "wbs_activity_id"], name: "wbs_activity_profiles_index", unique: true, using: :btree
  add_index "organization_profiles_wbs_activities", ["wbs_activity_id", "organization_profile_id"], name: "wbs_activity_organization_profiles", using: :btree

  create_table "organization_technologies", force: :cascade do |t|
    t.integer  "organization_id",    limit: 4
    t.string   "name",               limit: 255
    t.string   "alias",              limit: 255
    t.text     "description",        limit: 65535
    t.float    "productivity_ratio", limit: 24
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "state",              limit: 20
    t.integer  "copy_id",            limit: 4
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.string   "headband_title",              limit: 255
    t.text     "description",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "number_hours_per_day",        limit: 24
    t.float    "number_hours_per_month",      limit: 24
    t.integer  "currency_id",                 limit: 4
    t.float    "cost_per_hour",               limit: 24
    t.float    "inflation_rate",              limit: 24
    t.integer  "limit1",                      limit: 4
    t.integer  "limit2",                      limit: 4
    t.integer  "limit3",                      limit: 4
    t.integer  "copy_number",                 limit: 4,     default: 0
    t.integer  "limit4",                      limit: 4
    t.float    "limit1_coef",                 limit: 24
    t.float    "limit2_coef",                 limit: 24
    t.float    "limit3_coef",                 limit: 24
    t.float    "limit4_coef",                 limit: 24
    t.string   "limit1_unit",                 limit: 255
    t.string   "limit2_unit",                 limit: 255
    t.string   "limit3_unit",                 limit: 255
    t.string   "limit4_unit",                 limit: 255
    t.boolean  "is_image_organization"
    t.text     "project_selected_columns",    limit: 65535
    t.integer  "estimations_counter",         limit: 4
    t.text     "estimations_counter_history", limit: 65535
    t.boolean  "copy_in_progress"
    t.string   "automatic_quotation_number",  limit: 255,   default: "0"
  end

  create_table "organizations_users", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "organization_id",       limit: 4
    t.integer  "originator_id",         limit: 4
    t.integer  "event_organization_id", limit: 4
    t.datetime "created_at"
    t.datetime "update_at"
    t.text     "transaction_id",        limit: 65535
  end

  create_table "pbs_project_elements", force: :cascade do |t|
    t.integer  "pe_wbs_project_id",          limit: 4
    t.string   "ancestry",                   limit: 255
    t.boolean  "is_root"
    t.integer  "work_element_type_id",       limit: 4
    t.string   "name",                       limit: 255
    t.integer  "project_link",               limit: 4
    t.integer  "position",                   limit: 4
    t.integer  "copy_id",                    limit: 4
    t.integer  "wbs_activity_id",            limit: 4
    t.integer  "wbs_activity_ratio_id",      limit: 4
    t.boolean  "is_completed"
    t.boolean  "is_validated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_technology_id", limit: 4
    t.text     "description",                limit: 65535
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "pbs_project_elements", ["ancestry"], name: "index_components_on_ancestry", using: :btree

  create_table "pe_attributes", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "alias",                  limit: 255
    t.text     "description",            limit: 65535
    t.string   "attr_type",              limit: 255
    t.text     "options",                limit: 65535
    t.text     "aggregation",            limit: 65535
    t.string   "custom_value",           limit: 255
    t.integer  "owner_id",               limit: 4
    t.text     "change_comment",         limit: 65535
    t.string   "reference_uuid",         limit: 255
    t.integer  "precision",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attribute_category_id",  limit: 4
    t.boolean  "single_entry_attribute"
    t.integer  "guw_model_id",           limit: 4
    t.integer  "operation_model_id",     limit: 4
    t.integer  "operation_input_id",     limit: 4
  end

  add_index "pe_attributes", ["alias"], name: "index_pe_attributes_on_alias", using: :btree

  create_table "pe_wbs_projects", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "project_id", limit: 4
    t.string   "wbs_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "peicons", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "icon_file_name",    limit: 255
    t.string   "icon_content_type", limit: 255
    t.integer  "icon_file_size",    limit: 4
    t.datetime "icon_updated_at"
    t.string   "uuid",              limit: 255
    t.integer  "record_status_id",  limit: 4
    t.string   "custom_value",      limit: 255
    t.integer  "owner_id",          limit: 4
    t.text     "change_comment",    limit: 65535
    t.integer  "reference_id",      limit: 4
    t.string   "reference_uuid",    limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "peicons", ["record_status_id"], name: "index_peicons_on_record_status_id", using: :btree
  add_index "peicons", ["reference_id"], name: "index_peicons_on_parent_id", using: :btree
  add_index "peicons", ["uuid"], name: "index_peicons_on_uuid", unique: true, using: :btree

  create_table "pemodules", force: :cascade do |t|
    t.string   "title",                    limit: 255
    t.string   "alias",                    limit: 255
    t.text     "description",              limit: 65535
    t.string   "with_activities",          limit: 255,   default: "0"
    t.integer  "type_id",                  limit: 4
    t.text     "compliant_component_type", limit: 65535
    t.boolean  "is_typed"
    t.string   "custom_value",             limit: 255
    t.integer  "owner_id",                 limit: 4
    t.text     "change_comment",           limit: 65535
    t.string   "reference_uuid",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "object_associated",     limit: 255
    t.string   "name",                  limit: 255
    t.text     "description",           limit: 65535
    t.boolean  "is_permission_project"
    t.string   "custom_value",          limit: 255
    t.integer  "owner_id",              limit: 4
    t.text     "change_comment",        limit: 65535
    t.string   "reference_uuid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias",                 limit: 255
    t.boolean  "is_master_permission"
    t.string   "category",              limit: 255,   default: "Admin"
    t.string   "object_type",           limit: 255
    t.text     "transaction_id",        limit: 65535
  end

  create_table "permissions_project_security_levels", force: :cascade do |t|
    t.integer  "permission_id",             limit: 4
    t.integer  "project_security_level_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id",             limit: 4
    t.integer  "event_organization_id",     limit: 4
    t.text     "transaction_id",            limit: 65535
  end

  create_table "platform_categories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.integer  "copy_id",         limit: 4
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.text     "description",    limit: 65535
    t.float    "cost_per_hour",  limit: 24
    t.string   "custom_value",   limit: 255
    t.integer  "owner_id",       limit: 4
    t.text     "change_comment", limit: 65535
    t.string   "reference_uuid", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "project_areas", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.integer  "copy_id",         limit: 4
  end

  create_table "project_categories", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.text     "description",     limit: 65535
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
    t.integer  "copy_id",         limit: 4
  end

  create_table "project_fields", force: :cascade do |t|
    t.integer  "project_id",      limit: 4
    t.integer  "field_id",        limit: 4
    t.integer  "views_widget_id", limit: 4
    t.string   "value",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "project_ressources", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "project_securities", force: :cascade do |t|
    t.integer  "project_id",                limit: 4
    t.integer  "user_id",                   limit: 4
    t.integer  "project_security_level_id", limit: 4
    t.integer  "group_id",                  limit: 4
    t.boolean  "is_model_permission"
    t.boolean  "is_estimation_permission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id",             limit: 4
    t.integer  "event_organization_id",     limit: 4
    t.text     "transaction_id",            limit: 65535
  end

  create_table "project_security_levels", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "custom_value",          limit: 255
    t.text     "change_comment",        limit: 65535
    t.string   "reference_uuid",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",           limit: 65535
    t.integer  "organization_id",       limit: 4
    t.integer  "copy_id",               limit: 4
    t.integer  "originator_id",         limit: 4
    t.integer  "event_organization_id", limit: 4
    t.text     "transaction_id",        limit: 65535
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title",                          limit: 255
    t.string   "version_number",                 limit: 64,    default: "1.0"
    t.string   "alias",                          limit: 255
    t.string   "ancestry",                       limit: 255
    t.text     "description",                    limit: 65535
    t.integer  "estimation_status_id",           limit: 4
    t.string   "state",                          limit: 255
    t.date     "start_date"
    t.integer  "organization_id",                limit: 4
    t.integer  "original_model_id",              limit: 4
    t.integer  "project_area_id",                limit: 4
    t.integer  "project_category_id",            limit: 4
    t.integer  "platform_category_id",           limit: 4
    t.integer  "acquisition_category_id",        limit: 4
    t.boolean  "is_model"
    t.integer  "master_anscestry",               limit: 4
    t.integer  "creator_id",                     limit: 4
    t.text     "purpose",                        limit: 65535
    t.text     "level_of_detail",                limit: 65535
    t.text     "scope",                          limit: 65535
    t.integer  "copy_number",                    limit: 4
    t.integer  "copy_id",                        limit: 4
    t.text     "included_wbs_activities",        limit: 65535
    t.boolean  "is_locked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status_comment",                 limit: 65535
    t.integer  "application_id",                 limit: 4
    t.string   "application_name",               limit: 255
    t.boolean  "private",                                      default: false
    t.boolean  "is_historicized"
    t.integer  "provider_id",                    limit: 4
    t.string   "request_number",                 limit: 255
    t.boolean  "use_automatic_quotation_number"
    t.string   "business_need",                  limit: 255
    t.integer  "originator_id",                  limit: 4
    t.integer  "event_organization_id",          limit: 4
    t.text     "transaction_id",                 limit: 65535
    t.boolean  "is_new_created_record"
    t.boolean  "allow_export_pdf"
  end

  add_index "projects", ["ancestry"], name: "index_projects_on_ancestry", using: :btree
  add_index "projects", ["organization_id", "is_model"], name: "index_projects_on_organization_id_and_is_model", using: :btree
  add_index "projects", ["organization_id", "is_model"], name: "organization_estimation_models", using: :btree

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "copy_id",         limit: 4
  end

  create_table "real_size_inputs", force: :cascade do |t|
    t.integer  "pbs_project_element_id", limit: 4
    t.integer  "module_project_id",      limit: 4
    t.integer  "size_unit_id",           limit: 4
    t.integer  "size_unit_type_id",      limit: 4
    t.integer  "project_id",             limit: 4
    t.float    "value_low",              limit: 24
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.float    "value_most_likely",      limit: 24
    t.float    "value_high",             limit: 24
  end

  create_table "record_statuses", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.integer  "status_id",        limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "record_statuses", ["record_status_id"], name: "index_record_statuses_on_record_status_id", using: :btree
  add_index "record_statuses", ["reference_id"], name: "index_record_statuses_on_parent_id", using: :btree
  add_index "record_statuses", ["uuid"], name: "index_record_statuses_on_uuid", unique: true, using: :btree

  create_table "size_unit_type_complexities", force: :cascade do |t|
    t.integer  "size_unit_type_id",              limit: 4
    t.integer  "organization_uow_complexity_id", limit: 4
    t.float    "value",                          limit: 24
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "size_unit_types", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "alias",            limit: 255
    t.text     "description",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
    t.integer  "organization_id",  limit: 4
  end

  create_table "size_units", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "alias",            limit: 255
    t.text     "description",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
  end

  create_table "skb_skb_datas", force: :cascade do |t|
    t.string  "name",              limit: 255
    t.float   "data",              limit: 24
    t.float   "processing",        limit: 24
    t.integer "skb_model_id",      limit: 4
    t.text    "description",       limit: 65535
    t.text    "custom_attributes", limit: 65535
    t.date    "project_date"
  end

  create_table "skb_skb_inputs", force: :cascade do |t|
    t.float   "data",              limit: 24
    t.float   "processing",        limit: 24
    t.float   "retained_size",     limit: 24
    t.integer "organization_id",   limit: 4
    t.integer "module_project_id", limit: 4
    t.integer "skb_model_id",      limit: 4
    t.text    "filters",           limit: 65535
  end

  create_table "skb_skb_models", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "size_unit",               limit: 255
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "organization_id",         limit: 4
    t.integer  "copy_number",             limit: 4
    t.integer  "copy_id",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",             limit: 65535
    t.string   "label_x",                 limit: 255
    t.string   "label_y",                 limit: 255
    t.string   "filter_a",                limit: 255
    t.string   "filter_b",                limit: 255
    t.string   "filter_c",                limit: 255
    t.string   "filter_d",                limit: 255
    t.text     "selected_attributes",     limit: 65535
    t.date     "date_min"
    t.date     "date_max"
    t.integer  "n_max",                   limit: 4
  end

  add_index "skb_skb_models", ["organization_id", "name"], name: "index_skb_skb_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "staffing_staffing_custom_data", force: :cascade do |t|
    t.integer  "staffing_model_id",                      limit: 4
    t.integer  "module_project_id",                      limit: 4
    t.integer  "pbs_project_element_id",                 limit: 4
    t.string   "staffing_method",                        limit: 255
    t.string   "period_unit",                            limit: 255
    t.decimal  "standard_effort",                                      precision: 20, scale: 6
    t.string   "global_effort_type",                     limit: 255
    t.decimal  "global_effort_value",                                  precision: 20, scale: 6
    t.string   "staffing_constraint",                    limit: 255
    t.float    "duration",                               limit: 24
    t.float    "max_staffing",                           limit: 24
    t.float    "t_max_staffing",                         limit: 24
    t.float    "mc_donell_coef",                         limit: 24
    t.float    "puissance_n",                            limit: 24
    t.text     "trapeze_default_values",                 limit: 65535
    t.text     "trapeze_parameter_values",               limit: 65535
    t.float    "form_coef",                              limit: 24
    t.float    "difficulty_coef",                        limit: 24
    t.float    "coef_a",                                 limit: 24
    t.float    "coef_b",                                 limit: 24
    t.float    "coef_a_prime",                           limit: 24
    t.float    "coef_b_prime",                           limit: 24
    t.float    "calculated_effort",                      limit: 24
    t.float    "theoretical_staffing",                   limit: 24
    t.float    "calculated_staffing",                    limit: 24
    t.text     "chart_actual_coordinates",               limit: 65535
    t.integer  "copy_id",                                limit: 4
    t.integer  "copy_number",                            limit: 4
    t.datetime "created_at",                                                                    null: false
    t.datetime "updated_at",                                                                    null: false
    t.text     "trapeze_chart_theoretical_coordinates",  limit: 65535
    t.text     "rayleigh_chart_theoretical_coordinates", limit: 65535
    t.float    "rayleigh_duration",                      limit: 24
    t.string   "actuals_based_on",                       limit: 255
    t.text     "mcdonnell_chart_theorical_coordinates",  limit: 65535
    t.float    "max_staffing_rayleigh",                  limit: 24
    t.float    "percent",                                limit: 24
  end

  create_table "staffing_staffing_models", force: :cascade do |t|
    t.integer  "organization_id",           limit: 4
    t.string   "name",                      limit: 255
    t.text     "description",               limit: 65535
    t.float    "mc_donell_coef",            limit: 24
    t.float    "puissance_n",               limit: 24
    t.text     "trapeze_default_values",    limit: 65535
    t.boolean  "three_points_estimation"
    t.boolean  "enabled_input"
    t.integer  "copy_id",                   limit: 4
    t.integer  "copy_number",               limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.float    "standard_unit_coefficient", limit: 24
    t.string   "effort_unit",               limit: 255
    t.string   "staffing_method",           limit: 255
    t.integer  "effort_week_unit",          limit: 4
    t.string   "config_type",               limit: 255
    t.integer  "min_range",                 limit: 4
    t.integer  "max_range",                 limit: 4
  end

  add_index "staffing_staffing_models", ["organization_id", "name"], name: "index_staffing_staffing_models_on_organization_id_and_name", unique: true, using: :btree

  create_table "status_histories", force: :cascade do |t|
    t.string   "organization",   limit: 255
    t.integer  "project_id",     limit: 4
    t.string   "project",        limit: 255
    t.string   "version_number", limit: 255
    t.datetime "change_date"
    t.string   "action",         limit: 255
    t.text     "comments",       limit: 65535
    t.string   "origin",         limit: 255
    t.string   "target",         limit: 255
    t.string   "user",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gap",            limit: 4
  end

  create_table "status_transitions", force: :cascade do |t|
    t.integer  "from_transition_status_id", limit: 4
    t.integer  "to_transition_status_id",   limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "technologies", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 65535
    t.string   "uuid",             limit: 255
    t.integer  "record_status_id", limit: 4
    t.string   "custom_value",     limit: 255
    t.integer  "owner_id",         limit: 4
    t.text     "change_comment",   limit: 65535
    t.integer  "reference_id",     limit: 4
    t.string   "reference_uuid",   limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "unit_of_works", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.string   "name",            limit: 255
    t.string   "alias",           limit: 255
    t.text     "description",     limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "state",           limit: 20
    t.integer  "display_order",   limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "password_hash",          limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "login_name",             limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "initials",               limit: 255
    t.datetime "last_login"
    t.datetime "previous_login"
    t.string   "time_zone",              limit: 255
    t.string   "auth_token",             limit: 255
    t.string   "password_reset_token",   limit: 255
    t.datetime "password_reset_sent_at"
    t.integer  "language_id",            limit: 4
    t.integer  "auth_type",              limit: 4
    t.text     "ten_latest_projects",    limit: 65535
    t.integer  "organization_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "object_per_page",        limit: 4
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",        limit: 4,     default: 0,     null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "avatar",                 limit: 255
    t.integer  "number_precision",       limit: 4
    t.boolean  "super_admin",                          default: false
    t.boolean  "password_changed"
    t.text     "description",            limit: 65535
    t.datetime "subscription_end_date"
    t.integer  "originator_id",          limit: 4
    t.integer  "event_organization_id",  limit: 4
    t.text     "transaction_id",         limit: 65535
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["login_name"], name: "index_users_on_login_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id",       limit: 4
    t.string  "foreign_key_name", limit: 255, null: false
    t.integer "foreign_key_id",   limit: 4
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.integer  "organization_id",                   limit: 4
    t.boolean  "is_model"
    t.string   "item_type",                         limit: 191,        null: false
    t.integer  "item_id",                           limit: 4,          null: false
    t.string   "event",                             limit: 255,        null: false
    t.string   "whodunnit",                         limit: 255
    t.text     "object",                            limit: 4294967295
    t.datetime "created_at"
    t.integer  "transaction_id",                    limit: 4
    t.text     "object_changes",                    limit: 4294967295
    t.boolean  "is_group_security"
    t.boolean  "is_user_security"
    t.boolean  "is_security_on_model"
    t.boolean  "is_security_on_created_from_model"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["organization_id"], name: "organization_audit_versions", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

  create_table "views", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.text     "description",       limit: 65535
    t.integer  "organization_id",   limit: 4
    t.integer  "pemodule_id",       limit: 4
    t.boolean  "is_reference_view"
    t.boolean  "is_default_view"
    t.integer  "initial_view_id",   limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "views_widgets", force: :cascade do |t|
    t.integer  "view_id",                      limit: 4
    t.integer  "widget_id",                    limit: 4
    t.string   "name",                         limit: 255
    t.integer  "module_project_id",            limit: 4
    t.integer  "estimation_value_id",          limit: 4
    t.integer  "pe_attribute_id",              limit: 4
    t.integer  "pbs_project_element_id",       limit: 4
    t.string   "icon_class",                   limit: 255
    t.string   "color",                        limit: 255
    t.string   "position_x",                   limit: 255
    t.string   "position_y",                   limit: 255
    t.string   "width",                        limit: 255
    t.string   "height",                       limit: 255
    t.string   "widget_type",                  limit: 255
    t.boolean  "show_min_max"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "position",                     limit: 4
    t.boolean  "show_name"
    t.boolean  "show_wbs_activity_ratio"
    t.boolean  "from_initial_view"
    t.boolean  "is_label_widget"
    t.text     "comment",                      limit: 65535
    t.boolean  "is_kpi_widget"
    t.text     "equation",                     limit: 65535
    t.string   "kpi_unit",                     limit: 255
    t.boolean  "use_organization_effort_unit"
    t.boolean  "show_tjm"
    t.integer  "min_value",                    limit: 4
    t.integer  "max_value",                    limit: 4
    t.string   "validation_text",              limit: 255
  end

  add_index "views_widgets", ["module_project_id", "pe_attribute_id", "estimation_value_id"], name: "module_project_views_widgets", using: :btree

  create_table "wbs_activities", force: :cascade do |t|
    t.string   "uuid",                     limit: 255
    t.string   "name",                     limit: 255
    t.string   "state",                    limit: 255
    t.text     "description",              limit: 65535
    t.integer  "organization_id",          limit: 4
    t.integer  "record_status_id",         limit: 4
    t.string   "custom_value",             limit: 255
    t.integer  "owner_id",                 limit: 4
    t.text     "change_comment",           limit: 65535
    t.integer  "reference_id",             limit: 4
    t.string   "reference_uuid",           limit: 255
    t.integer  "copy_number",              limit: 4,     default: 0
    t.integer  "copy_id",                  limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "three_points_estimation"
    t.string   "cost_unit",                limit: 255
    t.float    "cost_unit_coefficient",    limit: 24
    t.string   "effort_unit",              limit: 255
    t.float    "effort_unit_coefficient",  limit: 24
    t.boolean  "enabled_input"
    t.integer  "phases_short_name_number", limit: 4,     default: 0
    t.string   "hide_wbs_header",          limit: 255
    t.string   "average_rate_wording",     limit: 255
  end

  add_index "wbs_activities", ["organization_id", "name"], name: "index_wbs_activities_on_organization_id_and_name", unique: true, using: :btree
  add_index "wbs_activities", ["organization_id"], name: "organization_wbs_activities", using: :btree
  add_index "wbs_activities", ["owner_id"], name: "index_wbs_activities_on_owner_id", using: :btree

  create_table "wbs_activity_elements", force: :cascade do |t|
    t.integer  "organization_id",    limit: 4
    t.string   "uuid",               limit: 255
    t.integer  "wbs_activity_id",    limit: 4
    t.string   "name",               limit: 255
    t.text     "description",        limit: 65535
    t.string   "ancestry",           limit: 255
    t.integer  "ancestry_depth",     limit: 4,     default: 0
    t.integer  "record_status_id",   limit: 4
    t.string   "custom_value",       limit: 255
    t.text     "change_comment",     limit: 65535
    t.integer  "reference_id",       limit: 4
    t.string   "reference_uuid",     limit: 255
    t.integer  "copy_id",            limit: 4
    t.string   "dotted_id",          limit: 255
    t.boolean  "is_root"
    t.string   "master_ancestry",    limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.float    "position",           limit: 24
    t.string   "phase_short_name",   limit: 255
    t.boolean  "allow_modif_effort"
    t.boolean  "allow_modif_cost"
  end

  add_index "wbs_activity_elements", ["ancestry"], name: "index_wbs_activity_elements_on_ancestry", using: :btree
  add_index "wbs_activity_elements", ["organization_id", "wbs_activity_id", "ancestry"], name: "organization_wbs_activity_elements", using: :btree
  add_index "wbs_activity_elements", ["wbs_activity_id"], name: "index_wbs_activity_elements_on_wbs_activity_id", using: :btree

  create_table "wbs_activity_inputs", force: :cascade do |t|
    t.integer "wbs_activity_ratio_id",  limit: 4
    t.integer "wbs_activity_id",        limit: 4
    t.integer "module_project_id",      limit: 4
    t.integer "pbs_project_element_id", limit: 4
    t.text    "comment",                limit: 65535
  end

  create_table "wbs_activity_ratio_elements", force: :cascade do |t|
    t.integer  "organization_id",         limit: 4
    t.integer  "wbs_activity_id",         limit: 4
    t.string   "uuid",                    limit: 255
    t.integer  "wbs_activity_ratio_id",   limit: 4
    t.integer  "wbs_activity_element_id", limit: 4
    t.float    "ratio_value",             limit: 24
    t.boolean  "simple_reference"
    t.integer  "record_status_id",        limit: 4
    t.string   "custom_value",            limit: 255
    t.text     "change_comment",          limit: 65535
    t.integer  "reference_id",            limit: 4
    t.string   "reference_uuid",          limit: 255
    t.boolean  "multiple_references"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "ancestry",                limit: 255
    t.boolean  "is_optional"
    t.string   "formula",                 limit: 255
    t.boolean  "is_modifiable",                         default: false
    t.integer  "copy_id",                 limit: 4
    t.boolean  "effort_is_modifiable"
    t.boolean  "cost_is_modifiable"
  end

  add_index "wbs_activity_ratio_elements", ["ancestry"], name: "index_wbs_activity_ratio_elements_on_ancestry", using: :btree
  add_index "wbs_activity_ratio_elements", ["organization_id", "wbs_activity_id", "wbs_activity_ratio_id", "wbs_activity_element_id"], name: "organization_wbs_activity_ratio_elements", using: :btree

  create_table "wbs_activity_ratio_profiles", force: :cascade do |t|
    t.integer  "wbs_activity_ratio_element_id", limit: 4
    t.integer  "organization_profile_id",       limit: 4
    t.float    "ratio_value",                   limit: 24
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "ancestry",                      limit: 255
  end

  add_index "wbs_activity_ratio_profiles", ["ancestry"], name: "index_wbs_activity_ratio_profiles_on_ancestry", using: :btree

  create_table "wbs_activity_ratio_variables", force: :cascade do |t|
    t.integer  "organization_id",              limit: 4
    t.integer  "wbs_activity_id",              limit: 4
    t.integer  "wbs_activity_ratio_id",        limit: 4
    t.string   "name",                         limit: 255
    t.text     "description",                  limit: 65535
    t.string   "percentage_of_input",          limit: 255
    t.boolean  "is_modifiable",                              default: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.boolean  "is_used_in_ratio_calculation"
  end

  add_index "wbs_activity_ratio_variables", ["organization_id", "wbs_activity_ratio_id"], name: "organization_wbs_activity_ratio_variables", using: :btree

  create_table "wbs_activity_ratios", force: :cascade do |t|
    t.integer  "organization_id",                    limit: 4
    t.string   "uuid",                               limit: 255
    t.string   "name",                               limit: 255
    t.text     "description",                        limit: 65535
    t.integer  "wbs_activity_id",                    limit: 4
    t.boolean  "do_not_show_cost"
    t.integer  "record_status_id",                   limit: 4
    t.string   "custom_value",                       limit: 255
    t.text     "change_comment",                     limit: 65535
    t.integer  "reference_id",                       limit: 4
    t.string   "reference_uuid",                     limit: 255
    t.integer  "copy_number",                        limit: 4,     default: 0
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "copy_id",                            limit: 4
    t.boolean  "allow_modify_retained_effort"
    t.boolean  "do_not_show_phases_with_zero_value"
    t.boolean  "allow_modify_ratio_reference"
    t.boolean  "allow_add_new_phase"
    t.boolean  "comment_required_if_modifiable"
  end

  add_index "wbs_activity_ratios", ["organization_id", "wbs_activity_id"], name: "organization_wbs_activity_ratios", using: :btree

  create_table "wbs_project_elements", force: :cascade do |t|
    t.integer  "pe_wbs_project_id",       limit: 4
    t.integer  "wbs_activity_element_id", limit: 4
    t.integer  "wbs_activity_id",         limit: 4
    t.string   "name",                    limit: 255
    t.text     "description",             limit: 65535
    t.text     "additional_description",  limit: 65535
    t.boolean  "exclude",                               default: false
    t.string   "ancestry",                limit: 255
    t.integer  "ancestry_depth",          limit: 4,     default: 0
    t.integer  "author_id",               limit: 4
    t.integer  "copy_id",                 limit: 4
    t.integer  "copy_number",             limit: 4,     default: 0
    t.boolean  "is_root"
    t.boolean  "can_get_new_child"
    t.integer  "wbs_activity_ratio_id",   limit: 4
    t.boolean  "is_added_wbs_root"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "widgets", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "icon_class",      limit: 255
    t.string   "color",           limit: 255
    t.integer  "pe_attribute_id", limit: 4
    t.string   "width",           limit: 255
    t.string   "height",          limit: 255
    t.string   "widget_type",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "work_element_types", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "alias",           limit: 255
    t.text     "description",     limit: 65535
    t.integer  "project_area_id", limit: 4
    t.integer  "peicon_id",       limit: 4
    t.string   "custom_value",    limit: 255
    t.integer  "owner_id",        limit: 4
    t.text     "change_comment",  limit: 65535
    t.string   "reference_uuid",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id", limit: 4
  end

  # WARNING: generating adapter-specific definition for estimation_status_group_roles_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER estimation_status_group_roles_after_delete_row_tr AFTER DELETE ON `estimation_status_group_roles`
FOR EACH ROW
BEGIN
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for estimation_status_group_roles_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER estimation_status_group_roles_after_insert_row_tr AFTER INSERT ON `estimation_status_group_roles`
FOR EACH ROW
BEGIN
    
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_after_delete_row_tr AFTER DELETE ON `groups`
FOR EACH ROW
BEGIN
    INSERT INTO autorization_log_events SET
      event_organization_id = OLD.event_organization_id,
      author_id = OLD.originator_id,
      item_type = 'Group',
      item_id = OLD.id,
      object_class_name = 'Group',
      event = 'delete',
      object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
      created_at = UTC_TIMESTAMP();
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_after_insert_row_tr AFTER INSERT ON `groups`
FOR EACH ROW
BEGIN
    
          INSERT INTO autorization_log_events SET
              event_organization_id = NEW.event_organization_id,
              author_id = NEW.originator_id,
              item_type = 'Group',
              item_id = NEW.id,
              object_class_name = 'Group',
              event = 'create',
              object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', ' "description": ', '["', '', '", "', NEW.description, '"]}'),
              created_at = UTC_TIMESTAMP();
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_after_update_of_name_description_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_after_update_of_name_description_row_tr AFTER UPDATE ON `groups`
FOR EACH ROW
BEGIN
    IF NEW.name <> OLD.name OR (NEW.name IS NULL) <> (OLD.name IS NULL) OR NEW.description <> OLD.description OR (NEW.description IS NULL) <> (OLD.description IS NULL) THEN
        
              INSERT INTO autorization_log_events SET
                event_organization_id = NEW.event_organization_id,
                author_id = NEW.originator_id,
                item_type = 'Group',
                item_id = OLD.id,
                object_class_name = 'Group',
                event = 'update',
                object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
                created_at = UTC_TIMESTAMP();
    END IF;
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_permissions_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_permissions_after_delete_row_tr AFTER DELETE ON `groups_permissions`
FOR EACH ROW
BEGIN
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_permissions_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_permissions_after_insert_row_tr AFTER INSERT ON `groups_permissions`
FOR EACH ROW
BEGIN
    
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_users_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_users_after_delete_row_tr AFTER DELETE ON `groups_users`
FOR EACH ROW
BEGIN
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for groups_users_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER groups_users_after_insert_row_tr AFTER INSERT ON `groups_users`
FOR EACH ROW
BEGIN
    
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for organizations_users_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER organizations_users_after_delete_row_tr AFTER DELETE ON `organizations_users`
FOR EACH ROW
BEGIN
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for organizations_users_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER organizations_users_after_insert_row_tr AFTER INSERT ON `organizations_users`
FOR EACH ROW
BEGIN
    
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for permissions_project_security_levels_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER permissions_project_security_levels_after_delete_row_tr AFTER DELETE ON `permissions_project_security_levels`
FOR EACH ROW
BEGIN
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for permissions_project_security_levels_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER permissions_project_security_levels_after_insert_row_tr AFTER INSERT ON `permissions_project_security_levels`
FOR EACH ROW
BEGIN
    
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
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for project_securities_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER project_securities_after_delete_row_tr AFTER DELETE ON `project_securities`
FOR EACH ROW
BEGIN
    
          IF ((SELECT is_new_created_record FROM projects WHERE id = OLD.project_id) != true) THEN
    
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
              is_model = (SELECT is_model FROM projects WHERE id = OLD.project_id),
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
          END IF;
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for project_securities_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER project_securities_after_insert_row_tr AFTER INSERT ON `project_securities`
FOR EACH ROW
BEGIN
    
          IF ((SELECT is_new_created_record FROM projects WHERE id = NEW.project_id) != true) THEN
    
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
                is_model = (SELECT is_model FROM projects WHERE id = NEW.project_id),
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
          END IF;
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for project_security_levels_after_delete_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER project_security_levels_after_delete_row_tr AFTER DELETE ON `project_security_levels`
FOR EACH ROW
BEGIN
    INSERT INTO autorization_log_events SET
      event_organization_id = OLD.event_organization_id,
      author_id = OLD.originator_id,
      item_type = 'ProjectSecurityLevel',
      item_id = OLD.id,
      object_class_name = 'ProjectSecurityLevel',
      event = 'delete',
      object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', '', '"],', ' "description": ', '["', OLD.description, '", "', '', '"]}'),
      created_at = UTC_TIMESTAMP();
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for project_security_levels_after_insert_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER project_security_levels_after_insert_row_tr AFTER INSERT ON `project_security_levels`
FOR EACH ROW
BEGIN
    
          INSERT INTO autorization_log_events SET
            event_organization_id = NEW.event_organization_id,
            author_id = NEW.originator_id,
            item_type = 'ProjectSecurityLevel',
            item_id = NEW.id,
            object_class_name = 'ProjectSecurityLevel',
            event = 'create',
            object_changes = CONCAT('{ "name": ', '["', '', '", "', NEW.name, '"],', '"description": ', '["', '', '", "', NEW.description, '"]}'),
            created_at = UTC_TIMESTAMP();
END
  TRIGGERSQL

  # WARNING: generating adapter-specific definition for project_security_levels_after_update_of_name_description_row_tr due to a mismatch.
  # either there's a bug in hairtrigger or you've messed up your migrations and/or db :-/
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER project_security_levels_after_update_of_name_description_row_tr AFTER UPDATE ON `project_security_levels`
FOR EACH ROW
BEGIN
    IF NEW.name <> OLD.name OR (NEW.name IS NULL) <> (OLD.name IS NULL) OR NEW.description <> OLD.description OR (NEW.description IS NULL) <> (OLD.description IS NULL) THEN
        INSERT INTO autorization_log_events SET
          event_organization_id = NEW.event_organization_id,
          author_id = NEW.originator_id,
          item_type = 'ProjectSecurityLevel',
          item_id = OLD.id,
          object_class_name = 'ProjectSecurityLevel',
          event = 'update',
          object_changes = CONCAT('{ "name": ', '["', OLD.name, '", "', NEW.name, '"],', ' "description": ', '["', OLD.description, '", "', NEW.description, '"]}'),
          created_at = UTC_TIMESTAMP();
    END IF;
END
  TRIGGERSQL

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-TRIGGERSQL)
CREATE DEFINER = 'root'@'localhost' TRIGGER user_events AFTER UPDATE ON `users`
FOR EACH ROW
BEGIN
          DECLARE old_value varchar(255);
          DECLARE new_value varchar(255);
          SET
            old_value = OLD.id,
            new_value = NEW.id;

          
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

end
