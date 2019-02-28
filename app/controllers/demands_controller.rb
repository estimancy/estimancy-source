class DemandsController < ApplicationController

  def index
    set_page_title "Liste des demandes"

    @demands = Demand.where(organization_id: params[:organization_id]).order("created_at ASC")
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    set_page_title (I18n.t('edit_demand'))
    @demand = Demand.find(params[:id])
    @organization = Organization.find(params[:organization_id])
    @uploader = AttachmentUploader.new


    @organization.services.each do |s|
      unless s.livrable.nil?
        ServiceDemandLivrable.where(organization_id: @organization.id,
                                    service_id: s.id,
                                    demand_id: @demand.id,
                                    livrable_id: s.livrable.id).first_or_create(contract_date: nil,
                                                                                delivered: true,
                                                                                delayed: nil)
      end
    end

    get_estimations
  end

  def new
    set_page_title (I18n.t('new_demand'))
    @demand = Demand.new
    @organization = Organization.find(params[:organization_id])
    @demand.attachment = params[:attachment]
  end

  def create
    set_page_title (I18n.t('create_demand'))
    @demand = Demand.new(params[:demand])
    @organization = Organization.find(params[:organization_id])

    if @demand.save

      StatusHistory.create(organization: @organization.name,
                           demand: @demand.name,
                           change_date: Time.now,
                           action: "Création de la demande",
                           origin: nil,
                           target: @organization.demand_statuses.first.nil? ? nil : @organization.demand_statuses.first.name,
                           user: current_user.name)

      @organization.services.each do |s|
        unless s.livrable.nil?
          ServiceDemandLivrable.create(organization_id: @organization.id,
                                       service_id: s.id,
                                       demand_id: @demand.id,
                                       livrable_id: s.livrable.id,
                                       contract_date: nil,
                                       delivered: true,
                                       delayed: nil)
        end
      end

      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end
  end

  def update
    @organization = Organization.find(params[:organization_id])
    @demand = Demand.find(params[:id])

    new_demand_statut = DemandStatus.find_by_id(params[:demand][:demand_status_id])

    if @demand.demand_status_id != params[:demand][:demand_status_id]
      StatusHistory.create(organization: @organization.name,
                           demand: @demand.name,
                           change_date: Time.now,
                           action: "Changement de statut",
                           origin: @demand.demand_status.nil? ? nil : @demand.demand_status.name,
                           target: new_demand_statut.nil? ? nil : new_demand_statut.name,
                           user: current_user.name)
    end

    @demand.update(params[:demand])

    @uploader = AttachmentUploader.new
    @uploader.store!(params[:attachment])

    if @demand.save

      @organization.services.each do |s|

        sdl = ServiceDemandLivrable.where(organization_id: @organization.id,
                                          service_id: params["service_#{s.id}"].to_i,
                                          demand_id: @demand.id).first

        unless sdl.nil?

          unless params["contract_date"].nil?
            sdl.contract_date = params["contract_date"]["#{s.id}"]
          end

          unless params["expected_date"].nil?
            sdl.expected_date = params["expected_date"]["#{s.id}"]
          end

          unless params["actual_date"].nil?
            sdl.actual_date = params["actual_date"]["#{s.id}"]
          end

          unless params["state"].nil?
            sdl.state = params["state"]["#{s.id}"]
          end

          unless params["selected"].nil?
            sdl.selected = params["selected"]["#{s.id}"]
          end

          # sdl.delivered = params["delivered"]["#{s.id}"]
          # sdl.delayed = params["delayed"]["#{s.id}"]
          sdl.save
        end
      end

      flash[:notice] = "Demande mise à jour avec succès"
      redirect_to :back
    end

  end

  def delete
    @demand = Demand.find(params[:demand_id])
    @demand.remove_attachment!
    @demand.save

    redirect_to :back
  end

  def destroy
    @demand = Demand.find(params[:id])
    @demand.remove_attachment!
    @demand.save

    @demand.delete

    redirect_to root_url
  end

  def export_billing

    @organization = Organization.find(params[:organization_id])

    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]

    worksheet.add_cell(0, 0, "Nom")
    worksheet.add_cell(0, 1, "Date")

    worksheet.add_cell(0, 2, "Montant Total (€)")

    worksheet.add_cell(0, 3, "Statut")
    worksheet.add_cell(0, 4, "Date")
    worksheet.add_cell(0, 5, "Montant")

    worksheet.add_cell(0, 6, "Statut")
    worksheet.add_cell(0, 7, "Date")
    worksheet.add_cell(0, 8, "Montant")

    # nom demande | date | montant total | date passage statut1 | montant 1 (pourcentage précédent) | date passage statut2 | montant 2 (pourcentage precednt) | etc...

    dsdts = []
    @organization.demands.each_with_index do |demand, index|
      if demand.demand_type.billing == "Echéance"
        worksheet.add_cell(index + 1, 0, demand.name)
        worksheet.add_cell(index + 1, 1, demand.created_at.to_s)
        worksheet.add_cell(index + 1, 2, demand.cost.to_f * 1000)

        shs = StatusHistory.where(organization: @organization.name, demand: demand.name).all
        shs.each do |sh|
          ds = DemandStatus.where(organization_id: @organization.id, name: sh.target).first

          unless ds.nil?
            dsdts << DemandStatusesDemandType.where(organization_id: @organization.id,
                                                    demand_type_id: demand.demand_type_id,
                                                    demand_status_id: ds.id).first
          end

          j = 0
          dsdts.compact.each do |dsdt|
            worksheet.add_cell(index + 1, 3+j, dsdt.demand_status.name)
            worksheet.add_cell(index + 1, 4+j, sh.change_date.to_s)
            worksheet.add_cell(index + 1, 5+j, ((demand.cost * 1000) * (dsdt.percent.to_f / 100)))
            j = j + 3
          end
        end
      elsif demand.demand_type.billing == "Abonnement"
        worksheet.add_cell(index + 1, 0, demand.name)
        worksheet.add_cell(index + 1, 1, demand.created_at.to_s)
      end
    end

    send_data(workbook.stream.string, filename: "#{@organization.name}-FACTURATION.xlsx", type: "application/vnd.ms-excel")
  end

  def estimations
    @organization = Organization.find(params[:organization_id])
    @demand = Demand.find(params[:demand_id])

    get_estimations
  end

  private def get_estimations
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => ""
    set_page_title I18n.t(:spec_estimations, parameter: @organization.to_s)

    if params[:filter_version].present?
      @filter_version = params[:filter_version]
    else
      @filter_version = '4'
    end

    @object_per_page = (current_user.object_per_page || 10)

    if params[:min].present? && params[:max].present?
      @min = params[:min].to_i
      @max = params[:max].to_i
    else
      @min = 0
      @max = @object_per_page
    end

    if session[:sort_action].blank?
      session[:sort_action] = "true"
    end

    if session[:sort_column].blank?
      session[:sort_column] = "start_date"
    end

    if session[:sort_order].blank?
      session[:sort_order] = "desc"
    end

    @sort_action = params[:sort_action].blank? ? session[:sort_action] : params[:sort_action]
    @sort_column = params[:sort_column].blank? ? session[:sort_column] : params[:sort_column]
    @sort_order = params[:sort_order].blank? ? session[:sort_order] : params[:sort_order]

    @search_column = session[:search_column]
    @search_value = session[:search_value]
    #@search_hash =  {} #session[:search_hash] || {}
    @search_hash = (params['search'].blank? ? session[:search_hash] : params['search'])
    @search_hash ||=  {}
    @search_string = ""

    # Pour garder le tri même lors du raffraichissement de la page

    projects = @demand.projects.where(:is_model => [nil, false])
    organization_projects = get_sorted_estimations(@organization.id, projects, @sort_column, @sort_order, @search_hash)

    res = []
    organization_projects.each do |p|
      if can?(:see_project, p, estimation_status_id: p.estimation_status_id)
        res << p
      end

    end

    @projects = res[@min..@max].nil? ? [] : res[@min..@max-1]

    last_page = res.paginate(:page => 1, :per_page => @object_per_page).total_pages
    @last_page_min = (last_page.to_i-1) * @object_per_page
    @last_page_max = @last_page_min + @object_per_page

    if params[:is_last_page] == "true" || (@min == @last_page_min)
      @is_last_page = "true"
    else
      @is_last_page = "false"
    end

    session[:sort_column] = @sort_column
    session[:sort_order] = @sort_order
    session[:sort_action] = @sort_action
    session[:is_last_page] = @is_last_page
    session[:search_column] = @search_column
    session[:search_value] = @search_value
    session[:search_hash] = @search_hash

    # @projects = check_for_projects(@min, @max)
    # @projects = check_for_projects(@min, @object_per_page)

    @fields_coefficients = {}
    @pfs = {}

    fields = @organization.fields
    ProjectField.where(project_id: @projects.map(&:id).uniq).each do |pf|
      begin
        if pf.field_id.in?(fields.map(&:id))
          if pf.project && pf.views_widget
            if pf.project_id == pf.views_widget.module_project.project_id
              @pfs["#{pf.project_id}_#{pf.field_id}".to_sym] = pf.value
            else
              pf.delete
            end
          else
            pf.delete
          end
        else
          pf.delete
        end

      rescue
        #puts "erreur"
      end
    end

    fields.each do |f|
      @fields_coefficients[f.id] = f.coefficient
    end

  end
end