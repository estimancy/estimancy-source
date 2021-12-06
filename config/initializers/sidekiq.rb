# Sidekiq config

# Sidekiq.configure_server do |config|
#   require 'periodic_jobs'
#
#   config.periodic do |manager|
#     manager.tz = ActiveSupport::TimeZone.new("France")
#     #manager.register("0 4 * * *", "DeleteRawDataExtractionFileWorker")
#     manager.register("* 12 * * *", "DeleteRawDataExtractionFileWorker")
#   end
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://redis.example.com:7372/0' }
# end


# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://localhost:6379/0' }   # config.redis = { url: 'redis://redis.example.com:7372/0' }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://localhost:6379/0' }
# end