require_relative 'base'

module Flatplan
  module Presenter

    # Renders a high-level visual flatplan diagram of a SeriesPublication
    # directly into the terminal console using clean ASCII indicators.
    class ConsoleFlatplan < Base

      # Compiles the publication model tree into a schematic console layout.
      #
      # @param publication [Model::SeriesPublication] the source domain model
      # @return [String] formatted ASCII schematic map
      def call(publication)
        buffer = []
        
        buffer << "=" * 60
        buffer << "  EDITORIAL FLATPLAN PREVIEW: #{publication.title.upcase}"
        buffer << "=" * 60 + "\n"

        publication.sections.each_with_index do |section, index|
          buffer << render_section_schema(section, index + 1)
          buffer << "· " * 30 + "\n"
        end

        buffer << "=" * 60
        buffer << "  METRICS: Total Spreads: #{publication.sections.size}"
        buffer << "=" * 60 + "\n"
        
        buffer.join("\n")
      end

      private

      # Dispatches schema rendering based on the polymorphic section type.
      def render_section_schema(section, number)
        case section
        when Model::TextAndMediaSection
          render_text_and_media(section, number)
        when Model::VisualPauseSection
          render_visual_pause(section, number)
        when Model::EditorialHeroSection
          render_editorial_hero(section, number)
        else
          " [?] Unknown layout section spread structure"
        end
      end

      def render_text_and_media(section, number)
        cameras = "📷 " * section.media_assets.size
        lines = []
        
        if section.text_alignment == :left
          lines << "Spread #{number}: [TEXT] ▓▓▓▓▓░░░░░░░░  |  [PHOTOS: #{section.media_assets.size}] #{cameras}"
          lines << "          [TEXT] ▓▓▓▓▓░░░░░░░░  |  (Layout: Text Left / Media Right)"
        else
          lines << "Spread #{number}: [PHOTOS: #{section.media_assets.size}] #{cameras}  |  [TEXT] ░░░░░░░░▓▓▓▓▓"
          lines << "          (Layout: Media Left / Text Right)  |  [TEXT] ░░░░░░░░▓▓▓▓▓"
        end
        lines.join("\n")
      end

      def render_visual_pause(section, number)
        cameras = "📷 " * section.media_assets.size
        lines = []
        lines << "Spread #{number}: " + " " * 12 + "【 VISUAL PAUSE: #{section.spacing.upcase} 】"
        lines << "          " + " " * 12 + " #{cameras.empty? ? '■ (Pure Silence)' : cameras}"
        lines.join("\n")
      end

      def render_editorial_hero(section, number)
        lines = []
        lines << "Spread #{number}: █" * 20 + " [EDITORIAL HERO]"
        lines << "          █" * 20 + " (Full Screen Accent Page)"
        lines.join("\n")
      end
    end
  end
end
