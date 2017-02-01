# Extraction (from Pure) and Transformation for Loading by DataCite's API
#
module ResearchMetadata

  # Transformer
  #
  module Transformer

    # Dataset
    #
    class Dataset

      # Dataset transformation
      #
      # @param id [String]
      # @param uuid [String]
      # @param doi [String]
      # @return [String]
      def transform(id: nil, uuid: nil, doi: nil)
        @dataset = extract uuid: uuid, id: id
        raise 'No metadata to transform' if @dataset.metadata.empty?
        person_o = person
        resource = ::Datacite::Mapping::Resource.new(
            identifier: identifier(doi),
            creators: person_o['creator'],
            titles: [ title ],
            publisher: publisher,
            publication_year: publication_year
        )
        resource.contributors = person_o['contributor']
        resource.descriptions = [ description ]
        resource.dates = dates
        resource.subjects = subjects
        file_o = file
        resource.sizes = file_o.map { |i| i['size'] }
        resource.formats = file_o.map { |i| i['mime'] }
        resource.rights_list = file_o.map { |i| i['license']['name'] }
        resource.geo_locations = spatial
        # resource.related_identifiers = related_identifiers
        resource.write_xml
      end

      private

      def extract(uuid: nil, id: nil)
        d = Puree::Dataset.new
        if !uuid.nil?
          d.find uuid: uuid
        else
          d.find id: id
        end
        d
      end

      def identifier(doi)
        ::Datacite::Mapping::Identifier.new(value: doi)
      end

      def person
        o = {}
        o['creator'] = []
        o['contributor'] = []
        person_types = %w(internal external other)
        person_types.each do |person_type|
          @dataset.person[person_type].each do |dataset_person|
            person = Puree::Person.new
            person.find uuid: dataset_person['uuid']

            if !person.metadata.empty?
              name = "#{person.name['last']}, #{person.name['first']}"
              pure_role = dataset_person['role']
              if pure_role == 'Creator'
                human = ::Datacite::Mapping::Creator.new name: name
              else
                pure_role = 'Other' if pure_role === 'Contributor'
                contributor_type = ::Datacite::Mapping::ContributorType.find_by_value pure_role
                human = ::Datacite::Mapping::Contributor.new  name: name,
                                                            type: contributor_type
              end

              identifier = name_identifier_orcid(person)
              human.identifier = identifier if !identifier.nil?

              affiliation = affiliations(person)
              human.affiliations = affiliation if !affiliation.empty?

              if dataset_person['role'] == 'Creator'
                o['creator'] << human
              else
                o['contributor'] << human
              end
            end
          end
        end
        o
      end

      def name_identifier_orcid(person)
        name_identifier = nil
        if !person.orcid.empty?
          name_identifier = ::Datacite::Mapping::NameIdentifier.new  scheme: 'ORCID',
                                                                   scheme_uri: URI('http://orcid.org/'),
                                                                   value: person.orcid
        end
        name_identifier
      end

      def affiliations(person)
        person.affiliation.map { |i| i['name'] }
      end

      def title
        ::Datacite::Mapping::Title.new value: @dataset.title
      end

      def publisher
        @dataset.publisher
      end

      def publication_year
        @dataset.available['year']
      end

      def description
        ::Datacite::Mapping::Description.new value: @dataset.description,
                                           type: ::Datacite::Mapping::DescriptionType::ABSTRACT
      end

      def dates
        a = []
        available = ::Datacite::Mapping::Date.new value: Puree::Date.iso(@dataset.available),
                                                type: ::Datacite::Mapping::DateType::AVAILABLE
        a << available

        temporal = @dataset.temporal
        temporal_range = ''
        if !temporal['start']['year'].empty?
          temporal_range << Puree::Date.iso(temporal['start'])
          if !temporal['end']['year'].empty?
            temporal_range << '/'
            temporal_range << Puree::Date.iso(temporal['end'])
          end
          if !temporal_range.empty?
            collected = ::Datacite::Mapping::Date.new value: temporal_range,
                                                      type: ::Datacite::Mapping::DateType::COLLECTED
            a << collected
          end
        end

        a
      end

      def subjects
        @dataset.keyword.map { |i| ::Datacite::Mapping::Subject.new value: i }
      end

      def file
        @dataset.file
      end

      def spatial
        # Pure has free text to list place names and does not allow a point to be associated with a specific place
        # Place names
        arr = @dataset.spatial.map { |i| ::Datacite::Mapping::GeoLocation.new place: i }

        # Lat Long point
        spatial_point = @dataset.spatial_point
        if !spatial_point.empty?
          point = ::Datacite::Mapping::GeoLocationPoint.new latitude:  spatial_point['latitude'],
                                                            longitude: spatial_point['longitude']
          geolocation = ::Datacite::Mapping::GeoLocation.new point: point
          arr << geolocation
        end
        arr
      end

      # There is no way in Pure UI to provide relationships to other resources,
      # which makes it difficult to infer specific relationships automatically
      def related_identifiers
        publications = @dataset.publication
        data = []
        publications.each do |i|
          if i['type'] === 'Dataset'
            pub = Puree::Dataset.new
          else
            pub = Puree::Publication.new
          end
          pub.find uuid: i['uuid']
          doi = pub.doi
          if !doi.empty?
            doi_part_to_remove = 'http://dx.doi.org/'
            doi_short = doi.gsub(doi_part_to_remove, '')
            doi_short.gsub!('/', '-')
            related_identifier =
                ::Datacite::Mapping::RelatedIdentifier.new(
                    value: doi_short,
                    identifier_type: ::Datacite::Mapping::RelatedIdentifierType::DOI,
                    relation_type: ::Datacite::Mapping::RelationType::IS_REFERENCED_BY)
            data << related_identifier
          end
        end
        data
      end

    end

  end

end