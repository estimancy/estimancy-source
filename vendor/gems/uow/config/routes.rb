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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

Uow::Engine.routes.draw do
  root :to => 'inputs#index'
  post 'save_uow' => 'inputs#save_uow', :as => 'save_uow'
  get 'load_gross' => 'inputs#load_gross', :as => 'load_gross'
  get 'update_complexity_select_box' => 'inputs#update_complexity_select_box', :as => 'update_complexity_select_box'
  get 'update_unit_of_works_select_box' => 'inputs#update_unit_of_works_select_box', :as => 'update_unit_of_works_select_box'

  get 'new_item/:module_project_id/:pbs_id/:row_index' => 'inputs#new_item', :as => 'new_item'
  get 'remove_item/:module_project_id/:input_id/:pbs_id/:row_index' => 'inputs#remove_item', :as => 'remove_item'
  get 'export/:module_project_id/:pbs_id' => 'inputs#export', :as => 'export'
  post 'import/:module_project_id/:pbs_id' => 'inputs#import', :as => 'import'
end