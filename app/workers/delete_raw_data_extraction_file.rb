class DeleteRawDataExtractionFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(filepath)
    File.delete(filepath) if File.exist?(filepath)
  end

end

