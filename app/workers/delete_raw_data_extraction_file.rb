require 'sidekiq-scheduler'

class DeleteRawDataExtractionFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    #Dir.glob(Rails.root.join('public', 'extraction_files', '*')).each do |filename|
    Dir.glob(Rails.root.join('public', SETTINGS['EXTRACTION_FILES_PATH'], '*')).each do |filename|
      #File.delete(filename) if File.exist?(filename)
      if filename != "dummy_extraction_file.xlsx"
        puts "Suppression des fichiers d'extraction des données brutes"
        #File.delete(filename) if File.mtime(filename) < 3.days.ago
        File.delete(filename) if File.mtime(filename) < 10.minutes.ago
      end
    end
  end

end

