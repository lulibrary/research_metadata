# ResearchMetadata

Metadata extraction from the Pure Research Information System and transformation of the metadata into the DataCite format.

## Status

[![Gem Version](https://badge.fury.io/rb/research_metadata.svg)](https://badge.fury.io/rb/research_metadata)
[![Build Status](https://semaphoreci.com/api/v1/aalbinclark/research_metadata/branches/master/badge.svg)](https://semaphoreci.com/aalbinclark/research_metadata)
[![Code Climate](https://codeclimate.com/github/lulibrary/research_metadata/badges/gpa.svg)](https://codeclimate.com/github/lulibrary/research_metadata)
[![Dependency Status](https://www.versioneye.com/user/projects/5899d1be1e07ae0048c8e4c6/badge.svg?style=flat-square)](https://www.versioneye.com/user/projects/5899d1be1e07ae0048c8e4c6)

## Installation

Add this line to your application's Gemfile:

    gem 'research_metadata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install research_metadata

## Usage

### Configuration

Create a hash for passing to a transformer.

```ruby
config = {
  url:      'https://YOUR_HOST/ws/api/59',
  username: 'YOUR_USERNAME',
  password: 'YOUR_PASSWORD',
  api_key:  'YOUR_API_KEY'
}
```

### Transformation

Create a metadata transformer for a Pure dataset.

```ruby
transformer = ResearchMetadata::Transformer::Dataset.new config
```

Give it a Pure identifier and a DOI...

```ruby
metadata = transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx',
                                 doi: '10.1234/foo/bar/1'
```

...and get DataCite-ready metadata.