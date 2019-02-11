class DemandTypesController < ApplicationController

  def index
    @demand_types = DemandType.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_demand_statuses'))
    @demand_type = DemandType.new
    @organization = Organization.find(params[:organization_id])
  end

  def create
    set_page_title (I18n.t('create_demand_statuses'))
    @demand_type = DemandType.new(params[:demand_type])
    @organization = Organization.find(params[:organization_id])

    if @demand_type.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end

  end

  def update
    @demand_type = DemandType.find(params[:id])
    @demand_type.update(params[:demand_type])

    @organization = @demand_type.organization
    @organization.demand_statuses.each do |ds|

      unless params["percent_#{ds.id}"].blank?
        pc = params["percent_#{ds.id}"].to_f
        dsdt = DemandStatusesDemandType.where(organization_id: @organization.id,
                                             demand_type_id: @demand_type.id,
                                             demand_status_id: ds.id).first
        if dsdt.nil?
          DemandStatusesDemandType.create(organization_id: @organization.id,
                                        demand_type_id: @demand_type.id,
                                        demand_status_id: ds.id,
                                        percent: pc)
        else
          dsdt.percent = pc
          dsdt.save
        end
      end
    end


    @organization.criticalities.each do |criticality|
      @organization.severities.each do |severity|

        unless params["duration_#{criticality.id}_#{severity.id}"].blank?

          duration = params["duration_#{criticality.id}_#{severity.id}"].to_f

          origin = DemandStatus.where(name: params["origin_status_#{criticality.id}_#{severity.id}"].to_i).first
          target = DemandStatus.where(name: params["target_status_#{criticality.id}_#{severity.id}"].to_i).first

          cs = CriticalitySeverity.where(organization_id: @organization.id,
                                         criticality_id: criticality.id,
                                         severity_id: severity.id).first

          if cs.nil?
            CriticalitySeverity.create(organization_id: @organization.id,
                                       criticality_id: criticality.id,
                                       severity_id: severity.id,
                                       duration: duration)
          else
            cs.duration = duration
            cs.save
          end

        end
      end
    end

    if @demand_type.save
      flash[:notice] = "Demande mise à jour avec succès"
    end

    redirect_to :back

  end

  def edit
    set_page_title (I18n.t('edit_demand_types'))
    @demand_type = DemandType.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  def destroy
    @demand_type = DemandType.find(params[:id])
    @demand_type.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end