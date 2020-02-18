# This file is used by Rack-based servers to start the application.

#require 'new_relic/rack/developer_mode'
#use NewRelic::Rack::DeveloperMode

require ::File.expand_path('../config/environment',  __FILE__)

# Test To call wordpress

use Rack::ReverseProxy do
  reverse_proxy /^\/support(\/.*)$/, 'https://estimancy.com/', :username => '', :password => '', :timeout => 500, :preserve_host => true
end

# End Test To call wordpress


run Projestimate::Application

