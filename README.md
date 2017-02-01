# ResearchMetadata [![Gem Version](https://badge.fury.io/rb/research_metadata.svg)](https://badge.fury.io/rb/research_metadata)

Extraction (from Pure) and Transformation for Loading by DataCite's API.

## Installation

Add this line to your application's Gemfile:

    gem 'research_metadata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install research_metadata

## Usage

### Configuration
Configure Pur&#233;e.

```ruby
Puree.base_url   = ENV['PURE_BASE_URL']
Puree.username   = ENV['PURE_USERNAME']
Puree.password   = ENV['PURE_PASSWORD']
Puree.basic_auth = true
```

### Transformation

Create a metadata transformer for a Pure dataset...

```ruby
transformer = ResearchMetadata::Transformer::Dataset.new
```

...and give it a Pure identifier and a DOI.

```ruby
metadata = transformer.transform uuid: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx',
                                 doi: '10.1234/foo/bar/1'
```