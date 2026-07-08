# lib/flatplan/presenter/pandoc_manifest_serializer.rb

require_relative "base"

module Flatplan
  module Presenter
    # Translates a domain SeriesPublication object into a highly structured,
    # semantic Pandoc Markdown layout document utilizing dynamic flatplan_ prefixes.
    class PandocManifestSerializer < Base
      # Serializes a SeriesPublication aggregate tree into a Pandoc document string.
      #
      # @param publication [Model::SeriesPublication] source domain aggregate
      # @return [String] Pandoc-compliant semantic Markdown string
      def call(publication)
        buffer = []

        # 1. Output Structured Pandoc YAML Front Matter Metadata Block
        buffer << "---"
        buffer << "title: '#{publication.title}'"
        buffer << "author: '#{publication.author || 'Unknown Author'}'"
        buffer << "date: '#{publication.date || Time.now.strftime("%Y-%m-%d")}'"
        buffer << "---"
        buffer << ""

        # 2. Process layout structures and compile semantic containers
        publication.sections.each do |section|
          buffer << render_section(section)
        end

        buffer.join("\n")
      end

      private

      # Determines rendering output based on the precise domain block subclass.
      def render_section(section)
        case section
        when Model::TextAndMediaSection
          render_text_and_media(section)
        when Model::VisualPauseSection
          render_visual_pause(section)
        when Model::EditorialHeroSection
          render_editorial_hero(section)
        else
          ""
        end
      end

      # Formats a TextAndMedia spread layout tracking block.
      def render_text_and_media(section)
        html = []
        html << "::: {.flatplan_section .flatplan_layout_#{section.text_alignment}_text}"
        html << ""
        html << "::: {.flatplan_story_text}"
        section.paragraphs.each { |p| html << "#{p}\n" }
        html << ":::"
        html << ""
        html << serialize_media_grid(section.media_assets)
        html << ":::\n"
        html.join("\n")
      end

      # Formats a whitespace VisualPause spread tracking block.
      def render_visual_pause(section)
        html = []
        html << "::: {.flatplan_visual_pause .flatplan_spacing_#{section.spacing}}"
        html << ""
        html << serialize_media_grid(section.media_assets)
        html << ":::\n"
        html.join("\n")
      end

      # Formats a full-scale EditorialHero showcase track.
      def render_editorial_hero(section)
        html = []
        html << "::: {.flatplan_editorial_hero}"
        html << ""
        html << serialize_media_grid(section.media_assets)
        html << ":::\n"
        html.join("\n")
      end

      # Encapsulates uniform serialization for the images array inside fenced_divs.
      def serialize_media_grid(assets)
        return "" if assets.nil? || assets.empty?

        html = []
        html << "::: {.flatplan_media_grid}"
        assets.each do |asset|
          html << "![#{asset.caption}](#{asset.filename})"
        end
        html << ":::"
        html.join("\n")
      end
    end
  end
end
