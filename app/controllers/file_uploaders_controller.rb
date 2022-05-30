=begin
class FileUploaderController < ApplicationController
   def index
     @file_uploader = FileUploader.all
   end

   def new
     @file_uploader = FileUploader.new
   end

   def create
     @file_uploader = FileUploader.new(file_params)

     if @file_uploader.save
       redirect_to file_uploader_path, notice: "The file #{@file_uploader.name} has been uploaded."
     else
       render "new"
     end
   end

   def destroy
     @resume = FileUploader.find(params[:id])
     @resume.destroy
     redirect_to file_uploader_path, notice:  "The file #{@file_uploader.name} has been deleted."
   end

   private
   def file_params
     params.require(:file_uploader).permit(:name, :attachment)
    end
end
=end