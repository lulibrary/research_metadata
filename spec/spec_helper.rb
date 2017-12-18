require 'puree'
require 'datacite/mapping'
require 'research_metadata/transformer/dataset'
require 'research_metadata/transformer/research_output'
require 'research_metadata/transformer/thesis'
require 'research_metadata/version'

def config
  {
      url:      ENV['PURE_URL_TEST_59'],
      username: ENV['PURE_USERNAME'],
      password: ENV['PURE_PASSWORD'],
      api_key:  ENV['PURE_API_KEY']
  }
end