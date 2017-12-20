require 'test_helper'

class TestTransformerDataset < Minitest::Test

  def transformer
    ResearchMetadata::Transformer::Dataset.new config
  end

  def test_transformer
     assert_instance_of ResearchMetadata::Transformer::Dataset, transformer
  end

  def test_transform
    # The 2014 Ebola virus disease outbreak in West Africa
    id = 'b050f4b5-e272-4914-8cac-3bdc1e673c58'

    metadata = transformer.transform id: id,
                                     doi: '10.1234/foo/bar/1'

    # puts metadata

    assert_equal true, metadata.downcase.start_with?('<resource')
  end

end