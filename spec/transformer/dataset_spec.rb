require 'spec_helper'

describe 'Dataset' do

  def setup
    @config = {
        url:      ENV['PURE_URL'],
        username: ENV['PURE_USERNAME'],
        password: ENV['PURE_PASSWORD']
    }
    @t = ResearchMetadata::Transformer::Dataset.new @config
  end

  it '#new' do
    setup
    t = ResearchMetadata::Transformer::Dataset.new @config
    expect(t).to be_a ResearchMetadata::Transformer::Dataset
  end

  describe 'data transformation' do
    before(:all) do
      setup
    end

    it '#transform with random UUID' do
      c = Puree::Extractor::Collection.new resource: :dataset,
                                           config: @config
      res = c.random_resource
      metadata = @t.transform uuid: res.uuid,
                              doi:  '10.1234/foo/bar/1'
      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)
    end

  end

end