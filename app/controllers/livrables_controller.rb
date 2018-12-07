class LivrablesController < ApplicationController
  before_action :set_livrable, only: [:show, :edit, :update, :destroy]

  # GET /livrables
  # GET /livrables.json
  def index
    @livrables = Livrable.where(organization_id: params[:organization_id]).all
    @organization = Organization.find(params[:organization_id])
  end
  end

  # GET /livrables/1
  # GET /livrables/1.json
  def show
  end

  # GET /livrables/new
  def new
    @livrable = Livrable.new
    @organization = Organization.find(params[:organization_id])
  end

  # GET /livrables/1/edit
  def edit
  end

  # POST /livrables
  # POST /livrables.json
  def create
    @livrable = Livrable.new(params[:livrable])

    respond_to do |format|
      if @livrable.save
        flash[:notice] = "Livrable créé avec succès"
        redirect_to organization_livrables_path(@organization)
      else
        render action: 'new'
      end
    end
  end

  # PATCH/PUT /livrables/1
  # PATCH/PUT /livrables/1.json
  def update
    respond_to do |format|
      if @livrable.update(livrable_params)
        format.html { redirect_to @livrable, notice: 'Livrable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @livrable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /livrables/1
  # DELETE /livrables/1.json
  def destroy
    @livrable.destroy
    respond_to do |format|
      format.html { redirect_to livrables_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_livrable
      @livrable = Livrable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def livrable_params
      params.require(:livrable).permit(:name, :description, :state, :organization_id)
    end
