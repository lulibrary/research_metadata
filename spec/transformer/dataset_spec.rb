require 'spec_helper'

describe 'Dataset' do

  def setup
    config = {
        url:      ENV['PURE_URL'],
        username: ENV['PURE_USERNAME'],
        password: ENV['PURE_PASSWORD']
    }
    @t = ResearchMetadata::Transformer::Dataset.new config
  end

  it '#new' do
    t = ResearchMetadata::Transformer::Dataset.new config
    expect(t).to be_an_instance_of ResearchMetadata::Transformer::Dataset
  end

  describe 'data transformation' do
    before(:all) do
      setup
    end

    it '#transform with random UUID' do
      c = Puree::Collection.new resource: :dataset
      res = c.find limit: 1,
                   offset: rand(0..c.count-1),
                   full: false
      metadata = @t.transform uuid: res[0]['uuid'],
                              doi:  '10.1234/foo/bar/1'
      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)
    end

    it '#transform with valid ID' do
      metadata = @t.transform id:  ENV['PURE_DATASET_ID'],
                              doi: '10.1234/foo/bar/1'
      is_xml = metadata.downcase.start_with?('<resource')
      expect(is_xml).to match(true)
    end

  end

end