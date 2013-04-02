# This file is used by Rack-based servers to start the application.

require 'new_relic/rack/developer_mode'
use NewRelic::Rack::DeveloperMode

require ::File.expand_path('../config/environment',  __FILE__)
run ProjestimateMaquette::Application

