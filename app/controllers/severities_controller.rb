class SeveritiesController < ApplicationController
    def index
        @severities = Severity.all
        @organization = Organization.find(params[:organization_id])
      end

      def new
        set_page_title (I18n.t('new_severity'))
        @severity = Severity.new
        @organization = Organization.find(params[:organization_id])
      end

      def edit
        set_page_title (I18n.t('edit_severity'))
        @severity = Severity.find(params[:id])
        @organization = Organization.find(params[:organization_id])
      end

      def create
        set_page_title (I18n.t('create_severity'))
        @severity = Severity.new(params[:severity])
        @organization = Organization.find(params[:organization_id])
        if @severity.save
          flash[:notice] = "Severity créé avec succès"
        end

        redirect_to :back
      end


      def update
        @severity = Severity.find(params[:id])
        @severity.update(params[:severity])

        if @severity.save
          flash[:notice] = "Severity mis à jour avec succès"
        end

        redirect_to :back

      end

      def destroy
        @severity = Severity.find(params[:id])
        @severity.destroy
        respond_to do |format|
          format.html { redirect_to :back }
          format.json { head :no_content }
        end
      end
end
