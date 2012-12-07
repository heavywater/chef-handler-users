# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "chef-handler-users"
  gem.version     = "0.0.12"
  gem.authors     = ["Heavy Water Operations, LLC. (OR)"]
  gem.email       = ["ops@hw-ops.com"]
  gem.homepage    = "http://github.com/heavywater/chef-handler-users"
  gem.summary     = "Chef Handler to report changes in users"
  gem.description = "Chef Handler to report changes in users"
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "pony"

  gem.add_development_dependency "rake"
end
