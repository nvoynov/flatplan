# frozen_string_literal: true

require_relative 'parser'

module Flatplan
  module Core
    
    # A medium-agnostic base builder that orchestrates parsing of plain manifests.
    # It decomposes text into structured steps, isolates properties, processes images,
    # and delegates final instantiations to the specific target factory.
    class Builder
      # @param factory [Object] a concrete medium factory
      def initialize(factory)
        @factory = factory
      end

      # Compiles a raw manifest string into a medium-specific Story object.
      # @param manifest_content [String] raw manifest file text
      # @return [Object] structured story root container
      def build(manifest_content)
        lines = manifest_content.lines.map(&:chomp)

        global_meta, remaining_lines = Parser.frontmatter(lines)
        raw_topics = Parser.topics(remaining_lines)

        elements = raw_topics
          .map{ build_element(it) }
          .compact

        title  = fetch_meta(global_meta, :title, 'Untitled Story')
        author = fetch_meta(global_meta, :author, 'Unknown Author')

        custom_kwargs = global_meta
          .transform_keys(&:to_sym)
          .except(:title, :author, :elements)
        
        custom_kwargs[:date] = parse_meta_time(global_meta) \
          if custom_kwargs[:date]

        @factory.story(
          title,
          author: author,
          elements: elements,
          **custom_kwargs
        )
      end
      
      private

      # Translates raw manifest properties hash into clean factory keywords.
      # @param properties [Hash{Symbol => String}] extracted raw properties
      # @return [Hash{Symbol => Object}] mapped keyword arguments
      def translate_metadata(properties) = raise(NotImplementedError)

      # hook for default media proprties
      # @return [Hash]
      def default_media_options = {}

      # Decomposed: Processes a single topic block using granular sub-methods
      def build_element(lines)
        cleaned_lines = lines.map(&:strip).reject(&:empty?)
        return nil if cleaned_lines.empty?

        return process_visual_pause \
          if Parser.visual_pause?(cleaned_lines.first)

        cleaned_lines.shift if cleaned_lines.first.start_with?(?#)
          
        properties, content_lines = Parser.properties(cleaned_lines)
        text, content_lines = Parser.text(content_lines)
        
        assets = parse_media_assets(content_lines)
        assemble_factory_models(text, assets, properties)
      end

      def process_visual_pause
        defined?(@factory.visual_pause) ? @factory.visual_pause : nil
      end
     
      # Parses lines within a media section, statefully aggregating metadata 
      # written beneath each markdown image tag.
      # @param lines [Array<String>] content lines of the section
      # @return [Array<Media>] collection of instantiated media objects
      def parse_media_assets(lines)
        assets_data = []
        current_asset = nil

        lines.each do |line|
          cleaned = line.strip
          next if cleaned.empty?
        
          if Parser.image?(cleaned)
            assets_data << current_asset if current_asset
            current_asset = Parser.image(cleaned)
          elsif current_asset && Parser.property?(cleaned)
            property = Parser.property(cleaned)
            current_asset[:properties].merge!(property)
          end
        end
        assets_data << current_asset if current_asset

        media_keywords = media_factory_keywords
        assets_data.map do |asset_hash|
          filtered_properties = asset_hash[:properties].select{ |key, _|
            media_keywords.include?(key) ||
            media_keywords.include?(:kwargs)
          }  
          final_options = filtered_properties.merge(default_media_options)
          @factory.media(asset_hash[:filepath], **final_options)
        end
      end

      # @return [Array<Symbol] of @factory#media
      def media_factory_keywords
        @media_factory_keywords ||= @factory.method(:media)
          .parameters.map { |_, name| name }
      end

      def parse_text_body_from(lines, assets)
        # Filter out lines that were processed as markdown images
        text_lines = lines.reject { |l| l.start_with?('![') && l.include?('](') }
        text_lines.join("\n").strip
      end

      # Routes atomic or composed models back to factory
      def assemble_factory_models(text_body, assets, properties)
        has_text  = !text_body.empty?
        has_media = !assets.empty?

        mapped_meta = translate_metadata(properties)

        if has_text && has_media
          web_text  = @factory.text(text_body, **mapped_meta.slice(:alignment, :width_category))
          web_media = @factory.media_assets(assets, **mapped_meta.slice(:columns, :aspect_mode))
          @factory.text_and_media(web_text, web_media, **mapped_meta.slice(:text_position, :flow))
        elsif has_text
          @factory.text(text_body, **mapped_meta.slice(:alignment, :width_category))
        elsif has_media
          @factory.media_assets(assets, **mapped_meta.slice(:columns, :aspect_mode))
        end
      end

      # Polyfill helper to extract configuration keys regardless of String or Symbol types
      def fetch_meta(meta, key, default = nil)
        meta[key] || meta[key.to_s] || default
      end

      def parse_meta_time(meta)
        raw_date = fetch_meta(meta, :date)
        return nil unless raw_date
        
        Time.parse(raw_date.to_s)
      rescue StandardError
        nil
      end
    end
  end
end
