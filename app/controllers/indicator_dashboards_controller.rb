class IndicatorDashboardsController < ApplicationController
  before_action :set_indicator_dashboard, only: [:show, :edit, :update, :destroy, :update_default_dashboards]
  after_action :update_default_dashboards, only: [:create, :update]

  def update_default_dashboards
    begin
      if @indicator_dashboard.is_default_dashboard?
       IndicatorDashboard.where(organization_id: @indicator_dashboard.organization_id).where.not(id: @indicator_dashboard.id).update_all(is_default_dashboard: false)
      end
    rescue
    end
  end


  # GET /indicator_dashboards
  # GET /indicator_dashboards.json
  def index
    @indicator_dashboards = IndicatorDashboard.all
  end

  # GET /indicator_dashboards/1
  # GET /indicator_dashboards/1.json
  def show
  end

  # GET /indicator_dashboards/new
  def new
    set_page_title I18n.t(:new_dashboard)
    @organization = Organization.find_by_id(params[:organization_id])
    @indicator_dashboard = IndicatorDashboard.new
  end

  # GET /indicator_dashboards/1/edit
  def edit
    set_page_title I18n.t(:edit_dashboard)
    @organization = @indicator_dashboard.organization
  end

  # POST /indicator_dashboards
  # POST /indicator_dashboards.json
  def create
    set_page_title I18n.t(:new_dashboard)

    @indicator_dashboard = IndicatorDashboard.new(indicator_dashboard_params)
    @organization = Organization.find_by_id(params['indicator_dashboard']['organization_id'])

    respond_to do |format|
      if @indicator_dashboard.save
        #format.html { redirect_to @indicator_dashboard, notice: 'Indicator dashboard was successfully created.' }
        format.html { redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_indicator_dashboards", item_title: 'indicator_dashboards', anchor: 'tabs-indicator_dashboards') }
        format.json { render action: 'show', status: :created, location: @indicator_dashboard }
      else
        format.html { render action: 'new' }
        format.json { render json: @indicator_dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indicator_dashboards/1
  # PATCH/PUT /indicator_dashboards/1.json
  def update
    set_page_title I18n.t(:edit_dashboard)
    @organization = @indicator_dashboard.organization

    respond_to do |format|
      if @indicator_dashboard.update(indicator_dashboard_params)
        #format.html { redirect_to @indicator_dashboard, notice: 'Indicator dashboard was successfully updated.' }
        format.html { redirect_to organization_global_kpis_path(@organization, partial_name: "tabs_kpi_indicator_dashboards", item_title: 'indicator_dashboards', anchor: 'tabs-indicator_dashboards') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @indicator_dashboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicator_dashboards/1
  # DELETE /indicator_dashboards/1.json
  def destroy
    @indicator_dashboard.destroy
    respond_to do |format|
      format.html { redirect_to indicator_dashboards_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indicator_dashboard
      @indicator_dashboard = IndicatorDashboard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indicator_dashboard_params
      params.require(:indicator_dashboard).permit(:organization_id, :name, :description, :is_default_dashboard, :show_name_description)
    end
end
