# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "csa/ccm/cli/version"

Gem::Specification.new do |spec|
  spec.name          = "csa-ccm"
  spec.version       = Csa::Ccm::Cli::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{Parsing and writing of the CSA CCM}
  spec.description   = %q{Parsing and writing of the CSA CCM located at https://cloudsecurityalliance.org/working-groups/cloud-controls-matrix.}
  spec.homepage      = "https://open.ribose.com"

  spec.files         = Dir['**/*'].reject { |f| f.match(%r{^(test|spec|features|.git)/|.(gem|gif|png|jpg|jpeg|xml|html|doc|pdf|dtd|ent)$}) }

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "rubyXL", "~> 3.4.3"
  spec.add_runtime_dependency "thor", "~> 0.20.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
