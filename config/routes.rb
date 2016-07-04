#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

require 'sidekiq/web'

Projestimate::Application.routes.draw do

  resources :applications
  resources :fields
  resources :views_widgets
  get 'update_view_widget_positions' => 'views_widgets#update_view_widget_positions', :as => 'update_view_widget_positions'
  get 'update_view_widget_sizes' => 'views_widgets#update_view_widget_sizes', :as => 'update_view_widget_sizes'
  get 'update_widget_module_project_data' => 'views_widgets#update_widget_module_project_data', :as => 'update_widget_module_project_data'
  get 'export_vignette' => 'views_widgets#export_vignette' , :as => 'export_vignette'

  resources :widgets

  resources :views

  resources :plans

  resources :estimation_statuses
  post '/set_estimation_status_workflow' => 'estimation_statuses#set_estimation_status_workflow', as: 'set_estimation_status_workflow'
  post '/set_estimation_status_group_roles' => 'estimation_statuses#set_estimation_status_group_roles', as: 'set_estimation_status_group_roles'


  resources :organization_profiles
  get 'refresh_organization_profiles' => 'organization_profiles#refresh_organization_profiles', as: 'refresh_organization_profiles'
  get 'refresh_organization_profile_data' => 'organization_profiles#refresh_organization_profile_data', as: 'refresh_organization_profile_data'


  resources :profiles

  # Mount the Sidekiq web interface
  mount Sidekiq::Web, at: "/sidekiq"

  resources :technologies

  resources :estimation_values
  get 'add_note_to_attribute' => 'estimation_values#add_note_to_attribute', :as => 'add_note_to_attribute'

  #devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks"}
  #devise_scope :user do
  #  get "help_login" => "registrations", :as => 'help_login'
  #end
  #==========
  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks", sessions: 'sessions'}, :skip => [:registrations]
  devise_scope :user do
    #get "metadata",   :to => "sessions#metadata"
    get "sign_in",   :to => "devise/sessions#new"
    get "sign_out",  :to => "devise/sessions#destroy"
    get "cancel_user_registration", :to => "devise/registrations#cancel"
    post "user_registration",       :to => "registrations#create"
    put "user_registration",        :to => "registrations#update", as: :update_user_registration
    #get "new_user_registration",    :to => "registrations#new"
    get "edit_user_registration",   :to => "devise/registrations#edit"
    get "help_login" => "registrations", :as => 'help_login'
  end
  get 'awaiting_confirmation' => 'registrations#awaiting_confirmation', :as => 'awaiting_confirmation'
#=====================

  resources :users

  get 'dashboard' => 'users#show', :as => 'dashboard'
  get 'validate' => 'users#validate', :as => 'validate'
  post 'create_inactive_user' => 'users#create_inactive_user', :as => 'create_inactive_user'
  get 'find_use_user' => 'users#find_use_user', :as => 'find_use_user'
  get 'about' => 'users#about', :as => 'about'
  match 'users/:id/unlock_user' => 'users#unlock_user', :as => 'unlock_user'
  get 'display_states' => 'users#display_states', :as => 'display_states'
  post 'send_feedback' => 'users#send_feedback', :as => 'send_feedback'

  resources :password_resets

  #resources :sessions
  #get 'log_in' => 'sessions#new', :as => 'log_in'
  #get 'log_out' => 'sessions#destroy', :as => 'log_out'
  #get 'ask_new_account' => 'sessions#ask_new_account', :as => 'ask_new_account'
  #get 'help_login' => 'sessions#help_login', :as => 'help_login'
  #get 'forgotten_password' => 'sessions#forgotten_password', :as => 'forgotten_password'
  #post 'reset_forgotten_password' => 'sessions#reset_forgotten_password', :as => 'reset_forgotten_password'

  resources :audits

  mount ExpertJudgement::Engine, :at => '/expert_judgement'
  mount Guw::Engine, :at => '/guw'
  mount Ge::Engine, :at => '/ge'
  mount Operation::Engine, :at => '/operation'
  mount Kb::Engine, :at => '/kb'
  mount Skb::Engine, :at => '/skb'
  mount Staffing::Engine, :at => '/staffing'
  mount BalancingModule::Engine, at: '/balancing_module'

  post "save_effort_breakdown" => "wbs_activities#save_effort_breakdown"
  post "update_effort_breakdown_retained_values" => "wbs_activities#update_effort_breakdown_retained_values"

  resources :organization_technologies
  get 'change_abacus' => 'organization_technologies#change_abacus', :as => 'change_abacus'


  resources :unit_of_works
  resources :attribute_categories

  resources :versions

  resources :reference_values
  resources :wbs_project_elements
  match 'projects/:project_id/wbs_project_elements/:wbs_project_id/change_wbs_project_ratio' => 'wbs_project_elements#change_wbs_project_ratio', :as => 'change_wbs_project_ratio'
  match 'wbs_project_elements/update_wbs_project_ratio_value' => 'wbs_project_elements#update_wbs_project_ratio_value', :as => 'update_wbs_project_ratio_value'

  resources :wbs_activity_ratios do
    collection { match 'wbs_activity_ratios/:wbs_activity_ratio_id/export' => 'wbs_activity_ratios#export', :as => 'export' }
    collection { match 'wbs_activity_ratios/import' => 'wbs_activity_ratios#import', :as => 'import' }
  end
  match 'wbs_activity_ratios/:ratio_id/validate_ratio' => 'wbs_activity_ratios#validate_ratio', :as => 'validate_ratio'
  get 'refresh_ratio_elements' => 'wbs_activities#refresh_ratio_elements', :as => 'refresh_ratio_elements'

  resources :wbs_activity_ratio_elements
  post 'save_values' => 'wbs_activity_ratio_elements#save_values', :as => 'save_values'

  resources :wbs_activity_elements
  match 'wbs_activities/:wbs_activity_id/duplicate_wbs_activity' => 'wbs_activities#duplicate_wbs_activity', :as => :duplicate_wbs_activity
  get 'update_status_collection' => 'wbs_activity_elements#update_status_collection', :as => 'update_status_collection'

  resources :wbs_activities do
    collection { post :import }
  end

  match 'homes/update_install' => 'homes#update_install', :as => 'update_install'

  resources :record_statuses

  resources :auth_methods

  resources :admin_settings

  # searches controller routes
  post 'searches/results'
  get 'searches/results' => 'searches#results', :as => 'searches/results'
  match 'searches/results' => 'searches#results', :as => 'search_results'

  resources :estimation_values
  match 'estimation_values/:type/convert' => 'estimation_values#convert', :as => 'convert'

  resources :attribute_modules

  resources :module_projects
  match 'module_projects/:project_id/module_projects_matrix' => 'module_projects#module_projects_matrix', :as => 'module_projects_matrix'
  match 'module_projects/associate_modules_projects' => 'module_projects#associate_modules_projects', :as => 'associate_modules_projects'
  match 'module_projects/associate_module_project_to_ratios' => 'module_projects#associate_module_project_to_ratios', :as => 'associate_module_project_to_ratios'
  post 'module_projects/associate'
  match 'module_projects/:module_project_id/activate_module_project' => 'module_projects#activate_module_project', :as => 'activate_module_project'
  get 'selected_balancing_attribute' => 'module_projects#selected_balancing_attribute', :as => 'selected_balancing_attribute'
  get 'show_module_project_results_view' => 'module_projects#show_module_project_results_view', :as => 'show_module_project_results_view'
  get 'edit_module_project_view_config' => 'module_projects#edit_module_project_view_config', as: 'edit_module_project_view_config'
  match 'update_module_project_view_config' => 'module_projects#update_module_project_view_config', as: 'update_module_project_view_config'
  post 'module_projects_reassign' => 'module_projects#module_projects_reassign', as: 'module_projects_reassign'
  get 'update_module_project_dynamic_connections' => 'module_projects#update_module_project_dynamic_connections', as: 'update_module_project_dynamic_connections'
  get 'update_module_project_left_and_top_positions' => 'module_projects#update_module_project_left_and_top_positions', as: 'update_module_project_left_and_top_positions'

  resources :module_project_ratio_elements do
    post "load_comments"
  end
  post "save_comments" => "module_project_ratio_elements#save_comments", as: "save_mp_ratio_element_comments"
  post "save_mp_ratio_element" => "module_project_ratio_elements#save_mp_ratio_element", as: "save_mp_ratio_element"
  get 'refresh_dashboard_module_project_ratio_elements' => 'module_project_ratio_elements#refresh_dashboard_module_project_ratio_elements', :as => 'refresh_dashboard_module_project_ratio_elements'
  get 'refresh_dashboard_retained_effort_and_cost' => 'module_project_ratio_elements#refresh_dashboard_retained_effort_and_cost', :as => 'refresh_dashboard_retained_effort_and_cost'
  get 'refresh_dashboard_added_phase_parents_cost_value' => 'module_project_ratio_elements#refresh_dashboard_added_phase_parents_cost_value', :as => 'refresh_dashboard_added_phase_parents_cost_value'

  resources :languages

  resources :project_securities
  get 'select_users' => 'project_securities#select_users', :as => 'select_users'

  resources :pe_attributes
  post 'check_attribute' => 'pe_attributes#check_attribute', :as => 'check_attribute'
  get 'find_use_attribute' => 'pe_attributes#find_use_attribute', :as => 'find_use_attribute'

  resources :currencies

  resources :organizations do
    resources :applications
    resources :fields
    resources :wbs_activities
    resources :groups
    resources :users, only: [:new, :create, :show, :edit, :update, :destroy]
    resources :project_categories
    resources :platform_categories
    resources :acquisition_categories
    resources :project_areas
    resources :project_security_levels
    resources :work_element_types
    resources :organization_profiles
    resources :views

    get "authorization" => 'organizations#authorization'
    get "setting" => 'organizations#setting'
    get "module_estimation" => 'organizations#module_estimation'
    get "users" => 'organizations#users', as: 'organization_users'
    get "estimations" => 'organizations#estimations'
    get "report" => 'organizations#report'
    post "generate_report_csv" => 'organizations#generate_report_csv'
    post "generate_report_excel" => 'organizations#generate_report_excel'
    post "generate_report_excel_from_file" => 'organizations#generate_report_excel_from_file'
    post "import_user" => 'organizations#import_user'
    post "export_user" => 'organizations#export_user'
    get "export_groups" => 'organizations#export_groups'
    post "import_groups" => 'organizations#import_groups'
    get "export_appli" => 'organizations#export_appli'
    post "import_appli" => 'organizations#import_appli'
    get "export_project_areas" => 'organizations#export_project_areas'
    post "import_project_areas" => 'organizations#import_project_areas'
    get "polyval_export" => 'organizations#polyval_export'

  end

  get "export_permissions" => 'permissions#export_permissions'
  post "import_permissions" => 'permissions#import_permissions'

  get 'organizationals_params' => 'organizations#organizationals_params', :as => 'organizationals_params'
  post '/organizations/:organization_id/export' => 'organizations#export', :as => 'export_organization'
  match 'organizations/:organization_id/duplicate_organization' => 'organizations#duplicate_organization', :as => :duplicate_organization
  get 'new_organization_from_image' => 'organizations#new_organization_from_image', as: 'new_organization_from_image'
  match 'create_organization_from_image' => 'organizations#create_organization_from_image', as: 'create_organization_from_image'
  get 'update_available_inline_columns' => 'organizations#update_available_inline_columns', as: 'update_available_inline_columns'
  get 'set_available_inline_columns' => 'organizations#set_available_inline_columns', as: 'set_available_inline_columns'
  match 'organizations/:organization_id/confirm_organization_deletion' => 'organizations#confirm_organization_deletion', :as => :confirm_organization_deletion

  resources :subcontractors

  resources :labor_categories

  resources :event_types

  resources :events

  resources :permissions
  post 'set_rights' => 'permissions#set_rights', :as => 'set_rights'
  post 'set_estimations_rights' => 'permissions#set_estimations_rights', :as => 'set_estimations_rights'
  post 'set_rights_project_security' => 'permissions#set_rights_project_security', :as => 'set_rights_project_security'
  get 'globals_permissions' => 'permissions#globals_permissions', :as => 'globals_permissions'

  post 'update_selected_users' => 'groups#update_selected_users'
  post 'update_selected_projects' => 'groups#update_selected_projects'

  resources :pemodules
  match 'pemodules/:module_id/pemodules_down' => 'pemodules#pemodules_down', :as => 'pemodules_down'
  match 'pemodules/:module_id/pemodules_up' => 'pemodules#pemodules_up', :as => 'pemodules_up'
  match 'pemodules/:module_id/pemodules_left' => 'pemodules#pemodules_left', :as => 'pemodules_left'
  match 'pemodules/:module_id/pemodules_right' => 'pemodules#pemodules_right', :as => 'pemodules_right'

  get 'list_attributes' => 'pemodules#list_attributes'
  get 'update_selected_attributes' => 'pemodules#update_selected_attributes'
  post 'set_attributes_module' => 'pemodules#set_attributes_module'
  get 'estimations_params' => 'pemodules#estimations_params', :as => 'estimations_params'
  get 'find_use_pemodule' => 'pemodules#find_use_pemodule', :as => 'find_use_pemodule'

  resources :groups
  get 'associated_user' => 'groups#associated_user', :as => 'associated_user'

  resources :pbs_project_elements
  get 'new' => 'pbs_project_elements#new'
  get 'up' => 'pbs_project_elements#up'
  get 'down' => 'pbs_project_elements#down'
  get 'selected_pbs_project_element' => 'pbs_project_elements#selected_pbs_project_element'
  get 'refresh_pbs_activity_ratios' => 'pbs_project_elements#refresh_pbs_activity_ratios', :as => 'refresh_pbs_activity_ratios'

  resources :pe_wbs_projects

  resources :projects
  match 'dashboard/:project_id/' => 'projects#dashboard', :as => 'dashboard'

  get 'append_pemodule' => 'projects#append_pemodule'
  get 'select_categories' => 'projects#select_categories', :as => 'select_categories'
  post 'run_estimation' => 'projects#run_estimation', :as => 'run_estimation'
  post 'copy_security/:project_id' => 'projects#copy_security', :as => 'copy_security'

  get 'show_estimation_graph' => 'projects#show_estimation_graph', :as => 'show_estimation_graph'
  get 'show_module_configuration' => 'projects#show_module_configuration', :as => 'show_module_configuration'

  get 'results_with_activities_by_profile' => 'projects#results_with_activities_by_profile', :as => 'results_with_activities_by_profile'
  get 'load_security_for_selected_user' => 'projects#load_security_for_selected_user', :as => 'load_security_for_selected_user'
  get 'load_security_for_selected_group' => 'projects#load_security_for_selected_group', :as => 'load_security_for_selected_group'
  get 'update_project_security_level' => 'projects#update_project_security_level', :as => 'update_project_security_level'
  get 'update_project_security_level_group' => 'projects#update_project_security_level_group', :as => 'update_project_security_level_group'
  get 'projects_global_params' => 'projects#projects_global_params', :as => 'projects_global_params'
  get 'commit' => 'projects#commit', :as => 'commit'
  get 'activate' => 'projects#activate', :as => 'activate'
  get 'activate_project' => 'projects#activate', :as => 'activate_project'
  match 'projects/:project_id/choose_project' => 'projects#choose_project', :as => 'choose_project'
  get 'find_use_project' => 'projects#find_use_project', :as => 'find_use_project'
  get 'find_use_estimation_model' => 'projects#find_use_estimation_model', :as => 'find_use_estimation_model'
  get 'check_in' => 'projects#check_in', :as => 'check_in'
  get 'check_out' => 'projects#check_out', :as => 'check_out'
  get 'select_pbs_project_elements' => 'projects#select_pbs_project_elements', :as => 'select_pbs_project_elements'
  get 'add_filter_on_project_version' => 'projects#add_filter_on_project_version', :as => 'add_filter_on_project_version'
  match 'checkout' => 'projects#checkout', :as => 'checkout'
  get 'collapse_project_version' => 'projects#collapse_project_version', :as => 'collapse_project_version'
  get 'update_organization_estimation_statuses' => 'projects#update_organization_estimation_statuses', as: 'update_organization_estimation_statuses'
  get 'add_comment_on_status_change' => 'projects#add_comment_on_status_change', as: 'add_comment_on_status_change'
  get 'change_new_estimation_data' => 'projects#change_new_estimation_data', as: 'change_new_estimation_data'
  get 'set_checkout_version' => 'projects#set_checkout_version', as: 'set_checkout_version'

  match 'update_comments_status_change' => 'projects#update_comments_status_change', as: 'update_comments_status_change'
  post 'add_wbs_activity_to_project' => 'projects#add_wbs_activity_to_project',  :as => 'add_wbs_activity_to_project'
  post 'update_project_security_level_group' => 'projects#update_project_security_level_group',  :as => 'update_project_security_level_group'
  post 'update_project_security_level' => 'projects#update_project_security_level',  :as => 'update_project_security_level'

  get 'refresh_wbs_project_elements' => 'projects#refresh_wbs_project_elements', :as => 'refresh_wbs_project_elements'
  get 'refresh_wbs_activity_ratios' => 'projects#refresh_wbs_activity_ratios',   :as => 'refresh_wbs_activity_ratios'
  get 'generate_wbs_project_elt_tree' => 'projects#generate_wbs_project_elt_tree', :as => 'generate_wbs_project_elt_tree'
  get 'render_selected_wbs_activity_elements' => 'projects#render_selected_wbs_activity_elements', as: 'render_selected_wbs_activity_elements'
  match 'projects/:id/display_estimation_plan' => 'projects#display_estimation_plan', :as => 'display_estimation_plan'

  match 'projects/:project_id/duplicate' => 'projects#duplicate', :as => :duplicate
  match 'projects/:project_id/confirm_deletion' => 'projects#confirm_deletion', :as => :confirm_deletion
  match 'projects/:project_id/locked_plan' => 'projects#locked_plan', :as => :locked_plan
  get 'show_project_history' => 'projects#show_project_history', :as => :show_project_history

  get 'projects_from' => 'projects#projects_from', :as => 'projects_from'
  post 'load_setting_module/:module_project_id' => 'projects#load_setting_module', :as => 'load_setting_module'

  #Master Data validation and restoration routes
  match ':controller/:id/validate_change' => ':controller#validate_change', :as => 'validate_change'
  match ':controller/:id/restore_change' => ':controller#restore_change', :as => 'restore_change'

  match 'wbs_activities/:id/validate_change_with_children' => 'wbs_activities#validate_change_with_children', :as => 'validate_change_with_children'
  post 'save_wbs_activity_ratio_per_profile' => 'wbs_activity_ratio_elements#save_wbs_activity_ratio_per_profile', :as => 'save_wbs_activity_ratio_per_profile'
  post "execute_estimation" => "projects#execute_estimation"
  get "export_my_project_xl/:project_id" => "projects#export_my_project_xl" , :as => 'export_my_project_xl'


  resources :translations
  get 'load_translations' => 'translations#load_translations', :as => 'load_translations'

  get 'maintenances' => 'admin_settings#maintenances', :as => 'maintenances'
  post 'mass_mailing' => 'admin_settings#mass_mailing', :as => 'mass_mailing'

  post 'update_selected_attribute_organizations' => 'attribute_organizations#update_selected_attribute_organizations'
  post 'save_cocomo_basic' => 'cocomo_basics#save_cocomo_basic', :as => 'EstimationControllers/save_cocomo_basic'

  get "/404" => "errors#not_found"
  get "/500" => "errors#internal_server_error"

  root :to => 'organizations#organizationals_params'
end
