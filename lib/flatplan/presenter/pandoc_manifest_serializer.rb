require_relative 'base'

module Flatplan
  module Presenter
    
    # Translates a domain SeriesPublication object into a highly structured,
    # semantic Pandoc Markdown layout document utilizing native fenced_divs.
    class PandocManifestSerializer < Base

      # Serializes a SeriesPublication aggregate tree into a Pandoc document string.
      #
      # @param publication [Model::SeriesPublication] source domain aggregate
      # @return [String] Pandoc-compliant semantic Markdown string
      def call(publication)
        buffer = []

        # 1. Output Pandoc YAML Front Matter Metadata Block
        buffer << "---"
        buffer << "title: '#{publication.title}'"
        buffer << "author: '#{publication.author || 'Unknown'}'"
        buffer << "date: '#{publication.date || Time.now.strftime('%Y-%m-%d')}'"
        buffer << "---"
        buffer << ""

        # 2. Append the standalone primary heading landmark
        buffer << "# #{publication.title}\n"

        # 3. Process layout structures and compile semantic containers
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
        html << "::: {.section-text-media .layout-#{section.text_alignment}-text}"
        html << ""
        html << "::: {.story-text}"
        section.paragraphs.each { |p| html << "#{p}\n" }
        html << ":::"
        html << ""
        html << "::: {.media-grid}"
        section.media_assets.each do |asset|
          html << "![#{asset.caption}](#{asset.filename})"
        end
        html << ":::"
        html << ""
        html << ":::\n"
        html.join("\n")
      end

      # Formats a whitespace VisualPause spread tracking block.
      def render_visual_pause(section)
        html = []
        html << "::: {.visual-pause .spacing-#{section.spacing}}"
        section.media_assets.each do |asset|
          html << "![#{asset.caption}](#{asset.filename})"
        end
        html << ":::\n"
        html.join("\n")
      end

      # Formats a full-scale EditorialHero showcase track.
      def render_editorial_hero(section)
        html = []
        html << "::: {.editorial-hero}"
        section.media_assets.each do |asset|
          html << "![#{asset.caption}](#{asset.filename})"
        end
        html << ":::\n"
        html.join("\n")
      end
    end
  end
end
