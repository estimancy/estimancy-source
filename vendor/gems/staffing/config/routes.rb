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

Staffing::Engine.routes.draw do

  post 'save_data' => "staffing_custom_data#save_data", as: "save_data"

  resources :staffing_custom_data do
    post 'old_save_staffing_custom_data'
  end

  post 'save_legend' => "staffing_custom_data#save_legend", as: "save_legend"

  resources :staffing_models do
    post 'duplicate'
    post 'export_staffing'
  end

  get "staffing_models/index"

  root to: 'staffing#index'
end
