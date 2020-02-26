$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mautic_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mautic_api"
  s.version     = MauticApi::VERSION
  s.authors     = ["Silviu"]
  s.email       = ["silviu@messbusters.org"]
  s.homepage    = "https://messbusters.co"
  s.summary     = ""
  s.description = "This gem allows simple integration with Mautic Api."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.require_paths = ["lib"]
  
  # s.add_dependency "oauth2", "~> 1.0.0"
  # s.add_dependency "jwt", "~> 1.0.0"
  # s.add_dependency "multi_json", "~> 1.12.1"
  # s.add_dependency "multi_xml", "~> 0.5.5"
  # s.add_dependency "rack", "~> 1.5.5"
  # s.add_dependency "redis"
  
end
