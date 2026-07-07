# lib/flatplan/presenter/manifest_serializer.rb

require_relative "base"

# lib/flatplan/presenter/manifest_serializer.rb

require_relative "base"

module Flatplan
  module Presenter
    # Serializes a domain SeriesPublication entity back into a clean,
    # human-readable Flatplan Markdown publishing manifest file symmetrically.
    class ManifestSerializer < Base
      # Formats a SeriesPublication object into a Markdown string template.
      #
      # @param publication [Model::SeriesPublication] the source domain entity
      # @return [String] formatted Markdown manifest ready to be saved to disk
      def call(publication)
        buffer = []

        # 1. Generate Structured YAML Front Matter Block
        buffer << "---"
        buffer << "title: '#{publication.title}'"
        buffer << "author: '#{publication.author || 'Unknown Author'}'"
        buffer << "date: '#{publication.date || Time.now.strftime("%Y-%m-%d")}'"
        buffer << "location: '#{publication.location}'" if publication.location
        if publication.keywords && !publication.keywords.empty?
          buffer << "keywords: #{publication.keywords.inspect}"
        end
        buffer << "description: '#{publication.description}'" if publication.description
        buffer << "---\n"

        # 2. Process Sections in sequential order based on explicit domain types
        publication.sections.each do |section|
          if section.is_a?(Model::TextAndMediaSection)
            buffer << "# Section Layout Block"
            buffer << "text: #{section.text_alignment}"
            buffer << "media: #{section.media_alignment}"
            buffer << "spacing: #{section.spacing}" unless section.spacing == :medium
            buffer << ""

            section.paragraphs.each { |p| buffer << "#{p}\n" }
            buffer << "" unless section.paragraphs.empty?

            section.media_assets.each { |asset| serialize_asset(buffer, asset) }
          elsif section.is_a?(Model::VisualPauseSection)
            buffer << "---"
            buffer << "spacing: #{section.spacing}\n" unless section.spacing == :large
          elsif section.is_a?(Model::EditorialHeroSection)
            buffer << "# Editorial Hero Block"
            buffer << "layout: hero\n"
            
            section.media_assets.each { |asset| serialize_asset(buffer, asset) }
          end
        end

        buffer.join("\n")
      end

      private

      # Encapsulates uniform serialization logic for an individual photographic asset card.
      # Assures strict boundary separation with clear blank lines underneath.
      def serialize_asset(buffer, asset)
        buffer << "![#{asset.caption}](#{asset.filename})"
        buffer << "title: #{asset.title}" if asset.title
        buffer << "captured_at: #{asset.captured_at}" if asset.captured_at
        buffer << "" # Universally guarantees an elegant whitespace break under every card
      end
    end
  end
end
