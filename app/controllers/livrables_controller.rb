class LivrablesController < ApplicationController

  def index
     @livrables = Livrable.where(organization_id: params[:organization_id]).all
    #@livrables = Livrable.all
    @organization = Organization.find(params[:organization_id])
  end

  def new
    set_page_title (I18n.t('new_livrable'))
    @livrable = Livrable.new
    @organization = Organization.find(params[:organization_id])
  end

  # GET /livrables/1/edit
  def edit
    set_page_title (I18n.t('edit_livrable'))
    @livrable = Livrable.find(params[:id])
    @organization = Organization.find(params[:organization_id])
  end

  # POST /livrables
  # POST /livrables.json
  def create
    set_page_title (I18n.t('create_livrable'))
    @livrable = Livrable.new(params[:livrable])
    @organization = Organization.find(params[:organization_id])

    if @livrable.save
      flash[:notice] = "Livrable créé avec succès"
      #redirect_to organization_livrables_path(@organization)
      #redirect_to :back
    end
      #render action: 'new'
      redirect_to :back

  end

  # PATCH/PUT /livrables/1
  # PATCH/PUT /livrables/1.json
  #def update
    #@livrable = Livrable.find(params[:id])

    #respond_to do |format|
       #if @livrable.update(params[:livrable])
        #format.html { redirect_to :back, notice: 'Livrable was successfully updated.' }
        #format.json { head :no_content }
      #else
        #format.html { render action: 'edit' }
        #format.json { render json: @livrable.errors, status: :unprocessable_entity }
      #end
    #end
  #end


  def update
    @livrable = Livrable.find(params[:id])
    @livrable.update(params[:livrable])

    if @livrable.save
      flash[:notice] = "Livrable mise à jour avec succès"
    end

    redirect_to :back
  end
  # DELETE /livrables/1
  # DELETE /livrables/1.json
  def destroy
    @livrable = Livrable.find(params[:id])
    @livrable.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end
end