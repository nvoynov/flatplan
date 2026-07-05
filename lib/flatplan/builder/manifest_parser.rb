require_relative 'base'

module Flatplan
  module Builder

    # Parses raw Flatplan Markdown manifest strings into validated
    # Model::SeriesPublication domain entity aggregates based on header tracking.
    class ManifestParser < Base
      # Compiles a raw Markdown content string into a publication domain model.
      #
      # @param content [String] the raw Markdown manifest file content
      # @return [Model::SeriesPublication] a fully populated domain model
      # @raise [ArgumentError] if the content is empty or structurally invalid
      def call(content:)
        if content.nil? || content.strip.empty?
          raise ArgumentError, "Manifest content cannot be empty"
        end

        lines = content.split("\n").map(&:strip)
        
        # 1. Parse metadata header safely from the very first line
        title = parse_title(lines.first)
        publication = Model::SeriesPublication.new(title: title)

        # 2. Filter out all top metadata lines and clean empty lines
        clean_lines = lines.reject { it.start_with?("%") || it.empty? }

        # 3. Slice content into separate topic blocks (headers, texts, and standalone pauses)
        raw_topics = slice_into_topics(clean_lines)

        # 4. Process each discovered topic into domain sections
        raw_topics.each do |topic_lines|
          section = build_section_from_topic(topic_lines)
          publication.add_section(section) if section
        end

        publication
      end

      private

      # Extracts publication title from the Pandoc metadata marker.
      def parse_title(first_line)
        if first_line&.start_with?("%")
          first_line.sub("%", "").strip
        else
          "Untitled Publication"
        end
      end

      # Slices plain lines array into pure blocks. Standalone '---' lines 
      # are isolated into their own single-element batches.
      def slice_into_topics(lines)
        topics = []
        current_topic = []

        lines.each do |line|
          if line == "---"
            # Cut current block early and flush it
            topics << current_topic unless current_topic.empty?
            current_topic = []
            
            # Isolate the pause separator into its own standalone batch
            topics << [line]
          elsif line.start_with?("#")
            # Cut block early on a new header landmark
            topics << current_topic unless current_topic.empty?
            current_topic = [line]
          else
            current_topic << line
          end
        end
        topics << current_topic unless current_topic.empty?
        topics
      end

      # Discovers metadata attributes, paragraphs, and images within a topic block.
      def build_section_from_topic(lines)
        return nil if lines.empty?

        # 1. Fast-track check for the isolated standalone visual pause token
        if lines == ["---"]
          return BuildSection.call(:visual_pause, media_assets: [], spacing: :large)
        end

        metadata = {}
        paragraphs = []
        assets = []

        lines.each do |line|
          if line.start_with?("#")
            next
          elsif line.match?(/^(text|media|spacing|layout):/)
            key, val = line.split(":", 2).map(&:strip)
            metadata[key.to_sym] = val.to_sym
          elsif line.start_with?("![") && line.include?("](")
            match = line.match(/!\[(.*?)\]\((.*?)\)/)
            if match
              # match[1] — это подпись из квадратных скобок (String)
              # match[2] — это имя файла из круглых скобок (String)
              assets << Model::LayoutAsset.new(
                filename: match[2].to_s,
                caption: match[1].to_s
              )
            end
          else
            paragraphs << line
          end
        end

        # Drop empty stray technical chunks
        return nil if paragraphs.empty? && assets.empty?

        # 2. Strict layout routing based on explicit architectural intent
        if metadata[:layout] == :pause
          BuildSection.call(
            :visual_pause, 
            media_assets: assets, 
            spacing: metadata[:spacing] || :large
          )
        elsif metadata[:layout] == :hero
          BuildSection.call(:editorial_hero, media_assets: assets)
        else
          # Any standard block starting with '#' is natively a TextAndMedia spread
          BuildSection.call(
            :text_and_media,
            media_assets: assets,
            text_alignment: metadata[:text] || :left,
            media_alignment: metadata[:media] || :right,
            paragraphs: paragraphs,
            spacing: metadata[:spacing] || :medium # Pass spacing safely as layout metadata
          )
        end
      end
    end
  end
end
