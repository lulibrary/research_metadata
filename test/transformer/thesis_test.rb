require 'test_helper'

class TestTransformerThesis < Minitest::Test

  def transformer
    ResearchMetadata::Transformer::Thesis.new config
  end

  def test_transformer
    assert_instance_of ResearchMetadata::Transformer::Thesis, transformer
  end

  def test_transform_1
    # Multimodalita e 'city branding'
    id = '376173c0-fd7a-4d63-93d3-3f2e58e8dc01'

    metadata = transformer.transform id: id,
                                     doi: '10.1234/foo/bar/1'

    # puts metadata

    assert_equal true, metadata.downcase.start_with?('<resource')
  end

  def test_transform_2
    # Nanoscale imaging and characterisation of Amyloid-β
    id ='9d3ad4d1-3d46-4551-9139-f783fd4e5123'

    metadata = transformer.transform id: id,
                                     doi: '10.1234/foo/bar/1'

    # puts metadata

    assert_equal true, metadata.downcase.start_with?('<resource')
  end

end