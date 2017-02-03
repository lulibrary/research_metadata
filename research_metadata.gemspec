# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'research_metadata/version'

Gem::Specification.new do |spec|
  spec.name          = "research_metadata"
  spec.version       = ResearchMetadata::VERSION
  spec.authors       = ["Adrian Albin-Clark"]
  spec.email         = ["a.albin-clark@lancaster.ac.uk"]
  spec.summary       = %q{Extraction and Transformation for Loading by DataCite's API.}
  spec.description   = %q{Extraction and Transformation for Loading by DataCite's API.}
  spec.homepage      = "https://aalbinclark.gitbooks.io/research_metadata"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "puree", "~> 0.20"
  spec.add_runtime_dependency "datacite-mapping", "~> 0.2"
end
