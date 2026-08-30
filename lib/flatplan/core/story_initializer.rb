# frozen_string_literal: true

module Flatplan
  module Core
    
    # A reusable, medium-agnostic orchestrator that takes raw assets and metadata,
    # processes them into standard primitives, and utilizes a provided factory
    # to compile a structured, initial domain model.
    class StoryInitializer
      # @param factory [Factory] a concrete medium factory
      def initialize(factory)
        @factory = factory
      end

      # Compiles raw metadata and filenames into a structured Story domain model.
      #
      # @param title [String] the name of the publication
      # @param author [String] the author or creator
      # @param filenames [Array<String>] list of discovered image files
      # @param raw_text [String, nil] introductory text block or description
      # @param metadata [Hash] dictionary of image properties (EXIF, dimension, titles)
      # @return [Story] a medium-specific story container (e.g., Flatplan::Web::Page)
      # @raise [ArgumentError] if the title is blank or empty
      def call(title:, author:, filenames: [], raw_text: nil, metadata: {})
        raise ArgumentError, "Publication title cannot be blank" \
          if title.nil? || title.strip.empty?

        text_body = raw_text || "Write your narrative here..."
        text_element = @factory.text(text_body)

        media_list = filenames.map do |filename|
          file_key = File.basename(filename, ".*")
          match = metadata[file_key] || {}

          @factory.media(
            filename,
            caption: match['caption'] || "Fallback caption",
            alt: match['alt'] || match['title'] || "",
            width: match['width']&.to_i,
            height: match['height']&.to_i
          )
        end

        media_assets_element = @factory.media_assets(media_list)

        initial_layout = @factory.text_and_media(text_element, media_assets_element)

        @factory.story(
          title.strip,
          author: author,
          description: "Initial draft of #{title}",
          date: Time.now,
          elements: [initial_layout]
        )
      end
    end
  end
end

