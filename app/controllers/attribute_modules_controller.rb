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
##############################################################################

class AttributeModulesController < ApplicationController
   #Module for master data changes validation



  def create
    authorize! :manage, PeAttribute
    @attribute_module = AttributeModule.new(params[:attribute_module])

    if @attribute_module.save
      redirect_to attribute_modules_path, notice: "#{I18n.t(:notice_attribute_module_successful_created)}"
    else
      render action: "new"
    end
  end

  def destroy
    authorize! :manage, PeAttribute
    @attribute_module = AttributeModule.find(params[:id])
    # if @attribute_module.is_defined? || @attribute_module.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      # @attribute_module.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    # else
      @attribute_module.destroy
    # end

    redirect_to edit_pemodule_path(@attribute_module.pemodule)
  end

end
