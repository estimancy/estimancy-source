require 'sidekiq-scheduler'

class DeleteRawDataExtractionFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    puts "Deleting extraction files"
    #Dir.glob(Rails.root.join('public', 'extraction_files', '*')).each do |filename|
    Dir.glob(Rails.root.join('public', SETTINGS['EXTRACTION_FILES_PATH'], '*')).each do |filename|
      #File.delete(filename) if File.mtime(filename) < 3.days.ago #File.delete(filename) if File.exist?(filename)
      File.delete(filename) if File.mtime(filename) < 10.minutes.ago
    end
  end

end

