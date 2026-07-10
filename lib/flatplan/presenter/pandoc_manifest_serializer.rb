# lib/flatplan/presenter/pandoc_manifest_serializer.rb

require_relative "manifest_serializer"

module Flatplan
  module Presenter
    # Translates a domain SeriesPublication object into a highly structured,
    # semantic Pandoc Markdown layout document utilizing dynamic flatplan_ prefixes.
    class PandocManifestSerializer < ManifestSerializer
      protected

      # Formats an isolated, prefixed TextAndMedia semantic container block.
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

      # Formats an isolated, prefixed whitespace VisualPause layout boundary block.
      def render_visual_pause(section)
        html = []
        html << "::: {.flatplan_visual_pause .flatplan_spacing_#{section.spacing}}"
        html << ""
        html << serialize_media_grid(section.media_assets)
        html << ":::\n"
        html.join("\n")
      end

      # Formats an isolated, prefixed full-scale EditorialHero showcase track.
      def render_editorial_hero(section)
        html = []
        html << "::: {.flatplan_editorial_hero}"
        html << ""
        html << serialize_media_grid(section.media_assets)
        html << ":::\n"
        html.join("\n")
      end

      private

      # Encapsulates uniform serialization for the images array inside fenced_divs.
      def serialize_media_grid(assets)
        return "" if assets.nil? || assets.empty?

        html = []
        html << "::: {.flatplan_media_grid}"
        assets.each do |asset|
          # Reuses the parent atomical token compilation helper dynamically
          html << serialize_image_tag(asset)
        end
        html << ":::"
        html.join("\n")
      end
    end
  end
end
