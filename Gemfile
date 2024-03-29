source 'https://rubygems.org'

# gem 'rails', '3.2.22'
gem 'rails', '4.2.11.1'
gem 'sprockets', '~> 3.7.2'

gem 'jquery-rails'
gem 'i18n'
gem 'builder'
gem 'cookies_eu'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'useragent'

# Include database gems for the adapters found in the database
# configuration file
gem 'mysql2', '~> 0.4.9' #'~> 0.3.11'
# gem 'pg','~> 0.15'
# require 'erb'
# require 'yaml'
# database_file = File.join(File.dirname(__FILE__), 'config/database.yml')
# if File.exist?(database_file)
#   database_config = YAML::load(ERB.new(IO.read(database_file)).result)
#   adapters = database_config.values.map { |c| c['adapter'] }.compact.uniq
#   if adapters.any?
#     adapters.each do |adapter|
#       case adapter
#         when 'mysql2'
#           if RUBY_PLATFORM =~ /i386-mingw32/
#             # do that since mysql2 version > 0.3.11 doesn't work properly on Windows
#             gem 'mysql2', '= 0.3.11', :platforms => [:mswin, :mingw]
#           else
#             gem 'mysql2', '~> 0.3.11', :platforms => :mri
#           end
#           gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
#         when 'mysql'
#           gem 'mysql', '~> 2.8.1', :platforms => [:mri, :mingw]
#           gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
#         when /postgresql/
#           gem 'pg', '>= 0.11.0', :platforms => [:mri, :mingw]
#           gem 'activerecord-jdbcpostgresql-adapter', :platforms => :jruby
#         when /sqlite3/
#           gem 'sqlite3', :platforms => [:mri, :mingw]
#           gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
#         when /sqlserver/
#           gem 'tiny_tds', '~> 0.5.1', :platforms => [:mri, :mingw]
#           gem 'activerecord-sqlserver-adapter', :platforms => [:mri, :mingw]
#         else
#           warn("Unknown database adapter `#{adapter}` found in config/database.yml, use Gemfile.local to load your own database gems")
#       end
#     end
#   else
#     warn('No adapter found in config/database.yml, please configure it first')
#   end
# else
#   warn('Please configure your config/database.yml first')
# end

#For PostgreSQL database
#gem 'pg'

gem 'curb', '~> 0.9.11' #sga to remove

#Permissions
#gem 'cancancan', '~> 1.10'
gem 'cancancan', '~> 3.2'

#Authentication for tests
gem 'warden'

#Tree
gem 'ancestry'

gem 'aescrypt'

gem 'net-ldap', '~> 0.3.1'

#Pagination library for Rails 3
gem 'will_paginate'
gem 'will_paginate-bootstrap'

#Searching
gem 'scoped_search'

#Workflow
gem 'aasm'

#Advanced form
gem 'simple_form'

#Icon management
gem 'paperclip', '~> 3.0'

#UUID generation tools
gem 'uuidtools'

#For deep copy of ActiveRecord object
gem 'amoeba', '~> 3.0.0'

# Required for rspec and rails command
#gem 'rb-readline'

#Optional gem for monitoring
# group :ic do
#   gem 'newrelic_rpm'
#   gem 'coveralls', :require => false
#   gem "codeclimate-test-reporter", :group => :test, :require => nil
#   gem 'inch'
# end

# spreadsheet files management
gem 'rubyzip'
gem 'zip-zip'
gem 'axlsx'
gem 'roo', '~> 2.1.0'
gem 'roo-xls'
gem 'rubyXL', '3.3.33'
gem 'nokogiri', "~> 1.11.7"   #tester le 1.12.5 #sga to remove
gem 'mechanize'

# Including
gem 'guw', :path => 'vendor/gems/guw'
gem 'ge', :path => 'vendor/gems/ge'
gem 'operation', :path => 'vendor/gems/operation'
gem 'kb', :path => 'vendor/gems/kb'
gem 'skb', :path => 'vendor/gems/skb'
gem 'balancing_module', :path => "vendor/gems/balancing_module"
gem 'expert_judgement', :path => "vendor/gems/expert_judgement"
gem 'staffing', :path => "vendor/gems/staffing"

# This gem provides the JavaScript InfoVis Toolkit for your rails application.
gem "jit-rails", "~> 0.0.2"

# Gem to audit User actions
gem "audited-activerecord"#, "~> 3.0"
# gem "audited", "~> 4.5"

#Authentication gem
gem 'devise'
gem 'omniauth', '~> 1.9.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-saml'
gem 'omniauth-rails_csrf_protection'
#gem 'repost'
#gem 'devise_saml_authenticatable'
#gem 'devise_ldap_authenticatable'

## Cron job gem management
gem 'whenever', :require => false

## Gem for getting the time difference
gem 'time_diff', '~> 0.3.0'

# Licence finder gem
# gem 'license_finder'

# gem 'tinymce-rails'

# Tool for asynchronous jobs processing
gem 'sidekiq'#, '~> 5.2.5'
gem 'sidekiq-scheduler'
gem 'sidekiq-limit_fetch'
gem 'redis-namespace'

gem 'sinatra', :require => false
gem 'slim'

# For chart generation
gem 'highcharts-rails'
gem 'groupdate'

#Dentaku is a parser and evaluator for mathematical formulas
gem 'dentaku', '~> 2.0', '>= 2.0.9'

#Faker
#gem 'faker'

gem 'passenger'
gem 'turbolinks'
gem 'delocalize'

# Gems used only for assets and not required
# in production environments by default.
# group :assets do
#   gem 'coffee-rails'
#   gem 'uglifier', '>= 1.0.3'
#   # gem 'jquery-datatables-rails'
#   # gem 'jquery-ui-rails', '5.0.5'
#   gem 'sass'
# end

gem 'sass-rails'

group :development do
  #For UML classes diagram generator (!looks not easy to turn it in order on windows)
  gem 'thin' #Instead of webrick (and avoid WARN  Could not determine content-length of response body. Set content-length of the response or set Response#chunked = true)
  #gem 'orphan_records'
  # To use debugger
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'meta_request'
  # gem 'localtower'
  # Generates diagrams using Graphviz
  #gem 'rails-erd', require: false, group: :development
  #gem 'byebug'
end

group :test do
  gem 'factory_girl_rails'
  # gem 'factory_bot'
  # gem 'capybara'
  # rspec goodies
  #gem 'rspec-rails', :group => [:test, :development]
  gem 'rspec-rails', '~> 3.0.1', :group => [:test, :development]
  # DRb server for testing frameworks
  gem 'spork'
  # command line tool to easily handle events on file system modifications
  #gem 'guard'
  #gem 'guard-bundler'
  #gem 'guard-rspec'
  #gem 'guard-spork'
  #gem 'guard-migrate'
  #gem 'guard-rake'
  #Coverage tool
  gem 'simplecov', :require => false, :group => :test
  # run some required services using foreman start, more on this at the end of the article
  gem 'foreman'

  #For cleaning the test database
  gem 'database_cleaner'
end

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
gem 'remotipart', '~> 1.2'

gem 'yaml_db'

gem 'test-unit'
gem 'bullet', group: :development

local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
if File.exists?(local_gemfile)
  puts 'Loading Gemfile.local ...' if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end

gem 'wicked_pdf', '~> 2.0.2'
gem 'wkhtmltopdf-binary'

gem 'prawn', '~> 1.2.1'
gem 'prawn-table', '~> 0.1.0'

gem 'rack-reverse-proxy', :require => 'rack/reverse_proxy'

gem 'grit'
gem 'pdfkit'

# gem 'paper_trail'

gem 'hairtrigger'

gem 'protected_attributes' # https://github.com/rails/protected_attributes
# gem 'active_resource' # https://github.com/rails/activeresource
gem 'actionpack-action_caching' # https://github.com/rails/actionpack-action_caching
gem 'activerecord-session_store' # https://github.com/rails/activerecord-session_store
gem "rails-observers", "0.1.5"

gem 'biz'

gem 'bootstrap-sass', '~> 3.3.7'

gem 'rack-cors', require: 'rack/cors'

# gem 'chartkick'

gem 'jquery-number-rails'

#gem 'momentjs-rails'
gem 'bootstrap-datepicker-rails'

gem 'jscolor-rails'

gem 'selectize-rails'

gem 'order_as_specified'

gem 'prometheus-client'

gem 'jquery-tablesorter'

gem 'minitest', '~> 5.15.0'
# gem 'jquery_block_ui'
gem 'blockuijs-rails',  :git => 'https://github.com/rusanu/blockuijs-rails.git'  #'git://github.com/rusanu/blockuijs-rails.git'

gem 'faraday', '~> 1.8.0' #essayer (1.9.3) #sga this line is to remove after updated ruby version