# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'research_metadata/version'

Gem::Specification.new do |spec|
  spec.name          = 'research_metadata'
  spec.version       = ResearchMetadata::VERSION
  spec.authors       = 'Adrian Albin-Clark'
  spec.email         = 'a.albin-clark@lancaster.ac.uk'
  spec.summary       = %q{Metadata extraction from the Pure Research Information System and transformation of the metadata into the DataCite format.}
  spec.metadata = {
    'source_code_uri' => "https://github.com/lulibrary/#{spec.name}",
    "documentation_uri" => "https://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
  }
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_runtime_dependency 'puree', '~> 2.0'
  spec.add_runtime_dependency 'datacite-mapping', '~> 0.2.5'

  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
end
