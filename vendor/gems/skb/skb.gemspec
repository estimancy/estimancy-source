$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "skb/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "skb"
  s.version     = Skb::VERSION
  s.authors     = "Estimancy"
  s.email       = "contact@estimancy.com"
  s.homepage    = "http://www.estimancy.com"
  s.summary     = "L'art d'estimer les projets"
  s.description = "L'art d'estimer les projets"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "rails", "~> 3.2.21"
end
