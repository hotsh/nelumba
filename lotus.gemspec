# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lotus/version"

Gem::Specification.new do |s|
  s.name        = "lotus"
  s.version     = Lotus::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Hackers of the Severed Hand']
  s.email       = ['hotsh@xomb.org']
  s.homepage    = "http://github.com/hotsh/lotus"
  s.summary     = %q{Generalized federated system backend for social networks with ActivityStreams/OStatus/pump.io.}
  s.description = %q{This gem allows easier implementation and utilization of distributed, federated social networks.}

  s.add_dependency "ratom"
  s.add_dependency "ruby-hmac"
  s.add_dependency "rsa"
  s.add_dependency "time-lord"
  s.add_dependency "nokogiri"

  s.add_development_dependency "rspec", "~> 2.10.0"
  s.add_development_dependency "rake", "~> 0.9.2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
