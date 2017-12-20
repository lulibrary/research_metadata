module ResearchMetadata

  module Transformer

    # Extracts research output metadata from the Pure Research Information System
    # and converts it into the DataCite format. Usage is for theses
    # (doctoral and master's).
    #
    class Thesis < ResearchMetadata::Transformer::ResearchOutput

      # @param config [Hash]
      # @option config [String] :url URL of the Pure host
      # @option config [String] :username Username of the Pure host account
      # @option config [String] :password Password of the Pure host account
      # @option config [String] :api_key API key of the Pure host account
      def initialize(config)
        @config = config
        @research_output_extractor = Puree::Extractor::Thesis.new config
      end

      private

      def pages
        count = @research_output.pages
        if count && count > 0
          return "#{count} pages"
        else
          return nil
        end
      end

      def publisher
        @research_output.publisher.name || 'Publisher unspecified'
      end

      def sizes(files)
        arr = files.map { |i| "#{i.size} B" }
        arr << pages if pages
        arr
      end

    end

  end

end