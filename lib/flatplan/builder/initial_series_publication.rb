require_relative 'base'

module Flatplan
  module Builder
    
    # Builds a starting, default SeriesPublication from raw folders and files.
    # Aggregates discovered photos into a single initial text-and-media section.
    class InitialSeriesPublication < Base

      # Compiles raw metadata and files into a validated domain entity.
      #
      # @param title [String] the name of the photo series
      # @param raw_text [String, nil] introductory text block or description
      # @param filenames [Array<String>] list of discovered image files
      # @param metadata [Hash] haso of image metadata
      # @return [Model::SeriesPublication] a populated series domain entity
      # @raise [ArgumentError] if the series title is blank or empty
      def call(title:, keywords: [], raw_text: nil, filenames: [], metadata: {})
        if title.nil? || title.strip.empty?
          raise ArgumentError, "Publication title cannot be blank"
        end

        publication = Model::SeriesPublication.new(
          title: title.strip,
          keywords:,
          author: config.author
        )
        
        paragraphs = raw_text.to_s.split("\n\n").map { it.strip }.reject { it.empty? }
        assets = filenames.map do |filename|
          file_key = File.basename(filename, ".*")
          match = metadata[file_key] || {}
          captured_at = match['captured_at']
          captured_at = captured_at ? Time.parse(captured_at) : Time.now 
         
          Model::LayoutAsset.new(
            filename: filename,
            caption: "Fallback caption",
            title: match['title'] || '',
            captured_at: captured_at
          )          
        end
          
        initial_section = Model::TextAndMediaSection.new(
          media_assets: assets,
          paragraphs: paragraphs
        )

        publication.add_section(initial_section)
        publication
      end
    end
  end
end
