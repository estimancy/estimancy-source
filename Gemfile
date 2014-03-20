source 'http://rubygems.org'

gem 'rails', '3.2.16'
gem 'jquery-rails', '~> 2.0.2'
gem 'i18n', '~> 0.6.0'
gem 'builder', '3.0.0'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', :require => 'bcrypt'
gem "useragent"

# Include database gems for the adapters found in the database
# configuration file
require 'erb'
require 'yaml'
database_file = File.join(File.dirname(__FILE__), 'config/database.yml')
if File.exist?(database_file)
  database_config = YAML::load(ERB.new(IO.read(database_file)).result)
  adapters = database_config.values.map { |c| c['adapter'] }.compact.uniq
  if adapters.any?
    adapters.each do |adapter|
      case adapter
        when 'mysql2'
          if RUBY_PLATFORM =~ /i386-mingw32/
            # do that since mysql2 version > 0.3.11 doesn't work properly on Windows
            gem 'mysql2', '= 0.3.11', :platforms => [:mswin, :mingw]
          else
            gem 'mysql2', '~> 0.3.11', :platforms => :mri
          end
          gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
        when 'mysql'
          gem 'mysql', '~> 2.8.1', :platforms => [:mri, :mingw]
          gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
        when /postgresql/
          gem 'pg', '>= 0.11.0', :platforms => [:mri, :mingw]
          gem 'activerecord-jdbcpostgresql-adapter', :platforms => :jruby
        when /sqlite3/
          gem 'sqlite3', :platforms => [:mri, :mingw]
          gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
        when /sqlserver/
          gem 'tiny_tds', '~> 0.5.1', :platforms => [:mri, :mingw]
          gem 'activerecord-sqlserver-adapter', :platforms => [:mri, :mingw]
        else
          warn("Unknown database adapter `#{adapter}` found in config/database.yml, use Gemfile.local to load your own database gems")
      end
    end
  else
    warn('No adapter found in config/database.yml, please configure it first')
  end
else
  warn('Please configure your config/database.yml first')
end

#Permissions
gem 'cancan'
#Authentication for tests
gem "warden"

#Tree
gem 'ancestry'

gem 'aescrypt'

# Optional gem for LDAP authentication
#group :ldap do
gem 'net-ldap', '~> 0.3.1'
#end

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
gem 'amoeba'

# Required for rspec and rails command
gem 'rb-readline'

#Cache management
gem 'cache_digests'

#Optional gem for monitoring
group :ic do
  gem 'newrelic_rpm'
end

# spreadsheet files management
gem 'rubyzip', '~> 0.9'
gem 'axlsx'
gem 'roo'

gem 'uos', :path => 'vendor/gems/uos'

# This gem provides the JavaScript InfoVis Toolkit for your rails application.
gem "jit-rails", "~> 0.0.2"

# Gem to audit User actions
gem "audited-activerecord", "~> 3.0"


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-datatables-rails'
  gem 'jquery-ui-rails'
  gem 'sass'
end

group :development do
  #For UML classes diagram generator (!looks not easy to turn it in order on windows)
  gem 'thin' #Instead of webrick (and avoid WARN  Could not determine content-length of response body. Set content-length of the response or set Response#chunked = true)
  #gem 'orphan_records'
  # To use debugger
  #gem 'ruby-debug19', :require => 'ruby-debug'
end

group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara'
  # rspec goodies
  gem 'rspec-rails', :group => [:test, :development]
  # DRb server for testing frameworks
  gem 'spork'
  # command line tool to easily handle events on file system modifications
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-migrate'
  gem 'guard-rake'
  #Coverage tool
  gem 'simplecov', :require => false, :group => :test
  # run some required services using foreman start, more on this at the end of the article
  gem 'foreman'
end

local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
if File.exists?(local_gemfile)
  puts 'Loading Gemfile.local ...' if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end