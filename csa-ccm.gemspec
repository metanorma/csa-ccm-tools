lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "csa/ccm/version"

Gem::Specification.new do |spec|
  spec.name          = "csa-ccm"
  spec.version       = Csa::Ccm::VERSION
  spec.authors       = ["Ribose"]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{Parsing and writing of the CSA CCM}
  spec.description   = %q{Parsing and writing of the CSA CCM located at https://cloudsecurityalliance.org/working-groups/cloud-controls-matrix.}
  spec.homepage      = "https://open.ribose.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "iso-639"
  spec.add_runtime_dependency "creek"
  spec.add_runtime_dependency "thor", "~> 0.20.3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
