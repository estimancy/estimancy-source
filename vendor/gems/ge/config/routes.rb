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

Ge::Engine.routes.draw do
  root :to => 'ge#index'
  resources :ge_models
  resources :ge_models do
    post "save_efforts"
    post "update_calculated_effort"
    post "duplicate"
    post "import"
    get "data_export"
    get "delete_all_factors_data"
  end

  resources :ge_model_factor_descriptions

  post 'ge_models/import_ge_model_instance' => 'ge_models#import', as: "import_ge_model_instance"
  get 'change_ge_model_instance_mode' => 'ge_models#change_ge_model_instance_mode', :as => 'change_ge_model_instance_mode'
end