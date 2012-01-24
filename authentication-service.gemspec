# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "authentication-service/version"

Gem::Specification.new do |s|
  s.name        = "authentication-service"
  s.version     = Authentication::Service::VERSION
  s.authors     = ["Evgeny Myasishchev"]
  s.email       = ["evgeny.myasishchev@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Authentication service for Rails (and not only)}
  s.description = %q{Provides authentication related stuff.}

  s.rubyforge_project = "authentication-service"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
