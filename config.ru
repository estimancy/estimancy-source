# This file is used by Rack-based servers to start the application.

#require 'new_relic/rack/developer_mode'
#use NewRelic::Rack::DeveloperMode

require ::File.expand_path('../config/environment',  __FILE__)

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

# Test To call wordpress

use Rack::ReverseProxy do
  reverse_proxy /^\/support(\/.*)$/, 'https://estimancy.com/', :username => '', :password => '', :timeout => 500, :preserve_host => true
end

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run Projestimate::Application

