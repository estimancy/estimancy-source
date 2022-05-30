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

class EstimationValuesController < ApplicationController
  helper_method :show_notes

  def add_note_to_attribute
    @estimation_value = EstimationValue.find(params[:estimation_value_id])
    @text_notes = ""
    if !@estimation_value.notes.nil?
      # show notes for PBS
      @text_notes = @estimation_value.notes["#{params[:pbs_project_elt_id]}"]
    end
  end

  # update notes for pbs
  def update
    @estimation_value = EstimationValue.find(params[:id])
    pbs_project_elt_id = params[:pbs_project_elt_id]
    current_notes = ""
    # Add notes for PBS
    current_notes = @estimation_value.notes.nil? ? "" : @estimation_value.notes["#{pbs_project_elt_id}"]
    @estimation_value.notes["#{pbs_project_elt_id}"] =  show_notes(params["estimation_value"]["notes"], current_notes.to_s.length)

    if @estimation_value.save
      flash[:notice] = I18n.t(:notice_notes_successfully_updated)
    else
      flash[:error] = I18n.t(:errors)
    end

    redirect_to :back
  end

  def show_notes(notes, current_note_length)
    user_infos = ""
    if current_note_length == 0
      user_infos = "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name} \r\n \r\n"
      user_infos << "_____________________________________________________________________________________ \r\n \r\n"
    else
      user_infos = "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name} \r\n"
    end
    notes.prepend(user_infos)
  end

end

