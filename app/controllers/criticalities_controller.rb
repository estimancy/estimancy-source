class CriticalitiesController < ApplicationController
  def index
    @criticalities = Criticality.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_criticality'))
    @criticality = Criticality.new
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    set_page_title (I18n.t('edit_criticality'))
    @criticality = Criticality.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def create
    set_page_title (I18n.t('create_criticality'))
    @criticality = Criticality.new(params[:criticality])
    @organization = Organization.find(params[:organization_id])
    if @criticality.save
      flash[:notice] = "Criticality créé avec succès"
    end

    redirect_to :back
  end


  def update
    @criticality = Criticality.find(params[:id])
    @criticality.update(params[:criticality])

    if @criticality.save
      flash[:notice] = "Criticality mis à jour avec succès"
    end

    redirect_to :back

  end

  def destroy
    @criticality = Criticality.find(params[:id])
    @criticality.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end
