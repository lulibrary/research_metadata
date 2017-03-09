# Extraction (from Pure) and Transformation for Loading by DataCite's API
#
module ResearchMetadata

  # Transformer
  #
  module Transformer

    # Dataset
    #
    class Dataset

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      def initialize(config)
        @config = config
        @dataset_extractor = Puree::Extractor::Dataset.new config
      end

      # Dataset transformation
      #
      # @param id [String]
      # @param uuid [String]
      # @param doi [String]
      # @return [String]
      def transform(id: nil, uuid: nil, doi: nil)
        @dataset = extract uuid: uuid, id: id
        raise 'No metadata to transform' if @dataset.nil?
        person_o = person
        file_o = file
        resource = ::Datacite::Mapping::Resource.new(
            identifier: identifier(doi),
            creators: person_o['creator'],
            titles: [ title ],
            publisher: publisher,
            publication_year: publication_year,
            subjects: subjects,
            contributors: person_o['contributor'],
            dates: dates,
            language: language,
            resource_type: resource_type,
            related_identifiers: related_identifiers,
            sizes: sizes(file_o),
            formats: formats(file_o),
            rights_list: rights_list(file_o),
            descriptions: description,
            geo_locations: spatial
        )
        resource.write_xml
      end

      private

      def sizes(files)
        files.map { |i| i.size }
      end

      def formats(files)
        files.map { |i| i.mime }
      end

      def rights_list(files)
        arr = []
        files.each do |i|
          if i.license
            rights = Datacite::Mapping::Rights.new uri: URI(i.license.url),
                                                   value: i.license.name
            arr << rights
          else
            arr << 'Not specified'
          end
        end
        arr
      end

      def affiliations(person)
        person.affiliations.map { |i| i.name }
      end

      def dates
        a = []

        available = @dataset.available
        if available
          date_made_available = ::Datacite::Mapping::Date.new value: available.strftime("%F"),
                                                    type: ::Datacite::Mapping::DateType::AVAILABLE
          a << date_made_available
        end

        temporal = @dataset.temporal
        temporal_range = ''
        if temporal
          if temporal.start
            temporal_range << temporal.start.strftime("%F")
            if temporal.end
              temporal_range << '/'
              temporal_range << temporal.end.strftime("%F")
            end
            if !temporal_range.empty?
              collected = ::Datacite::Mapping::Date.new value: temporal_range,
                                                        type: ::Datacite::Mapping::DateType::COLLECTED
              a << collected
            end
          end
        end
        a
      end

      def description
        desc = @dataset.description
        if desc
          d = ::Datacite::Mapping::Description.new value: desc,
                                             type: ::Datacite::Mapping::DescriptionType::ABSTRACT
          [d]
        else
          []
        end
      end

      def extract(uuid: nil, id: nil)
        if !uuid.nil?
          return @dataset_extractor.find uuid: uuid
        else
          return @dataset_extractor.find id: id
        end
      end

      def file
        @dataset.files
      end

      def identifier(doi)
        ::Datacite::Mapping::Identifier.new(value: doi)
      end

      def language
        @dataset.locale
      end

      def name_identifier_orcid(person)
        name_identifier = nil
        if person.orcid
          name_identifier = ::Datacite::Mapping::NameIdentifier.new scheme: 'ORCID',
                                                                    scheme_uri: URI('http://orcid.org/'),
                                                                    value: person.orcid
        end
        name_identifier
      end

      def person
        o = {}
        o['creator'] = []
        o['contributor'] = []
        all_persons = []
        all_persons << @dataset.persons_internal
        all_persons << @dataset.persons_external
        all_persons << @dataset.persons_other
        all_persons.each do |person_type|
          person_type.each do |individual|
            pure_role =individual.role.gsub(/\s+/, '')
              name = individual.name.last_first
              if pure_role == 'Creator'
                human = ::Datacite::Mapping::Creator.new name: name
              else
                pure_role = 'Other' if pure_role === 'Contributor'
                contributor_type = ::Datacite::Mapping::ContributorType.find_by_value pure_role
                if contributor_type
                  human = ::Datacite::Mapping::Contributor.new  name: name,
                                                                type: contributor_type
                end
              end
              if human
                if individual.uuid
                  person_extractor = Puree::Extractor::Person.new @config
                  person = person_extractor.find uuid: individual.uuid
                  if person
                    identifier = name_identifier_orcid person
                    human.identifier = identifier if identifier

                    affiliation = affiliations person
                    human.affiliations = affiliation if affiliation
                  end
                end
                if individual.role == 'Creator'
                  o['creator'] << human
                else
                  o['contributor'] << human
                end
              end
          end
        end
        o
      end

      def publication_year
        @dataset.available.year
      end

      def publisher
        @dataset.publisher
      end

      def related_identifiers
        publications = @dataset.publications
        data = []
        publications.each do |i|
          # Skip as the relationship cannot currently be determined
          next if i.type === 'Dataset'

          publication_extractor = Puree::Extractor::Publication.new @config
          pub = publication_extractor.find uuid: i.uuid

          # Restrict to those with a DOI
          doi = pub.doi if pub.methods.include? :doi

          if doi
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

      def resource_type
        ::Datacite::Mapping::ResourceType.new(
            resource_type_general: ::Datacite::Mapping::ResourceTypeGeneral::DATASET,
            value: 'Dataset'
        )
      end

      def spatial
        # Pure has free text to list place names and does not allow a point to
        # be associated with a specific place

        # Place names
        arr = @dataset.spatial_places.map { |i| ::Datacite::Mapping::GeoLocation.new place: i }

        # Lat Long point
        spatial_point = @dataset.spatial_point
        if spatial_point
          point = ::Datacite::Mapping::GeoLocationPoint.new latitude:  spatial_point.latitude,
                                                            longitude: spatial_point.longitude
          geolocation = ::Datacite::Mapping::GeoLocation.new point: point
          arr << geolocation
        end
        arr
      end

      def subjects
        @dataset.keywords.map { |i| ::Datacite::Mapping::Subject.new value: i }
      end

      def title
        ::Datacite::Mapping::Title.new value: @dataset.title
      end

    end

  end

end