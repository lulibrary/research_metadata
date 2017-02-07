# ResearchMetadata

Extraction and Transformation for Loading by DataCite's API.

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

...and give it a Pure identifier and a DOI...

```ruby
metadata = transformer.transform uuid: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx',
                                 doi: '10.1234/foo/bar/1'
```

...to get DataCite-ready metadata.

## Documentation
[API in YARD](http://www.rubydoc.info/gems/research_metadata)

[Detailed usage in GitBook](https://aalbinclark.gitbooks.io/research_metadata)