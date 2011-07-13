# -*- encoding: utf-8 -*-
require File.expand_path("../lib/Erudite/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "Erudite"
  s.version     = Erudite::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Irvin Owens Jr" ]
  s.email       = [ "irvin@owensperformance.com" ]
  s.homepage    = "http://eruditedb.tumblr.com"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "Erudite"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
