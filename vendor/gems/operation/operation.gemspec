$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "operation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "operation"
  s.version     = Operation::VERSION
  s.authors     = "Estimancy"
  s.email       = "contact@estimancy.com"
  s.homepage    = "http://www.estimancy.com"
  s.summary     = "L'art d'estimer les projets"
  s.description = "L'art d'estimer les projets"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
end
