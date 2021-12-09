require 'sidekiq-scheduler'
require 'fileutils'

class DeleteRawDataExtractionFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    #Dir.glob(Rails.root.join('public', 'extraction_files', '*')).each do |filename|
    Dir.glob(Rails.root.join('public', SETTINGS['EXTRACTION_FILES_PATH'], '*')).each do |filename|
      #File.delete(filename) if File.exist?(filename)
      # should_skip = File.basename( f ) =~ /^Counters.dat$/
      if File.basename(filename) != "dummy_extraction_file.xlsx"
        puts "Suppression des fichiers d'extraction des données brutes"
        #File.delete(filename) if File.mtime(filename) < 10.minutes.ago
        #File.delete(filename) if File.mtime(filename) < 3.days.ago

        #if File.mtime(filename) < 2.minutes.ago
        if File.mtime(filename) < 3.days.ago
          FileUtils.rm filename
        end
      end
    end
  end

end

