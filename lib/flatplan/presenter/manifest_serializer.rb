# lib/flatplan/presenter/manifest_serializer.rb

require_relative "../../kairos"
require_relative "base"

module Flatplan
  module Presenter
    # Symmetrically serializes a domain SeriesPublication entity back into 
    # a clean, human-readable Flatplan Markdown publishing manifest file.
    class ManifestSerializer < Base
      # Formats a SeriesPublication object into a Markdown string template.
      #
      # @param publication [Model::SeriesPublication] the source domain entity
      # @return [String] formatted Markdown manifest ready to be saved to disk
      def call(publication)
        @publication = publication
        buffer = []

        # 1. Output Structured YAML Front Matter Metadata Block
        buffer << render_yaml_front_matter(publication)

        # 2. Process layout structures sequentially via polymorphic routing
        publication.sections.each do |section|
          buffer << render_section(section)
        end

        buffer.join("\n")
      end

      protected

      # Generates a unified YAML configuration block for the publication.
      #
      # @param pub [Model::SeriesPublication] target publication record
      # @return [String] compiled YAML front matter text block
      def render_yaml_front_matter(pub)
        yaml = []
        yaml << "---"
        yaml << "title: '#{pub.title}'"
        yaml << "author: #{pub.author}"
        yaml << "date: '#{pub.date}'"
        yaml << "location: '#{pub.location}'" if pub.location
        yaml << "keywords: #{pub.keywords.inspect}" if pub.keywords
        yaml << "description: '#{pub.description}'" if pub.description
        yaml << "---\n"
        yaml.join("\n")
      end

      # Dispatches rendering logic based on the precise section domain subclass.
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

      # Formats a standard flat TextAndMedia document layout block.
      def render_text_and_media(section)
        buf = []
        buf << "# Section Layout Block"
        buf << "text: #{section.text_alignment}"
        buf << "media: #{section.media_alignment}"
        buf << "spacing: #{section.spacing}" unless section.spacing == :medium
        buf << ""

        section.paragraphs.each { |p| buf << "#{p}\n" }
        buf << "" unless section.paragraphs.empty?

        section.media_assets.each { |asset| serialize_asset(buf, asset) }
        buf.join("\n")
      end

      # Formats a plain visual whitespace pause layout boundary block.
      def render_visual_pause(section)
        buf = []
        buf << "---"
        buf << "spacing: #{section.spacing}\n" unless section.spacing == :large
        buf.join("\n")
      end

      # Formats a full-bleed structural EditorialHero layout block.
      def render_editorial_hero(section)
        buf = []
        buf << "# Editorial Hero Block"
        buf << "layout: hero\n"
        section.media_assets.each { |asset| serialize_asset(buf, asset) }
        buf.join("\n")
      end

      # Encapsulates uniform serialization logic for an individual image asset.
      def serialize_asset(buffer, asset)
        buffer << serialize_image_tag(asset)
        buffer << "title: #{asset.title}" if asset.title && !asset.title.empty?
        buffer << "captured_at: #{asset.captured_at}" if asset.captured_at

        # Embed Kairos hints dynamically upon target criteria validation
        if asset.captured_at && (!asset.title || asset.title.empty?)
          Kairos
            .call(asset.captured_at, @publication.keywords)
            .map { |k, v| "kairos_#{k}_hint: #{v}" }
            .each { |hint| buffer << hint }
        end
        
        buffer << ""
      end

      # Compiles an isolated standard Markdown image link tag token string.
      # This serves as the primary granular override hook for downstream presenters.
      #
      # @param asset [Model::LayoutAsset] targeting media asset
      # @return [String] formatted standard image markdown token
      def serialize_image_tag(asset)
        "!\[#{asset.caption}\]\(#{asset.filename}\)"
      end
    end
  end
end
