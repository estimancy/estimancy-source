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

class Staffing::StaffingCustomDataController < ApplicationController

  # GET /staffing_custom_data
  # GET /staffing_custom_data.json
  def index
    @staffing_custom_data = StaffingCustomDatum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @staffing_custom_data }
    end
  end

  # GET /staffing_custom_data/1
  # GET /staffing_custom_data/1.json
  def show
    @staffing_custom_datum = StaffingCustomDatum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @staffing_custom_datum }
    end
  end

  # GET /staffing_custom_data/new
  # GET /staffing_custom_data/new.json
  def new
    @staffing_custom_datum = StaffingCustomDatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @staffing_custom_datum }
    end
  end

  # GET /staffing_custom_data/1/edit
  def edit
    @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
  end

  # POST /staffing_custom_data
  # POST /staffing_custom_data.json
  def create
    @staffing_custom_datum = StaffingCustomDatum.new(params[:staffing_custom_datum])

    respond_to do |format|
      if @staffing_custom_datum.save
        format.html { redirect_to @staffing_custom_datum, notice: 'Staffing custom datum was successfully created.' }
        format.json { render json: @staffing_custom_datum, status: :created, location: @staffing_custom_datum }
      else
        format.html { render action: "new" }
        format.json { render json: @staffing_custom_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /staffing_custom_data/1
  # PUT /staffing_custom_data/1.json
  def update
    @staffing_custom_datum = StaffingCustomDatum.find(params[:id])

    respond_to do |format|
      if @staffing_custom_datum.update_attributes(params[:staffing_custom_datum])
        format.html { redirect_to @staffing_custom_datum, notice: 'Staffing custom datum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @staffing_custom_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staffing_custom_data/1
  # DELETE /staffing_custom_data/1.json
  def destroy
    @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
    @staffing_custom_datum.destroy

    respond_to do |format|
      format.html { redirect_to staffing_custom_data_url }
      format.json { head :no_content }
    end
  end

  #Save Team/Staffing custom data
  def save_staffing_custom_data
    authorize! :execute_estimation_plan, @project

    @component = current_component
    @module_project = current_module_project
    @staffing_model = @module_project.staffing_model
    trapeze_default_values = @staffing_model.trapeze_default_values

    @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).first
    @staffing_model.trapeze_default_values =  { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] }

    if @staffing_custom_data.nil?
      @staffing_custom_data = Staffing::StaffingCustomDatum.create( staffing_model_id: @staffing_model.id,
                                                                    module_project_id: @module_project.id,
                                                                    pbs_project_element_id: @component.id,
                                                                    staffing_method: 'trapeze',
                                                                    period_unit: 'week',
                                                                    global_effort_type: 'probable',
                                                                    mc_donell_coef: 6,
                                                                    puissance_n: 0.33,
                                                                    trapeze_default_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] },
                                                                    trapeze_parameter_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] } )
    end


    if @staffing_custom_data.update_attributes(params[:staffing_custom_datum])

      effort = @staffing_custom_data.global_effort_value

      duration = @staffing_custom_data.duration
      rayleigh_duration_duration = @staffing_custom_data.rayleigh_duration

      @duration = [duration, rayleigh_duration_duration].max

      trapeze_parameter_values = @staffing_custom_data.trapeze_parameter_values

      # Calcul des vraies valeurs de (x0, x1, x2, x3) en % de la durée D ; et  (y0, y3) en % de M
      x0 = trapeze_parameter_values[:x0].to_f / 100
      x1 = trapeze_parameter_values[:x1].to_f / 100
      x2 = trapeze_parameter_values[:x2].to_f / 100
      x3 = trapeze_parameter_values[:x3].to_f / 100
      y0 = trapeze_parameter_values[:y0].to_f / 100
      y3 = trapeze_parameter_values[:y3].to_f / 100

      # Calcul du Max staffing M = 2 * (E/D) * (1 / (x3 + x2 - x1 - x0 + y0*(x1 - x2) + y3*(x3 - x2)))
      max_staffing = 2 * (effort / @duration) * ( 1 / (x3 + x2 - x1 - x0 + y0*(x1 - x2) + y3*(x3 - x2)))
      @staffing_custom_data.max_staffing = max_staffing

      x0D = x0 * @duration
      x1D = x1 * @duration
      x2D = x2 * @duration
      x3D = x3 * @duration

      # Calcul de a, b, a', b' avec
      # a = M(1 - y0) / D(x1 - x2)
      coef_a = (max_staffing*(1-y0)) / (@duration*(x1-x0))
      @staffing_custom_data.coef_a = coef_a

      # b = M(x1y0 - x0) / (x1 - x0)
      coef_b = (max_staffing * ((x1*y0) - x0)) / (x1-x0)
      @staffing_custom_data.coef_b = coef_b

      # a' = M(1 - y3) / D(x2 - x3)
      coef_a_prime = (max_staffing*(1-y3)) / (@duration*(x2-x3))
      @staffing_custom_data.coef_a_prime = coef_a_prime

      # b' = M(x2y3 - x3) / D(x2 - x3)
      coef_b_prime = (max_staffing * ((x2*y3) - x3)) / (x2-x3)
      @staffing_custom_data.coef_b_prime = coef_b_prime

      # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
      # Creation du jeu de donnees pour le tracer la courbe
      trapeze_theorical_staffing_values = []
      actual_staffing_values = []

      for t in 0..@duration
        case t
          #intervalle_1 = x(semaine) compris dans [0 ; x0*D]     =>  f(x) = 0
          when 0..x0D
            t_staffing = 0

          #intervalle_2 = x(semaine) compris dans ]x0*D ; x1*D]  =>   f(x) = ax+b
          when x0D..x1D
            t_staffing = (coef_a * t) + coef_b

          #intervalle_3 = x(semaine) compris dans ]x1*D ; x2*D]  =>   f(x) = M
          when x1D..x2D
            t_staffing = max_staffing

          #intervalle_4 = x(semaine) compris dans ]x2*D ; x3*D]   =>  f(x) = a'x+b'
          when x2D..x3D
            t_staffing = (coef_a_prime * t) + coef_b_prime

          #intervalle_5 = x(semaine) compris dans ]x3*D ; infini[  => f(x) = 0
          else
            t_staffing = 0
        end

        trapeze_theorical_staffing_values << ["#{t}", t_staffing]
      end

      @staffing_custom_data.trapeze_chart_theoretical_coordinates = trapeze_theorical_staffing_values
      @staffing_custom_data.save

      max_staffing = @staffing_custom_data.max_staffing
      staffing_constraint = @staffing_custom_data.staffing_constraint

      # Contrainte de Staffing Max
      if staffing_constraint == "max_staffing_constraint"
        # coefficient de forme : a
        form_coef = (max_staffing*max_staffing) * (Math.exp(1) / (2*effort*effort))
        @staffing_custom_data.form_coef = form_coef

        # coefficient de difficulté
        difficulty_coef = 2*effort*form_coef
        @staffing_custom_data.difficulty_coef = difficulty_coef

        # numero de la semaine au Pic de Staffing
        t_max_staffing = Math.sqrt(1/(2*form_coef))
        @staffing_custom_data.t_max_staffing = t_max_staffing

        # Duree en semaines : Tfin = duration
        true_duration = Math.sqrt((-Math.log(1-0.97)) / form_coef)
        @staffing_custom_data.rayleigh_duration = true_duration

        # Contrainte de Durée
      elsif staffing_constraint == "duration_constraint"

        # coefficient de forme : a
        form_coef = -Math.log(1-0.97) / (@duration * @duration)
        @staffing_custom_data.form_coef = form_coef

        # coefficient de difficulté
        difficulty_coef = 2*effort*form_coef
        @staffing_custom_data.difficulty_coef = difficulty_coef

        # numero de la semaine au Pic de Staffing
        t_max_staffing = Math.sqrt(1/(2*form_coef))
        @staffing_custom_data.t_max_staffing = t_max_staffing

        # MAx Staffing
        max_staffing = effort / (t_max_staffing * Math.sqrt(Math.exp(1)))
        @staffing_custom_data.max_staffing = max_staffing
      end

      # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
      rayleigh_chart_theoretical_coordinates = []
      rayleigh_chart_actual_coordinates = []

      for t in 0..@duration
        # E(t) = 2 * K * a * t * e(-a*t*t)
        t_staffing = 2 * effort * form_coef * t * Math.exp(-form_coef*t*t)
        rayleigh_chart_theoretical_coordinates << ["#{t}", t_staffing]
        if params[:actuals].present?
          actual_staffing_values << params[:actuals].to_a.map{|i| [i.first.to_f, i.last.to_f]}
        else
          actual_staffing_values << ["#{t}", t_staffing]
        end
      end

      @staffing_custom_data.rayleigh_chart_theoretical_coordinates = rayleigh_chart_theoretical_coordinates

      if params[:actuals].present?
        @staffing_custom_data.chart_actual_coordinates = actual_staffing_values.first
      else
        @staffing_custom_data.chart_actual_coordinates = rayleigh_chart_theoretical_coordinates
      end
    end

    @staffing_custom_data.save

    update_staffing_estimation_values

    redirect_to :back
  end


  #Update estimation values
  def update_staffing_estimation_values
    @staffing_model = @module_project.staffing_model
    @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).first

    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
      ["low", "most_likely", "high"].each do |level|

        if @staffing_model.three_points_estimation?
          size = params[:"retained_size_#{level}"].to_f
        else
          size = params[:"retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          effort = @staffing_custom_data.global_effort_value
          ev.send("string_data_#{level}")[current_component.id] = effort * @staffing_model.standard_unit_coefficient
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "duration"
          duration = @staffing_custom_data.duration
          ev.send("string_data_#{level}")[current_component.id] = duration
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "staffing"
          max_staffing = @staffing_custom_data.max_staffing
          ev.send("string_data_#{level}")[current_component.id] = max_staffing
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @staffing_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
    end
  end
end
