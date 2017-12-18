require 'spec_helper'

describe 'Dataset' do

  def setup
    @t = ResearchMetadata::Transformer::Dataset.new config
  end

  it '#new' do
    setup
    t = ResearchMetadata::Transformer::Dataset.new config
    expect(t).to be_a ResearchMetadata::Transformer::Dataset
  end

  describe 'data transformation' do
    before(:all) do
      setup
    end

    it '#transform with known UUID' do
      # The 2014 Ebola virus disease outbreak in West Africa
      id = 'b050f4b5-e272-4914-8cac-3bdc1e673c58'

      metadata = @t.transform id: id,
                              doi: '10.1234/foo/bar/1'
      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)

      # puts metadata
    end

  end

end