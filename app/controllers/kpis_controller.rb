class KpisController < ApplicationController

  def new
    set_page_title I18n.t(:new_kpi)
    @kpi = Kpi.new
    @organization = Organization.find_by_id(params[:organization_id])

    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
    set_breadcrumbs I18n.t(:kpis) => organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators'), I18n.t('new_kpi') => ""
  end


  def edit
    @kpi = Kpi.find(params[:id])
    @organization = @kpi.organization

    set_page_title I18n.t(:edit_kpi, value: @kpi.name)
    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", @organization.to_s => edit_organization_path(@organization)
  end



  def create
    params[:kpi].permit!
    @kpi = Kpi.new(params[:kpi])
    @organization = Organization.find_by_id(params['kpi']['organization_id'])

    set_page_title I18n.t(:new_kpi)
    #set_breadcrumbs I18n.t(:kpis) => organization_setting_path(@organization, anchor: "tabs-kpi"), I18n.t('new_kpi') => ""

    @kpi.start_date = @kpi.start_date.beginning_of_day rescue nil
    @kpi.end_date = @kpi.end_date.end_of_day rescue nil

    start_date = params[:kpi][:start_date]
    end_date = params[:kpi][:end_date]
    # kpi_start_date = @kpi.start_date.beginning_of_day rescue nil
    # kpi_end_date = @kpi.end_date.end_of_day rescue nil

    if start_date.blank? || end_date.blank?
      start_and_end_date_array = calculate_start_end_dates(params[:kpi])
      new_start_date = start_and_end_date_array.first
      new_end_date = start_and_end_date_array.last

      if start_date.blank?
        kpi_start_date = new_start_date.beginning_of_day rescue nil
        @kpi.start_date = kpi_start_date
      end

      if end_date.blank?
        kpi_end_date = new_end_date.end_of_day rescue nil
        @kpi.end_date = kpi_end_date
      end
    end


    if @kpi.save
      #redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_productivity")
      redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
    else
      render action: 'new'
    end
  end


  def update
    params[:kpi].permit!
    @kpi = Kpi.find(params[:id])
    @organization = @kpi.organization

    #set_page_title I18n.t(:edit_kpi, value: @kpi.name)
    #set_breadcrumbs I18n.t(:organizations) => "/all_organizations?organization_id=#{@organization.id}", "#{@organization.to_s} / #{I18n.t(:kpis)} / #{@kpi.to_s}" => edit_organization_path(@organization)

    start_date = params[:kpi][:start_date]
    end_date = params[:kpi][:end_date]

    if @kpi.update_attributes(params[:kpi])

      kpi_start_date = @kpi.start_date.beginning_of_day rescue nil
      kpi_end_date = @kpi.end_date.end_of_day rescue nil

      if start_date.blank? || end_date.blank?
        start_and_end_date_array = calculate_start_end_dates(params[:kpi])
        new_start_date = start_and_end_date_array.first
        new_end_date = start_and_end_date_array.last

        if start_date.blank?
          kpi_start_date = new_start_date.beginning_of_day rescue nil
        end

        if end_date.blank?
          kpi_end_date = new_end_date.end_of_day rescue nil
        end
      end

      #on sauvegarde les valeurs du KPI
      orga_ctr = OrganizationsController.new
      calculation_output = orga_ctr.get_indicators_dashboard_kpi_values(@organization.id, @kpi.id)

      @kpi.update_attributes(start_date: kpi_start_date, end_date: kpi_end_date, indicator_result: calculation_output)

      #flash[:notice] =  "#{I18n.t (:notice_kpi_successful_updated)}"
      #redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_productivity")
      redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
    else
      render action: 'edit'
    end
  end


  def destroy
    @organization = Organization.find(params[:organization_id])
    @kpi = Kpi.find(params[:id])

    @kpi.destroy

    flash[:notice] = I18n.t(:notice_kpi_successful_deleted)
    #redirect_to organization_authorization_path(@organization, partial_name: 'tabs_authorization_groups', item_title: I18n.t('groups'), anchor: "tabs-group")
    redirect_to organization_setting_path(@organization, partial_name: 'tabs_indicators', item_title: I18n.t('indicators'), anchor: 'tabs-indicators')
  end

  #Update the module_project corresponding data of view
  def update_productivity_kpi_field
    estimation_model_id = params['estimation_model_id']

    if !estimation_model_id.nil? && estimation_model_id != 'undefined'

      @estimation_model = Project.find(estimation_model_id)

      @estimation_model_project_fields = @estimation_model.project_fields
      @estimation_model_fields = []

      @estimation_model_project_fields.each do |pf|
        @estimation_model_fields << pf.field
      end
    end
  end

  private
  # Calculate Start date / End date
  def calculate_start_end_dates(kpi_params)
    #@kpi = Kpi.find(params[:id])

    period_start_date = kpi_params[:period_start_date] #@kpi.period_start_date
    period_end_date = kpi_params[:period_end_date] #@kpi.period_end_date

    period_start_date_history = kpi_params[:period_start_date_history].to_i #@kpi.period_start_date_history
    period_end_date_history = kpi_params[:period_end_date_history].to_i #@kpi.period_end_date_history

    start_date = kpi_params[:start_date]
    end_date = kpi_params[:end_date]

    if start_date.blank?
      start_date =  calculate_selected_date(period_start_date, period_start_date_history)
    end

    if end_date.blank?
      end_date =  calculate_selected_date(period_end_date, period_end_date_history)
    end

    [start_date, end_date]
  end



  def calculate_selected_date(period_selected_date, period_history)

    output_date = Date.new
    todays_date = Date.new

    case period_selected_date
      when "current_date"
        if period_history.blank?
          output_date = Date.today
        else
          output_date = Date.today + period_history.day
        end

      when "date_week"
        if period_history.blank?
          output_date = Date.today.beginning_of_week
        else
          output_date = Date.today.beginning_of_week + period_history.week
        end

      when "date_month"
        if period_history.blank?
          output_date = Date.today.beginning_of_month
        else
          output_date = Date.today.beginning_of_month + period_history.month
        end

      when "date_trimester"
        current_date_month = Date.today.month
        orga_ctr = OrganizationsController.new
        trimester_month = orga_ctr.get_trimester_beginning_month( (((current_date_month - 1) / 3) + 1).floor, Date.today.year)

        if period_history.blank?
          output_date = trimester_month.beginning_of_month
        else
          output_date = trimester_month.beginning_of_month + (period_history*3).month
        end

      when "date_semester"
        current_date_month = Date.today.month
        orga_ctr = OrganizationsController.new

        trimester_month = orga_ctr.get_semester_beginning_month( (((current_date_month - 1) / 6) + 1).floor, Date.today.year )

        if period_history.blank?
          output_date = trimester_month.beginning_of_month
        else
          output_date = trimester_month.beginning_of_month + (period_history*6).month
        end

      when "date_year"
        if period_history.blank?
          output_date = Date.today.beginning_of_year
        else
          output_date = Date.today.beginning_of_year + period_history.year
        end

      #when "enter_date"
    end

    output_date
  end

end
