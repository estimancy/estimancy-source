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
      format.html # show.js.erb
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
  def save_data
    authorize! :execute_estimation_plan, @project

    # begin

    @component = current_component
    @module_project = current_module_project
    @staffing_model = @module_project.staffing_model
    current_organization = @current_organization

    @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).first

    @staffing_custom_data.percent = params[:percents]
    @staffing_custom_data.standard_effort = params[:standard_effort].to_f
    @staffing_custom_data.global_effort_value = params[:new_effort].to_f
    @staffing_custom_data.duration = params[:new_duration]
    @staffing_custom_data.max_staffing_rayleigh = params[:new_staffing_rayleigh]
    @staffing_custom_data.max_staffing = params[:new_staffing_trapeze]
    @staffing_custom_data.percent = params[:percents]

    @staffing_custom_data.save

    if @staffing_custom_data.standard_effort == 0
      @staffing_custom_data.global_effort_value = nil
      @staffing_custom_data.duration = nil
      @staffing_custom_data.max_staffing_rayleigh = nil
      @staffing_custom_data.max_staffing = nil
      @staffing_custom_data.percent = nil

      @staffing_custom_data.save

      current_module_project.toggle_done

      update_staffing_estimation_values

      @module_project = current_module_project
      @project = @module_project.project

      ViewsWidget::update_field(@module_project, @current_organization, @project, current_component)

      # Reset all view_widget results
      ViewsWidget.reset_nexts_mp_estimation_values(@module_project, current_component)
      @module_project.all_nexts_mp_with_links.each do |module_project|
        ViewsWidget::update_field(module_project, @current_organization, @project, current_component, true)
      end

      redirect_to :back and return
    end


    ###########
    # Graphe d'origine
    ###########

    #### Rayleigh

    attribute = @module_project.pemodule.pe_attributes.where(alias: "effort").first
    effort_week_unit = @staffing_model.effort_week_unit.nil? ? 1 : @staffing_model.effort_week_unit.to_f

    begin
      current_ev = EstimationValue.where(:organization_id => current_organization.id, :module_project_id => @module_project.id, :pe_attribute_id => attribute.id, :in_out => "input").first

      if !current_ev.estimation_value_id.nil?
        ev = EstimationValue.find(current_ev.estimation_value_id)
      else
        ev = EstimationValue.where(:organization_id => current_organization.id,
                                   :module_project_id => @module_project.previous.last,
                                   :pe_attribute_id => attribute.id,
                                    :in_out => "output").first
      end
    rescue
      ev = nil
    end

    begin
      begin
        previous_activity_root = @module_project.previous.last.wbs_activity.wbs_activity_elements.first.root
        effort = ev.string_data_probable[current_component.id][previous_activity_root.id][:value] / (@staffing_model.standard_unit_coefficient.nil? ? 1 : @staffing_model.standard_unit_coefficient.to_f)
      rescue
        effort = ev.string_data_probable[current_component.id] / (@staffing_model.standard_unit_coefficient.nil? ? 1 : @staffing_model.standard_unit_coefficient.to_f)
      end
    rescue
      begin
        effort = ev.string_data_probable[current_component.id].to_f / (@staffing_model.standard_unit_coefficient.nil? ? 1 : @staffing_model.standard_unit_coefficient.to_f)
      rescue
        effort = 0
      end
    end

    @md_duration = @staffing_model.mc_donell_coef * (effort * @staffing_model.standard_unit_coefficient.to_f / effort_week_unit) ** @staffing_model.puissance_n
    form_coef = -Math.log(1-0.97) / (@md_duration * @md_duration)
    mcdonnell_chart_theorical_coordinates = []
    for t in 0..@md_duration
      t_staffing = (@staffing_custom_data.global_effort_value * @staffing_model.standard_unit_coefficient.to_f / @staffing_model.effort_week_unit) * form_coef * t * Math.exp(-form_coef*t*t)
      mcdonnell_chart_theorical_coordinates << ["#{t}", 2 * t_staffing]
    end
    @staffing_custom_data.mcdonnell_chart_theorical_coordinates = mcdonnell_chart_theorical_coordinates


    #### Trapeze
    trapeze_parameter_values = @staffing_model.trapeze_default_values

    x0 = trapeze_parameter_values[:x0].to_f / 100
    x1 = trapeze_parameter_values[:x1].to_f / 100
    x2 = trapeze_parameter_values[:x2].to_f / 100
    x3 = trapeze_parameter_values[:x3].to_f / 100
    y0 = trapeze_parameter_values[:y0].to_f / 100
    y3 = trapeze_parameter_values[:y3].to_f / 100

    @staffing_trapeze = (2 * (effort * @staffing_model.standard_unit_coefficient.to_f / effort_week_unit) / @md_duration) / ((x3 + x2 - x1 - x0 + y0 * (x1 - x0) + y3 * (x3 - x2)))

    x0D = x0 * @md_duration
    x1D = x1 * @md_duration
    x2D = x2 * @md_duration
    x3D = x3 * @md_duration

    coef_a = (@staffing_trapeze*(1-y0)) / (@md_duration*(x1-x0))
    @staffing_custom_data.coef_a = coef_a

    coef_b = (@staffing_trapeze * ((x1*y0) - x0)) / (x1-x0)
    @staffing_custom_data.coef_b = coef_b

    coef_a_prime = (@staffing_trapeze * (1-y3)) / (@md_duration*(x2-x3))
    @staffing_custom_data.coef_a_prime = coef_a_prime

    coef_b_prime = (@staffing_trapeze * ((x2*y3) - x3)) / (x2-x3)
    @staffing_custom_data.coef_b_prime = coef_b_prime

    # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
    # Creation du jeu de donnees pour le tracer la courbe
    chart_actual_coordinates = []
    for t in 0..@md_duration
      case t
        when 0..x0D
          t_staffing = 0
        when x0D..x1D
          t_staffing = (coef_a * t) + coef_b
        when x1D..x2D
          t_staffing = @staffing_trapeze
        when x2D..x3D
          t_staffing = (coef_a_prime * t) + coef_b_prime
        else
          t_staffing = 0
      end
      chart_actual_coordinates << ["#{t}", t_staffing]
    end
    @staffing_custom_data.chart_actual_coordinates = chart_actual_coordinates

    begin
      @staffing_custom_data.save
    rescue
      #
    end


    ###########
    # Graphe Ajusté
    ###########

    ##### Trapeze

    trapeze_parameter_values = @staffing_model.trapeze_default_values

    x0 = trapeze_parameter_values[:x0].to_f / 100
    x1 = trapeze_parameter_values[:x1].to_f / 100
    x2 = trapeze_parameter_values[:x2].to_f / 100
    x3 = trapeze_parameter_values[:x3].to_f / 100
    y0 = trapeze_parameter_values[:y0].to_f / 100
    y3 = trapeze_parameter_values[:y3].to_f / 100
    @duration = @staffing_custom_data.duration
    @staffing_trapeze = @staffing_custom_data.max_staffing

    x0D = x0 * @duration
    x1D = x1 * @duration
    x2D = x2 * @duration
    x3D = x3 * @duration

    coef_a = (@staffing_trapeze*(1-y0)) / (@duration*(x1-x0))
    @staffing_custom_data.coef_a = coef_a

    coef_b = (@staffing_trapeze * ((x1*y0) - x0)) / (x1-x0)
    @staffing_custom_data.coef_b = coef_b

    coef_a_prime = (@staffing_trapeze * (1-y3)) / (@duration*(x2-x3))
    @staffing_custom_data.coef_a_prime = coef_a_prime

    coef_b_prime = (@staffing_trapeze * ((x2*y3) - x3)) / (x2-x3)
    @staffing_custom_data.coef_b_prime = coef_b_prime

    # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
    # Creation du jeu de donnees pour le tracer la courbe
    trapeze_theorical_staffing_values = []

    for t in 0..@duration
      case t
        when 0..x0D
          t_staffing = 0
        when x0D..x1D
          t_staffing = (coef_a * t) + coef_b
        when x1D..x2D
          t_staffing = @staffing_trapeze
        when x2D..x3D
          t_staffing = (coef_a_prime * t) + coef_b_prime
        else
          t_staffing = 0
      end
      trapeze_theorical_staffing_values << ["#{t}", t_staffing]
    end
    @staffing_custom_data.trapeze_chart_theoretical_coordinates = trapeze_theorical_staffing_values
    begin
      @staffing_custom_data.save
    rescue
      # ignored
    end

    ##### Rayleigh

    rayleigh_chart_theoretical_coordinates = []

    form_coef = -Math.log(1-0.97) / (@duration * @duration)
    @staffing_custom_data.form_coef = form_coef

    t_max_staffing = Math.sqrt(1/(2*form_coef))
    @staffing_custom_data.t_max_staffing = t_max_staffing

    for t in 0..@duration
      t_staffing = (@staffing_custom_data.global_effort_value * @staffing_model.standard_unit_coefficient.to_f / @staffing_model.effort_week_unit) * form_coef * t * Math.exp(-form_coef*t*t)
      rayleigh_chart_theoretical_coordinates << ["#{t}", (2 * t_staffing)]
    end

    @staffing_custom_data.rayleigh_chart_theoretical_coordinates = rayleigh_chart_theoretical_coordinates

    begin
      @staffing_custom_data.save
    rescue
      # ignored
    end

    update_staffing_estimation_values

    @module_project = current_module_project
    @project = @module_project.project

    ViewsWidget::update_field(@module_project, current_organization, @project, current_component)

    # Reset all view_widget results
    ViewsWidget.reset_nexts_mp_estimation_values(@module_project, current_component)
    @module_project.all_nexts_mp_with_links.each do |module_project|
      ViewsWidget::update_field(module_project, current_organization, @project, current_component, true)
    end

    redirect_to :back
  end

  #Save Team/Staffing custom data
  def old_save_staffing_custom_data
    authorize! :execute_estimation_plan, @project

    @component = current_component
    @module_project = current_module_project
    @staffing_model = @module_project.staffing_model
    trapeze_default_values = @staffing_model.trapeze_default_values

    @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).first
    @staffing_model.trapeze_default_values =  { :x0 => trapeze_default_values[:x0],
                                                :y0 => trapeze_default_values[:y0],
                                                :x1 => trapeze_default_values[:x1],
                                                :x2 => trapeze_default_values[:x2],
                                                :x3 => trapeze_default_values[:x3],
                                                :y3 => trapeze_default_values[:y3] }

    if @staffing_custom_data.nil?
      @staffing_custom_data = Staffing::StaffingCustomDatum.create( staffing_model_id: @staffing_model.id,
                                                                    module_project_id: @module_project.id,
                                                                    pbs_project_element_id: @component.id,
                                                                    mc_donell_coef: 6,
                                                                    puissance_n: 0.33,
                                                                    trapeze_default_values: { :x0 => trapeze_default_values[:x0],
                                                                                              :y0 => trapeze_default_values[:y0],
                                                                                              :x1 => trapeze_default_values[:x1],
                                                                                              :x2 => trapeze_default_values[:x2],
                                                                                              :x3 => trapeze_default_values[:x3],
                                                                                              :y3 => trapeze_default_values[:y3] },
                                                                    trapeze_parameter_values: { :x0 => trapeze_default_values[:x0],
                                                                                                :y0 => trapeze_default_values[:y0],
                                                                                                :x1 => trapeze_default_values[:x1],
                                                                                                :x2 => trapeze_default_values[:x2],
                                                                                                :x3 => trapeze_default_values[:x3],
                                                                                                :y3 => trapeze_default_values[:y3] } )
    end

    if @staffing_custom_data.update_attributes(params[:staffing_custom_datum])

      @staffing_custom_data.global_effort_value = params[:staffing_custom_datum]['global_effort_value']
      @staffing_custom_data.staffing_constraint = params[:option_radios]
      @staffing_custom_data.trapeze_parameter_values = @staffing_model.trapeze_default_values
      @staffing_custom_data.save

      constraint = @staffing_custom_data.staffing_constraint

      effort = @staffing_custom_data.global_effort_value.to_f * @staffing_model.standard_unit_coefficient.to_f / (@staffing_model.effort_week_unit.nil? ? 1 : @staffing_model.effort_week_unit.to_f)

      # =====================================================================================================================================
      # Trapeze
      trapeze_parameter_values = @staffing_custom_data.trapeze_parameter_values

      # Calcul des vraies valeurs de (x0, x1, x2, x3) en % de la durée D ; et  (y0, y3) en % de M
      x0 = trapeze_parameter_values[:x0].to_f / 100
      x1 = trapeze_parameter_values[:x1].to_f / 100
      x2 = trapeze_parameter_values[:x2].to_f / 100
      x3 = trapeze_parameter_values[:x3].to_f / 100
      y0 = trapeze_parameter_values[:y0].to_f / 100
      y3 = trapeze_parameter_values[:y3].to_f / 100

      if constraint == "max_staffing_constraint"
        @staffing_trapeze = @staffing_custom_data.max_staffing

        @duration = (2 * effort / @staffing_trapeze) / ((x3 + x2 - x1 - x0 + y0 * (x1 - x0) + y3 * (x3 - x2)))

        @staffing_custom_data.duration = @duration

      elsif constraint == "duration_constraint"

        @duration = (@staffing_custom_data.duration == 0) ? (@staffing_model.mc_donell_coef * (effort * @staffing_model.standard_unit_coefficient.to_f / @staffing_model.effort_week_unit) ** @staffing_model.puissance_n) : @staffing_custom_data.duration

        @staffing_trapeze = (2 * effort / (@duration.nil? ? 1 : @duration)) / ((x3 + x2 - x1 - x0 + y0 * (x1 - x0) + y3 * (x3 - x2)))

        @staffing_custom_data.max_staffing = @staffing_trapeze
      end

      x0D = x0 * @duration
      x1D = x1 * @duration
      x2D = x2 * @duration
      x3D = x3 * @duration

      # Calcul de a, b, a', b' avec
      # a = M(1 - y0) / D(x1 - x2)
      coef_a = (@staffing_trapeze*(1-y0)) / (@duration*(x1-x0))
      @staffing_custom_data.coef_a = coef_a

      # b = M(x1y0 - x0) / (x1 - x0)
      coef_b = (@staffing_trapeze * ((x1*y0) - x0)) / (x1-x0)
      @staffing_custom_data.coef_b = coef_b

      # a' = M(1 - y3) / D(x2 - x3)
      coef_a_prime = (@staffing_trapeze*(1-y3)) / (@duration * (x2-x3))
      @staffing_custom_data.coef_a_prime = coef_a_prime

      # b' = M(x2y3 - x3) / D(x2 - x3)
      coef_b_prime = (@staffing_trapeze * ((x2*y3) - x3)) / (x2-x3)
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
            t_staffing = @staffing_trapeze

          #intervalle_4 = x(semaine) compris dans ]x2*D ; x3*D]   =>  f(x) = a'x+b'
          when x2D..x3D
            t_staffing = (coef_a_prime * t) + coef_b_prime

          #intervalle_5 = x(semaine) compris dans ]x3*D ; infini[  => f(x) = 0
          else
            t_staffing = 0
        end

        trapeze_theorical_staffing_values << ["#{t}", t_staffing]
      end

      begin
        @staffing_custom_data.trapeze_chart_theoretical_coordinates = trapeze_theorical_staffing_values
        @staffing_custom_data.save
      rescue
        # ignored
      end

      # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
      rayleigh_chart_theoretical_coordinates = []
      mcdonnell_chart_theorical_coordinates = []


      # =====================================================================================================================================
      # Rayleigh
      # Contrainte de Staffing Max

      @staffing_rayleigh = @staffing_custom_data.max_staffing_rayleigh

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
      @staffing_custom_data.max_staffing_rayleigh = max_staffing

      for t in 0..@duration
        # E(t) = 2 * K * a * t * e(-a*t*t)
        t_staffing = 1 * effort * form_coef * t * Math.exp(-form_coef*t*t)
        rayleigh_chart_theoretical_coordinates << ["#{t}", 2 * t_staffing]
        if params[:actuals].present?
          actual_staffing_values << params[:actuals].to_a.map{|i| [i.first.to_f, i.last.to_f]}
        else
          actual_staffing_values << ["#{t}", 2 * t_staffing]
        end
      end
      @staffing_custom_data.rayleigh_chart_theoretical_coordinates = rayleigh_chart_theoretical_coordinates



      # =====================================================================================================================================

      #For mcdonnell
      @md_duration = @staffing_model.mc_donell_coef * effort ** @staffing_model.puissance_n

      # coefficient de forme : a
      form_coef = -Math.log(1-0.97) / (@md_duration * @md_duration)
      @staffing_custom_data.form_coef = form_coef

      # coefficient de difficulté
      difficulty_coef = 2*effort*form_coef
      @staffing_custom_data.difficulty_coef = difficulty_coef

      # numero de la semaine au Pic de Staffing
      t_max_staffing = Math.sqrt(1/(2*form_coef))
      @staffing_custom_data.t_max_staffing = t_max_staffing

      # MAx Staffing
      #max_staffing = effort / (t_max_staffing * Math.sqrt(Math.exp(1)))
      # @staffing_custom_data.max_staffing_rayleigh = @staffing

      for t in 0..@md_duration
        # E(t) = 2 * K * a * t * e(-a*t*t)
        t_staffing = 1 * effort * form_coef * t * Math.exp(-form_coef*t*t)
        mcdonnell_chart_theorical_coordinates << ["#{t}", 2 * t_staffing]
      end
      @staffing_custom_data.mcdonnell_chart_theorical_coordinates = mcdonnell_chart_theorical_coordinates

      if params["actuals_based_on"].present?
        if params["actuals_based_on"]["mcdonell"]
          @staffing_custom_data.duration = @md_duration
          @staffing_custom_data.save
        end
      end

      if params["actuals_based_on"].present?
        if params["actuals_based_on"]["custom"]
          if params[:actuals].present?
            @staffing_custom_data.chart_actual_coordinates = actual_staffing_values.first
          end
        else
          @staffing_custom_data.chart_actual_coordinates = trapeze_theorical_staffing_values
        end
      end
    end

    begin
      @staffing_custom_data.save
    rescue
      # ignored
    end

    update_staffing_estimation_values

    @module_project = current_module_project
    @project = @module_project.project

    ViewsWidget::update_field(@module_project, current_organization, @project, current_component)

    # Reset all view_widget results
    ViewsWidget.reset_nexts_mp_estimation_values(@module_project, current_component)
    @module_project.all_nexts_mp_with_links.each do |module_project|
      ViewsWidget::update_field(module_project, current_organization, @project, current_component, true)
    end

    redirect_to :back
  end

  private
  #Update estimation values
  def update_staffing_estimation_values
    @staffing_model = @module_project.staffing_model
    @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).last #first

    current_mp  = current_module_project

    current_mp.pemodule.attribute_modules.each do |am|
      in_out = []

      if am.in_out == "both"
        in_out = ["input", "output"]
      else
        in_out = ["#{am.in_out}"]
      end

      evs = EstimationValue.where(:organization_id => current_mp.organization_id, :module_project_id => current_mp.id, :pe_attribute_id => am.pe_attribute.id, in_out: in_out)

      evs.each do |ev|
        #ev = EstimationValue.where(:organization_id => current_mp.organization_id, :module_project_id => current_mp.id, :pe_attribute_id => am.pe_attribute.id).first
        tmp_prbl = Array.new

        ["low", "most_likely", "high"].each do |level|

          if @staffing_model.three_points_estimation?
            size = params[:"retained_size_#{level}"].to_f
          else
            size = params[:"retained_size_most_likely"].to_f
          end

          # new_effort = params[:new_effort]
          # new_duration = params[:new_duration]
          # new_staffing_rayleigh = params[:new_staffing_rayleigh]
          # new_staffing_trapeze = params[:new_staffing_trapeze]

          if am.pe_attribute.alias == "effort" && ev.in_out == "input"
            ev.send("string_data_#{level}")[current_component.id] = @staffing_custom_data.standard_effort.to_f * @staffing_model.standard_unit_coefficient.to_f
            ev.save
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]

          elsif am.pe_attribute.alias == "effort" && ev.in_out == "output"
            ev.send("string_data_#{level}")[current_component.id] = @staffing_custom_data.global_effort_value.to_f * @staffing_model.standard_unit_coefficient.to_f
            ev.save
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]

          elsif am.pe_attribute.alias == "duration"
            ev.send("string_data_#{level}")[current_component.id] = @staffing_custom_data.duration
            ev.save
            tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
          elsif am.pe_attribute.alias == "staffing"
            ev.send("string_data_#{level}")[current_component.id] = @staffing_custom_data.max_staffing
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
end
