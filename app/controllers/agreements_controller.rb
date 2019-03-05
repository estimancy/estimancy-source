class AgreementsController < ApplicationController

  def new
    set_page_title (I18n.t('new_demand_statuses'))
    @agreement = Agreement.new
    @demand_type = DemandType.find(params[:demand_type_id])
    @organization = Organization.find(params[:organization_id])
  end

  def create
    set_page_title (I18n.t('create_demand_statuses'))

    @agreement = Agreement.new(params[:agreement])

    @demand_type = DemandType.find(params[:demand_type_id].to_i)
    @organization = Organization.find(params[:organization_id].to_i)

    @agreement.demand_type_id = @demand_type.id
    @agreement.organization_id = @organization.id

    if @agreement.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to :back
    else
      render action: 'new'
    end

  end

  def edit
    set_page_title (I18n.t('edit_agreeements'))
    @agreement = Agreement.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def update
    @agreement = Agreement.find(params[:id])
    @agreement.update(params[:agreement])
    
    if @agreement.save
      flash[:notice] = "Demande mise à jour avec succès"
    end

    redirect_to :back
  end
  
  def destroy
    @agreement = Agreement.find(params[:id])
    @agreement.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end