require_relative 'base'

module Flatplan
  module Presenter
    
    # Serializes a domain SeriesPublication entity back into a clean, human-readable
    # Flatplan Markdown publishing manifest file symmetrically.
    class ManifestSerializer < Base

      # Formats a SeriesPublication object into a Markdown string template.
      #
      # @param publication [Model::SeriesPublication] the source domain entity
      # @return [String] formatted Markdown manifest ready to be saved to disk
      def call(publication)
        buffer = []
        
        # 1. Generate Metadata Headers
        buffer << "% #{publication.title}"
        buffer << "% #{publication.author || 'Unknown Author'}"
        buffer << "% #{publication.date || Time.now.strftime('%Y-%m-%d')}\n"
        
        buffer << "#{publication.description}\n" if publication.description

        # 2. Process Sections in sequential order based on explicit domain types
        publication.sections.each do |section|
          if section.is_a?(Model::TextAndMediaSection)
            buffer << "# Section Layout Block"
            buffer << "text: #{section.text_alignment}"
            buffer << "media: #{section.media_alignment}\n"
            
            section.paragraphs.each { |p| buffer << "#{p}\n" }
            buffer << "" unless section.paragraphs.empty?
            
            section.media_assets.each do |asset|
              buffer << "![#{asset.caption}](#{asset.filename})"
            end
            buffer << ""
          elsif section.is_a?(Model::VisualPauseSection)
            # Symmetrically serialize the domain pause as a native markdown layout boundary
            buffer << "---"
            buffer << "spacing: #{section.spacing}\n" unless section.spacing == :large
          elsif section.is_a?(Model::EditorialHeroSection)
            buffer << "# Editorial Hero Block"
            buffer << "layout: hero\n"
            section.media_assets.each do |asset|
              buffer << "![#{asset.caption}](#{asset.filename})"
            end
            buffer << ""
          end
        end

        buffer.join("\n")
      end
    end
  end
end
