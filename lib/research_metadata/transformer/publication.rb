module ResearchMetadata

  module Transformer

    # Extracts publication metadata from the Pure Research Information System
    # and converts it into the DataCite format. Example usage is for theses
    # (doctoral and master's).
    #
    class Publication

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      def initialize(config)
        @config = config
        @publication_extractor = Puree::Extractor::Publication.new config
      end

      # Publication transformation
      #
      # @param id [String]
      # @param uuid [String]
      # @param doi [String]
      # @return [String, nil]
      def transform(id: nil, uuid: nil, doi: nil)
        @publication = extract uuid: uuid, id: id
        return nil if !@publication
        return nil if !publication_year
        person_o = person
        file_o = file
        resource = ::Datacite::Mapping::Resource.new(
            identifier: identifier(doi),
            creators: person_o['creator'],
            titles: titles,
            publication_year: publication_year,
            publisher: publisher,
            subjects: subjects,
            contributors: person_o['contributor'],
            language: language,
            resource_type: resource_type,
            sizes: sizes(file_o),
            formats: formats(file_o),
            rights_list: rights_list(file_o),
            descriptions: description
        )
        resource.write_xml
      end

      private

      def pages
        count = @publication.pages
        if count > 0
          return "#{count} pages"
        else
          return nil
        end
      end

      def sizes(files)
        arr = files.map { |i| "#{i.size} B" }
        arr << pages if pages
        arr
      end

      def formats(files)
        files.map { |i| i.mime }
      end

      def rights_list(files)
        arr = []
        files.each do |i|
          if i.license
            rights = Datacite::Mapping::Rights.new value: i.license.name
            arr << rights
          else
            arr << 'License unspecified'
          end
        end
        arr
      end

      def affiliations(person)
        person.affiliations.map { |i| i.name }
      end

      def description
        desc = @publication.description
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
          return @publication_extractor.find uuid: uuid
        else
          return @publication_extractor.find id: id
        end
      end

      def file
        @publication.files
      end

      def identifier(doi)
        ::Datacite::Mapping::Identifier.new(value: doi)
      end

      def language
        @publication.locale
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
        all_persons << @publication.persons_internal
        all_persons << @publication.persons_external
        all_persons << @publication.persons_other
        all_persons.each do |person_type|
          person_type.each do |individual|
            pure_role =individual.role.gsub(/\s+/, '')
            role = pure_role
            name = individual.name.last_first
            role = 'Creator' if pure_role === 'Author'
            if role == 'Creator'
              human = ::Datacite::Mapping::Creator.new name: name
            else
              role = 'Other' if pure_role === 'Contributor'
              contributor_type = ::Datacite::Mapping::ContributorType.find_by_value role
              if contributor_type
                human = ::Datacite::Mapping::Contributor.new name: name,
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
              if role == 'Creator'
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
        @publication.statuses.each do |i|
          if i.stage === 'Published'
            return i.date.year
          end
        end
        nil
      end

      def publisher
        @publication.publisher || 'Not specified'
      end

      def resource_type
        ::Datacite::Mapping::ResourceType.new(
            resource_type_general: ::Datacite::Mapping::ResourceTypeGeneral::TEXT,
            value: 'Text'
        )
      end

      def subjects
        @publication.keywords.map { |i| ::Datacite::Mapping::Subject.new value: i }
      end

      def titles
        arr = []
        title = ::Datacite::Mapping::Title.new value: @publication.title
        arr << title
        subtitle = @publication.subtitle
        if subtitle
          arr << ::Datacite::Mapping::Title.new(value: subtitle,
                                                type: ::Datacite::Mapping::TitleType::SUBTITLE)
        end
        arr
      end

    end

  end

end