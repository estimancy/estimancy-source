# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'effort_breakdown/version'

Gem::Specification.new do |gem|
  gem.name = 'effort_breakdown'
  gem.version = EffortBreakdown::VERSION
  gem.authors = 'Estimancy'
  gem.email = 'contact@estimancy.com'
  gem.description = 'This module split a global effort into effort per activities (i.e. effort per WBS-activity-elements) using a WBS-activity-ratio table.'
  gem.summary = 'Implementation of a basic breakdown of the effort by activities for ProjEstimate'
  gem.license = 'AGPL-3'
  gem.homepage = 'forge.estimancy.com'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = 'lib'
end
