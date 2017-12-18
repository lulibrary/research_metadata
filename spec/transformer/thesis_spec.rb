require 'spec_helper'

describe 'Thesis' do

  def setup
    @t = ResearchMetadata::Transformer::Thesis.new config
  end

  it '#new' do
    setup
    t = ResearchMetadata::Transformer::Thesis.new config
    expect(t).to be_a ResearchMetadata::Transformer::Thesis
  end

  describe 'data transformation' do
    before(:all) do
      setup
    end

    it '#transform with known UUID 1' do
      # Multimodalita e 'city branding'
      id = '376173c0-fd7a-4d63-93d3-3f2e58e8dc01'

      metadata = @t.transform id: id,
                              doi: '10.1234/foo/bar/1'

      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)

      # puts metadata
    end

    it '#transform with known UUID 2' do
      # Nanoscale imaging and characterisation of Amyloid-β
      id ='9d3ad4d1-3d46-4551-9139-f783fd4e5123'

      metadata = @t.transform id: id,
                              doi: '10.1234/foo/bar/1'

      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)

      # puts metadata
    end

  end

end