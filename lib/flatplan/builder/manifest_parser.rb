# lib/flatplan/builder/manifest_parser.rb

require "yaml"
require_relative "base"

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

        raw_lines = content.split("\n").map(&:strip)

        # 1. Extract and Parse YAML Front Matter Block securely
        front_matter, remaining_lines = extract_front_matter(raw_lines)
        
        publication = Model::SeriesPublication.new(
          title: front_matter[:title] || "Untitled Publication",
          author: front_matter[:author],
          date: front_matter[:date],
          location: front_matter[:location],
          keywords: front_matter[:keywords] || [],
          description: front_matter[:description]
        )

        # 2. Filter empty rows from the remaining body
        clean_lines = remaining_lines # TODO: eliminate "magic" kairos_
          .reject{ it.empty? || it.start_with?('kairos_') }

        # 3. Slice content into separate topic blocks
        raw_topics = slice_into_topics(clean_lines)

        # 4. Process each discovered topic into domain sections
        raw_topics.each do |topic_lines|
          section = build_section_from_topic(topic_lines)
          publication.add_section(section) if section
        end

        publication
      end

      private

      # Safely isolates and parses the top YAML metadata configuration block.
      def extract_front_matter(lines)
        unless lines.first == "---"
          return [{}, lines]
        end

        yaml_lines = []
        remaining_lines = []
        inside_yaml = false
        yaml_closed = false

        lines.each_with_index do |line, index|
          if line == "---" && !yaml_closed
            if inside_yaml
              inside_yaml = false
              yaml_closed = true # Жестко запечатываем блок Front Matter
              next
            else
              inside_yaml = true
              next
            end
          end

          if inside_yaml
            yaml_lines << line
          else
            remaining_lines << line
          end
        end

        parsed = YAML.safe_load(yaml_lines.join("\n"), permitted_classes: [Symbol]) || {}
        symbolized = parsed.transform_keys(&:to_sym)

        [symbolized, remaining_lines]
      end

      # Slices plain lines array into blocks bounded by headers or standalone pauses.
      def slice_into_topics(lines)
        topics = []
        current_topic = []

        lines.each do |line|
          if line == "---"
            topics << current_topic unless current_topic.empty?
            current_topic = []
            topics << [line]
          elsif line.start_with?("#")
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

        if lines == ["---"]
          return BuildSection.call(:visual_pause, media_assets: [], spacing: :large)
        end

        metadata = {}
        paragraphs = []
        assets = []
        last_asset = nil

        lines.each do |line|
          if line.start_with?("#")
            next
          elsif line.match?(/^(text|media|spacing|layout):/)
            key, val = line.split(":", 2).map(&:strip)
            metadata[key.to_sym] = val.to_sym
          elsif line.start_with?("title:") && last_asset
            last_asset.title = line.split(":", 2).last.strip
          elsif line.start_with?("captured_at:") && last_asset
            last_asset.captured_at = line.split(":", 2).last.strip.then{ Time.new(it) }
          elsif line.start_with?("![") && line.include?("](")
            match = line.match(/!\[(.*?)\]\((.*?)\)/)
            if match
              # Extract string captures strictly using modern mapping indices
              last_asset = Model::LayoutAsset.new(
                filename: match[2].to_s,
                caption: match[1].to_s
              )
              assets << last_asset
            end
          else
            paragraphs << line
          end
        end

        return nil if paragraphs.empty? && assets.empty?

        if metadata[:layout] == :pause
          BuildSection.call(
            :visual_pause, 
            media_assets: assets, 
            spacing: metadata[:spacing] || :large
          )
        elsif metadata[:layout] == :hero
          BuildSection.call(:editorial_hero, media_assets: assets)
        else
          BuildSection.call(
            :text_and_media,
            media_assets: assets,
            text_alignment: metadata[:text] || :left,
            media_alignment: metadata[:media] || :right,
            paragraphs: paragraphs,
            spacing: metadata[:spacing] || :medium
          )
        end
      end
    end
  end
end
