# encoding: utf-8
#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
RUBYOPT='-rpsych'
require File.expand_path('../config/application', __FILE__)

# temp fix for NoMethodError: undefined method `last_comment'
# remove when fixed in Rake 11.x
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

Projestimate::Application.load_tasks
