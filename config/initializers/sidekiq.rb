# Sidekiq config

# Sidekiq.configure_server do |config|
#   config.redis = { url: 'redis://localhost:6379/0' }   # config.redis = { url: 'redis://redis.example.com:7372/0' }
#   config.redis = { :namespace => 'Saas', :url => 'redis://127.0.0.1:6379/1' }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = { url: 'redis://localhost:6379/0' }
#   config.redis = { :namespace => 'Saas', :url => 'redis://127.0.0.1:6379/1' }
# end



config_redis = {
  url: ENV.fetch('REDIS_URL_SIDEKIQ', SETTINGS['REDIS_URL_SIDEKIQ']),
  namespace: ENV.fetch('REDIS_NAMESPACE_SIDEKIQ', SETTINGS['REDIS_NAMESPACE_SIDEKIQ'])
}

Sidekiq.configure_server do |config|
  config.redis = config_redis
end

Sidekiq.configure_client do |config|
  config.redis = config_redis
end