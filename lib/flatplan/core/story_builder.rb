# frozen_string_literal: true

require 'yaml'

module Flatplan
  module Core
    # A medium-agnostic base builder that orchestrates parsing of plain manifests.
    # It decomposes text into structured steps, isolates properties, processes images,
    # and delegates final instantiations to the specific target factory.
    class StoryBuilder
      # @param factory [Object] a concrete medium factory
      def initialize(factory)
        @factory = factory
      end

      # Compiles a raw manifest string into a medium-specific Story object.
      # @param manifest_content [String] raw manifest file text
      # @return [Object] structured story root container
      def build(manifest_content)
        lines = manifest_content.lines.map(&:chomp)

        global_meta, remaining_lines = extract_frontmatter(lines)
        raw_topics = slice_into_topics(remaining_lines)

        elements = raw_topics.map { |topic_lines| build_element(topic_lines) }.compact

        title  = fetch_meta(global_meta, :title, 'Untitled Story')
        author = fetch_meta(global_meta, :author, 'Unknown Author')

        # Удаляем из хэша базовые инварианты, чтобы не дублировать их в kwargs
        # Превращаем все ключи в символы для рантайм-безопасности
        custom_kwargs = global_meta.transform_keys(&:to_sym).except(:title, :author, :elements)
        
        # Корректируем дату, если она есть
        custom_kwargs[:date] = parse_meta_time(global_meta) if custom_kwargs[:date]

        # ИСПРАВЛЕНО: Никакого слова :slug в ядре. Отдаем только базу + мешок custom_kwargs
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

      # Slices plain lines array into blocks bounded by headers or standalone pauses.
      def slice_into_topics(lines)
        topics = []
        current_topic = []

        lines.each do |line|
          cleaned_line = line.strip
          
          if cleaned_line == '---' || cleaned_line == '<!-- visual_pause -->'
            topics << current_topic unless current_topic.empty?
            current_topic = []
            topics << [line]
          elsif cleaned_line.start_with?('#')
            topics << current_topic unless current_topic.empty?
            current_topic = [line]
          else
            current_topic << line
          end
        end
        topics << current_topic unless current_topic.empty?
        topics
      end

      # Decomposed: Processes a single topic block using granular sub-methods
      def build_element(lines)
        cleaned_lines = lines.map(&:strip).reject(&:empty?)
        return nil if cleaned_lines.empty?

        return process_visual_pause if visual_pause?(cleaned_lines.first)

        properties, content_lines = extract_section_properties(cleaned_lines)
        assets = parse_media_assets_from(content_lines)
        text_body = parse_text_body_from(content_lines, assets)

        assemble_factory_models(text_body, assets, properties)
      end

      def visual_pause?(line)
        line == '---' || line == '<!-- visual_pause -->'
      end

      def process_visual_pause
        defined?(@factory.visual_pause) ? @factory.visual_pause : nil
      end

      # Isolates header and key-value properties from pure content lines
      def extract_section_properties(lines)
        properties = {}
        content_lines = []

        lines.each do |line|
          next if line.start_with?('#') # Ignore comments or titles

          if line.match(/^([a-z_]+)\s*:\s*(.+)$/)
            properties[$1.to_sym] = $2.strip
          else
            content_lines << line
          end
        end

        [properties, content_lines]
      end

      # Uses your verified native regex to extract paths and captions
      def parse_media_assets_from(lines)
        assets = []
        lines.each do |line|
          if line.start_with?('![') && line.include?('](')
            match = line.match(/!\[(.*?)\]\((.*?)\)/)
            if match
              # Собираем только то, что гарантированно дает маркдаун-строка
              core_options = {
                caption: match[1].to_s,
                alt:     match[1].to_s
              }

              # Склеиваем с опциями конкретного медиа-носителя (Web, Book)
              final_options = core_options.merge(default_media_options)

              assets << @factory.media(match[2].to_s, **final_options)
            end
          end
        end
        assets
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

      # Robust frontmatter extractor clearing empty spacing
      def extract_frontmatter(lines)
        cleaned_lines = lines.drop_while { |l| l.strip.empty? }
        return [{}, lines] unless cleaned_lines.first&.strip == '---'

        frontmatter_lines = []
        content_lines = []
        in_frontmatter = true

        cleaned_lines.drop(1).each do |line|
          if in_frontmatter && line.strip == '---'
            in_frontmatter = false
            next
          end
          in_frontmatter ? frontmatter_lines << line : content_lines << line
        end

        begin
          meta = YAML.load(frontmatter_lines.join("\n")) || {}
          [meta, content_lines]
        rescue StandardError
          [{}, lines]
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
