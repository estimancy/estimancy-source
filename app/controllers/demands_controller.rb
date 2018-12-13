class DemandsController < ApplicationController

  def index
    @demands = Demand.where(organization_id: params[:organization_id]).all
    @organization = Organization.find(params[:organization_id])
  end

  def edit
    @demand = Demand.find(params[:id])
    @organization = Organization.find(params[:organization_id])
    @uploader = AttachmentUploader.new
    @uploader.store!(params[:attachment])
  end

  def new
    @demand = Demand.new
    @organization = Organization.find(params[:organization_id])
    @demand.attachment = params[:attachment]
  end

  def create
    @demand = Demand.new(params[:demand])
    @organization = Organization.find(params[:organization_id])

   #  @organization.livrables.each do |livrable|
   #    ServiceDemandLivrable.create(organization_id: @organization.id,
   #                                  service_id: nil,
   #                                  demand_id: @demand.id,
   #                                  livrable_id: livrable.id,
   #                                  delivered: "red",
   #                                  delayed: nil)
   # end

    if @demand.save
      flash[:notice] = "Demande créee avec succès"
      redirect_to organization_demands_path(@organization)
    else
      render action: 'new'
    end
  end

  def update
    @organization = Organization.find(params[:organization_id])
    @demand = Demand.find(params[:id])
    @demand.update(params[:demand])

    @uploader = AttachmentUploader.new
    @uploader.store!(params[:attachment])

    if @demand.save
      flash[:notice] = "Demande mise à jour avec succès"
      redirect_to organization_demands_path(@organization)
    end

  end

  def delete
    @demand = Demand.find(params[:demand_id])
    @demand.remove_attachment!
    @demand.save
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