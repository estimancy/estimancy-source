#encoding: utf-8
##########################################################################
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
##########################################################################

class AuditsController < ApplicationController

  load_and_authorize_resource :except => [:index]

  def index
    @audits = Audit.all
    set_page_title I18n.t(:Audit)
    set_breadcrumbs I18n.t(:Audit) => audits_path, I18n.t('actions_history') => ""

    #@audits = Audit.filter(:params => params, :filter => :audit_filter)
    #@wf_filter = WillFilter::Filter.deserialize_from_params(params)
  end

end
