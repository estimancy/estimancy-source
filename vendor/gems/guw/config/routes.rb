# encoding: UTF-8
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

Guw::Engine.routes.draw do
  root :to => 'guw#index'

  resources :guw_type_complexities
  resources :guw_complexities
  resources :guw_complexity_work_units
  resources :guw_attributes
  resources :guw_unit_of_works
  resources :guw_unit_of_works do
    get "up"
    get "down"
    post "duplicate"
    post "add_correction"
    post "load_name"
    post "load_comments"
    post "load_trackings"
    post "load_cotations"
    post "save_coefficient_comments"
    post "save_cplx_comments"
  end

  get "load_coefficient_comments" => "guw_unit_of_works#load_coefficient_comments"
  get "load_cplx_comments" => "guw_unit_of_works#load_cplx_comments"

  resources :guw_unit_of_work_groups
  post "create_group" => "guw_unit_of_work_groups#create_group", as: "create_group"


  resources :guw_work_units
  resources :guw_work_units do
    post "create_notes"
  end

  resources :guw_weightings

  resources :guw_factors

  resources :guw_types
  resources :guw_attribute_complexities

  resources :guw_models do
    resources :guw_attributes
    resources :guw_unit_of_works
    resources :guw_weightings
    resources :guw_factors
    resources :guw_outputs
    resources :guw_coefficients
    resources :guw_coefficients do
      resources :guw_coefficient_elements
    end
    resources :guw_work_units
    resources :guw_unit_of_work_groups
    resources :guw_types do
      resources :guw_attribute_complexities
      resources :guw_attribute_types
      resources :guw_complexities
      resources :guw_type_complexities

      post "guw_attribute_complexities/save_attributs_complexities"
    end
    post "duplicate"
    post "export"
    post "export_with_wbs"
    post "export_old_config"
    post "export_new_config"
    get "all_guw_types"

    get "scale_module_attributes"
    post "save_scale_module_attributes"
    get "show_data_model"
  end

  post "import_old_config" => "guw_models#import_old_config"
  post "import_new_config" => "guw_models#import_new_config"
  post "import_guw" => "guw_unit_of_works#import_guw"
  post "old_import_guw" => "guw_unit_of_works#old_import_guw"

  post "guw_unit_of_works/save_guw_unit_of_works"
  post "guw_unit_of_works/save_guw_unit_of_works_with_multiple_outputs"

  post "guw_complexity_work_units/save_complexity_work_units"

  get "change_selected_state" => "guw_unit_of_works#change_selected_state", as: "change_selected_state"
  get "change_cotation" => "guw_unit_of_works#change_cotation", as: "change_cotation"
  get "change_work_unit" => "guw_unit_of_works#change_work_unit", as: "change_work_unit"
  get "change_complexity" => "guw_unit_of_works#change_complexity", as: "change_complexity"
  get "change_technology" => "guw_unit_of_works#change_technology", as: "change_technology"
  get "change_technology_form" => "guw_unit_of_works#change_technology_form", as: "change_technology_form"
  post "save_name" => "guw_unit_of_works#save_name", as: "save_name"
  post "save_comments" => "guw_unit_of_works#save_comments", as: "save_comments"
  post "save_trackings" => "guw_unit_of_works#save_trackings", as: "save_trackings"
  post "ml_trt" => "guw_unit_of_works#ml_trt", as: "ml_trt"
  post "ml_data" => "guw_unit_of_works#ml_data", as: "ml_data"
  post "extract_from_url" => "guw_unit_of_works#extract_from_url", as: "extract_from_url"

  get "yolo" => "guw_unit_of_works#yolo", as: "yolo"

  post "save_uo" => "guw_unit_of_works#save_uo", as: "save_uo"
  post "save_uo_with_multiple_outputs" => "guw_unit_of_works#save_uo_with_multiple_outputs", as: "save_uo_with_multiple_outputs"

  post "auto_sizing" => "guw_models#auto_sizing", as: "auto_sizing"

  post "deported" => "guw_unit_of_works#deported", as: "deported"
end