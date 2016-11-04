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

Skb::Engine.routes.draw do
  root :to => 'skb#index'
  resources :skb_models
  resources :skb_models do
    get "save_size"
    post "import"
    get "data_export"
    post "duplicate"
    post "raz"
  end

  match 'skb_models/import_skb_model' => 'skb_models#import', as: "import_skb_model"

end