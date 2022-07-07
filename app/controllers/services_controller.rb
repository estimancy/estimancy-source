class ServicesController < ApplicationController

  def index
    @services = Service.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_service'))
    @service = Service.new
    @organization = Organization.find(params[:organization_id])
  end

  # GET /services/1/edit
  def edit
    set_page_title (I18n.t('edit_service'))
    @service = Service.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  # POST /services
  # POST /services.json
  def create
    set_page_title (I18n.t('create_service'))
    @service = Service.new(params[:service])
    @organization = Organization.find(params[:organization_id])
    if @service.save
      flash[:notice] = "Service créé avec succès"
    end

    redirect_to :back
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json

  #def update
    #@service = Service.find(params[:id])
    #@organization = Organization.find(params[:organization_id])

    #respond_to do |format|
      #if @service.update(params[:service])
        #format.html { redirect_to organization_services_url(@service), notice: 'Service was successfully updated.' }
        #format.html { redirect_to :back, notice: 'Service was successfully updated.' }
        #format.json { head :no_content }
      #else
        #format.html { render action: 'edit' }
        #format.json { render json: @service.errors, status: :unprocessable_entity }
      #end
    #end

    #end
  #end

  def update
    @service = Service.find(params[:id])
    @service.update(params[:service])

    if @service.save
      flash[:notice] = "Service mis à jour avec succès"
    end

    redirect_to :back

  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service = Service.find(params[:id])
    @service.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end