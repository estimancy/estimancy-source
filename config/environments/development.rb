#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

#require 'openssl'

Projestimate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make codefalse changes.
  config.cache_classes = false

  config.reload_plugins = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  # config.active_support.deprecation = :debug

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_controller.perform_caching = true

  #Default URL option
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.default_url_options = { host: APP_CONFIG['HOST_URL'] }
  config.eager_load = false

  # For Bullet gem
  config.after_initialize do
    Bullet.enable = true
    #Bullet.sentry = true
    #Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true

    # Bullet.growl = true
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }

    # Bullet.honeybadger = true
    # Bullet.bugsnag = true
    # Bullet.appsignal = true
    # Bullet.airbrake = true
    # Bullet.rollbar = true
    # Bullet.add_footer = true
    # Bullet.skip_html_injection = false
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware', ['my_file.rb', 'my_method'], ['my_file.rb', 16..20] ]
    # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
  end

end