# frozen_string_literal: true

module Flatplan
  module Core

    # A medium-agnostic base serializer that formats a Story domain entity
    # and its inner layout sections into a standardized text manifest structure.
    # It relies entirely on the built-in metadata hash of each block.
    class Serializer
      # Initializes the serializer with a target-specific translation map.
      # @param property_map [Hash{Symbol => String}] maps Ruby keywords to public manifest keys
      def initialize(property_map = {})
        @property_map = property_map
      end

      # Serializes a complete Story container into a full manifest content string.
      # @param story [Story]
      # @return [String] formatted markdown document
      def serialize(story)
        header = <<~MARKDOWN
          ---
          title: #{story.title.to_s.inspect}
          author: #{story.author.to_s.inspect}
          description: #{story.description.to_s.inspect}
          date: #{story.date.to_s.inspect}
          ---
        MARKDOWN

        body = story.elements.map { |element| serialize_section(element) }.join("\n\n")
        "#{header}\n#{body}\n"
      end

      private

      # Translates a single PORO block into a markdown layout section.
      # @param element [Base]
      # @return [String]
      def serialize_section(element)
        output = []

        class_name = element.class.name.split('::').last
        output << "# #{class_name}"

        medium_spec = element.class.initialize_args - %i[text media assets media_assets]
        medium_spec.each do |spec|
          key = @property_map.fetch(spec, spec.to_s)
          output << "#{key}: #{element.public_send(spec)}"
        end
        
        output << "" # Empty line separator before payload data

        if element.respond_to?(:text) && element.text
          output << element.text.body
        elsif element.respond_to?(:body) && element.body
          output << element.body
        end

        media_group = if element.respond_to?(:media) then element.media
                      elsif element.respond_to?(:assets) then element
                      end

        if media_group && media_group.respond_to?(:assets) && media_group.assets
          output << "" if output.last != "" && !output.last.nil?
          media_group.assets.each do |media|
            # Media objects themselves might have metadata like alt or captions
            alt_text = media.respond_to?(:alt) ? media.alt : ""
            output << "![#{alt_text}](#{media.filepath})"

            # for mixing extra things like Kairos hints
            extra_lines = serialize_media_asset(media)
            output.concat(extra_lines) if extra_lines.any?
          end
        end

        output.join("\n").strip
      end

      protected

      # hook for mixing extra media information
      def serialize_media_asset(media)
        []
      end
    end
  end
end

