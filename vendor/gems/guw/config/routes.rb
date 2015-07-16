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
    post "load_name"
    post "load_comments"
    post "load_trackings"
    post "load_cotations"
  end
  resources :guw_unit_of_work_groups

  resources :guw_work_units
  resources :guw_work_units do
    post "create_notes"
  end

  resources :guw_types
  resources :guw_attribute_complexities

  resources :guw_models do
    resources :guw_attributes
    resources :guw_unit_of_works
    resources :guw_work_units
    resources :guw_unit_of_work_groups
    resources :guw_types do
      resources :guw_attribute_complexities
      resources :guw_complexities
      resources :guw_type_complexities

      post "guw_attribute_complexities/save_attributs_complexities"
    end
    post "duplicate"
    post "export"
  end

  post "guw_unit_of_works/save_guw_unit_of_works"
  post "guw_complexity_work_units/save_complexity_work_units"

  get "change_selected_state" => "guw_unit_of_works#change_selected_state", as: "change_selected_state"
  get "change_cotation" => "guw_unit_of_works#change_cotation", as: "change_cotation"
  get "change_operation" => "guw_unit_of_works#change_operation", as: "change_operation"
  get "change_technology" => "guw_unit_of_works#change_technology", as: "change_technology"
  get "change_technology_form" => "guw_unit_of_works#change_technology_form", as: "change_technology_form"
  post "save_name" => "guw_unit_of_works#save_name", as: "save_name"
  post "save_comments" => "guw_unit_of_works#save_comments", as: "save_comments"
  post "save_trackings" => "guw_unit_of_works#save_trackings", as: "save_trackings"
  post "save_uo" => "guw_unit_of_works#save_uo", as: "save_uo"
end