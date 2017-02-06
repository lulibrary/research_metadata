require 'spec_helper'

describe 'Dataset' do

  def setup
    Puree.base_url   = ENV['PURE_BASE_URL']
    Puree.username   = ENV['PURE_USERNAME']
    Puree.password   = ENV['PURE_PASSWORD']
    Puree.basic_auth = true
    @t = ResearchMetadata::Transformer::Dataset.new
  end

  it '#new' do
    t = ResearchMetadata::Transformer::Dataset.new
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