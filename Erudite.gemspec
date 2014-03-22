# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Erudite/version'

Gem::Specification.new do |spec|
  spec.name          = "Erudite"
  spec.version       = Erudite::VERSION
  spec.authors       = ["Irvin Owens Jr"]
  spec.email         = ["0x8badbeef@sigsegv.us"]
  spec.summary       = %q{Erudite is a ruby nosql DB}
  spec.description   = %q{}
  spec.homepage      = "http://erditedb.tumblr.com"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
