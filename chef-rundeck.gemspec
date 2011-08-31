# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'chef-rundeck/version'

Gem::Specification.new do |s|
  s.name      = "chef-rundeck"
  s.version   = ChefRundeck::VERSION
  s.platform  = Gem::Platform::RUBY
  s.authors   = ["Adam Jacob"]
  s.email     = ["adam@opscode.com"]
  s.homepage  = "https://github.com/opscode/chef-rundeck"
  s.summary   = %q{Integrates Chef with RunDeck}
  s.description = %q{Provides a resource endpoint for RunDeck from a Chef Server}

  s.rubyforge_project = "chef-rundeck"

  s.add_dependency "chef"
  s.add_dependency "sinatra"
  s.add_development_dependency "rspec", ">= 1.2.9"
  s.add_development_dependency "yard", ">= 0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
